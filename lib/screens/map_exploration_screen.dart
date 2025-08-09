import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/svg_canvas_vietnam_map_widget.dart';
import '../services/game_progress_service.dart';
import '../models/game_progress.dart';
import '../models/province.dart';

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

  String? _getProvinceBackgroundImage(String provinceId) {
    // Map province ID to background image path
    final backgroundMap = {
      'Hai Phong': 'assets/images/provinces/hai_phong_bg.png',
    };
    final imagePath = backgroundMap[provinceId];
    if (imagePath != null) {
      print('Loading background image: $imagePath for province: $provinceId');
    }
    return imagePath;
  }

  Future<bool> _checkImageExists(String imagePath) async {
    try {
      // Thử load image để kiểm tra xem có tồn tại không
      await precacheImage(AssetImage(imagePath), context);
      return true;
    } catch (e) {
      print('Image not found: $imagePath - $e');
      return false;
    }
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryOrange.withValues(alpha: 0.3),
            AppTheme.primaryOrange.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
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
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                                                                                      // Background image cho tỉnh có hình ảnh
                             if (_getProvinceBackgroundImage(_selectedProvince!.id) != null)
                               Positioned.fill(
                                 child: Image.asset(
                                   _getProvinceBackgroundImage(_selectedProvince!.id)!,
                                   fit: BoxFit.cover,
                                   errorBuilder: (context, error, stackTrace) {
                                     print('Error loading image: $error');
                                     return _buildFallbackBackground();
                                   },
                                 ),
                               ),
                             // Fallback background cho các tỉnh khác
                             if (_getProvinceBackgroundImage(_selectedProvince!.id) == null)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            // Overlay để text dễ đọc
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.3),
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(16),
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
                                            : Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedProvince!.nameVietnamese,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (!_selectedProvince!.isUnlocked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Chưa mở khóa',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedProvince!.description,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ),
                                  if (_selectedProvince!.isUnlocked) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Thông tin thú vị:',
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // TODO: Implement detailed info action
                                          },
                                          icon: const Icon(Icons.info_outline, size: 16),
                                          label: const Text('Chi tiết'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryOrange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ..._selectedProvince!.facts.take(2).map((fact) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(color: AppTheme.primaryOrange)),
                                          Expanded(
                                            child: Text(
                                              fact,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.white.withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
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