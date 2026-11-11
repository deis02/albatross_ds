import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'icon.dart';
import 'interaction.dart';
import 'tokens.g.dart';

/// Primary (purple, default), neutral (dark) or danger (red).
enum AdsButtonTone { primary, neutral, danger }

/// Solid is the strongest, soft the middle, ghost the lightest.
enum AdsButtonAppearance { solid, soft, ghost }

/// xl 56 · l 48 (default) · m 40 · s 32 · xs 24.
enum AdsButtonSize { xl, l, m, s, xs }

enum _Glow { white, purple }

class _Palette {
  const _Palette(this.bg, this.bgPress, this.fg, this.ring);
  final Color bg;
  final Color bgPress;
  final Color fg;
  final Color? ring;
}

class _Metrics {
  const _Metrics(this.height, this.padX, this.gap, this.icon, this.type);
  final double height;
  final double padX;
  final double gap;
  final double icon;
  final TextStyle type;
}

const Color _clear = Color(0x00000000);

/// Albatross Button (components.css `.btn`).
///
/// One primary per screen. Combine [tone], [appearance] and [size]; set
/// [loading] while the action runs (keeps tone, width and label, cannot be
/// tapped again). [onPressed] null = disabled.
///
/// ```dart
/// AdsButton(label: 'Pay for me', onPressed: pay)
/// AdsButton(label: 'Add a player', appearance: AdsButtonAppearance.soft, size: AdsButtonSize.m, onPressed: add)
/// AdsButton.glow(label: 'Get Swing Pass', onPressed: open)
/// ```
class AdsButton extends StatelessWidget {
  const AdsButton({
    super.key,
    required String this.label,
    this.onPressed,
    this.tone = AdsButtonTone.primary,
    this.appearance = AdsButtonAppearance.solid,
    this.size = AdsButtonSize.l,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.block = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : _glow = null;

  /// The glow button (`.btn--glow`, Figma Button size=glow): glass fill, a light
  /// running round the 1.5px outline. Padding 12/16, height hugs to 44, radius 12,
  /// CTA M. White on purple, dark or photo backgrounds; [purple] on light ones.
  const AdsButton.glow({
    super.key,
    required String this.label,
    this.onPressed,
    bool purple = false,
    this.icon,
    this.loading = false,
    this.block = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  })  : _glow = purple ? _Glow.purple : _Glow.white,
        tone = AdsButtonTone.primary,
        appearance = AdsButtonAppearance.solid,
        size = AdsButtonSize.l,
        trailingIcon = null;

  const AdsButton._iconOnly({
    super.key,
    required Widget this.icon,
    required String this.semanticLabel,
    this.onPressed,
    this.tone = AdsButtonTone.primary,
    this.appearance = AdsButtonAppearance.solid,
    this.size = AdsButtonSize.l,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
  })  : label = null,
        trailingIcon = null,
        block = false,
        _glow = null;

  final String? label;
  final VoidCallback? onPressed;
  final AdsButtonTone tone;
  final AdsButtonAppearance appearance;
  final AdsButtonSize size;

  /// Icon before the label. Any widget; sized and tinted through [IconTheme].
  final Widget? icon;

  /// Icon after the label.
  final Widget? trailingIcon;
  final bool loading;

  /// Full width.
  final bool block;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;
  final _Glow? _glow;

  bool get _iconOnlyButton => label == null;

  _Palette _palette(bool enabled) {
    if (_glow != null) {
      if (!enabled) return const _Palette(AdsColors.light300, AdsColors.light300, AdsColors.dark200, null);
      return _glow == _Glow.white
          ? const _Palette(_clear, _clear, AdsColors.light100, AdsColors.glassLine)
          : const _Palette(_clear, _clear, AdsColors.dark500, null);
    }
    if (!enabled) {
      final Color bg = appearance == AdsButtonAppearance.ghost ? _clear : AdsColors.light300;
      return _Palette(bg, bg, AdsColors.dark200, null);
    }
    // solid bg, solid press, solid fg, soft bg, soft press, soft ring, soft fg, ghost fg, ghost press
    final List<Color> t = switch (tone) {
      AdsButtonTone.primary => const <Color>[
          AdsColors.purple500, AdsColors.purple600, AdsColors.light100,
          AdsColors.purple50, AdsColors.purple100, AdsColors.purple100, AdsColors.purple600,
          AdsColors.purple600, AdsColors.purple50,
        ],
      AdsButtonTone.neutral => const <Color>[
          AdsColors.dark500, AdsColors.dark400, AdsColors.light100,
          AdsColors.light300, AdsColors.light500, AdsColors.light500, AdsColors.dark500,
          AdsColors.dark500, AdsColors.light300,
        ],
      AdsButtonTone.danger => const <Color>[
          AdsColors.red700, AdsColors.redPress, AdsColors.light100,
          AdsColors.red50, AdsColors.red100, AdsColors.red100, AdsColors.red700,
          AdsColors.red700, AdsColors.red50,
        ],
    };
    return switch (appearance) {
      AdsButtonAppearance.solid => _Palette(t[0], t[1], t[2], null),
      AdsButtonAppearance.soft => _Palette(t[3], t[4], t[6], t[5]),
      AdsButtonAppearance.ghost => _Palette(_clear, t[8], t[7], null),
    };
  }

  _Metrics _metrics() {
    if (_glow != null) return _Metrics(44, AdsSpace.s16, AdsSpace.s8, 16, AdsType.ctaM);
    final bool ghost = appearance == AdsButtonAppearance.ghost;
    return switch (size) {
      AdsButtonSize.xl => _Metrics(56, ghost ? AdsSpace.s16 : AdsSpace.s32, AdsSpace.gapRelated, 24, AdsType.ctaL),
      AdsButtonSize.l => _Metrics(48, ghost ? AdsSpace.s12 : AdsSpace.s24, AdsSpace.gapRelated, 20, AdsType.ctaL),
      AdsButtonSize.m => _Metrics(40, ghost ? AdsSpace.s8 : AdsSpace.s16, AdsSpace.gapRelated, 20, AdsType.ctaL),
      AdsButtonSize.s => _Metrics(32, ghost ? AdsSpace.s8 : AdsSpace.s12, AdsSpace.gapTight, 16, AdsType.ctaS),
      AdsButtonSize.xs => _Metrics(24, AdsSpace.s8, AdsSpace.gapTight, 16, AdsType.ctaS),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final double radius = _glow != null ? AdsRadius.r12 : AdsRadius.r8;
    final _Palette p = _palette(enabled);
    final _Metrics m = _metrics();

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      excludeSemantics: _iconOnlyButton,
      child: AdsTappable(
        enabled: enabled,
        onTap: loading ? null : onPressed,
        focusNode: focusNode,
        autofocus: autofocus,
        cursor: loading ? SystemMouseCursors.progress : null,
        builder: (BuildContext context, AdsStates st) {
          final Color bg = (st.pressed || st.hovered) ? p.bgPress : p.bg;
          final List<Widget> parts = <Widget>[];
          final double loaderSize = (size == AdsButtonSize.s || size == AdsButtonSize.xs || _glow != null) ? 16 : 24;
          if (loading) {
            parts.add(AdsBusy(size: loaderSize, color: p.fg));
          } else if (icon != null) {
            parts.add(adsIconSlot(icon!, size: m.icon, color: p.fg));
          }
          if (label != null) {
            parts.add(Text(label!, maxLines: 1, softWrap: false, style: m.type.copyWith(color: p.fg)));
          }
          if (trailingIcon != null && !loading) {
            parts.add(adsIconSlot(trailingIcon!, size: m.icon, color: p.fg));
          }
          final List<Widget> row = <Widget>[];
          for (int i = 0; i < parts.length; i++) {
            if (i > 0) row.add(SizedBox(width: m.gap));
            row.add(parts[i]);
          }

          final EdgeInsets pad = _glow != null
              ? const EdgeInsets.symmetric(vertical: AdsSpace.s12, horizontal: AdsSpace.s16)
              : EdgeInsets.symmetric(horizontal: _iconOnlyButton ? 0 : m.padX);

          Widget box = AnimatedContainer(
            duration: adsMotion(context, 120),
            height: _glow != null ? null : m.height,
            width: _iconOnlyButton ? m.height : (block ? double.infinity : null),
            constraints: BoxConstraints(minWidth: m.height),
            padding: pad,
            decoration: BoxDecoration(
              color: _glow != null && enabled ? null : bg,
              gradient: _glow != null && enabled ? AdsGradients.glassFill : null,
              borderRadius: BorderRadius.circular(radius),
            ),
            foregroundDecoration: adsRing(p.ring, radius),
            child: Row(
              mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: row,
            ),
          );
          if (_glow != null && enabled) {
            box = _GlowRing(purple: _glow == _Glow.purple, radius: radius, child: box);
          }
          return AdsFocusRing(visible: st.focused, radius: radius, child: box);
        },
      ),
    );
  }
}

/// Icon-only button (`.btn--icon`): square, needs a [semanticLabel].
///
/// ```dart
/// AdsIconButton(icon: const AdsIcon('share'), semanticLabel: 'Share',
///     appearance: AdsButtonAppearance.soft, onPressed: share)
/// ```
class AdsIconButton extends StatelessWidget {
  const AdsIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.tone = AdsButtonTone.primary,
    this.appearance = AdsButtonAppearance.solid,
    this.size = AdsButtonSize.l,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final AdsButtonTone tone;
  final AdsButtonAppearance appearance;
  final AdsButtonSize size;
  final bool loading;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AdsButton._iconOnly(
      icon: icon,
      semanticLabel: semanticLabel,
      onPressed: onPressed,
      tone: tone,
      appearance: appearance,
      size: size,
      loading: loading,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}

/// Two buttons side by side, equal width: the safe one on the left, the action
/// on the right (`.btn-pair`).
class AdsButtonPair extends StatelessWidget {
  const AdsButtonPair({super.key, required this.secondary, required this.primary});

  final Widget secondary;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: secondary),
        const SizedBox(width: AdsSpace.gapRelated),
        Expanded(child: primary),
      ],
    );
  }
}

