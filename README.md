# albatross_ds

Albatross, the Swing design system, for Flutter. The web version lives at https://stat.chara.id/swing/ds/ and is the source of truth: tokens are generated from its `tokens.css`, and every widget follows its `components.css`.

Bahasa Indonesia: [README.id.md](README.id.md)

## Status: phase 1

| Ready | Coming in phase 2 |
|---|---|
| Tokens (colour, spacing, radius, opacity, type, paragraph spacing, elevation) | Badge, Bottom navigation, Card, Divider, Date & time, List, Loading (Swing loader), Modal, Page header, Pagination, PIN, Rating, Search, Slider, Stepper, Toaster, Tooltip |
| `AdsButton` (incl. `AdsButton.glow`), `AdsIconButton`, `AdsButtonPair` | |
| `AdsTextField`, `AdsSelect` + `showAdsOptionsSheet`, `showAdsSheet` | |
| `AdsTag`, `AdsTagGroup`, `AdsCheckbox`, `AdsCheckTile`, `AdsRadio`, `AdsRadioTile`, `AdsTabs` | |
| `AdsFeaturedPromo`, `AdsSwingPassBackground`, `AdsSwingPassMark` | |

Gallery (Flutter web build of `example/`): https://deis02.github.io/albatross_ds/

## Install

```yaml
# pubspec.yaml
dependencies:
  albatross_ds:
    git:
      url: https://github.com/deis02/albatross_ds
      ref: main
```

```dart
import 'package:albatross_ds/albatross_ds.dart';

MaterialApp(theme: AdsTheme.light(), home: const HomePage());
```

The package ships the Manrope font (variable, OFL) and the few icons its widgets use. For other icons, copy the SVG from the DS Icon page into your app and pass your own widget to the `icon` slot.

## Usage

```dart
AdsButton(label: 'Pay for me', onPressed: pay)
AdsButton(label: 'Add a player', appearance: AdsButtonAppearance.soft, size: AdsButtonSize.m, onPressed: add)
AdsButton.glow(label: 'Get Swing Pass', onPressed: open)            // on purple or photos
AdsIconButton(icon: const AdsIcon('info'), semanticLabel: 'Info', onPressed: info)

AdsTextField(label: 'Email', placeholder: 'name@email.com', help: 'We send the receipt here')
AdsSelect<String>(label: 'City', value: city, options: cities, onChanged: (v) => setState(() => city = v))

AdsTag(label: 'Golf', selected: golf, onChanged: (v) => setState(() => golf = v))
AdsCheckTile(label: 'Caddie', value: caddie, onChanged: (v) => setState(() => caddie = v!))
AdsRadioTile<int>(label: '18 holes', value: 18, groupValue: holes, onChanged: (v) => setState(() => holes = v))
AdsTabs(tabs: const [AdsTabItem(label: 'Reservations'), AdsTabItem(label: 'History')], selectedIndex: tab, onChanged: (i) => setState(() => tab = i), fixed: true)

// tokens
Container(
  padding: const EdgeInsets.all(AdsSpace.insetCard),
  decoration: BoxDecoration(color: AdsColors.light200, borderRadius: BorderRadius.circular(AdsRadius.r12)),
  child: Text('Tee time', style: AdsType.h6.copyWith(color: AdsColors.dark500)),
)
```

Token names follow the CSS names: `--purple-500` → `AdsColors.purple500`, `--space-16` → `AdsSpace.s16`, `--page-x` → `AdsSpace.pageX`, `--radius-8` → `AdsRadius.r8`, `--type-b1s` → `AdsType.b1s`, `--type-b1-para` → `AdsParagraph.b1`, `--opacity-40` → `AdsOpacity.o40`, `--elevation-1` → `AdsElevation.e1`.

## Updating tokens

`lib/src/tokens.g.dart` is generated. When `tokens.css` changes on the DS site:

```bash
node tool/gen_tokens.js          # reads https://stat.chara.id/swing/ds/tokens.css
```

CI runs the same script on every push and warns when the committed file is behind the site.

## What differs from the web

- Flutter has no inset shadow, so rings are drawn as borders on top of the box (same look, nothing moves).
- The 48px finger area that CSS adds around Button S/XS and Tag is not added here; keep those inside a row that is at least 44 tall.
- The loading state uses a simple arc until the Swing loader comes with the Loading component.
- Labels (`AdsType.lblL`, `AdsType.lblS`) are always uppercase: call `.toUpperCase()` on the text.

## Development

```bash
flutter pub get && (cd example && flutter pub get)
flutter analyze --no-fatal-infos
flutter test
cd example && flutter run -d chrome
```
