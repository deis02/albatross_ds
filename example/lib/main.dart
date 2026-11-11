import 'package:albatross_ds/albatross_ds.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albatross DS · Flutter',
      debugShowCheckedModeBanner: false,
      theme: AdsTheme.light(),
      home: const GalleryPage(),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  int _tab = 0;
  int _tabS = 0;
  bool _busy = false;
  bool? _caddie = true;
  bool? _cart = false;
  int _holes = 18;
  String? _city;
  final Set<String> _sports = <String>{'Golf'};
  final List<String> _picked = <String>['Bali', 'Bandung'];

  void _toast(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m), duration: const Duration(milliseconds: 1200)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Albatross DS · Flutter')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AdsSpace.pageX, AdsSpace.pageTop, AdsSpace.pageX, AdsSpace.pageBottom),
            children: <Widget>[
              Text('Tahap 1: Button, IconButton, Text field, Select, Tag, Checkbox, Radio, Tabs. Token dari tokens.css.',
                  style: AdsType.b2.copyWith(color: AdsColors.dark300)),
              const _Section('Button'),
              AdsButton(label: 'Pay for me', block: true, onPressed: () => _toast('Pay')),
              const SizedBox(height: AdsSpace.s12),
              Wrap(spacing: AdsSpace.s8, runSpacing: AdsSpace.s8, children: <Widget>[
                AdsButton(label: 'Add a player', appearance: AdsButtonAppearance.soft, size: AdsButtonSize.m, onPressed: () => _toast('Add')),
                AdsButton(label: 'Cancel', tone: AdsButtonTone.neutral, appearance: AdsButtonAppearance.soft, size: AdsButtonSize.m, onPressed: () {}),
                AdsButton(label: 'Cancel booking', tone: AdsButtonTone.danger, size: AdsButtonSize.m, onPressed: () {}),
                AdsButton(label: 'Change', appearance: AdsButtonAppearance.ghost, size: AdsButtonSize.s, onPressed: () {}),
                AdsButton(label: 'Share', icon: const AdsIcon('info'), size: AdsButtonSize.s, onPressed: () {}),
                const AdsButton(label: 'Disabled', size: AdsButtonSize.m),
              ]),
              const SizedBox(height: AdsSpace.s12),
              AdsButton(
                label: _busy ? 'Processing payment…' : 'Tap to load',
                loading: _busy,
                block: true,
                onPressed: () {
                  setState(() => _busy = true);
                  Future<void>.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _busy = false);
                  });
                },
              ),
              const SizedBox(height: AdsSpace.s12),
              AdsButtonPair(
                secondary: AdsButton(label: 'Cancel', tone: AdsButtonTone.neutral, appearance: AdsButtonAppearance.soft, onPressed: () {}),
                primary: AdsButton(label: 'Confirm', onPressed: () {}),
              ),
              const _Section('Glow'),
              Container(
                padding: const EdgeInsets.all(AdsSpace.s24),
                decoration: BoxDecoration(gradient: AdsGradients.purple, borderRadius: BorderRadius.circular(AdsRadius.r16)),
                child: Row(children: <Widget>[
                  AdsButton.glow(label: 'Get Swing Pass', onPressed: () => _toast('Glow')),
                  const SizedBox(width: AdsSpace.s8),
                  const AdsButton.glow(label: 'Disabled'),
                ]),
              ),
              const SizedBox(height: AdsSpace.s12),
              Container(
                padding: const EdgeInsets.all(AdsSpace.s24),
                decoration: BoxDecoration(color: AdsColors.light200, borderRadius: BorderRadius.circular(AdsRadius.r16)),
                child: Row(children: <Widget>[AdsButton.glow(label: 'Get Swing Pass', purple: true, onPressed: () {})]),
              ),
              const _Section('Featured promo'),
              AdsFeaturedPromo(title: 'Rp 999,000 · Sun & PH PM Deal at Suvarna Jakarta Golf Club', onTap: () => _toast('Deal')),
              const SizedBox(height: AdsSpace.s12),
              AdsFeaturedPromo(
                title: 'Rp 1,250,000 · Weekday morning 18 holes, caddie and cart included, at Pondok Indah Golf Course',
                onTap: () => _toast('Deal'),
              ),
              const SizedBox(height: AdsSpace.s12),
              AdsFeaturedPromo(title: 'Rp 999,000 · Sun & PH PM Deal at Suvarna Jakarta Golf Club', claimed: true, onTap: () => _toast('Deal')),
              const _Section('Cashback table'),
              Text('Play more to earn more with Swing Credits at Suvarna Jakarta Golf Club', style: AdsType.h4.copyWith(color: AdsColors.dark500)),
              const SizedBox(height: AdsSpace.s24),
              const AdsCashbackTable(rows: <AdsCashbackRow>[
                AdsCashbackRow(day: 'Mon - Fri', time: '05:00 - 12:00', regular: '10%', pass: '50%'),
                AdsCashbackRow(day: 'Mon - Fri', time: '12:00 - 20:00', regular: '8%', pass: '40%'),
                AdsCashbackRow(day: 'Sat - Sun', time: '05:00 - 20:00', regular: '8%', pass: '40%'),
              ]),
              const _Section('Icon button'),
              Wrap(spacing: AdsSpace.s8, children: <Widget>[
                AdsIconButton(icon: const AdsIcon('info'), semanticLabel: 'Info', onPressed: () {}),
                AdsIconButton(icon: const AdsIcon('info'), semanticLabel: 'Info', appearance: AdsButtonAppearance.soft, onPressed: () {}),
                AdsIconButton(icon: const AdsIcon('close-lg'), semanticLabel: 'Close', tone: AdsButtonTone.neutral, appearance: AdsButtonAppearance.ghost, onPressed: () {}),
                AdsIconButton(icon: const AdsIcon('info'), semanticLabel: 'Info', size: AdsButtonSize.m, onPressed: () {}),
              ]),
              const _Section('Text field'),
              const AdsTextField(
                label: 'Email',
                placeholder: 'name@email.com',
                help: 'We send the receipt here',
                helpIcon: AdsIcon('info'),
                keyboardType: TextInputType.emailAddress,
                clearable: true,
              ),
              const SizedBox(height: AdsSpace.gapGroup),
              const AdsTextField(label: 'Password', obscureText: true),
              const SizedBox(height: AdsSpace.gapGroup),
              const AdsTextField(label: 'Amount', prefixText: 'Rp', keyboardType: TextInputType.number),
              const SizedBox(height: AdsSpace.gapGroup),
              const AdsTextField(label: 'Phone', status: AdsFieldStatus.error, help: 'Use the number on your account', helpIcon: AdsIcon('info')),
              const SizedBox(height: AdsSpace.gapGroup),
              const AdsTextField(label: 'Note for the club', multiline: true, maxLength: 200),
              const SizedBox(height: AdsSpace.gapGroup),
              const AdsTextField(label: 'Member ID', enabled: false),
              const _Section('Select'),
              AdsSelect<String>(
                label: 'City',
                value: _city,
                options: const <AdsOption<String>>[
                  AdsOption<String>(value: 'jkt', label: 'Jakarta', hint: '12 courses'),
                  AdsOption<String>(value: 'bdg', label: 'Bandung', hint: '6 courses'),
                  AdsOption<String>(value: 'bali', label: 'Bali', hint: '9 courses'),
                  AdsOption<String>(value: 'sby', label: 'Surabaya', enabled: false, hint: 'Coming soon'),
                ],
                onChanged: (String v) => setState(() => _city = v),
              ),
              const SizedBox(height: AdsSpace.gapGroup),
              const AdsSelect<String>(label: 'Club', options: <AdsOption<String>>[]),
              const _Section('Tag'),
              AdsTagGroup(children: <Widget>[
                for (final String s in <String>['Golf', 'Padel', 'Tennis', 'Running'])
                  AdsTag(
                    label: s,
                    selected: _sports.contains(s),
                    onChanged: (bool on) => setState(() => on ? _sports.add(s) : _sports.remove(s)),
                  ),
              ]),
              const SizedBox(height: AdsSpace.s12),
              AdsTagGroup(children: <Widget>[
                for (final String p in _picked)
                  AdsTag(label: p, selected: true, tone: AdsTagTone.primary, onRemove: () => setState(() => _picked.remove(p))),
                AdsTag(label: 'Price', trailingIcon: const AdsIcon('chevron-down'), onTap: () => _toast('Price sheet')),
              ]),
              const SizedBox(height: AdsSpace.s12),
              const AdsTagGroup(children: <Widget>[
                AdsTag(label: 'Teal', tone: AdsTagTone.teal, size: AdsTagSize.s),
                AdsTag(label: 'Pink', tone: AdsTagTone.pink, size: AdsTagSize.s),
                AdsTag(label: 'Orange', tone: AdsTagTone.orange, size: AdsTagSize.s),
                AdsTag(label: 'Green', tone: AdsTagTone.green, size: AdsTagSize.s),
                AdsTag(label: 'Red', tone: AdsTagTone.red, size: AdsTagSize.s),
                AdsTag(label: 'Off', enabled: false, size: AdsTagSize.s),
              ]),
              const _Section('Checkbox'),
              AdsCheckTile(label: 'Caddie', hint: 'One caddie per player', meta: 'Rp150k', value: _caddie, onChanged: (bool? v) => setState(() => _caddie = v)),
              AdsCheckTile(label: 'Golf cart', value: _cart, onChanged: (bool? v) => setState(() => _cart = v)),
              const AdsCheckTile(label: 'Locker (sold out)', value: false, onChanged: null),
              const SizedBox(height: AdsSpace.s8),
              AdsCheckTile(label: 'Rental clubs', hint: 'Callaway set, right hand', card: true, value: _cart, onChanged: (bool? v) => setState(() => _cart = v)),
              const SizedBox(height: AdsSpace.s8),
              Row(children: <Widget>[
                AdsCheckbox(value: true, onChanged: (bool? v) {}, semanticLabel: 'On'),
                const SizedBox(width: AdsSpace.s16),
                AdsCheckbox(value: null, onChanged: (bool? v) {}, semanticLabel: 'Mixed'),
                const SizedBox(width: AdsSpace.s16),
                AdsCheckbox(value: false, error: true, onChanged: (bool? v) {}, semanticLabel: 'Error'),
                const SizedBox(width: AdsSpace.s16),
                const AdsCheckbox(value: true, onChanged: null, semanticLabel: 'Disabled'),
              ]),
              const _Section('Radio'),
              for (final int h in <int>[9, 18])
                AdsRadioTile<int>(label: '$h holes', hint: h == 9 ? 'About 2 hours' : 'About 4 hours', value: h, groupValue: _holes, onChanged: (int v) => setState(() => _holes = v)),
              const SizedBox(height: AdsSpace.s8),
              AdsRadioTile<int>(label: '27 holes', hint: 'Two courses', card: true, value: 27, groupValue: _holes, onChanged: (int v) => setState(() => _holes = v)),
              const _Section('Tabs'),
              AdsTabs(
                tabs: const <AdsTabItem>[AdsTabItem(label: 'Reservations'), AdsTabItem(label: 'History')],
                selectedIndex: _tab,
                onChanged: (int i) => setState(() => _tab = i),
                fixed: true,
                flush: true,
              ),
              const SizedBox(height: AdsSpace.gapGroup),
              AdsTabs(
                tabs: const <AdsTabItem>[
                  AdsTabItem(label: 'All'),
                  AdsTabItem(label: 'Golf'),
                  AdsTabItem(label: 'Padel'),
                  AdsTabItem(label: 'Tennis'),
                  AdsTabItem(label: 'Closed', enabled: false),
                ],
                selectedIndex: _tabS,
                onChanged: (int i) => setState(() => _tabS = i),
                small: true,
                flush: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AdsSpace.gapSection, bottom: AdsSpace.s12),
      child: Text(title, style: AdsType.h5.copyWith(color: AdsColors.dark300)),
    );
  }
}
