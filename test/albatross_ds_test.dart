import 'package:albatross_ds/albatross_ds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(
      theme: AdsTheme.light(),
      home: Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: child))),
    );

Size _boxOf(WidgetTester t, String text) =>
    t.getSize(find.ancestor(of: find.text(text), matching: find.byType(AnimatedContainer)).first);

void main() {
  test('tokens match tokens.css', () {
    expect(AdsColors.purple500, const Color(0xFF5C00E6));
    expect(AdsColors.dark500, const Color(0xFF1C1C28));
    expect(AdsSpace.pageX, 24);
    expect(AdsSpace.s16, 16);
    expect(AdsRadius.r8, 8);
    expect(AdsOpacity.o40, 0.4);
    expect(AdsType.b1.fontSize, 14);
    expect(AdsType.b1.height! * 14, closeTo(22, 0.01));
    expect(AdsParagraph.b1, 12);
  });

  testWidgets('button taps, disabled does not', (WidgetTester t) async {
    int n = 0;
    await t.pumpWidget(_app(Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      AdsButton(label: 'Pay for me', onPressed: () => n++),
      const AdsButton(label: 'Off'),
    ])));
    await t.tap(find.text('Pay for me'));
    expect(n, 1);
    await t.tap(find.text('Off'), warnIfMissed: false);
    expect(n, 1);
  });

  testWidgets('button sizes have the DS heights', (WidgetTester t) async {
    void noop() {}
    await t.pumpWidget(_app(Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      AdsButton(label: 'XL', size: AdsButtonSize.xl, onPressed: noop),
      AdsButton(label: 'L', onPressed: noop),
      AdsButton(label: 'M', size: AdsButtonSize.m, onPressed: noop),
      AdsButton(label: 'S', size: AdsButtonSize.s, onPressed: noop),
      AdsButton(label: 'XS', size: AdsButtonSize.xs, onPressed: noop),
    ])));
    expect(_boxOf(t, 'XL').height, 56);
    expect(_boxOf(t, 'L').height, 48);
    expect(_boxOf(t, 'M').height, 40);
    expect(_boxOf(t, 'S').height, 32);
    expect(_boxOf(t, 'XS').height, 24);
  });

  testWidgets('loading button keeps its label and ignores taps', (WidgetTester t) async {
    int n = 0;
    await t.pumpWidget(_app(AdsButton(label: 'Processing payment', loading: true, onPressed: () => n++)));
    await t.tap(find.text('Processing payment'));
    await t.pump(const Duration(milliseconds: 300));
    expect(n, 0);
    expect(find.byType(AdsBusy), findsOneWidget);
  });

  testWidgets('glow button hugs to 44 and its ring runs', (WidgetTester t) async {
    await t.pumpWidget(_app(Container(
      color: AdsColors.purple500,
      padding: const EdgeInsets.all(16),
      child: AdsButton.glow(label: 'Get Swing Pass', onPressed: () {}),
    )));
    await t.pump(const Duration(milliseconds: 1000));
    expect(_boxOf(t, 'Get Swing Pass').height, 44);
    expect(t.takeException(), isNull);
  });

  testWidgets('icon button is square', (WidgetTester t) async {
    await t.pumpWidget(_app(AdsIconButton(icon: const AdsIcon('info'), semanticLabel: 'Info', onPressed: () {})));
    final Size s = t.getSize(find.byType(AnimatedContainer).first);
    expect(s.width, 48);
    expect(s.height, 48);
  });

  testWidgets('text field takes text and counts', (WidgetTester t) async {
    final TextEditingController c = TextEditingController();
    await t.pumpWidget(_app(AdsTextField(label: 'Email', controller: c, maxLength: 40, clearable: true)));
    await t.enterText(find.byType(TextField), 'ghais@swing.id');
    await t.pumpAndSettle();
    expect(c.text, 'ghais@swing.id');
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('14/40'), findsOneWidget);
  });

  testWidgets('select opens the sheet and returns the pick', (WidgetTester t) async {
    String? city;
    await t.pumpWidget(_app(StatefulBuilder(
      builder: (BuildContext context, StateSetter set) => AdsSelect<String>(
        label: 'City',
        value: city,
        options: const <AdsOption<String>>[
          AdsOption<String>(value: 'jkt', label: 'Jakarta'),
          AdsOption<String>(value: 'bdg', label: 'Bandung'),
        ],
        onChanged: (String v) => set(() => city = v),
      ),
    )));
    await t.tap(find.text('City'));
    await t.pumpAndSettle();
    expect(find.text('Jakarta'), findsOneWidget);
    await t.tap(find.text('Bandung'));
    await t.pumpAndSettle();
    expect(city, 'bdg');
    expect(find.text('Bandung'), findsOneWidget);
  });

  testWidgets('checkbox toggles, mixed goes to ticked', (WidgetTester t) async {
    bool? v = false;
    bool? all;
    await t.pumpWidget(_app(StatefulBuilder(
      builder: (BuildContext context, StateSetter set) => Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        AdsCheckTile(label: 'Caddie', value: v, onChanged: (bool? x) => set(() => v = x)),
        AdsCheckbox(value: all, onChanged: (bool? x) => set(() => all = x), semanticLabel: 'All'),
      ]),
    )));
    await t.tap(find.text('Caddie'));
    await t.pumpAndSettle();
    expect(v, isTrue);
    await t.tap(find.byType(AdsCheckbox));
    await t.pumpAndSettle();
    expect(all, isTrue);
  });

  testWidgets('radio picks its value', (WidgetTester t) async {
    int holes = 9;
    await t.pumpWidget(_app(StatefulBuilder(
      builder: (BuildContext context, StateSetter set) => Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        AdsRadioTile<int>(label: '9 holes', value: 9, groupValue: holes, onChanged: (int x) => set(() => holes = x)),
        AdsRadioTile<int>(label: '18 holes', value: 18, groupValue: holes, onChanged: (int x) => set(() => holes = x), card: true),
      ]),
    )));
    await t.tap(find.text('18 holes'));
    await t.pumpAndSettle();
    expect(holes, 18);
  });

  testWidgets('tag toggles and removes', (WidgetTester t) async {
    bool golf = false;
    int removed = 0;
    await t.pumpWidget(_app(StatefulBuilder(
      builder: (BuildContext context, StateSetter set) => AdsTagGroup(children: <Widget>[
        AdsTag(label: 'Golf', selected: golf, onChanged: (bool x) => set(() => golf = x)),
        AdsTag(label: 'Bali', selected: true, tone: AdsTagTone.primary, onRemove: () => removed++),
        const AdsTag(label: 'Off', enabled: false),
      ]),
    )));
    await t.tap(find.text('Golf'));
    await t.pumpAndSettle();
    expect(golf, isTrue);
    await t.tap(find.byWidgetPredicate((Widget w) => w is Semantics && w.properties.label == 'Remove Bali'));
    expect(removed, 1);
  });

  testWidgets('tabs report the tapped index', (WidgetTester t) async {
    int tab = 0;
    await t.pumpWidget(_app(StatefulBuilder(
      builder: (BuildContext context, StateSetter set) => Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        AdsTabs(
          tabs: const <AdsTabItem>[AdsTabItem(label: 'Reservations'), AdsTabItem(label: 'History')],
          selectedIndex: tab,
          onChanged: (int i) => set(() => tab = i),
          fixed: true,
        ),
        AdsTabs(
          tabs: const <AdsTabItem>[AdsTabItem(label: 'All'), AdsTabItem(label: 'Golf'), AdsTabItem(label: 'Padel')],
          selectedIndex: 0,
          onChanged: (int i) {},
          small: true,
        ),
      ]),
    )));
    await t.tap(find.text('History'));
    await t.pumpAndSettle();
    expect(tab, 1);
  });
}
