/// Sound effects, the desktop equivalent of the upstream `playSound`.
library;

import 'package:audioplayers/audioplayers.dart';

import '../state/settings_controller.dart';

enum SoundId {
  roulette('sounds/roulette.mp3'),
  coin('sounds/coin.wav'),
  magicball('sounds/magicball.mp3'),
  dice('sounds/dice.wav');

  const SoundId(this.asset);

  final String asset;
}

class SoundController {
  SoundController(this._settings);

  final SettingsController _settings;
  final Map<SoundId, AudioPlayer> _players = {};
  bool _unavailable = false;

  /// True when the platform audio plugin could not be used; the settings
  /// screen shows a note instead of pretending the toggle works.
  bool get unavailable => _unavailable;

  Future<void> play(SoundId id) async {
    if (!_settings.sound || _unavailable) return;
    try {
      final player = _players.putIfAbsent(id, () => AudioPlayer());
      await player.stop();
      await player.play(AssetSource(id.asset));
    } catch (_) {
      // Audio is a nicety: never let a missing backend break the app.
      _unavailable = true;
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
