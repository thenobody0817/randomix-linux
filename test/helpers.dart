import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:randomix/services/sound_service.dart';
import 'package:randomix/state/prefs.dart';
import 'package:randomix/state/settings_controller.dart';
import 'package:randomix/state/tool_shortcuts.dart';
import 'package:randomix/theme/accent_colors.dart';
import 'package:randomix/theme/app_theme.dart';

/// Wires a widget with the same providers the real app uses, backed by an
/// in-memory preference store.
class TestHarness {
  TestHarness([Map<String, Object?>? initial])
    : store = MemoryPrefsStore({
        'blob': false, // keeps animations settled in tests
        ...?initial,
      }) {
    settings = SettingsController(store);
  }

  final MemoryPrefsStore store;
  late final SettingsController settings;
  final ToolShortcuts shortcuts = ToolShortcuts();

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        Provider<PrefsStore>.value(value: store),
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<ToolShortcuts>.value(value: shortcuts),
        Provider<SoundController>(create: (_) => SoundController(settings)),
      ],
      child: MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: Accent.blue,
          amoled: false,
        ),
        home: child,
      ),
    );
  }
}

void setSurface(WidgetTester tester, {Size size = const Size(900, 800)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}
