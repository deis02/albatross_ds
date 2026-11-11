import 'dart:ui' show FontFeature;

import 'package:flutter/widgets.dart';

import 'interaction.dart';
import 'tokens.g.dart';

/// Error and success states of a field (`.field.is-error` / `.is-success`).
enum AdsFieldStatus { none, error, success }

/// Resolved colours of a text field or select box for one state.
@immutable
class AdsFieldLook {
  const AdsFieldLook({
    required this.bg,
    required this.ring,
    required this.ringWidth,
    required this.label,
    required this.text,
    required this.icon,
    required this.help,
  });

  final Color bg;
  final Color? ring;
  final double ringWidth;
  final Color label;
  final Color text;
  final Color icon;
  final Color help;

  /// components.css `.field` and its states.
  factory AdsFieldLook.of({
    required bool focused,
    required bool hovered,
    required bool enabled,
    bool readOnly = false,
    AdsFieldStatus status = AdsFieldStatus.none,
  }) {
    if (!enabled) {
      return const AdsFieldLook(
        bg: AdsColors.light300,
        ring: null,
        ringWidth: 1,
        label: AdsColors.dark100,
        text: AdsColors.dark100,
        icon: AdsColors.dark100,
        help: AdsColors.dark100,
      );
    }
    if (status == AdsFieldStatus.error) {
      return AdsFieldLook(
        bg: AdsColors.red50,
        ring: AdsColors.red500,
        ringWidth: focused ? 2 : 1,
        label: AdsColors.red500,
        text: AdsColors.dark500,
        icon: AdsColors.dark300,
        help: AdsColors.red500,
      );
    }
    if (status == AdsFieldStatus.success) {
      return AdsFieldLook(
        bg: focused ? AdsColors.light100 : AdsColors.light200,
        ring: AdsColors.green500,
        ringWidth: focused ? 2 : 1,
        label: AdsColors.green500,
        text: AdsColors.dark500,
        icon: AdsColors.dark300,
        help: AdsColors.green500,
      );
    }
    if (readOnly) {
      return AdsFieldLook(
        bg: AdsColors.light200,
        ring: focused ? AdsColors.light500 : null,
        ringWidth: 2,
        label: AdsColors.dark300,
        text: AdsColors.dark500,
        icon: AdsColors.dark300,
        help: AdsColors.dark300,
      );
    }
    if (focused) {
      return const AdsFieldLook(
        bg: AdsColors.light100,
        ring: AdsColors.purple500,
        ringWidth: 2,
        label: AdsColors.purple600,
        text: AdsColors.dark500,
        icon: AdsColors.dark300,
        help: AdsColors.dark300,
      );
    }
    return AdsFieldLook(
      bg: AdsColors.light200,
      ring: hovered ? AdsColors.dark100 : AdsColors.light500,
      ringWidth: 1,
      label: AdsColors.dark300,
      text: AdsColors.dark500,
      icon: AdsColors.dark300,
      help: AdsColors.dark300,
    );
  }
}

/// The 56 box behind a text field or select: light-200, radius 12, a 1px ring
/// that turns 2px Purple 500 on focus (drawn inside, so nothing moves).
class AdsFieldBox extends StatelessWidget {
  const AdsFieldBox({super.key, required this.look, required this.child, this.minHeight = 56, this.padRight = AdsSpace.s16});

  final AdsFieldLook look;
  final Widget child;
  final double minHeight;
  final double padRight;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: adsMotion(context, 150),
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.only(left: AdsSpace.s16, right: padRight),
      decoration: BoxDecoration(color: look.bg, borderRadius: BorderRadius.circular(AdsRadius.r12)),
      foregroundDecoration: adsRing(look.ring, AdsRadius.r12, width: look.ringWidth),
      child: child,
    );
  }
}

/// The label that rests in the middle of the box at body size and moves up
/// to B2 Semibold on focus or once there is a value.
class AdsFieldLabel extends StatelessWidget {
  const AdsFieldLabel({super.key, required this.text, required this.resting, required this.color});

  final String text;
  final bool resting;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: resting ? 1 : 0),
      duration: adsMotion(context, 180),
      curve: adsEaseOut,
      builder: (BuildContext context, double t, Widget? child) {
        // resting: translateY(10) scale(14/12), centred in the 56 box
        return Transform.translate(
          offset: Offset(0, 10 * t),
          child: Transform.scale(scale: 1 + (14 / 12 - 1) * t, alignment: Alignment.centerLeft, child: child),
        );
      },
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AdsType.b2s.copyWith(color: color),
      ),
    );
  }
}

/// Helper row under a field: icon 16 + B2 text, optional counter on the right.
class AdsFieldHelp extends StatelessWidget {
  const AdsFieldHelp({super.key, this.text, this.icon, this.counter, required this.color});

  final String? text;
  final Widget? icon;
  final String? counter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AdsSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: AdsSpace.s4),
              child: SizedBox(
                height: 20,
                child: Center(
                  child: IconTheme.merge(data: IconThemeData(size: 16, color: color), child: SizedBox(width: 16, height: 16, child: icon)),
                ),
              ),
            ),
          Expanded(child: Text(text ?? '', style: AdsType.b2.copyWith(color: color))),
          if (counter != null)
            Padding(
              padding: const EdgeInsets.only(left: AdsSpace.s8),
              child: Text(
                counter!,
                style: AdsType.b2.copyWith(color: AdsColors.dark200, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
              ),
            ),
        ],
      ),
    );
  }
}
