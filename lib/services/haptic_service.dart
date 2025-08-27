import 'package:flutter/services.dart';
import 'settings_service.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  Future<bool> _enabled() async => await SettingsService().isVibrationEnabled();

  Future<void> light() async {
    if (await _enabled()) await HapticFeedback.lightImpact();
  }

  Future<void> medium() async {
    if (await _enabled()) await HapticFeedback.mediumImpact();
  }

  Future<void> heavy() async {
    if (await _enabled()) await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    if (await _enabled()) await HapticFeedback.selectionClick();
  }
}
