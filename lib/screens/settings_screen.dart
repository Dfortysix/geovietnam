import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/settings_service.dart';
import '../services/background_audio_service.dart';
import 'about_app_screen.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  double _musicVolume = 0.6;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = SettingsService();
    final sound = await settings.isSoundEnabled();
    final vib = await settings.isVibrationEnabled();
    final noti = await settings.isNotificationsEnabled();
    final vol = await settings.getMusicVolume();
    setState(() {
      _soundEnabled = sound;
      _vibrationEnabled = vib;
      _notificationsEnabled = noti;
      _musicVolume = vol;
      _loading = false;
    });
    // Đảm bảo khởi tạo audio
    await BackgroundAudioService().init();
    // Đồng bộ trạng thái audio
    await BackgroundAudioService().setEnabled(_soundEnabled);
    await BackgroundAudioService().setVolume(_musicVolume);
    // Khởi tạo thông báo
    await NotificationService().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle('Âm thanh & rung'),
                    _buildSwitchTile(
                      icon: Icons.volume_up,
                      title: 'Âm thanh',
                      value: _soundEnabled,
                      onChanged: (v) async {
                        setState(() => _soundEnabled = v);
                        await BackgroundAudioService().setEnabled(v);
                      },
                    ),
                    _buildVolumeSlider(),
                    _buildSwitchTile(
                      icon: Icons.vibration,
                      title: 'Rung',
                      value: _vibrationEnabled,
                      onChanged: (v) async {
                        setState(() => _vibrationEnabled = v);
                        await SettingsService().setVibrationEnabled(v);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Thông báo'),
                    _buildSwitchTile(
                      icon: Icons.notifications_active,
                      title: 'Bật thông báo',
                      value: _notificationsEnabled,
                      onChanged: (v) async {
                        if (v == _notificationsEnabled) return; // Tránh gọi lại nếu giá trị không đổi
                        
                        setState(() => _notificationsEnabled = v);
                        await SettingsService().setNotificationsEnabled(v);
                        await NotificationService().init();
                        if (v) {
                          await NotificationService().scheduleDailyReminders();
                        } else {
                          await NotificationService().cancelAll();
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle('Khác'),
                    _buildNavTile(
                      icon: Icons.info_outline,
                      title: 'Về ứng dụng',
                      subtitle: 'Phiên bản và thông tin',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutAppScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, color: AppTheme.primaryOrange),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.music_note, color: AppTheme.primaryOrange),
              SizedBox(width: 12),
              Text('Âm lượng nhạc nền'),
            ],
          ),
          Slider(
            value: _musicVolume,
            onChanged: (v) async {
              setState(() => _musicVolume = v);
              await BackgroundAudioService().setVolume(v);
            },
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: (_musicVolume * 100).round().toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.primaryOrange),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }


}


