import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/game_progress_service.dart';
import '../models/game_progress.dart';
import 'settings_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  GameProgress? _gameProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGameProgress();
  }

  Future<void> _loadGameProgress() async {
    try {
      final progress = await GameProgressService.getCurrentProgress();
      setState(() {
        _gameProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🏆 Tiến độ & Thành tích'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: AppTheme.primaryOrange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              tooltip: 'Cài đặt',
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Tiến độ & Thành tích'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryOrange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Cài đặt',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Thống kê tổng quan
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'Thống kê tổng quan',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.map,
                            title: 'Tỉnh đã mở khóa',
                            value: '${_gameProgress!.unlockedCount}',
                            subtitle: 'trên ${_gameProgress!.provinces.length} tỉnh',
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star,
                            title: 'Tổng điểm',
                            value: '${_gameProgress!.totalScore}',
                            subtitle: 'điểm tích lũy',
                            color: AppTheme.secondaryYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.local_fire_department,
                            title: 'Daily Streak',
                            value: '${_gameProgress!.dailyStreak}',
                            subtitle: 'ngày liên tiếp',
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.percent,
                            title: 'Hoàn thành',
                            value: '${_gameProgress!.completionPercentage.toStringAsFixed(1)}%',
                            subtitle: 'tiến độ',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 16),

              // Tiến độ chi tiết
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến độ khám phá',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _gameProgress!.completionPercentage / 100,
                      backgroundColor: AppTheme.lightOrange.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã khám phá: ${_gameProgress!.unlockedCount} tỉnh',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          'Còn lại: ${_gameProgress!.provinces.length - _gameProgress!.unlockedCount} tỉnh',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Danh sách tỉnh đã mở khóa
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tỉnh đã mở khóa',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_gameProgress!.unlockedCount == 0)
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Chưa có tỉnh nào được mở khóa',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hoàn thành Daily Challenge để mở khóa tỉnh đầu tiên!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _gameProgress!.provinces
                            .where((province) => province.isUnlocked)
                            .map((province) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryOrange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    province.nameVietnamese,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                            .toList(),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

              const SizedBox(height: 16),

              // Hướng dẫn
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightOrange.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.primaryOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mẹo để tiến bộ nhanh:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('Chơi Daily Challenge mỗi ngày để duy trì streak'),
                    _buildTipItem('Trả lời đúng 7/7 câu hỏi để mở khóa tỉnh mới'),
                    _buildTipItem('Khám phá bản đồ để xem thông tin chi tiết'),
                    _buildTipItem('Tích lũy điểm số để mở khóa các tính năng đặc biệt'),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.primaryOrange)),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 