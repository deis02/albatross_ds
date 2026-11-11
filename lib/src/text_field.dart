import 'package:flutter/material.dart' show Material, MaterialType, TextField, InputDecoration;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'field_chrome.dart';
import 'icon.dart';
import 'interaction.dart';
import 'tokens.g.dart';

export 'field_chrome.dart' show AdsFieldStatus;

/// Albatross Text field (components.css `.field`).
///
/// The label sits in the box and moves up on focus or once there is a value.
/// [placeholder] is a hint that only shows while typing; always keep the label.
///
/// ```dart
/// AdsTextField(label: 'Email', placeholder: 'name@email.com',
///     help: 'We send the receipt here', helpIcon: const AdsIcon('info'),
///     keyboardType: TextInputType.emailAddress)
/// ```
class AdsTextField extends StatefulWidget {
  const AdsTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.help,
    this.helpIcon,
    this.status = AdsFieldStatus.none,
    this.enabled = true,
    this.readOnly = false,
    this.leadingIcon,
    this.prefixText,
    this.clearable = false,
    this.obscureText = false,
    this.multiline = false,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;

  /// Helper or error text under the box.
  final String? help;
  final Widget? helpIcon;
  final AdsFieldStatus status;
  final bool enabled;
  final bool readOnly;

  /// Icon before the text, 20 (`.field__lead`).
  final Widget? leadingIcon;

  /// Short unit before the value, like `Rp` (`.field__affix`). Hidden while the label rests.
  final String? prefixText;

  /// Shows a clear button while focused and not empty.
  final bool clearable;

  /// Password field with a show/hide button.
  final bool obscureText;

  /// Grows from two box heights (112) with the text.
  final bool multiline;

  /// Adds a counter on the right of the help row.
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AdsTextField> createState() => _AdsTextFieldState();
}

class _AdsTextFieldState extends State<AdsTextField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  bool _hover = false;
  late bool _hidden = widget.obscureText;

  TextEditingController get _ctrl => widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_changed);
    _focus.addListener(_changed);
  }

  @override
  void didUpdateWidget(AdsTextField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _ownController)?.removeListener(_changed);
      _ctrl.addListener(_changed);
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_changed);
      _focus.addListener(_changed);
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_changed);
    _focus.removeListener(_changed);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool focused = _focus.hasFocus;
    final bool empty = _ctrl.text.isEmpty;
    final bool resting = empty && !focused;
    final AdsFieldLook look = AdsFieldLook.of(
      focused: focused,
      hovered: _hover,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      status: widget.status,
    );

    final List<Widget> actions = <Widget>[
      if (widget.clearable && focused && !empty && widget.enabled && !widget.readOnly)
        _FieldAction(
          icon: const AdsIcon('close-sm'),
          label: 'Clear',
          color: look.icon,
          onTap: () {
            _ctrl.clear();
            widget.onChanged?.call('');
          },
        ),
      if (widget.obscureText)
        _FieldAction(
          icon: AdsIcon(_hidden ? 'eye' : 'eye-off'),
          label: _hidden ? 'Show password' : 'Hide password',
          color: look.icon,
          onTap: widget.enabled ? () => setState(() => _hidden = !_hidden) : null,
        ),
    ];

    final Widget input = Material(
      type: MaterialType.transparency,
      child: TextField(
        controller: _ctrl,
        focusNode: _focus,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: _hidden,
        maxLines: widget.multiline ? null : 1,
        minLines: widget.multiline ? 3 : null,
        maxLength: widget.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        keyboardType: widget.multiline ? TextInputType.multiline : widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: AdsType.b1.copyWith(color: look.text),
        cursorColor: AdsColors.purple500,
        buildCounter: (BuildContext context, {required int currentLength, required bool isFocused, required int? maxLength}) => null,
        decoration: InputDecoration.collapsed(
          hintText: focused ? widget.placeholder : null,
          hintStyle: AdsType.b1.copyWith(color: AdsColors.dark200),
        ),
      ),
    );

    final Widget valueRow = Row(
      children: <Widget>[
        if (widget.prefixText != null && !resting)
          Padding(
            padding: const EdgeInsets.only(right: AdsSpace.s12),
            child: Text(widget.prefixText!, style: AdsType.b1.copyWith(color: look.icon)),
          ),
        Expanded(child: input),
      ],
    );

    final Widget textArea = widget.multiline
        ? Stack(
            children: <Widget>[
              Padding(padding: const EdgeInsets.only(top: AdsSpace.s24, bottom: AdsSpace.s12), child: valueRow),
              Positioned(left: 0, right: 0, top: AdsSpace.s8, child: IgnorePointer(child: AdsFieldLabel(text: widget.label, resting: resting, color: look.label))),
            ],
          )
        : SizedBox(
            height: 56,
            child: Stack(
              children: <Widget>[
                Positioned(left: 0, right: 0, top: AdsSpace.s24, child: valueRow),
                Positioned(left: 0, right: 0, top: AdsSpace.s8, child: IgnorePointer(child: AdsFieldLabel(text: widget.label, resting: resting, color: look.label))),
              ],
            ),
          );

    // TextFieldTapRegion: tapping clear or show-password does not count as a tap outside the field
    final Widget box = TextFieldTapRegion(child: MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.text : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.enabled ? _focus.requestFocus : null,
        child: AdsFieldBox(
          look: look,
          minHeight: widget.multiline ? 112 : 56,
          padRight: actions.isEmpty ? AdsSpace.s16 : AdsSpace.s8,
          child: Row(
            crossAxisAlignment: widget.multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.leadingIcon != null)
                Padding(
                  padding: EdgeInsets.only(right: AdsSpace.s12, top: widget.multiline ? AdsSpace.s16 : 0),
                  child: adsIconSlot(widget.leadingIcon!, size: 20, color: look.icon),
                ),
              Expanded(child: textArea),
              ...actions,
            ],
          ),
        ),
      ),
    ));

    final String? counter = widget.maxLength == null ? null : '${_ctrl.text.characters.length}/${widget.maxLength}';
    final bool hasHelp = widget.help != null || counter != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        box,
        if (hasHelp) const SizedBox(height: AdsSpace.s8),
        if (hasHelp) AdsFieldHelp(text: widget.help, icon: widget.helpIcon, counter: counter, color: look.help),
      ],
    );
  }
}

/// 40 inline button inside the box (clear, show password).
class _FieldAction extends StatelessWidget {
  const _FieldAction({required this.icon, required this.label, required this.color, this.onTap});

  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: AdsTappable(
        onTap: onTap,
        enabled: onTap != null,
        builder: (BuildContext context, AdsStates st) => AdsFocusRing(
          visible: st.focused,
          radius: AdsRadius.r8,
          offset: -2,
          child: AnimatedContainer(
            duration: adsMotion(context, 120),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: st.pressed ? AdsColors.light300 : const Color(0x00000000),
              borderRadius: BorderRadius.circular(AdsRadius.r8),
            ),
            child: Center(child: adsIconSlot(icon, size: 20, color: color)),
          ),
        ),
      ),
    );
  }
}
