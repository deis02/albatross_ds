import 'package:flutter/widgets.dart';

import 'checkbox.dart' show adsChoiceRow;
import 'interaction.dart';
import 'tokens.g.dart';

/// Albatross Radio (components.css `.radio`): one choice from a short list.
/// Selected = Purple 500 fill with a white dot 8. [onChanged] null = disabled.
///
/// ```dart
/// AdsRadio<int>(value: 18, groupValue: holes, onChanged: (v) => setState(() => holes = v), semanticLabel: '18 holes')
/// ```
class AdsRadio<T> extends StatelessWidget {
  const AdsRadio({super.key, required this.value, required this.groupValue, required this.onChanged, this.error = false, this.semanticLabel});

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final bool error;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    final bool on = value == groupValue;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: on,
      enabled: enabled,
      label: semanticLabel,
      child: AdsTappable(
        enabled: enabled,
        onTap: enabled ? () => onChanged!(value) : null,
        builder: (BuildContext context, AdsStates st) =>
            AdsFocusRing(visible: st.focused, radius: AdsRadius.full, child: AdsRadioDot(on: on, states: st, error: error)),
      ),
    );
  }
}

/// The circle on its own, drawn for a given state.
class AdsRadioDot extends StatelessWidget {
  const AdsRadioDot({super.key, required this.on, required this.states, this.error = false});

  final bool on;
  final AdsStates states;
  final bool error;

  @override
  Widget build(BuildContext context) {
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
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        foregroundDecoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ring, width: 2)),
        child: Center(
          child: AnimatedScale(
            scale: on ? 1 : 0,
            duration: adsMotion(context, 200),
            curve: const Cubic(0.3, 1.5, 0.5, 1),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AdsColors.light100, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

/// Radio with a label (row 44) or as an option tile. Same layout as AdsCheckTile.
///
/// ```dart
/// AdsRadioTile<int>(label: '18 holes', hint: 'About 4 hours', value: 18,
///     groupValue: holes, onChanged: (v) => setState(() => holes = v))
/// ```
class AdsRadioTile<T> extends StatelessWidget {
  const AdsRadioTile({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.hint,
    this.meta,
    this.card = false,
    this.error = false,
  });

  final String label;
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? hint;
  final String? meta;
  final bool card;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    final bool on = value == groupValue;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: on,
      enabled: enabled,
      child: AdsTappable(
        enabled: enabled,
        onTap: enabled ? () => onChanged!(value) : null,
        builder: (BuildContext context, AdsStates st) => adsChoiceRow(
          context: context,
          states: st,
          control: AdsFocusRing(
            visible: st.focused && !card,
            radius: AdsRadius.full,
            child: AdsRadioDot(on: on, states: st, error: error),
          ),
          label: label,
          hint: hint,
          meta: meta,
          card: card,
          on: on,
        ),
      ),
    );
  }
}
