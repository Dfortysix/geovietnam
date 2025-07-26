import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/authentic_senni_widget.dart';
import 'game_screen.dart';
import 'senni_demo_screen.dart';
import 'senni_animation_demo_screen.dart';
import 'authentic_senni_demo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthenticSenniHelper.showSenniInScreen(
      situation: 'greeting',
      senniSize: 120,
      messageDuration: const Duration(seconds: 5),
      child: Scaffold(
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
                // Header with animated elements
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
                      
                      // Title with animation
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
                    ],
                  ),
                ),
                
                // Main content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cardShadow,
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Welcome text with animation
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: AppTheme.cardGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '🌟 Chào mừng bạn!',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      color: AppTheme.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Hãy thử sức với những câu hỏi thú vị về địa lý Việt Nam',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
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
                            
                            const SizedBox(height: 40),
                            
                            // Game options with animations
                            _buildGameOption(
                              context,
                              icon: Icons.play_arrow,
                              title: '🚀 Bắt đầu chơi',
                              subtitle: 'Tham gia ngay vào cuộc phiêu lưu địa lý',
                              gradient: AppTheme.primaryGradient,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GameScreen(),
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
                              title: '🏆 Bảng xếp hạng',
                              subtitle: 'Xem điểm số cao nhất',
                              gradient: const LinearGradient(
                                colors: [AppTheme.secondaryYellow, AppTheme.lightOrange],
                              ),
                              onTap: () {
                                // TODO: Implement leaderboard
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Tính năng đang phát triển'),
                                    backgroundColor: AppTheme.primaryOrange,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                            
                            _buildGameOption(
                              context,
                              icon: Icons.settings,
                              title: '⚙️ Cài đặt',
                              subtitle: 'Tùy chỉnh game theo ý thích',
                              gradient: const LinearGradient(
                                colors: [AppTheme.lightOrange, AppTheme.accentOrange],
                              ),
                              onTap: () {
                                // TODO: Implement settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Tính năng đang phát triển'),
                                    backgroundColor: AppTheme.primaryOrange,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            ).animate().fadeIn(
                              duration: 800.ms,
                              delay: 1800.ms,
                            ).slideX(
                              begin: 0.3,
                              duration: 800.ms,
                              delay: 1800.ms,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            _buildGameOption(
                              context,
                              icon: Icons.face,
                              title: '🌸 Demo Senni',
                              subtitle: 'Xem demo linh vật Senni',
                              gradient: const LinearGradient(
                                colors: [Colors.pink, Colors.purple],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SenniDemoScreen(),
                                  ),
                                );
                              },
                            ).animate().fadeIn(
                              duration: 800.ms,
                              delay: 2100.ms,
                            ).slideX(
                              begin: 0.3,
                              duration: 800.ms,
                              delay: 2100.ms,
                            ),

                            const SizedBox(height: 16),

                            _buildGameOption(
                              context,
                              icon: Icons.animation,
                              title: '🎭 Animation Demo',
                              subtitle: 'Xem tất cả animation sinh động',
                              gradient: const LinearGradient(
                                colors: [Colors.orange, Colors.red],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SenniAnimationDemoScreen(),
                                  ),
                                );
                              },
                            ).animate().fadeIn(
                              duration: 800.ms,
                              delay: 2400.ms,
                            ).slideX(
                              begin: 0.3,
                              duration: 800.ms,
                              delay: 2400.ms,
                            ),

                            const SizedBox(height: 16),

                            _buildGameOption(
                              context,
                              icon: Icons.face_retouching_natural,
                              title: '🌸 Authentic Senni',
                              subtitle: 'Linh vật theo phong cách mascot.txt',
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AuthenticSenniDemoScreen(),
                                  ),
                                );
                              },
                            ).animate().fadeIn(
                              duration: 800.ms,
                              delay: 2700.ms,
                            ).slideX(
                              begin: 0.3,
                              duration: 800.ms,
                              delay: 2700.ms,
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Footer with animation
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
                                    'Phiên bản 1.0.0',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                                        ).animate().fadeIn(
              duration: 800.ms,
              delay: 3000.ms,
            ).slideY(
              begin: 0.3,
              duration: 800.ms,
              delay: 3000.ms,
            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
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