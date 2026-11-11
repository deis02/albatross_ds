import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'featured_promo.dart' show AdsSwingPassMark;
import 'tokens.g.dart';

/// Which plan the "You are here" tab sits over.
enum AdsCashbackPlan { regular, pass, none }

/// One time slot: its days, hours and the cashback for each plan.
@immutable
class AdsCashbackRow {
  const AdsCashbackRow({required this.day, required this.time, required this.regular, required this.pass});

  final String day;
  final String time;
  final String regular;
  final String pass;
}

/// Albatross Cashback table (components.css `.cashback-table`, Figma Swing Web App
/// 271:7933 "Cashback details"): the cashback a regular player and a Swing Pass
/// member get, per time slot.
///
/// Three equal columns. Regular column Light 200 with Dark 300 values; Swing Pass
/// column Purple 50 with Dark 500 values, outlined 2px Purple 500 with radius 16 on
/// the right. Light 500 line under every row. A Green 500 "You are here" tab sits
/// over the [current] plan.
///
/// ```dart
/// AdsCashbackTable(
///   current: AdsCashbackPlan.regular,
///   rows: const [
///     AdsCashbackRow(day: 'Mon - Fri', time: '05:00 - 12:00', regular: '10%', pass: '50%'),
///     AdsCashbackRow(day: 'Sat - Sun', time: '05:00 - 20:00', regular: '8%', pass: '40%'),
///   ],
/// )
/// ```
class AdsCashbackTable extends StatelessWidget {
  const AdsCashbackTable({
    super.key,
    required this.rows,
    this.current = AdsCashbackPlan.regular,
    this.regularLabel = 'Regular Swing players',
    this.passLabel = 'Swing Pass members',
    this.hereLabel = 'You are here',
    this.unit = 'cashback',
  });

  final List<AdsCashbackRow> rows;
  final AdsCashbackPlan current;
  final String regularLabel;
  final String passLabel;
  final String hereLabel;
  final String unit;

  Widget _hereTab() => Container(
        padding: const EdgeInsets.symmetric(vertical: AdsSpace.s8, horizontal: AdsSpace.s12),
        decoration: const BoxDecoration(
          color: AdsColors.green500,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AdsRadius.r8)),
        ),
        child: Text(hereLabel, textAlign: TextAlign.center, style: AdsType.b2s.copyWith(color: AdsColors.light100)),
      );

  Widget _plan(String label, Widget mark, {required bool pass}) => Container(
        padding: const EdgeInsets.symmetric(vertical: AdsSpace.s16, horizontal: AdsSpace.s12),
        decoration: BoxDecoration(
          color: pass ? AdsColors.purple50 : AdsColors.light200,
          borderRadius: pass ? const BorderRadius.only(topRight: Radius.circular(AdsRadius.r16)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            mark,
            const SizedBox(height: AdsSpace.s8),
            Text(label, textAlign: TextAlign.center, style: AdsType.b2s.copyWith(color: AdsColors.dark500)),
          ],
        ),
      );

  Widget _value(String v, {required bool pass, bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: AdsSpace.s16, horizontal: AdsSpace.s12),
        decoration: BoxDecoration(
          color: pass ? AdsColors.purple50 : AdsColors.light200,
          borderRadius: pass && last ? const BorderRadius.only(bottomRight: Radius.circular(AdsRadius.r16)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              v,
              textAlign: TextAlign.center,
              style: AdsType.h5.copyWith(
                color: pass ? AdsColors.dark500 : AdsColors.dark300,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            Text(unit, textAlign: TextAlign.center, style: AdsType.b2.copyWith(color: AdsColors.dark300)),
          ],
        ),
      );

  // a Light 500 line under a row: label and regular always, Swing Pass except under the last row
  Widget _rule({required bool pass}) => Row(
        children: <Widget>[
          const Expanded(child: SizedBox(height: 1, child: ColoredBox(color: AdsColors.light500))),
          const Expanded(child: SizedBox(height: 1, child: ColoredBox(color: AdsColors.light500))),
          Expanded(child: SizedBox(height: 1, child: ColoredBox(color: pass ? AdsColors.light500 : AdsColors.purple50))),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final Widget regularMark = SvgPicture.asset(
      'assets/brand/albatross-icon.svg',
      package: 'albatross_ds',
      width: 32,
      height: 32,
      colorFilter: const ColorFilter.mode(AdsColors.dark300, BlendMode.srcIn),
    );
    // the Swing Pass mark in the Swing Pass gradient (an approximation of the ADS mesh)
    final Widget passMark = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect r) => const RadialGradient(
        center: Alignment(-0.5, 1),
        radius: 1.4,
        colors: <Color>[Color(0xFF9466D8), AdsColors.purple500, Color(0xFF4500AE)],
        stops: <double>[0, 0.55, 1],
      ).createShader(r),
      child: const AdsSwingPassMark(size: 32, color: AdsColors.light100),
    );

    final List<Widget> body = <Widget>[
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Expanded(child: SizedBox()),
            Expanded(child: _plan(regularLabel, regularMark, pass: false)),
            Expanded(child: _plan(passLabel, passMark, pass: true)),
          ],
        ),
      ),
      Row(children: const <Widget>[
        Expanded(child: SizedBox(height: 1)),
        Expanded(child: SizedBox(height: 1, child: ColoredBox(color: AdsColors.light500))),
        Expanded(child: SizedBox(height: 1, child: ColoredBox(color: AdsColors.light500))),
      ]),
    ];
    for (int i = 0; i < rows.length; i++) {
      final AdsCashbackRow r = rows[i];
      final bool last = i == rows.length - 1;
      body.add(Semantics(
        container: true,
        label: '${r.day} ${r.time}. $regularLabel ${r.regular} $unit. $passLabel ${r.pass} $unit.',
        excludeSemantics: true,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AdsSpace.s16, AdsSpace.s16, AdsSpace.s8, AdsSpace.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(r.day, style: AdsType.b1s.copyWith(color: AdsColors.dark500)),
                      const SizedBox(height: AdsSpace.s4),
                      Text(r.time, style: AdsType.b2.copyWith(color: AdsColors.dark300)),
                    ],
                  ),
                ),
              ),
              Expanded(child: _value(r.regular, pass: false)),
              Expanded(child: _value(r.pass, pass: true, last: last)),
            ],
          ),
        ),
      ));
      body.add(_rule(pass: !last));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (current != AdsCashbackPlan.none)
          Row(
            children: <Widget>[
              const Expanded(child: SizedBox()),
              Expanded(child: current == AdsCashbackPlan.regular ? _hereTab() : const SizedBox()),
              Expanded(child: current == AdsCashbackPlan.pass ? _hereTab() : const SizedBox()),
            ],
          ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) => Stack(
            children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: body),
              // 2px Purple 500 outline round the Swing Pass column
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: c.maxWidth / 3,
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.fromBorderSide(BorderSide(color: AdsColors.purple500, width: 2)),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AdsRadius.r16),
                        bottomRight: Radius.circular(AdsRadius.r16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
