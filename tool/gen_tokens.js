#!/usr/bin/env node
/* Albatross DS: tokens.css -> lib/src/tokens.g.dart
   Usage: node tool/gen_tokens.js [path-or-url-to-tokens.css]
   Default source: https://stat.chara.id/swing/ds/tokens.css
   Every :root custom property is read, var() chains are resolved, and each token family
   becomes one Dart class. The naming rule is the same one the DS site uses for its Flutter
   chips (nav.js adsDartName): --purple-500 -> AdsColors.purple500, --space-16 -> AdsSpace.s16,
   --radius-8 -> AdsRadius.r8, --type-b1s -> AdsType.b1s, --opacity-40 -> AdsOpacity.o40. */
'use strict';
const fs = require('fs');
const path = require('path');
const https = require('https');

const SRC = process.argv[2] || 'https://stat.chara.id/swing/ds/tokens.css';
const OUT = path.join(__dirname, '..', 'lib', 'src', 'tokens.g.dart');

function load(src) {
  if (!/^https?:/.test(src)) return Promise.resolve(fs.readFileSync(src, 'utf8'));
  return new Promise((ok, no) => https.get(src, r => {
    if (r.statusCode !== 200) return no(new Error('HTTP ' + r.statusCode + ' for ' + src));
    let b = ''; r.setEncoding('utf8'); r.on('data', c => (b += c)); r.on('end', () => ok(b));
  }).on('error', no));
}

