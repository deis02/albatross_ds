import 'package:flutter/widgets.dart';

import 'field_chrome.dart';
import 'icon.dart';
import 'interaction.dart';
import 'sheet.dart';
import 'tokens.g.dart';

/// One choice in a select sheet.
@immutable
class AdsOption<T> {
  const AdsOption({required this.value, required this.label, this.hint, this.icon, this.enabled = true});

  final T value;
  final String label;
  final String? hint;

  /// Leading icon, 20.
  final Widget? icon;
  final bool enabled;
}

/// Albatross Select (components.css `.field--select`): looks like a text field,
/// opens a sheet of options. [onChanged] null = disabled.
///
/// ```dart
/// AdsSelect<String>(
///   label: 'City',
///   value: city,
///   options: const [AdsOption(value: 'jkt', label: 'Jakarta'), AdsOption(value: 'bdg', label: 'Bandung')],
///   onChanged: (v) => setState(() => city = v),
/// )
/// ```
class AdsSelect<T> extends StatefulWidget {
  const AdsSelect({
    super.key,
    required this.label,
    required this.options,
    this.value,
    this.onChanged,
    this.sheetTitle,
    this.leadingIcon,
    this.status = AdsFieldStatus.none,
    this.help,
    this.helpIcon,
  });

  final String label;
  final List<AdsOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;

  /// Sheet title. Defaults to [label].
  final String? sheetTitle;
  final Widget? leadingIcon;
  final AdsFieldStatus status;
  final String? help;
  final Widget? helpIcon;

  @override
  State<AdsSelect<T>> createState() => _AdsSelectState<T>();
}

class _AdsSelectState<T> extends State<AdsSelect<T>> {
  bool _open = false;

  Future<void> _pick() async {
    setState(() => _open = true);
    final T? picked = await showAdsOptionsSheet<T>(
      context: context,
      title: widget.sheetTitle ?? widget.label,
      options: widget.options,
      selected: widget.value,
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (picked != null) widget.onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onChanged != null;
    AdsOption<T>? current;
    for (final AdsOption<T> o in widget.options) {
      if (o.value == widget.value) current = o;
    }
    final bool resting = current == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          button: true,
          enabled: enabled,
          label: widget.label,
          value: current?.label,
          excludeSemantics: true,
          child: AdsTappable(
            enabled: enabled,
            onTap: _pick,
            builder: (BuildContext context, AdsStates st) {
              final AdsFieldLook look = AdsFieldLook.of(
                focused: st.focused || _open,
                hovered: st.hovered,
                enabled: enabled,
                status: widget.status,
              );
              return AdsFieldBox(
                look: look,
                child: Row(
                  children: <Widget>[
                    if (widget.leadingIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: AdsSpace.s12),
                        child: adsIconSlot(widget.leadingIcon!, size: 20, color: look.icon),
                      ),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              left: 0,
                              right: 0,
                              top: AdsSpace.s24,
                              child: Text(
                                current?.label ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AdsType.b1.copyWith(color: look.text),
                              ),
                            ),
                            Positioned(left: 0, right: 0, top: AdsSpace.s8, child: AdsFieldLabel(text: widget.label, resting: resting, color: look.label)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AdsSpace.s12),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: adsMotion(context, 200),
                      child: AdsIcon('chevron-down', size: 20, color: look.icon),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.help != null) const SizedBox(height: AdsSpace.s8),
        if (widget.help != null)
          AdsFieldHelp(
            text: widget.help,
            icon: widget.helpIcon,
            color: AdsFieldLook.of(focused: false, hovered: false, enabled: enabled, status: widget.status).help,
          ),
      ],
    );
  }
}

/// Opens the options sheet on its own and returns the picked value
/// (null when closed without a pick).
Future<T?> showAdsOptionsSheet<T>({
  required BuildContext context,
  required String title,
  required List<AdsOption<T>> options,
  T? selected,
}) {
  return showAdsSheet<T>(
    context: context,
    title: title,
    builder: (BuildContext ctx) => AdsOptionList<T>(
      options: options,
      selected: selected,
      onSelected: (T v) => Navigator.of(ctx).pop(v),
    ),
  );
}

/// Single-choice option rows (components.css `.options` / `.option`).
class AdsOptionList<T> extends StatelessWidget {
  const AdsOptionList({super.key, required this.options, required this.onSelected, this.selected});

  final List<AdsOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AdsSpace.s24),
        child: Text('Nothing to choose yet', textAlign: TextAlign.center, style: AdsType.b1.copyWith(color: AdsColors.dark300)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < options.length; i++)
          _OptionRow<T>(
            option: options[i],
            selected: options[i].value == selected,
            last: i == options.length - 1,
            onTap: options[i].enabled ? () => onSelected(options[i].value) : null,
          ),
      ],
    );
  }
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({required this.option, required this.selected, required this.last, this.onTap});

  final AdsOption<T> option;
  final bool selected;
  final bool last;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color text = !enabled ? AdsColors.dark100 : (selected ? AdsColors.purple600 : AdsColors.dark500);
    final Color hint = !enabled ? AdsColors.dark100 : AdsColors.dark300;
    return Semantics(
      selected: selected,
      button: true,
      enabled: enabled,
      child: AdsTappable(
        enabled: enabled,
        onTap: onTap,
        builder: (BuildContext context, AdsStates st) => AdsFocusRing(
          visible: st.focused,
          radius: 0,
          offset: -2,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(vertical: AdsSpace.s8),
            decoration: BoxDecoration(
              color: st.pressed ? AdsColors.light200 : const Color(0x00000000),
              border: last ? null : const Border(bottom: BorderSide(color: AdsColors.light500)),
            ),
            child: Row(
              children: <Widget>[
                if (option.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AdsSpace.s12),
                    child: adsIconSlot(option.icon!, size: 20, color: hint),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(option.label, style: (selected ? AdsType.b1s : AdsType.b1).copyWith(color: text)),
                      if (option.hint != null) Text(option.hint!, style: AdsType.b2.copyWith(color: hint)),
                    ],
                  ),
                ),
                const SizedBox(width: AdsSpace.s12),
                AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: adsMotion(context, 150),
                  child: AnimatedScale(
                    scale: selected ? 1 : 0.6,
                    duration: adsMotion(context, 200),
                    curve: const Cubic(0.3, 1.5, 0.5, 1),
                    child: const AdsIcon('checkmark', size: 20, color: AdsColors.purple600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
