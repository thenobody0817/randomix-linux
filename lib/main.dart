import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'state/prefs.dart';
import 'state/settings_controller.dart';
import 'theme/accent_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PrefsStore store;
  try {
    store = SharedPrefsStore(await SharedPreferences.getInstance());
  } catch (_) {
    // A broken prefs backend should not stop the dice from rolling.
    store = MemoryPrefsStore();
  }

  final settings = SettingsController(store);
  final systemSeed = await SystemAccent.detect();

  runApp(
    MultiProvider(
      providers: [
        Provider<PrefsStore>.value(value: store),
        ChangeNotifierProvider<SettingsController>.value(value: settings),
      ],
      child: RandomixApp(settings: settings, systemSeed: systemSeed),
    ),
  );
}
