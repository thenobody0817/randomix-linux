import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randomix/core/spin_style.dart';
import 'package:randomix/screens/settings_screen.dart';
import 'package:randomix/state/settings_controller.dart';
import 'package:randomix/strings.dart';
import 'package:randomix/theme/accent_colors.dart';

import 'helpers.dart';

void main() {
  testWidgets('toggles persist through the preference store', (tester) async {
    setSurface(tester, size: const Size(900, 2400));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const SettingsScreen()));
    await tester.pump();

    await tester.tap(
      find.widgetWithText(SwitchListTile, S.hideDescriptionsName),
    );
    await tester.pump();

    expect(harness.settings.hideDescriptions, isTrue);
    expect(harness.store.getBool('hide_descriptions'), isTrue);

    await tester.tap(find.widgetWithText(SwitchListTile, S.allowEqualsName));
    await tester.pump();
    expect(harness.store.getBool('allow_equals'), isTrue);
  });

  testWidgets('changing the theme and the accent applies immediately', (
    tester,
  ) async {
    setSurface(tester, size: const Size(900, 2400));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const SettingsScreen()));
    await tester.pump();

    await tester.tap(find.text(S.themeDark));
    await tester.pump();
    expect(harness.settings.themeMode, AppThemeMode.dark);
    expect(harness.store.getString('theme_color'), 'dark');

    await tester.tap(find.byTooltip(S.violet));
    await tester.pump();
    expect(harness.settings.accent, Accent.violet);
    expect(harness.store.getString('accent_color'), 'violet');
  });

  testWidgets('the roulette spin style can be changed', (tester) async {
    setSurface(tester, size: const Size(900, 2600));
    final harness = TestHarness();

    await tester.pumpWidget(harness.wrap(const SettingsScreen()));
    await tester.pump();

    expect(harness.settings.spinStyle, RouletteSpinStyle.wheel);

    await tester.tap(find.text(S.spinStyleCoverflow));
    await tester.pump();

    expect(harness.settings.spinStyle, RouletteSpinStyle.coverflow);
    expect(harness.store.getString('spin_style'), 'coverflow');

    await tester.tap(find.text(S.spinStyleChips));
    await tester.pump();
    expect(harness.store.getString('spin_style'), 'chips');
  });

  testWidgets('reset restores the defaults after confirmation', (tester) async {
    setSurface(tester, size: const Size(900, 2800));
    final harness = TestHarness({
      'hide_descriptions': true,
      'accent_color': 'crimson',
      'allow_equals': true,
      'spin_style': 'chips',
    });

    await tester.pumpWidget(harness.wrap(const SettingsScreen()));
    await tester.pump();

    expect(harness.settings.hideDescriptions, isTrue);

    await tester.scrollUntilVisible(find.text(S.resetSettings).last, 200);
    await tester.tap(find.text(S.resetSettings).last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, S.resetSettings));
    // The reset re-enables the blob background, which animates forever, so
    // settle a few frames by hand instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(harness.settings.hideDescriptions, isFalse);
    expect(harness.settings.allowEquals, isFalse);
    expect(harness.settings.accent, Accent.blue);
    expect(harness.settings.spinStyle, RouletteSpinStyle.wheel);
    await tester.pump(const Duration(seconds: 5));
  });
}
