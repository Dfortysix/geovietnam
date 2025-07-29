import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/vietnam_map_widget.dart';
import '../services/game_progress_service.dart';
import '../models/game_progress.dart';
import '../models/province.dart';

class MapExplorationScreen extends StatefulWidget {
  const MapExplorationScreen({Key? key}) : super(key: key);

  @override
  State<MapExplorationScreen> createState() => _MapExplorationScreenState();
}

class _MapExplorationScreenState extends State<MapExplorationScreen> {
  GameProgress? _gameProgress;
  bool _isLoading = true;
  Province? _selectedProvince;

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

  void _onProvinceTap(String provinceId) {
    if (_gameProgress != null) {
      final province = _gameProgress!.provinces.firstWhere(
        (p) => p.id == provinceId,
        orElse: () => _gameProgress!.provinces.first,
      );
      setState(() {
        _selectedProvince = province;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🗺️ Khám phá bản đồ'),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
        title: const Text('🗺️ Khám phá bản đồ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Header với thông tin tiến độ
            if (_gameProgress != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiến độ khám phá',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_gameProgress!.unlockedCount}/${_gameProgress!.provinces.length}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _gameProgress!.completionPercentage / 100,
                      backgroundColor: AppTheme.lightOrange.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_gameProgress!.completionPercentage.toStringAsFixed(1)}% hoàn thành',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),

            // Bản đồ Việt Nam
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                                  child: VietnamMapWidget(
                  onProvinceTap: _onProvinceTap,
                  unlockedProvinces: _gameProgress != null 
                      ? Map.fromEntries(
                          _gameProgress!.provinces.map((p) => MapEntry(p.id, p.isUnlocked))
                        )
                      : null,
                ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            ),

            // Thông tin tỉnh được chọn
            if (_selectedProvince != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedProvince!.isUnlocked 
                              ? Icons.check_circle 
                              : Icons.lock,
                          color: _selectedProvince!.isUnlocked 
                              ? Colors.green 
                              : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedProvince!.nameVietnamese,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!_selectedProvince!.isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Chưa mở khóa',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedProvince!.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (_selectedProvince!.isUnlocked) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Thông tin thú vị:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._selectedProvince!.facts.map((fact) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppTheme.primaryOrange)),
                            Expanded(
                              child: Text(
                                fact,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

            // Hướng dẫn
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chạm vào tỉnh trên bản đồ để xem thông tin. Hoàn thành Daily Challenge để mở khóa khu vực mới!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }
} 