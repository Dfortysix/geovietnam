import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/svg_canvas_vietnam_map_widget.dart';
import '../widgets/province_detail_widget.dart';
import '../widgets/province_overview_widget.dart';
import '../services/game_progress_service.dart';
import '../services/province_detail_service.dart';
import '../models/game_progress.dart';
import '../models/province.dart';
import '../data/provinces_data.dart';

class MapExplorationScreen extends StatefulWidget {
  const MapExplorationScreen({super.key});

  @override
  State<MapExplorationScreen> createState() => _MapExplorationScreenState();
}

class _MapExplorationScreenState extends State<MapExplorationScreen> with TickerProviderStateMixin {
  GameProgress? _gameProgress;
  bool _isLoading = true;
  Province? _selectedProvince;
  
  // Animation controller cho smooth transitions
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _loadGameProgress();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadGameProgress() async {
    try {
      final progress = await GameProgressService.getCurrentProgress();
      if (mounted) {
        setState(() {
          _gameProgress = progress;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onProvinceTap(String provinceId) async {
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

  String? _getProvinceBackgroundImage(String provinceId) {
    return ProvincesData.getProvinceBackgroundImage(provinceId);
  }

  void _showProvinceDetailScreen(BuildContext context) {
    if (_selectedProvince != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProvinceDetailWidget(
            provinceId: _selectedProvince!.id,
            provinceName: _selectedProvince!.nameVietnamese,
          ),
        ),
      );
    }
  }

  void _unlockAllProvinces() async {
    if (_gameProgress != null) {
      // Tạo danh sách tỉnh mới với tất cả đã mở khóa
      final unlockedProvinces = _gameProgress!.provinces.map((province) {
        return province.copyWith(
          isUnlocked: true,
          isExplored: true,
          unlockedDate: DateTime.now(),
        );
      }).toList();
      
      // Tạo GameProgress mới
      final newProgress = _gameProgress!.copyWith(
        provinces: unlockedProvinces,
        unlockedProvincesCount: unlockedProvinces.length,
      );
      
      // Lưu vào storage
      await GameProgressService.saveProgress(newProgress);
      
      // Cập nhật UI
      setState(() {
        _gameProgress = newProgress;
      });
      
      // Hiển thị thông báo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã mở khóa tất cả các tỉnh!'),
            backgroundColor: AppTheme.primaryOrange,
            duration: Duration(seconds: 2),
          ),
        );
      }
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
        actions: [
          // Nút mở khóa tất cả (chỉ hiển thị khi chưa mở khóa hết)
          if (_gameProgress != null && _gameProgress!.unlockedProvincesCount < _gameProgress!.provinces.length)
            IconButton(
              onPressed: _unlockAllProvinces,
              icon: const Icon(Icons.lock_open, color: AppTheme.primaryOrange),
              tooltip: 'Mở khóa tất cả tỉnh',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Header với thông tin tiến độ
            if (_gameProgress != null)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${_gameProgress!.unlockedProvincesCount}/${_gameProgress!.provinces.length}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _gameProgress!.unlockedProvincesCount / _gameProgress!.provinces.length,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Bản đồ Việt Nam
            Expanded(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      height: 600,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SvgCanvasVietnamMapWidget(
                          onProvinceTap: _onProvinceTap,
                          unlockedProvinces: _gameProgress != null 
                              ? Map.fromEntries(
                                  _gameProgress!.provinces.map((p) => MapEntry(p.id, p.isUnlocked))
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Thông tin tỉnh được chọn
            if (_selectedProvince != null)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: ProvinceOverviewWidget(
                        province: _selectedProvince!,
                        backgroundImagePath: _getProvinceBackgroundImage(_selectedProvince!.id),
                        onDetailPressed: () => _showProvinceDetailScreen(context),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
} 