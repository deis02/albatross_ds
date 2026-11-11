import 'package:flutter/widgets.dart';

import 'icon.dart';
import 'interaction.dart';
import 'tokens.g.dart';

/// Albatross Checkbox (components.css `.checkbox`): 24 box, radius 8, 2px ring.
/// `value: null` shows the mixed state (a "select all" with some ticked);
/// tapping it ticks everything. [onChanged] null = disabled.
///
/// ```dart
/// AdsCheckbox(value: caddie, onChanged: (v) => setState(() => caddie = v!), semanticLabel: 'Caddie')
/// ```
class AdsCheckbox extends StatelessWidget {
  const AdsCheckbox({super.key, required this.value, required this.onChanged, this.error = false, this.semanticLabel});

  final bool? value;
  final ValueChanged<bool?>? onChanged;

  /// Red ring while unticked (`[aria-invalid="true"]`).
  final bool error;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    return Semantics(
      checked: value == true,
      enabled: enabled,
      label: semanticLabel,
      child: AdsTappable(
        enabled: enabled,
        onTap: enabled ? () => onChanged!(value == null ? true : !value!) : null,
        builder: (BuildContext context, AdsStates st) =>
            AdsFocusRing(visible: st.focused, radius: AdsRadius.r8, child: AdsCheckboxBox(value: value, states: st, error: error)),
      ),
    );
  }
}

/// The box on its own, drawn for a given state. Used by [AdsCheckbox] and [AdsCheckTile].
class AdsCheckboxBox extends StatelessWidget {
  const AdsCheckboxBox({super.key, required this.value, required this.states, this.error = false});

  final bool? value;
  final AdsStates states;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final bool on = value != false;
    final bool enabled = states.enabled;
    final Color bg = !enabled
        ? (on ? AdsColors.dark100 : AdsColors.light300)
        : on
            ? (states.pressed ? AdsColors.purple600 : AdsColors.purple500)
            : AdsColors.light100;
    final Color ring = !enabled
        ? (on ? AdsColors.dark100 : AdsColors.light500)
        : on
            ? bg
            : error
                ? AdsColors.red500
                : states.hovered
                    ? AdsColors.purple500
                    : AdsColors.dark200;
    return AnimatedScale(
      scale: states.pressed ? 0.92 : 1,
      duration: adsMotion(context, 120),
      child: AnimatedContainer(
        duration: adsMotion(context, 150),
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdsRadius.r8)),
        foregroundDecoration: adsRing(ring, AdsRadius.r8, width: 2),
        child: Center(
          child: value == null
              ? Container(width: 12, height: 2, color: AdsColors.light100)
              : TweenAnimationBuilder<double>(
                  // the tick draws in from left to right
                  tween: Tween<double>(end: value! ? 1 : 0),
                  duration: adsMotion(context, 240),
                  curve: adsEaseOut,
                  builder: (BuildContext context, double t, Widget? child) => ClipRect(clipper: _LeftReveal(t), child: child),
                  child: const AdsIcon('checkmark', style: AdsIconStyle.solid, size: 16, color: AdsColors.light100),
                ),
        ),
      ),
    );
  }
}

class _LeftReveal extends CustomClipper<Rect> {
  const _LeftReveal(this.t);

  final double t;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * t, size.height);

  @override
  bool shouldReclip(_LeftReveal old) => old.t != t;
}

/// Checkbox with a label (`.check`, row 44) or as a selectable option tile
/// (`.check--card`). The whole row toggles.
///
/// ```dart
/// AdsCheckTile(label: 'Caddie', hint: 'Rp150.000 per round', meta: 'Rp150k',
///     value: caddie, onChanged: (v) => setState(() => caddie = v!))
/// ```
class AdsCheckTile extends StatelessWidget {
  const AdsCheckTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.meta,
    this.card = false,
    this.error = false,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? hint;

  /// Short value on the right, like a price.
  final String? meta;

  /// Selectable option tile: padding 16, radius 12, Purple 50 + Purple 500 ring when ticked.
  final bool card;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    return Semantics(
      checked: value == true,
      enabled: enabled,
      child: AdsTappable(
        enabled: enabled,
        onTap: enabled ? () => onChanged!(value == null ? true : !value!) : null,
        builder: (BuildContext context, AdsStates st) => adsChoiceRow(
          context: context,
          states: st,
          control: AdsFocusRing(
            visible: st.focused && !card,
            radius: AdsRadius.r8,
            child: AdsCheckboxBox(value: value, states: st, error: error),
          ),
          label: label,
          hint: hint,
          meta: meta,
          card: card,
          on: value != false,
        ),
      ),
    );
  }
}

/// Row and card layout shared by [AdsCheckTile] and AdsRadioTile.
Widget adsChoiceRow({
  required BuildContext context,
  required AdsStates states,
  required Widget control,
  required String label,
  required bool card,
  required bool on,
  String? hint,
  String? meta,
}) {
  final bool enabled = states.enabled;
  final Color labelC = enabled ? AdsColors.dark500 : AdsColors.dark100;
  final Color hintC = enabled ? AdsColors.dark300 : AdsColors.dark100;
  final Widget row = Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      control,
      const SizedBox(width: AdsSpace.s12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 24),
              child: Align(alignment: Alignment.centerLeft, widthFactor: 1, child: Text(label, style: AdsType.b1.copyWith(color: labelC))),
            ),
            if (hint != null) Text(hint, style: AdsType.b2.copyWith(color: hintC)),
          ],
        ),
      ),
      if (meta != null)
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 24),
          child: Align(alignment: Alignment.centerRight, widthFactor: 1, child: Text(meta, style: AdsType.b2s.copyWith(color: labelC))),
        ),
    ],
  );
  if (!card) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AdsSpace.tapMin),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: AdsSpace.s8), child: row),
    );
  }
  final Color bg = !enabled ? AdsColors.light200 : (on ? AdsColors.purple50 : AdsColors.light100);
  final Color ring = enabled && on ? AdsColors.purple500 : AdsColors.light500;
  return AdsFocusRing(
    visible: states.focused,
    radius: AdsRadius.r12,
    child: AnimatedContainer(
      duration: adsMotion(context, 150),
      padding: const EdgeInsets.all(AdsSpace.s16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AdsRadius.r12)),
      foregroundDecoration: adsRing(ring, AdsRadius.r12),
      child: row,
    ),
  );
}
