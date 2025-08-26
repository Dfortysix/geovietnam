import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;

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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('Âm thanh & rung'),
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: 'Âm thanh',
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'Rung',
                value: _vibrationEnabled,
                onChanged: (v) => setState(() => _vibrationEnabled = v),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Thông báo'),
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Bật thông báo',
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Khác'),
              _buildNavTile(
                icon: Icons.info_outline,
                title: 'Về ứng dụng',
                subtitle: 'Phiên bản và thông tin',
                onTap: () {},
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


