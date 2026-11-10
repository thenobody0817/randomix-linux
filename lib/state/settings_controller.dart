/// App-wide settings, with the same preference keys and defaults as the
/// Android app so behaviour is recognisable to upstream users.
library;

import 'package:flutter/foundation.dart';

import '../core/dice_roller.dart';
import '../theme/accent_colors.dart';
import 'prefs.dart';

enum AppThemeMode {
  system('system'),
  dark('dark'),
  light('light');

  const AppThemeMode(this.id);

  final String id;

  static AppThemeMode fromId(String? id) => AppThemeMode.values.firstWhere(
    (m) => m.id == id,
    orElse: () => AppThemeMode.system,
  );
}

/// Preference keys. Upstream names are preserved where they still make sense.
class K {
  const K._();

  static const first = 'first';
  static const lastPage = 'last_page';
  static const lastPageSettings = 'last_page_settings';
  static const themeColor = 'theme_color';
  static const amoledDark = 'amoled_dark';
  static const accentColor = 'accent_color';
  static const blob = 'blob';
  static const sound = 'sound';
  static const hideDescriptions = 'hide_descriptions';
  static const allowEquals = 'allow_equals';
  static const removeLast = 'remove_last';
  static const rudeAnswers = 'rude_answers';
  static const customAnswers = 'custom_answers';
  static const customAnswersActive = 'custom_answers_active';
  static const rouletteRangeMode = 'roulette_range_mode';
  static const rouletteRangeMin = 'roulette_range_min';
  static const rouletteRangeMax = 'roulette_range_max';
  static const rouletteOptions = 'roulette_options';
  static const recent = 'recent';
  static const diceType = 'ud_dice_type';
  static const diceCount = 'ud_dice_count';
}

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    _load();
  }

  final PrefsStore _prefs;

  // Defaults mirror the upstream preferences.xml.
  AppThemeMode themeMode = AppThemeMode.system;
  bool amoled = false;
  Accent accent = Accent.blue;
  bool blob = true;
  bool sound = false;
  bool hideDescriptions = false;
  bool allowEquals = false;
  bool removeLast = false;
  bool rudeAnswers = false;
  bool customAnswersActive = false;
  String customAnswers = '';
  String lastPage = 'roulette';
  bool lastPageSettings = false;
  bool introSeen = false;

  void _load() {
    introSeen = _prefs.getBool(K.first);
    themeMode = AppThemeMode.fromId(_prefs.getString(K.themeColor));
    amoled = _prefs.getBool(K.amoledDark);
    accent = Accent.fromId(_prefs.getString(K.accentColor));
    blob = _prefs.getBool(K.blob, defaultValue: true);
    sound = _prefs.getBool(K.sound);
    hideDescriptions = _prefs.getBool(K.hideDescriptions);
    allowEquals = _prefs.getBool(K.allowEquals);
    removeLast = _prefs.getBool(K.removeLast);
    rudeAnswers = _prefs.getBool(K.rudeAnswers);
    customAnswersActive = _prefs.getBool(K.customAnswersActive);
    customAnswers = _prefs.getString(K.customAnswers) ?? '';
    lastPage = _prefs.getString(K.lastPage) ?? 'roulette';
    lastPageSettings = _prefs.getBool(K.lastPageSettings);
  }

  Future<void> setThemeMode(AppThemeMode value) async {
    if (themeMode == value) return;
    themeMode = value;
    notifyListeners();
    await _prefs.setString(K.themeColor, value.id);
  }

  Future<void> setAmoled(bool value) async {
    if (amoled == value) return;
    amoled = value;
    notifyListeners();
    await _prefs.setBool(K.amoledDark, value);
  }

  Future<void> setAccent(Accent value) async {
    if (accent == value) return;
    accent = value;
    notifyListeners();
    await _prefs.setString(K.accentColor, value.id);
  }

  Future<void> setBlob(bool value) async {
    if (blob == value) return;
    blob = value;
    notifyListeners();
    await _prefs.setBool(K.blob, value);
  }

  Future<void> setSound(bool value) async {
    if (sound == value) return;
    sound = value;
    notifyListeners();
    await _prefs.setBool(K.sound, value);
  }

  Future<void> setHideDescriptions(bool value) async {
    if (hideDescriptions == value) return;
    hideDescriptions = value;
    notifyListeners();
    await _prefs.setBool(K.hideDescriptions, value);
  }

  Future<void> setAllowEquals(bool value) async {
    if (allowEquals == value) return;
    allowEquals = value;
    notifyListeners();
    await _prefs.setBool(K.allowEquals, value);
  }

  Future<void> setRemoveLast(bool value) async {
    if (removeLast == value) return;
    removeLast = value;
    notifyListeners();
    await _prefs.setBool(K.removeLast, value);
  }

  Future<void> setRudeAnswers(bool value) async {
    if (rudeAnswers == value) return;
    rudeAnswers = value;
    notifyListeners();
    await _prefs.setBool(K.rudeAnswers, value);
  }

  Future<void> setCustomAnswersActive(bool value) async {
    if (customAnswersActive == value) return;
    customAnswersActive = value;
    notifyListeners();
    await _prefs.setBool(K.customAnswersActive, value);
  }

  Future<void> setCustomAnswers(String value) async {
    if (customAnswers == value) return;
    customAnswers = value;
    notifyListeners();
    await _prefs.setString(K.customAnswers, value);
  }

  Future<void> setLastPage(String pageKey, {required bool settingsOpen}) async {
    lastPage = pageKey;
    lastPageSettings = settingsOpen;
    await _prefs.setString(K.lastPage, pageKey);
    await _prefs.setBool(K.lastPageSettings, settingsOpen);
  }

  Future<void> markIntroSeen() async {
    introSeen = true;
    notifyListeners();
    await _prefs.setBool(K.first, true);
  }

  /// Shows the introduction again from the settings.
  Future<void> resetIntro() async {
    introSeen = false;
    notifyListeners();
    await _prefs.remove(K.first);
  }

  Future<void> reset() async {
    themeMode = AppThemeMode.system;
    amoled = false;
    accent = Accent.blue;
    blob = true;
    sound = false;
    hideDescriptions = false;
    allowEquals = false;
    removeLast = false;
    rudeAnswers = false;
    customAnswersActive = false;
    customAnswers = '';
    notifyListeners();
    await _prefs.remove(K.themeColor);
    await _prefs.remove(K.amoledDark);
    await _prefs.remove(K.accentColor);
    await _prefs.remove(K.blob);
    await _prefs.remove(K.sound);
    await _prefs.remove(K.hideDescriptions);
    await _prefs.remove(K.allowEquals);
    await _prefs.remove(K.removeLast);
    await _prefs.remove(K.rudeAnswers);
    await _prefs.remove(K.customAnswers);
    await _prefs.remove(K.customAnswersActive);
  }

  /// Dice defaults come from the upstream preference file.
  DiceType get diceType => DiceType.fromName(_prefs.getString(K.diceType));

  int get diceCount => _prefs.getInt(K.diceCount, defaultValue: 1);

  Future<void> setDiceType(DiceType type) =>
      _prefs.setString(K.diceType, type.name);

  Future<void> setDiceCount(int count) => _prefs.setInt(K.diceCount, count);
}