/* ---------- parse ---------- */
function readVars(css) {
  css = css.replace(/\/\*[\s\S]*?\*\//g, '');
  const vars = {};
  const re = /:root\s*\{([\s\S]*?)\n\}/g;
  let m;
  while ((m = re.exec(css))) {
    const body = m[1];
    const d = /(--[a-z0-9-]+)\s*:\s*([^;]+);/g;
    let x;
    while ((x = d.exec(body))) vars[x[1]] = x[2].trim().replace(/\s+/g, ' ');
  }
  return vars;
}
function resolve(vars, v, depth = 0) {
  if (depth > 20) throw new Error('var() loop at ' + v);
  return v.replace(/var\((--[a-z0-9-]+)(?:,\s*([^()]+))?\)/g, (m, n, fb) => {
    if (vars[n] != null) return resolve(vars, vars[n], depth + 1);
    if (fb != null) return fb.trim();
    throw new Error('unknown token ' + n);
  });
}

/* ---------- values ---------- */
function hex2(n) { return Math.round(n).toString(16).padStart(2, '0').toUpperCase(); }
function parseColor(s) {
  s = s.trim();
  let m;
  if ((m = s.match(/^#([0-9a-f]{6})$/i))) return { r: parseInt(m[1].slice(0, 2), 16), g: parseInt(m[1].slice(2, 4), 16), b: parseInt(m[1].slice(4, 6), 16), a: 1 };
  if ((m = s.match(/^#([0-9a-f]{3})$/i))) return parseColor('#' + m[1].split('').map(c => c + c).join(''));
  if ((m = s.match(/^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+)\s*)?\)$/))) return { r: +m[1], g: +m[2], b: +m[3], a: m[4] == null ? 1 : +m[4] };
  if (s === 'transparent') return { r: 0, g: 0, b: 0, a: 0 };
  if ((m = s.match(/^color-mix\(in srgb,\s*(.+?)\s+([\d.]+)%\s*,\s*(.+)\)$/))) {
    const a = parseColor(m[1]), p = +m[2] / 100;
    if (m[3].trim() === 'transparent') return { r: a.r, g: a.g, b: a.b, a: a.a * p };
    const b = parseColor(m[3]);
    return { r: a.r * p + b.r * (1 - p), g: a.g * p + b.g * (1 - p), b: a.b * p + b.b * (1 - p), a: a.a * p + b.a * (1 - p) };
  }
  return null;
}
function dartColor(c) { return 'Color(0x' + hex2(c.a * 255) + hex2(c.r) + hex2(c.g) + hex2(c.b) + ')'; }
function px(s) { const m = String(s).trim().match(/^(-?[\d.]+)(px)?$/); return m ? +m[1] : null; }
function num(n) { const s = String(Math.round(n * 10000) / 10000); return s.includes('.') ? s : s + '.0'; }

function splitTop(s, sep = ',') {
  const out = []; let d = 0, cur = '';
  for (const ch of s) {
    if (ch === '(') d++; else if (ch === ')') d--;
    if (ch === sep && d === 0) { out.push(cur.trim()); cur = ''; } else cur += ch;
  }
  if (cur.trim()) out.push(cur.trim());
  return out;
}
function shadows(s) {
  if (s === 'none') return 'const <BoxShadow>[]';
  const parts = splitTop(s).map(p => {
    const inset = /\binset\b/.test(p);
    const colM = p.match(/(rgba?\([^)]*\)|#[0-9a-f]{3,6}|color-mix\(.*\))/i);
    const col = colM ? parseColor(colM[1]) : { r: 0, g: 0, b: 0, a: 1 };
    const lens = p.replace(colM ? colM[1] : '', '').replace('inset', '').trim().split(/\s+/).map(px).filter(x => x != null);
    const [x = 0, y = 0, blur = 0, spread = 0] = lens;
    if (inset) return null;   // Flutter has no inset shadow; the DS only uses inset for rings
    return 'BoxShadow(color: ' + dartColor(col) + ', offset: Offset(' + num(x) + ', ' + num(y) + '), blurRadius: ' + num(blur) + (spread ? ', spreadRadius: ' + num(spread) : '') + ')';
  }).filter(Boolean);
  return 'const <BoxShadow>[' + parts.join(', ') + ']';
}
function cssAngleAlign(deg) {
  // CSS: 0deg points up, 90deg right. Flutter Alignment: x right, y down.
  const r = deg * Math.PI / 180, x = Math.sin(r), y = -Math.cos(r);
  const k = Math.max(Math.abs(x), Math.abs(y)) || 1;
  return { begin: 'Alignment(' + num(-x / k) + ', ' + num(-y / k) + ')', end: 'Alignment(' + num(x / k) + ', ' + num(y / k) + ')' };
}
function linearGradient(s) {
  const m = s.match(/^linear-gradient\((.*)\)$/); if (!m) return null;
  const parts = splitTop(m[1]);
  let deg = 180;
  if (/deg$/.test(parts[0])) deg = parseFloat(parts.shift());
  else if (/^to /.test(parts[0])) { const t = parts.shift(); deg = { 'to top': 0, 'to right': 90, 'to bottom': 180, 'to left': 270 }[t] ?? 180; }
  const cols = [], stops = [];
  parts.forEach((p, i) => {
    const pm = p.match(/^(.*?)\s+(-?[\d.]+)%$/);
    const c = parseColor(pm ? pm[1] : p);
    if (!c) throw new Error('gradient colour ' + p);
    cols.push(dartColor(c));
    stops.push(pm ? +pm[2] / 100 : (parts.length === 1 ? 0 : i / (parts.length - 1)));
  });
  const a = cssAngleAlign(deg);
  return 'LinearGradient(begin: ' + a.begin + ', end: ' + a.end + ', colors: <Color>[' + cols.join(', ') + '], stops: <double>[' + stops.map(num).join(', ') + '])';
}
const WEIGHT = { 400: 'FontWeight.w400', 500: 'FontWeight.w500', 600: 'FontWeight.w600', 700: 'FontWeight.w700', 800: 'FontWeight.w800' };
function textStyle(font, trackEm, upper) {
  const m = font.match(/^(\d{3})\s+([\d.]+)px\s*\/\s*([\d.]+)px/);
  if (!m) throw new Error('font shorthand ' + font);
  const w = +m[1], size = +m[2], lh = +m[3];
  const track = trackEm == null ? 0 : (String(trackEm).trim() === '0' ? 0 : parseFloat(trackEm) * size);
  return 'TextStyle(fontFamily: _family, package: _package, fontWeight: ' + WEIGHT[w] +
    ', fontVariations: <FontVariation>[FontVariation(\'wght\', ' + num(w) + ')], fontSize: ' + num(size) +
    ', height: ' + num(lh / size) + ', letterSpacing: ' + num(track) + ', leadingDistribution: TextLeadingDistribution.even)' +
    (upper ? ' /* label: show the text in uppercase */' : '');
}

/* ---------- names (keep in sync with adsDartName in the DS site nav.js) ---------- */
function camel(s) { return s.replace(/-([a-z0-9])/g, (m, c) => c.toUpperCase()); }

async function main() {
  const css = await load(SRC);
  const vars = readVars(css);
  const R = n => resolve(vars, vars[n]);
  const names = Object.keys(vars);
  const out = { colors: [], gradients: [], space: [], radius: [], opacity: [], type: [], typeDesktop: [], para: [], paraDesktop: [], elevation: [], skipped: [] };
  const RAMPS = /^--(dark|light|purple|teal|blue|pink|green|orange|red)-(\d+|press)$/;

  for (const n of names) {
    const v = R(n);
    let m;
    if (RAMPS.test(n)) { out.colors.push([camel(n.slice(2)), dartColor(parseColor(v)), n]); continue; }
    if ((m = n.match(/^--color-(.+)$/))) { out.colors.push([camel(m[1]), dartColor(parseColor(v)), n]); continue; }
    if (/^--(scrim|scrim-media|scrim-media-soft|glass-line)$/.test(n)) { out.colors.push([camel(n.slice(2)), dartColor(parseColor(v)), n]); continue; }
    if ((m = n.match(/^--gradient-(.+)$/)) || /^--(glass-fill|deal-scrim)$/.test(n)) {
      const g = linearGradient(v);
      if (g) out.gradients.push([camel(m ? m[1] : n.slice(2)), g, n]); else out.skipped.push([n, 'not a single linear-gradient: build it by hand (see AdsGradients note)']);
      continue;
    }
    if ((m = n.match(/^--space-(\d+)$/))) { out.space.push(['s' + m[1], num(px(v)), n]); continue; }
    if (/^--(gap-[a-z]+|page-x|page-top|page-bottom|inset-card|inset-row-y|inset-row-x|inset-chip-y|inset-chip-x|header-h|tap-min)$/.test(n)) { out.space.push([camel(n.slice(2)), num(px(v)), n]); continue; }
    if ((m = n.match(/^--radius-(\d+|full)$/))) { out.radius.push([m[1] === 'full' ? 'full' : 'r' + m[1], num(px(v)), n]); continue; }
    if ((m = n.match(/^--ads-radius-(\d+)$/))) { out.radius.push(['ads' + m[1], num(px(v)), n]); continue; }
    if ((m = n.match(/^--opacity-(\d+)$/))) { out.opacity.push(['o' + m[1], num(parseFloat(v)), n]); continue; }
    if ((m = n.match(/^--type-desktop-([a-z0-9-]+)-para$/))) { out.paraDesktop.push([camel(m[1]), num(px(v)), n]); continue; }
    if ((m = n.match(/^--type-([a-z0-9-]+)-para$/))) { out.para.push([camel(m[1]), num(px(v)), n]); continue; }
    if (/-track$/.test(n)) continue;
    if ((m = n.match(/^--type-desktop-([a-z0-9-]+)$/))) { out.typeDesktop.push([camel(m[1]), textStyle(v, vars[n + '-track'] ? R(n + '-track') : 0, false), n]); continue; }
    if ((m = n.match(/^--type-([a-z0-9-]+)$/))) { out.type.push([camel(m[1]), textStyle(v, vars[n + '-track'] ? R(n + '-track') : 0, /^lbl/.test(m[1])), n]); continue; }
    if ((m = n.match(/^--elevation-(.+)$/))) { out.elevation.push([/^\d$/.test(m[1]) ? 'e' + m[1] : camel(m[1]), shadows(v), n]); continue; }
    out.skipped.push([n, 'no Flutter equivalent (CSS-only: z-index, shorthand padding, ring, font stack)']);
  }

  const cls = (name, doc, type, rows, isConst = true) =>
    '/// ' + doc + '\nabstract final class ' + name + ' {\n' +
    rows.map(r => '  /// `' + r[2] + '`\n  static ' + (isConst ? 'const ' : 'final ') + type + ' ' + r[0] + ' = ' + r[1] + ';').join('\n') + '\n}\n';

  const dart =
`// GENERATED by tool/gen_tokens.js from ${/^https?:/.test(SRC) ? SRC : path.basename(SRC)}. Do not edit by hand.
// Re-run: node tool/gen_tokens.js
// ignore_for_file: constant_identifier_names, lines_longer_than_80_chars

import 'dart:ui' show FontVariation, TextLeadingDistribution;

import 'package:flutter/painting.dart';

const String _family = 'Manrope';
const String _package = 'albatross_ds';

${cls('AdsColors', 'Colour ramps (Dark = text, Light = backgrounds) and the colour roles.', 'Color', out.colors)}
${cls('AdsGradients', 'Linear gradients from tokens.css. The Swing Pass mesh is radial: see AdsSwingPassBackground.', 'LinearGradient', out.gradients)}
${cls('AdsSpace', '4px grid. sN = N logical pixels; gap and padding roles keep their CSS names.', 'double', out.space)}
${cls('AdsRadius', 'Only 8, 12 and 16 are rounding steps. full is for circles.', 'double', out.radius)}
${cls('AdsOpacity', 'Opacity steps (Figma shows these as %).', 'double', out.opacity)}
${cls('AdsType', 'Mobile text styles. Labels (lblL, lblS) are always uppercase: call .toUpperCase() on the text.', 'TextStyle', out.type)}
${cls('AdsTypeDesktop', 'Desktop text styles (screens 1024 and up).', 'TextStyle', out.typeDesktop)}
${cls('AdsParagraph', 'Space between two paragraphs of one text block, per text style (mobile).', 'double', out.para)}
${cls('AdsParagraphDesktop', 'Paragraph spacing for the desktop text styles.', 'double', out.paraDesktop)}
${cls('AdsElevation', 'Shadows. Inset rings are drawn as borders in the widgets.', 'List<BoxShadow>', out.elevation.map(r => [r[0], r[1].replace(/^const /, ''), r[2]]))}`;

  fs.mkdirSync(path.dirname(OUT), { recursive: true });
  fs.writeFileSync(OUT, dart);
  const count = k => out[k].length;
  console.log('wrote ' + path.relative(process.cwd(), OUT));
  console.log(['colors', 'gradients', 'space', 'radius', 'opacity', 'type', 'typeDesktop', 'para', 'paraDesktop', 'elevation'].map(k => k + ' ' + count(k)).join(' · '));
  console.log('not generated: ' + out.skipped.length + (out.skipped.length ? ' (' + out.skipped.map(s => s[0]).join(' ') + ')' : ''));
}
main().catch(e => { console.error(e.message); process.exit(1); });
