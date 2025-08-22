import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/user_service.dart';

// Custom painter for laurel wreath
class LaurelWreathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    
    // Draw the main wreath circle
    canvas.drawCircle(center, radius, paint);
    
    // Draw laurel leaves around the circle
    final leafPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    
    final int leafCount = 12;
    for (int i = 0; i < leafCount; i++) {
      final angle = (2 * pi * i) / leafCount;
      final leafX = center.dx + (radius - 8) * cos(angle);
      final leafY = center.dy + (radius - 8) * sin(angle);
      
      // Draw leaf shape
      final leafPath = Path();
      leafPath.moveTo(leafX, leafY);
      leafPath.quadraticBezierTo(
        leafX + 8 * cos(angle + pi/6),
        leafY + 8 * sin(angle + pi/6),
        leafX + 12 * cos(angle),
        leafY + 12 * sin(angle),
      );
      leafPath.quadraticBezierTo(
        leafX + 8 * cos(angle - pi/6),
        leafY + 8 * sin(angle - pi/6),
        leafX,
        leafY,
      );
      
      canvas.drawPath(leafPath, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '🏆 Bảng xếp hạng',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Leaderboard Content
              Expanded(
                child: _buildLeaderboard(_loading, _rows),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboard(bool loading, List<Map<String, dynamic>> data) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu bảng xếp hạng',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Top 3 Section
          if (data.length >= 3) _buildTop3Section(data.take(3).toList()),
          
          const SizedBox(height: 20),
          
          // Other Ranks Section
          if (data.length > 3) _buildOtherRanksSection(data.skip(3).toList()),
        ],
      ),
    );
  }

  Widget _buildTop3Section(List<Map<String, dynamic>> top3) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
                     // Header with Trophy Icon
           Container(
             width: double.infinity,
             padding: const EdgeInsets.symmetric(vertical: 16),
             decoration: BoxDecoration(
               gradient: const LinearGradient(
                 colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                 begin: Alignment.centerLeft,
                 end: Alignment.centerRight,
               ),
               borderRadius: BorderRadius.circular(12),
             ),
             child: const Center(
               child: Icon(
                 Icons.emoji_events,
                 size: 48,
                 color: Colors.white,
               ),
             ),
           ),
          
          const SizedBox(height: 24),
          
          // Top 3 Podium
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2nd Place (Left)
              if (top3.length >= 2) Expanded(child: _buildTop3Item(top3[1], 2)),

              // 1st Place (Center)
              Expanded(child: _buildTop3Item(top3[0], 1)),

              // 3rd Place (Right)
              if (top3.length >= 3) Expanded(child: _buildTop3Item(top3[2], 3)),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(delay: 100.ms);
  }

  Widget _buildTop3Item(Map<String, dynamic> item, int rank) {
    final title = item['displayName'] ?? 'Người chơi';
    final value = item['totalScore'] ?? 0;
    final photoUrl = item['photoUrl'] as String?;
    
    Color rankColor;
    double avatarSize;
    double scoreSize;
    
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Vàng
        avatarSize = 80;
        scoreSize = 20;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Bạc
        avatarSize = 60;
        scoreSize = 18;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Đồng
        avatarSize = 60;
        scoreSize = 18;
        break;
      default:
        rankColor = Colors.grey[600]!;
        avatarSize = 50;
        scoreSize = 16;
    }

                   return Column(
        children: [
          // Avatar with special frame, crown, and laurel wreath for 1st place
          SizedBox(
            width: avatarSize + 70,
            height: avatarSize + 70,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
              // Laurel wreath background for 1st place (from assets)
              if (rank == 1)
                Positioned(
                  top: -20,
                  left: -20,
                  right: -20,
                  bottom: -20,
                  child: IgnorePointer(
                    child: Center(
                      child: Image.asset(
                        'assets/images/icons/laurel-wreath.png',
                        width: avatarSize + 60,
                        height: avatarSize + 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              
              Container(
                width: avatarSize + 10,
                height: avatarSize + 10,
                decoration: rank == 1 ? BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ) : null,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  margin: rank == 1 ? const EdgeInsets.all(5) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: rank == 1 ? null : Border.all(
                      color: rankColor,
                      width: 2,
                    ),
                    color: rank == 1 ? Colors.white : null,
                  ),
                  child: ClipOval(
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.lightOrange,
                                child: Center(
                                  child: Text(
                                    title.isNotEmpty ? title[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryOrange,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppTheme.lightOrange,
                            child: Center(
                              child: Text(
                                title.isNotEmpty ? title[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryOrange,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              
              // Crown for 1st place (from assets)
              if (rank == 1)
                Positioned(
                  top: -12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset(
                      'assets/images/icons/crown.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            

              ],
            ),
          ),
        
        const SizedBox(height: 12),
        
                 // Score
         Text(
           '${_formatNumber(value)}',
           style: TextStyle(
             fontSize: scoreSize,
             fontWeight: FontWeight.bold,
             color: rankColor,
           ),
         ),
      ],
    );
  }

  Widget _buildOtherRanksSection(List<Map<String, dynamic>> otherRanks) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: otherRanks.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
          indent: 70,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          final item = otherRanks[index];
          final rank = index + 4; // Start from rank 4
          final title = item['displayName'] ?? 'Người chơi';
          final value = item['totalScore'] ?? 0;
          final photoUrl = item['photoUrl'] as String?;
          
          return _buildOtherRankItem(
            rank: rank,
            title: title,
            value: value,
            photoUrl: photoUrl,
          ).animate().slideX(
            begin: 0.3,
            duration: 300.ms,
            delay: (index * 50).ms,
          ).fadeIn(
            duration: 300.ms,
            delay: (index * 50).ms,
          );
        },
      ),
    );
  }

  Widget _buildOtherRankItem({
    required int rank,
    required String title,
    required int value,
    String? photoUrl,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.lightOrange,
                          child: Center(
                            child: Text(
                              title.isNotEmpty ? title[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppTheme.lightOrange,
                      child: Center(
                        child: Text(
                          title.isNotEmpty ? title[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
             trailing: Text(
         '${_formatNumber(value)}',
         style: const TextStyle(
           fontSize: 16,
           fontWeight: FontWeight.bold,
           color: AppTheme.primaryOrange,
         ),
       ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
}


