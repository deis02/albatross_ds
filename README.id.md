# albatross_ds

Albatross, design system Swing, versi Flutter. Versi web-nya ada di https://stat.chara.id/swing/ds/ dan itu yang jadi acuan. Token di-generate dari `tokens.css` di sana, dan tiap widget ngikutin `components.css`.

English: [README.md](README.md)

## Status: tahap 1

| Udah ada | Masuk tahap 2 |
|---|---|
| Token (warna, spacing, radius, opacity, type, paragraph spacing, elevation) | Badge, Bottom navigation, Card, Divider, Date & time, List, Loading (Swing loader), Modal, Page header, Pagination, PIN, Rating, Search, Slider, Stepper, Toaster, Tooltip |
| `AdsButton` (termasuk `AdsButton.glow`), `AdsIconButton`, `AdsButtonPair` | |
| `AdsTextField`, `AdsSelect` + `showAdsOptionsSheet`, `showAdsSheet` | |
| `AdsTag`, `AdsTagGroup`, `AdsCheckbox`, `AdsCheckTile`, `AdsRadio`, `AdsRadioTile`, `AdsTabs` | |

Gallery (build Flutter web dari `example/`): https://deis02.github.io/albatross_ds/

## Pasang

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

Package ini udah bawa font Manrope (variable, lisensi OFL) dan beberapa ikon yang dipakai widget-nya. Buat ikon lain, copy SVG-nya dari halaman Icon di DS ke app lo, terus kasih widget-nya ke slot `icon`.

## Cara pakai

```dart
AdsButton(label: 'Pay for me', onPressed: pay)
AdsButton(label: 'Add a player', appearance: AdsButtonAppearance.soft, size: AdsButtonSize.m, onPressed: add)
AdsButton.glow(label: 'Get Swing Pass', onPressed: open)            // di atas ungu atau foto
AdsIconButton(icon: const AdsIcon('info'), semanticLabel: 'Info', onPressed: info)

AdsTextField(label: 'Email', placeholder: 'name@email.com', help: 'We send the receipt here')
AdsSelect<String>(label: 'City', value: city, options: cities, onChanged: (v) => setState(() => city = v))

AdsTag(label: 'Golf', selected: golf, onChanged: (v) => setState(() => golf = v))
AdsCheckTile(label: 'Caddie', value: caddie, onChanged: (v) => setState(() => caddie = v!))
AdsRadioTile<int>(label: '18 holes', value: 18, groupValue: holes, onChanged: (v) => setState(() => holes = v))
AdsTabs(tabs: const [AdsTabItem(label: 'Reservations'), AdsTabItem(label: 'History')], selectedIndex: tab, onChanged: (i) => setState(() => tab = i), fixed: true)
```

Nama token ngikutin nama CSS-nya: `--purple-500` → `AdsColors.purple500`, `--space-16` → `AdsSpace.s16`, `--page-x` → `AdsSpace.pageX`, `--radius-8` → `AdsRadius.r8`, `--type-b1s` → `AdsType.b1s`, `--type-b1-para` → `AdsParagraph.b1`, `--opacity-40` → `AdsOpacity.o40`, `--elevation-1` → `AdsElevation.e1`.

## Update token

`lib/src/tokens.g.dart` itu hasil generate. Kalau `tokens.css` di situs DS berubah:

```bash
node tool/gen_tokens.js          # baca https://stat.chara.id/swing/ds/tokens.css
```

CI jalanin script yang sama tiap push, dan ngasih warning kalau file di repo ketinggalan dari situs.

## Bedanya sama versi web

- Flutter nggak punya inset shadow, jadi garis tepi digambar sebagai border di atas kotaknya. Tampilannya sama, isinya nggak geser.
- Area jari 48px yang ditambahin CSS di sekitar Button S/XS dan Tag nggak ada di sini. Taruh komponen itu di baris yang tingginya minimal 44.
- Loading pakai busur sederhana dulu sampai Swing loader masuk bareng komponen Loading.
- Label (`AdsType.lblL`, `AdsType.lblS`) selalu huruf kapital: panggil `.toUpperCase()` di teksnya.

## Development

```bash
flutter pub get && (cd example && flutter pub get)
flutter analyze --no-fatal-infos
flutter test
cd example && flutter run -d chrome
```
