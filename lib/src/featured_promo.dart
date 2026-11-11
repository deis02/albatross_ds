import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'button.dart';
import 'icon.dart';
import 'interaction.dart';
import 'tokens.g.dart';

/// The Swing Pass background (`--gradient-swing-pass`): Purple 500 with a light
/// violet glow from the bottom left and a deep purple one from the top right.
/// CSS draws it with two elliptical radial gradients, which a single Flutter
/// gradient cannot express, so it is two layers over the base colour.
class AdsSwingPassBackground extends StatelessWidget {
  const AdsSwingPassBackground({super.key, this.child, this.borderRadius});

  final Widget? child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget layers = Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        const Positioned.fill(child: ColoredBox(color: AdsColors.purple500)),
        // radial-gradient(120% 90% at 25% 100%, #9466D8 0%, transparent 60%)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, 1),
                radius: 1.2,
                colors: <Color>[Color(0xFF9466D8), Color(0x009466D8)],
                stops: <double>[0, 0.6],
              ),
            ),
          ),
        ),
        // radial-gradient(90% 70% at 100% 0%, #4500AE 0%, transparent 70%)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1, -1),
                radius: 0.9,
                colors: <Color>[Color(0xFF4500AE), Color(0x004500AE)],
                stops: <double>[0, 0.7],
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
    return borderRadius == null ? layers : ClipRRect(borderRadius: borderRadius!, child: layers);
  }
}

/// The Swing Pass mark (brand/swing-pass.svg), [size] square, in [color].
class AdsSwingPassMark extends StatelessWidget {
  const AdsSwingPassMark({super.key, this.size = 20, this.color = AdsColors.purple500});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/brand/swing-pass.svg',
      package: 'albatross_ds',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

/// Albatross Featured promo (components.css `.featured-promo`, Figma Swing Web App
/// 6131:52581): one deal that only Swing Pass members get.
///
/// Purple 500 line, radius 12; Swing Pass strip on the left with the white pass
/// mark; white body, padding 16, gap 16. Title B2 Semibold, two lines then …;
/// [tag] B3 Semibold Purple 500; a Button S with a chevron on the bottom line.
/// The whole card is one tap target, the button inside only marks it.
///
/// [claimed]: the member already has this deal. An "Active" status takes the
/// button's place, the same size as Button S (32, padding 0 12, radius 8):
/// Light 300, CTA S Dark 300, green tick 16. The card stays tappable.
///
/// ```dart
/// AdsFeaturedPromo(
///   title: 'Rp 999,000 · Sun & PH PM Deal at Suvarna Jakarta Golf Club',
///   onTap: () => openDeal(deal),
/// )
/// AdsFeaturedPromo(title: deal.title, claimed: true, onTap: () => openDeal(deal))
/// ```
class AdsFeaturedPromo extends StatelessWidget {
  const AdsFeaturedPromo({
    super.key,
    required this.title,
    this.tag = 'Swing Pass Exclusive',
    this.actionLabel = 'Join',
    this.claimed = false,
    this.claimedLabel = 'Active',
    this.onTap,
    this.semanticLabel,
  });

  final String title;
  final String tag;
  final String actionLabel;

  /// The member already has this deal: show [claimedLabel] instead of the button.
  final bool claimed;
  final String claimedLabel;
  final VoidCallback? onTap;

  /// What a screen reader says. Defaults to title, tag and action.
  final String? semanticLabel;

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel ?? '$title. $tag. ${claimed ? claimedLabel : actionLabel}',
      excludeSemantics: true,
      child: AdsTappable(
        onTap: onTap,
        enabled: true,
        cursor: onTap == null ? SystemMouseCursors.basic : null,
        builder: (BuildContext context, AdsStates st) => AdsFocusRing(
          visible: st.focused,
          radius: AdsRadius.r12,
          child: AnimatedScale(
            scale: st.pressed ? 0.98 : 1,
            duration: adsMotion(context, 120),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AdsColors.light100,
                border: Border.all(color: AdsColors.purple500),
                borderRadius: BorderRadius.circular(AdsRadius.r12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AdsRadius.r12 - 1),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const AdsSwingPassBackground(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: AdsSpace.s8),
                          child: Center(child: AdsSwingPassMark(size: 20, color: AdsColors.light100)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AdsSpace.s16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AdsType.b2s.copyWith(color: AdsColors.dark500),
                                    ),
                                    const SizedBox(height: AdsSpace.s4),
                                    Text(
                                      tag,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: AdsType.b3s.copyWith(color: AdsColors.purple500),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AdsSpace.s16),
                              // a marker, not a second button: the card is the tap target
                              if (claimed)
                                _ClaimedStatus(label: claimedLabel)
                              else
                                IgnorePointer(
                                child: ExcludeFocus(
                                  child: AdsButton(
                                    label: actionLabel,
                                    size: AdsButtonSize.s,
                                    trailingIcon: const AdsIcon('chevron-right'),
                                    onPressed: _noop,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Active" status of a claimed deal: Button S size, Light 300, CTA S Dark 300, green tick 16.
class _ClaimedStatus extends StatelessWidget {
  const _ClaimedStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: AdsSpace.s12),
      decoration: BoxDecoration(color: AdsColors.light300, borderRadius: BorderRadius.circular(AdsRadius.r8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AdsIcon('tick-circle', style: AdsIconStyle.solid, size: 16, color: AdsColors.green500),
          const SizedBox(width: AdsSpace.s4),
          Text(label, maxLines: 1, softWrap: false, style: AdsType.ctaS.copyWith(color: AdsColors.dark300)),
        ],
      ),
    );
  }
}
