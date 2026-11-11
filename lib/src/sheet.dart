import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';

import 'icon.dart';
import 'interaction.dart';
import 'tokens.g.dart';

/// Opens an Albatross bottom sheet (components.css `.sheet`): white, top corners 16,
/// handle, H5 title with a close button, scrolling body, optional sticky [footer].
/// Max 480 wide and 88% of the screen tall, scrim behind.
Future<T?> showAdsSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  Widget? footer,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AdsColors.light100,
    barrierColor: AdsColors.scrim,
    elevation: 0,
    constraints: const BoxConstraints(maxWidth: 480),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AdsRadius.r16))),
    builder: (BuildContext ctx) => AdsSheet(title: title, footer: footer, child: builder(ctx)),
  );
}

/// The sheet layout on its own, for custom routes.
class AdsSheet extends StatelessWidget {
  const AdsSheet({super.key, required this.title, required this.child, this.footer});

  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(top: AdsSpace.s8),
              decoration: BoxDecoration(color: AdsColors.light500, borderRadius: BorderRadius.circular(AdsRadius.r8)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AdsSpace.pageX, AdsSpace.s12, AdsSpace.s16, AdsSpace.gapGroup),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Semantics(header: true, child: Text(title, style: AdsType.h5.copyWith(color: AdsColors.dark500))),
                ),
                const SizedBox(width: AdsSpace.gapGroup),
                _SheetClose(onTap: () => Navigator.of(context).maybePop()),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(AdsSpace.pageX, AdsSpace.s8, AdsSpace.pageX, footer == null ? AdsSpace.s24 + bottom : AdsSpace.s24),
              child: child,
            ),
          ),
          if (footer != null)
            DecoratedBox(
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AdsColors.light500))),
              child: Padding(
                padding: EdgeInsets.fromLTRB(AdsSpace.pageX, AdsSpace.s16, AdsSpace.pageX, AdsSpace.s32 + bottom),
                child: footer,
              ),
            ),
        ],
      ),
    );
  }
}

class _SheetClose extends StatelessWidget {
  const _SheetClose({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      excludeSemantics: true,
      child: AdsTappable(
        onTap: onTap,
        builder: (BuildContext context, AdsStates st) => AdsFocusRing(
          visible: st.focused,
          radius: AdsRadius.r8,
          offset: -2,
          child: Container(
            width: AdsSpace.tapMin,
            height: AdsSpace.tapMin,
            decoration: BoxDecoration(
              color: st.pressed ? AdsColors.light300 : const Color(0x00000000),
              borderRadius: BorderRadius.circular(AdsRadius.r8),
            ),
            child: const Center(child: AdsIcon('close-lg', size: 24, color: AdsColors.dark300)),
          ),
        ),
      ),
    );
  }
}
