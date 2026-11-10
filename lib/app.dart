import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'screens/intro_screen.dart';
import 'services/sound_service.dart';
import 'state/settings_controller.dart';
import 'state/tool_shortcuts.dart';
import 'strings.dart';
import 'theme/app_theme.dart';

class RandomixApp extends StatelessWidget {
  const RandomixApp({super.key, required this.settings, this.systemSeed});

  final SettingsController settings;
  final Color? systemSeed;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ToolShortcuts>(create: (_) => ToolShortcuts()),
        Provider<SoundController>(
          create: (_) => SoundController(settings),
          dispose: (_, controller) => controller.dispose(),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, s, _) => MaterialApp(
          title: S.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: s.accent,
            amoled: s.amoled,
            systemSeed: systemSeed,
          ),
          darkTheme: AppTheme.build(
            brightness: Brightness.dark,
            accent: s.accent,
            amoled: s.amoled,
            systemSeed: systemSeed,
          ),
          themeMode: switch (s.themeMode) {
            AppThemeMode.system => ThemeMode.system,
            AppThemeMode.dark => ThemeMode.dark,
            AppThemeMode.light => ThemeMode.light,
          },
          home: s.introSeen ? const HomeShell() : const IntroScreen(),
        ),
      ),
    );
  }
}
