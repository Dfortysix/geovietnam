import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final UserService _userService = UserService();
  bool _loading = true;
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await _userService.getTopUsersByScoreThenUnlocked(limit: 100);
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Bảng xếp hạng')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _buildList(_loading, _rows, valueKey: 'totalScore', secondaryKey: 'unlockedProvincesCount'),
      ),
    );
  }

  Widget _buildList(
    bool loading,
    List<Map<String, dynamic>> data, {
    required String valueKey,
    required String secondaryKey,
  }) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
    }
    if (data.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu bảng xếp hạng'));
    }
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = data[index];
        final rank = index + 1;
        final title = item['displayName'] ?? 'Người chơi';
        final value = item[valueKey] ?? 0;
        final unlocked = item[secondaryKey] ?? 0;
        final photoUrl = item['photoUrl'] as String?;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.lightOrange,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl == null || photoUrl.isEmpty ? Text('$rank') : null,
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Hạng #$rank • Tỉnh đã mở: $unlocked'),
          trailing: Text('$value', style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}


