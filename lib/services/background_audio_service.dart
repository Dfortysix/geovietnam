import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'settings_service.dart';

class BackgroundAudioService {
  static final BackgroundAudioService _instance = BackgroundAudioService._internal();
  factory BackgroundAudioService() => _instance;
  BackgroundAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setSource(AssetSource('audio/theme.mp3'));

    final volume = await SettingsService().getMusicVolume();
    await _player.setVolume(volume);

    final enabled = await SettingsService().isSoundEnabled();
    if (enabled) {
      await _safePlay();
    }
  }

  Future<void> _safePlay() async {
    try {
      await _player.resume();
    } catch (_) {}
  }

  Future<void> play() async {
    await init();
    await _safePlay();
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    await SettingsService().setSoundEnabled(enabled);
    if (enabled) {
      await play();
    } else {
      await pause();
    }
  }

  Future<void> setVolume(double volume) async {
    await SettingsService().setMusicVolume(volume);
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}
