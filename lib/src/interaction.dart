import 'package:flutter/widgets.dart';

import 'tokens.g.dart';

/// The interaction state a component draws from.
@immutable
class AdsStates {
  const AdsStates({this.hovered = false, this.pressed = false, this.focused = false, this.enabled = true});

  final bool hovered;
  final bool pressed;
  final bool focused;
  final bool enabled;
}

/// DS motion: the given duration, or zero when the platform asks for reduced motion.
Duration adsMotion(BuildContext context, int milliseconds) {
  final bool off = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return off ? Duration.zero : Duration(milliseconds: milliseconds);
}

/// The DS ease-out used for marks and labels: cubic-bezier(.2, .8, .2, 1).
const Cubic adsEaseOut = Cubic(0.2, 0.8, 0.2, 1);

/// Tap, hover, keyboard focus and Enter/Space activation in one place, with no
/// Material ripple. [builder] gets the current [AdsStates].
///
/// [enabled] is how the component looks; it is interactive only when it is
/// enabled and [onTap] is not null (a loading button is enabled but not tappable).
class AdsTappable extends StatefulWidget {
  const AdsTappable({
    super.key,
    required this.builder,
    this.onTap,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.cursor,
  });

  final Widget Function(BuildContext context, AdsStates states) builder;
  final VoidCallback? onTap;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final MouseCursor? cursor;

  @override
  State<AdsTappable> createState() => _AdsTappableState();
}

class _AdsTappableState extends State<AdsTappable> {
  bool _hover = false;
  bool _press = false;
  bool _focus = false;

  bool get _live => widget.enabled && widget.onTap != null;

  void _set(VoidCallback change) {
    if (mounted) setState(change);
  }

  @override
  Widget build(BuildContext context) {
    final bool live = _live;
    return FocusableActionDetector(
      enabled: live,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: widget.cursor ?? (live ? SystemMouseCursors.click : SystemMouseCursors.forbidden),
      onShowHoverHighlight: (bool v) => _set(() => _hover = v),
      onShowFocusHighlight: (bool v) => _set(() => _focus = v),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (ActivateIntent intent) {
          widget.onTap?.call();
          return null;
        }),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: live ? (TapDownDetails d) => _set(() => _press = true) : null,
        onTapUp: live ? (TapUpDetails d) => _set(() => _press = false) : null,
        onTapCancel: live ? () => _set(() => _press = false) : null,
        onTap: live ? widget.onTap : null,
        child: widget.builder(
          context,
          AdsStates(
            hovered: _hover && live,
            pressed: _press && live,
            focused: _focus && live,
            enabled: widget.enabled,
          ),
        ),
      ),
    );
  }
}

/// The DS keyboard focus ring: 2px Purple 500, [offset] outside the shape
/// (negative = inside, like tabs and option rows).
class AdsFocusRing extends StatelessWidget {
  const AdsFocusRing({
    super.key,
    required this.visible,
    required this.radius,
    required this.child,
    this.offset = 2,
  });

  final bool visible;
  final double radius;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;
    final double o = offset + 2;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        Positioned(
          left: -o,
          top: -o,
          right: -o,
          bottom: -o,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AdsColors.purple500, width: 2),
                borderRadius: BorderRadius.circular((radius + o).clamp(0, double.infinity).toDouble()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A 1px (or [width]) ring drawn inside the box without moving its content,
/// like the CSS `box-shadow: 0 0 0 1px … inset` the DS uses. Null = no ring.
BoxDecoration? adsRing(Color? color, double radius, {double width = 1}) {
  if (color == null) return null;
  return BoxDecoration(
    border: Border.all(color: color, width: width),
    borderRadius: BorderRadius.circular(radius),
  );
}
