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
  bool _loadingScore = true;
  bool _loadingUnlocked = true;
  List<Map<String, dynamic>> _topByScore = [];
  List<Map<String, dynamic>> _topByUnlocked = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final score = await _userService.getTopUsersByScore(limit: 100);
    final unlocked = await _userService.getTopUsersByUnlocked(limit: 100);
    if (!mounted) return;
    setState(() {
      _topByScore = score;
      _topByUnlocked = unlocked;
      _loadingScore = false;
      _loadingUnlocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🏆 Bảng xếp hạng'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Điểm số'),
              Tab(text: 'Tỉnh đã mở'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: TabBarView(
            children: [
              _buildList(_loadingScore, _topByScore, valueKey: 'totalScore', suffix: 'đ'),
              _buildList(_loadingUnlocked, _topByUnlocked, valueKey: 'unlockedProvincesCount', suffix: ' tỉnh'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    bool loading,
    List<Map<String, dynamic>> data, {
    required String valueKey,
    required String suffix,
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
        final photoUrl = item['photoUrl'] as String?;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.lightOrange,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl == null || photoUrl.isEmpty ? Text('$rank') : null,
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Text('$value$suffix', style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
          subtitle: Text('Hạng #$rank'),
        );
      },
    );
  }
}


