import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/game_progress_service.dart';
import '../services/daily_challenge_service.dart';
import '../models/game_progress.dart';
import '../widgets/google_play_games_widget.dart';
import 'game_screen.dart';
import 'daily_challenge_screen.dart';
import 'map_exploration_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameProgress? _gameProgress;
  bool _isLoading = true;
  Map<String, dynamic>? _dailyChallenge;

  @override
  void initState() {
    super.initState();
    _loadGameProgress();
  }

  Future<void> _loadGameProgress() async {
    try {
      final progress = await GameProgressService.getCurrentProgress();
      final dailyChallenge = await DailyChallengeService.getCurrentDailyChallenge();
      setState(() {
        _gameProgress = progress;
        _dailyChallenge = dailyChallenge;
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryOrange,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.65),
                    Colors.transparent,
                    AppTheme.primaryOrange.withOpacity(0.18),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header với thông tin game
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Animated globe icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: AppTheme.glowShadow,
                        ),
                        child: const Icon(
                          Icons.public,
                          size: 60,
                          color: Colors.white,
                        ),
                      ).animate().scale(
                        duration: 1.2.seconds,
                        curve: Curves.elasticOut,
                      ).then().shimmer(
                        duration: 2.seconds,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Title với animation
                      Text(
                        '🌏 GeoVietnam',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          background: Paint()
                            ..shader = AppTheme.primaryGradient.createShader(
                              const Rect.fromLTWH(0, 0, 200, 70),
                            ),
                        ),
                      ).animate().fadeIn(
                        duration: 800.ms,
                        delay: 300.ms,
                      ).slideY(
                        begin: 0.3,
                        duration: 800.ms,
                        delay: 300.ms,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        '🎮 Khám phá địa lý Việt Nam',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ).animate().fadeIn(
                        duration: 800.ms,
                        delay: 600.ms,
                      ).slideY(
                        begin: 0.3,
                        duration: 800.ms,
                        delay: 600.ms,
                      ),

                      const SizedBox(height: 20),

                      // Progress indicator
                      if (_gameProgress != null) ...[
                        Container(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    icon: Icons.star,
                                    label: 'Điểm số',
                                    value: '${_gameProgress!.totalScore}',
                                  ),
                                  _buildStatItem(
                                    icon: Icons.local_fire_department,
                                    label: 'Streak',
                                    value: '${_gameProgress!.dailyStreak} ngày',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(
                          duration: 800.ms,
                          delay: 900.ms,
                        ).slideY(
                          begin: 0.3,
                          duration: 800.ms,
                          delay: 900.ms,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Game options
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildDailyChallengeOption(context),
                        
                        const SizedBox(height: 16),
                        
                        _buildGameOption(
                          context,
                          icon: Icons.map,
                          title: '🗺️ Khám phá bản đồ',
                          subtitle: 'Xem các khu vực đã mở khóa và thông tin chi tiết',
                          gradient: const LinearGradient(
                            colors: [AppTheme.secondaryYellow, AppTheme.lightOrange],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MapExplorationScreen(),
                              ),
                            );
                          },
                        ).animate().fadeIn(
                          duration: 800.ms,
                          delay: 1200.ms,
                        ).slideX(
                          begin: 0.3,
                          duration: 800.ms,
                          delay: 1200.ms,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildGameOption(
                          context,
                          icon: Icons.leaderboard,
                          title: '🏆 Tiến độ & Thành tích',
                          subtitle: 'Xem thống kê chi tiết và thành tích của bạn',
                          gradient: const LinearGradient(
                            colors: [AppTheme.lightOrange, AppTheme.accentOrange],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProgressScreen(),
                              ),
                            );
                          },
                        ).animate().fadeIn(
                          duration: 800.ms,
                          delay: 1500.ms,
                        ).slideX(
                          begin: 0.3,
                          duration: 800.ms,
                          delay: 1500.ms,
                        ),

                        const SizedBox(height: 16),
                        
                        // Google Play Games Integration
                        const GooglePlayGamesWidget().animate().fadeIn(
                          duration: 800.ms,
                          delay: 1800.ms,
                        ).slideX(
                          begin: 0.3,
                          duration: 800.ms,
                          delay: 1800.ms,
                        ),

                        const SizedBox(height: 40),
                        
                        // Footer với animation
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.lightOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.lightOrange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.textSecondary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Phiên bản 1.0.0 - Hệ thống Unlock Daily',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(
                          duration: 800.ms,
                          delay: 2100.ms,
                        ).slideY(
                          begin: 0.3,
                          duration: 800.ms,
                          delay: 2100.ms,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryOrange,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallengeOption(BuildContext context) {
    final canPlay = _dailyChallenge?['canPlay'] ?? false;
    final attempts = _dailyChallenge?['attempts'] ?? 0;
    final maxAttempts = _dailyChallenge?['maxAttempts'] ?? 3;
    final remainingAttempts = maxAttempts - attempts;
    final isProvinceUnlockedToday = _dailyChallenge?['isProvinceUnlockedToday'] ?? false;
    
    return GestureDetector(
      onTap: (canPlay && !isProvinceUnlockedToday) ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DailyChallengeScreen(),
          ),
        ).then((_) => _loadGameProgress());
      } : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isProvinceUnlockedToday
              ? const LinearGradient(
                  colors: [Colors.green, Colors.greenAccent],
                )
              : canPlay 
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                    )
                  : const LinearGradient(
                      colors: [Colors.grey, Colors.grey],
                    ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(
            color: isProvinceUnlockedToday
                ? Colors.green.withOpacity(0.3)
                : canPlay 
                    ? AppTheme.primaryOrange.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.softShadow,
              ),
                             child: Icon(
                 isProvinceUnlockedToday ? Icons.check_circle : Icons.celebration,
                 color: Colors.white,
                 size: 24,
               ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                                     Row(
                     children: [
                       Flexible(
                         child: Text(
                           isProvinceUnlockedToday ? '🎉 Chúc mừng!' : '🎯 Daily Challenge',
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                             color: Colors.white,
                             fontWeight: FontWeight.w600,
                           ),
                           overflow: TextOverflow.ellipsis,
                         ),
                       ),
                       if (isProvinceUnlockedToday) ...[
                         const SizedBox(width: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: const Text(
                             'Hoàn thành',
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       ] else if (!canPlay) ...[
                         const SizedBox(width: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.2),
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: const Text(
                             'Hết lượt',
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                       ],
                     ],
                   ),
                  const SizedBox(height: 4),
                                     Text(
                     isProvinceUnlockedToday
                         ? 'Đã mở khóa tỉnh hôm nay!'
                         : canPlay 
                             ? '7 câu hỏi - Còn $remainingAttempts lần thử hôm nay'
                             : 'Đã hết lượt thử hôm nay',
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: Colors.white.withOpacity(0.9),
                     ),
                     overflow: TextOverflow.ellipsis,
                     maxLines: 2,
                   ),
                ],
              ),
            ),
                         if (canPlay && !isProvinceUnlockedToday)
               Icon(
                 Icons.arrow_forward_ios,
                 color: Colors.white,
                 size: 16,
               ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: 800.ms,
      delay: 1200.ms,
    ).slideX(
      begin: 0.3,
      duration: 800.ms,
      delay: 1200.ms,
    );
  }

  Widget _buildGameOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    LinearGradient? gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient ?? const LinearGradient(
            colors: [AppTheme.cardBackground, AppTheme.cardBackground],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(
            color: AppTheme.lightOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient ?? AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.softShadow,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 