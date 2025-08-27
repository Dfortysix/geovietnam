import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _soundEnabledKey = 'settings_sound_enabled';
  static const String _vibrationEnabledKey = 'settings_vibration_enabled';
  static const String _notificationsEnabledKey = 'settings_notifications_enabled';
  static const String _musicVolumeKey = 'settings_music_volume'; // 0.0 - 1.0

  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  Future<bool> isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationEnabledKey, enabled);
  }

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<double> getMusicVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_musicVolumeKey) ?? 0.6;
  }

  Future<void> setMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_musicVolumeKey, volume.clamp(0.0, 1.0));
  }
}
