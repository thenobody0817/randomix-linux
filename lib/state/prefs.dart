/// Persistence abstraction so logic and widgets can be tested without the
/// platform plugin, plus the shared-preferences implementation used by the app.
library;

import 'package:shared_preferences/shared_preferences.dart';

abstract class PrefsStore {
  String? getString(String key);
  bool getBool(String key, {bool defaultValue = false});
  int getInt(String key, {int defaultValue = 0});
  List<String>? getStringList(String key);

  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
}

class SharedPrefsStore implements PrefsStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  @override
  int getInt(String key, {int defaultValue = 0}) =>
      _prefs.getInt(key) ?? defaultValue;

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// In-memory store used by tests and as a fallback if the plugin is missing.
class MemoryPrefsStore implements PrefsStore {
  MemoryPrefsStore([Map<String, Object?>? initial]) : _data = {...?initial};

  final Map<String, Object?> _data;

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  bool getBool(String key, {bool defaultValue = false}) =>
      _data[key] as bool? ?? defaultValue;

  @override
  int getInt(String key, {int defaultValue = 0}) =>
      _data[key] as int? ?? defaultValue;

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> setBool(String key, bool value) async => _data[key] = value;

  @override
  Future<void> setInt(String key, int value) async => _data[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}