/// A small spinning arc in the button colour while it is busy.
/// Stand-in until the Swing loader lands with the Loading component (phase 2).
class AdsBusy extends StatefulWidget {
  const AdsBusy({super.key, this.size = 24, this.color = AdsColors.purple500, this.semanticLabel = 'Loading'});

  final double size;
  final Color color;
  final String semanticLabel;

  @override
  State<AdsBusy> createState() => _AdsBusyState();
}

class _AdsBusyState extends State<AdsBusy> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool off = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (off) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(painter: _ArcPainter(_c, widget.color)),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.t, this.color) : super(repaint: t);

  final Animation<double> t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width / 10;
    final Rect r = (Offset.zero & size).deflate(w);
    canvas.drawArc(
      r,
      t.value * 2 * math.pi,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}

/// The glow ring: a 1.5px outline whose gradient turns counter-clockwise,
/// 2 s, ease in-out, forever. Stops when reduced motion is on.
class _GlowRing extends StatefulWidget {
  const _GlowRing({required this.purple, required this.radius, required this.child});

  final bool purple;
  final double radius;
  final Widget child;

  @override
  State<_GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<_GlowRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool off = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (off) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GlowPainter(_c, widget.purple, widget.radius),
      child: widget.child,
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.t, this.purple, this.radius) : super(repaint: t);

  final Animation<double> t;
  final bool purple;
  final double radius;

  static const Cubic _ease = Cubic(0.5, 0, 0.5, 1);

  @override
  void paint(Canvas canvas, Size size) {
    // CSS turns --btn-glow-a from 0 to -360deg; a negative rotation is counter-clockwise.
    final double a = -2 * math.pi * _ease.transform(t.value);
    final Rect rect = Offset.zero & size;
    final Gradient g = purple
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const <Color>[Color(0x005C00E6), Color(0x005C00E6), AdsColors.purple500],
            stops: const <double>[0, 0.25, 1],
            transform: GradientRotation(a),
          )
        : SweepGradient(
            colors: const <Color>[Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0xFFFFFFFF), Color(0xE6FFFFFF), Color(0x00FFFFFF)],
            stops: const <double>[0, 0.55, 0.80, 0.86, 1],
            transform: GradientRotation(a),
          );
    final RRect rr = RRect.fromRectAndRadius(rect.deflate(0.75), Radius.circular(radius - 0.75));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = g.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.purple != purple || old.radius != radius;
}
