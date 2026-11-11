import 'package:flutter/widgets.dart';

import 'icon.dart';
import 'interaction.dart';
import 'tokens.g.dart';

/// neutral (default) · primary · teal · pink · orange · green · red · onMedia (on a photo).
enum AdsTagTone { neutral, primary, teal, pink, orange, green, red, onMedia }

/// M 32 (default) · S 24.
enum AdsTagSize { m, s }

class _TagLook {
  const _TagLook(this.bg, this.ring, this.fg, this.bgOn, this.fgOn, this.press, this.ringHover);
  final Color bg;
  final Color ring;
  final Color fg;
  final Color bgOn;
  final Color fgOn;
  final Color press;
  final Color ringHover;
}

const Map<AdsTagTone, _TagLook> _looks = <AdsTagTone, _TagLook>{
  AdsTagTone.neutral: _TagLook(AdsColors.light100, AdsColors.light500, AdsColors.dark500, AdsColors.dark500, AdsColors.light100, AdsColors.light300, AdsColors.dark100),
  AdsTagTone.primary: _TagLook(AdsColors.purple50, AdsColors.purple100, AdsColors.purple600, AdsColors.purple500, AdsColors.light100, AdsColors.purple100, AdsColors.purple200),
  AdsTagTone.teal: _TagLook(AdsColors.teal50, AdsColors.teal100, AdsColors.teal700, AdsColors.teal700, AdsColors.light100, AdsColors.teal100, AdsColors.teal300),
  AdsTagTone.pink: _TagLook(AdsColors.pink50, AdsColors.pink100, AdsColors.pink700, AdsColors.pink700, AdsColors.light100, AdsColors.pink100, AdsColors.pink300),
  AdsTagTone.orange: _TagLook(AdsColors.orange50, AdsColors.orange100, AdsColors.orange700, AdsColors.orange700, AdsColors.light100, AdsColors.orange100, AdsColors.orange300),
  AdsTagTone.green: _TagLook(AdsColors.green50, AdsColors.green100, AdsColors.green700, AdsColors.green700, AdsColors.light100, AdsColors.green100, AdsColors.green300),
  AdsTagTone.red: _TagLook(AdsColors.red50, AdsColors.red100, AdsColors.red700, AdsColors.red700, AdsColors.light100, AdsColors.red100, AdsColors.red300),
  AdsTagTone.onMedia: _TagLook(AdsColors.scrimMediaSoft, AdsColors.light100, AdsColors.light100, AdsColors.light100, AdsColors.dark500, AdsColors.scrimMedia, AdsColors.light100),
};

/// Albatross Tag (components.css `.tag`): a tappable pill for filters,
/// interests and quick choices. A label that only shows a status is a Badge.
///
/// Toggle with [selected] + [onChanged]; a menu tag uses [onTap] and a
/// trailing chevron; a picked value shows a remove button with [onRemove].
///
/// ```dart
/// AdsTag(label: 'Golf', selected: golf, onChanged: (v) => setState(() => golf = v))
/// AdsTag(label: 'Bali', selected: true, onRemove: () => remove('Bali'))
/// ```
class AdsTag extends StatelessWidget {
  const AdsTag({
    super.key,
    required this.label,
    this.selected = false,
    this.onChanged,
    this.onTap,
    this.onRemove,
    this.tone = AdsTagTone.neutral,
    this.size = AdsTagSize.m,
    this.icon,
    this.trailingIcon,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  /// Shows the x button (a removable, picked value).
  final VoidCallback? onRemove;
  final AdsTagTone tone;
  final AdsTagSize size;

  /// Lead icon, 16 (12 on S).
  final Widget? icon;

  /// Trailing icon, for example a chevron on a menu tag.
  final Widget? trailingIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final _TagLook l = _looks[tone]!;
    final bool small = size == AdsTagSize.s;
    final double h = small ? 24 : 32;
    final double px = small ? AdsSpace.s8 : AdsSpace.s12;
    final double iconSize = small ? 12 : 16;
    final TextStyle type = small ? AdsType.b3s : AdsType.b2s;
    final VoidCallback? tap = onTap ?? (onChanged == null ? null : () => onChanged!(!selected));
    final bool tappable = tap != null;

    return Semantics(
      button: tappable,
      toggled: onChanged != null ? selected : null,
      enabled: enabled,
      child: AdsTappable(
        enabled: enabled,
        onTap: tap,
        cursor: tappable ? null : SystemMouseCursors.basic,
        builder: (BuildContext context, AdsStates st) {
          Color bg = l.bg;
          Color ring = st.hovered && !selected ? l.ringHover : l.ring;
          Color fg = l.fg;
          if (selected) {
            bg = l.bgOn;
            ring = l.bgOn;
            fg = l.fgOn;
          } else if (st.pressed) {
            bg = l.press;
          }
          if (!enabled) {
            bg = AdsColors.light200;
            ring = AdsColors.light300;
            fg = AdsColors.dark100;
          }
          final bool trailing = trailingIcon != null || onRemove != null;
          return AdsFocusRing(
            visible: st.focused,
            radius: AdsRadius.full,
            child: AnimatedScale(
              scale: st.pressed ? 0.96 : 1,
              duration: adsMotion(context, 120),
              child: AnimatedContainer(
                duration: adsMotion(context, 150),
                height: h,
                padding: EdgeInsets.only(
                  left: icon != null ? px - AdsSpace.s4 : px,
                  right: trailing ? px - AdsSpace.s4 : px,
                ),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdsRadius.full)),
                foregroundDecoration: adsRing(ring, AdsRadius.full),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[adsIconSlot(icon!, size: iconSize, color: fg), const SizedBox(width: AdsSpace.gapTight)],
                    Text(label, maxLines: 1, softWrap: false, style: type.copyWith(color: fg)),
                    if (trailingIcon != null) ...<Widget>[const SizedBox(width: AdsSpace.gapTight), adsIconSlot(trailingIcon!, size: iconSize, color: fg)],
                    if (onRemove != null) ...<Widget>[
                      const SizedBox(width: AdsSpace.gapTight),
                      _TagRemove(label: label, small: small, color: fg, onTap: enabled ? onRemove : null),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TagRemove extends StatelessWidget {
  const _TagRemove({required this.label, required this.small, required this.color, this.onTap});

  final String label;
  final bool small;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double box = small ? 16 : 20;
    return Semantics(
      button: true,
      label: 'Remove $label',
      excludeSemantics: true,
      child: AdsTappable(
        enabled: onTap != null,
        onTap: onTap,
        builder: (BuildContext context, AdsStates st) => AdsFocusRing(
          visible: st.focused,
          radius: AdsRadius.full,
          offset: 0,
          child: SizedBox(
            width: box,
            height: box,
            child: Center(child: AdsIcon('close-sm', size: small ? 12 : 16, color: color)),
          ),
        ),
      ),
    );
  }
}

/// A wrapping group of tags with the DS gap (8). Set [scroll] for one
/// sideways-scrolling row (`.tags--scroll`).
class AdsTagGroup extends StatelessWidget {
  const AdsTagGroup({super.key, required this.children, this.scroll = false, this.semanticLabel});

  final List<Widget> children;
  final bool scroll;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget body = scroll
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AdsSpace.pageX),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < children.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: AdsSpace.gapRelated),
                  children[i],
                ],
              ],
            ),
          )
        : Wrap(spacing: AdsSpace.gapRelated, runSpacing: AdsSpace.gapRelated, children: children);
    return Semantics(container: true, label: semanticLabel, child: body);
  }
}
