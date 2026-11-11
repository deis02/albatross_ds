import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'tokens.g.dart';

/// Line (default) or solid icon set.
enum AdsIconStyle { line, solid }

/// An icon from the Albatross icon set.
///
/// The package bundles only the icons its widgets use (checkmark, chevron-down,
/// close-sm, close-lg, eye, eye-off, info). For any other icon, add the SVG from
/// https://stat.chara.id/swing/ds/icon.html to your app and pass your own widget
/// (for example `SvgPicture.asset(...)`) to the `icon` slot of a component.
///
/// Size and colour come from the nearest [IconTheme] unless given here, so the
/// components can size and tint whatever icon widget you pass them.
class AdsIcon extends StatelessWidget {
  const AdsIcon(this.name, {super.key, this.style = AdsIconStyle.line, this.size, this.color});

  /// File name without `.svg`, as listed on the DS Icon page.
  final String name;
  final AdsIconStyle style;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final IconThemeData theme = IconTheme.of(context);
    final double s = size ?? theme.size ?? 24;
    final Color c = color ?? theme.color ?? AdsColors.dark500;
    return SvgPicture.asset(
      'assets/icons/${style.name}/$name.svg',
      package: 'albatross_ds',
      width: s,
      height: s,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}

/// Puts [child] (any icon widget) at [size] and [color].
Widget adsIconSlot(Widget child, {required double size, required Color color}) {
  return IconTheme.merge(
    data: IconThemeData(size: size, color: color),
    child: SizedBox(width: size, height: size, child: Center(child: child)),
  );
}
