import 'package:flutter/widgets.dart';

import 'icon.dart';
import 'interaction.dart';
import 'tokens.g.dart';

/// One tab.
@immutable
class AdsTabItem {
  const AdsTabItem({required this.label, this.icon, this.enabled = true});

  final String label;

  /// Icon before the label, 20 (16 on small tabs).
  final Widget? icon;
  final bool enabled;
}

/// Albatross Tabs (components.css `.tabs`): H6 labels, Dark 300; the selected
/// one is Purple 600 with a 2px Purple 500 bar. 44 tall, line underneath.
///
/// [fixed]: equal widths, max 4 tabs. Otherwise the row scrolls sideways.
/// [small]: second-level tabs inside a card or sheet (B2 Semibold).
/// [flush]: no side padding, for a container that is already padded.
///
/// ```dart
/// AdsTabs(
///   tabs: const [AdsTabItem(label: 'Reservations'), AdsTabItem(label: 'History')],
///   selectedIndex: tab,
///   onChanged: (i) => setState(() => tab = i),
///   fixed: true,
/// )
/// ```
class AdsTabs extends StatelessWidget {
  const AdsTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.fixed = false,
    this.small = false,
    this.flush = false,
  }) : assert(!fixed || tabs.length <= 4, 'Fixed tabs: max 4');

  final List<AdsTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool fixed;
  final bool small;
  final bool flush;

  @override
  Widget build(BuildContext context) {
    final double side = flush ? 0 : (small ? AdsSpace.s8 : AdsSpace.s12);
    final List<Widget> items = <Widget>[
      for (int i = 0; i < tabs.length; i++)
        _Tab(item: tabs[i], selected: i == selectedIndex, small: small, bounded: fixed, onTap: () => onChanged(i)),
    ];
    final Widget row = fixed
        ? Row(children: <Widget>[for (final Widget t in items) Expanded(child: t)])
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisSize: MainAxisSize.min, children: items),
          );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdsColors.light500))),
        child: Padding(padding: EdgeInsets.symmetric(horizontal: side), child: row),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.small, required this.bounded, required this.onTap});

  final AdsTabItem item;
  final bool selected;
  final bool small;

  /// Fixed tabs have a width to ellipsize into; scrolling tabs size to their label.
  final bool bounded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double px = small ? AdsSpace.s8 : AdsSpace.s12;
    final TextStyle type = small ? AdsType.b2s : AdsType.h6;
    return Semantics(
      selected: selected,
      button: true,
      enabled: item.enabled,
      child: AdsTappable(
        enabled: item.enabled,
        onTap: onTap,
        builder: (BuildContext context, AdsStates st) {
          final Color fg = !item.enabled ? AdsColors.dark100 : (selected ? AdsColors.purple600 : AdsColors.dark300);
          return AdsFocusRing(
            visible: st.focused,
            radius: AdsRadius.r8,
            offset: -2,
            child: Container(
              constraints: const BoxConstraints(minHeight: AdsSpace.tapMin),
              padding: EdgeInsets.symmetric(horizontal: px),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: AdsSpace.tapMin),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (item.icon != null) ...<Widget>[
                          adsIconSlot(item.icon!, size: small ? 16 : 20, color: fg),
                          SizedBox(width: small ? AdsSpace.gapTight : AdsSpace.gapRelated),
                        ],
                        if (bounded)
                          Flexible(child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: type.copyWith(color: fg)))
                        else
                          Text(item.label, maxLines: 1, softWrap: false, style: type.copyWith(color: fg)),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 2,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: selected ? 1 : 0),
                      duration: adsMotion(context, 200),
                      curve: Curves.ease,
                      builder: (BuildContext context, double t, Widget? child) =>
                          Transform(alignment: Alignment.center, transform: Matrix4.diagonal3Values(t, 1, 1), child: child),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: AdsColors.purple500, borderRadius: BorderRadius.circular(AdsRadius.full)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
