import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/user_service.dart';

// Custom painter for bokeh effect
class BokehPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF8C42).withValues(alpha: 0.2) // Orange with transparency
      ..style = PaintingStyle.fill;

    // Draw multiple bokeh circles
    final circles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.9),
      Offset(size.width * 0.7, size.height * 0.6),
    ];

    for (final center in circles) {
      final radius = 20 + (center.dx + center.dy) % 30; // Varying sizes
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient, // Use project's theme gradient
          ),
          child: Stack(
            children: [
              // Bokeh effect background
              Positioned.fill(
                child: CustomPaint(
                  painter: BokehPainter(),
                ),
              ),
             SafeArea(
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
                               color: Colors.black,
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
                             color: Colors.black,
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
           ],
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

     return Container(
       margin: const EdgeInsets.symmetric(horizontal: 20),
       decoration: BoxDecoration(
         color: const Color(0xFF8B4513), // Dark brown wood color
         borderRadius: BorderRadius.circular(25),
         border: Border.all(
           color: const Color(0xFFD2691E), // Lighter brown border
           width: 3,
         ),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withValues(alpha: 0.3),
             blurRadius: 15,
             offset: const Offset(0, 8),
           ),
         ],
       ),
       child: Container(
         margin: const EdgeInsets.all(8),
         decoration: BoxDecoration(
           color: const Color(0xFF654321), // Inner dark brown
           borderRadius: BorderRadius.circular(20),
         ),
         child: SingleChildScrollView(
           padding: const EdgeInsets.all(20),
           child: Column(
             children: [
               // Top 3 Section
               if (data.length >= 3) _buildTop3Section(data.take(3).toList()),
               
               const SizedBox(height: 8),
               
               // Other Ranks Section
               if (data.length > 3) _buildOtherRanksSection(data.skip(3).toList()),
             ],
           ),
         ),
       ),
     );
   }

     Widget _buildTop3Section(List<Map<String, dynamic>> top3) {
     return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513), // Dark brown wood
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD2691E), // Lighter brown border
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
     child: Column(
       children: [
                     // Header with Ribbon Banner
          SizedBox(
            width: double.infinity,
            height: 156,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ribbon image background
                Center(
                  child: Image.asset(
                    'assets/images/icons/ribbon.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                // Text overlay
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: const Text(
                    'BXH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
         const SizedBox(height: 0),
          
                                 // Top 3 Podium
            Transform.translate(
              offset: const Offset(0, -8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2nd Place (Left)
                  if (top3.length >= 2) Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildTop3Item(top3[1], 2),
                    ),
                  ),
 
                  // 1st Place (Center)
                  Expanded(
                    child: _buildTop3Item(top3[0], 1),
                  ),
 
                  // 3rd Place (Right)
                  if (top3.length >= 3) Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildTop3Item(top3[2], 3),
                    ),
                  ),
                ],
              ),
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
          avatarSize = 64;
          scoreSize = 20;
          break;
        case 2:
          rankColor = const Color(0xFFC0C0C0); // Bạc
          avatarSize = 52;
          scoreSize = 18;
          break;
        case 3:
          rankColor = const Color(0xFFCD7F32); // Đồng
          avatarSize = 52;
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
                        Center(
                          child: SizedBox(
                            width: rank == 1 ? avatarSize + 60 : avatarSize + 40,
                            height: rank == 1 ? avatarSize + 50 : avatarSize + 14,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                // Laurel wreath background for 1st place (from assets)
                                if (rank == 1)
                                  Positioned(
                                    top: -16,
                                    left: -16,
                                    right: -16,
                                    bottom: -16,
                                    child: IgnorePointer(
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/icons/laurel-wreath.png',
                                          width: avatarSize + 56,
                                          height: avatarSize + 56,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                Container(
                                  width: avatarSize + 10,
                                  height: avatarSize + 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: rank == 1 
                                      ? const LinearGradient(
                                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : rank == 2
                                        ? const LinearGradient(
                                            colors: [Color(0xFFC0C0C0), Color(0xFFA0A0A0)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : const LinearGradient(
                                            colors: [Color(0xFFCD7F32), Color(0xFFB8860B)],
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
                                  ),
                                  child: Container(
                                    width: avatarSize,
                                    height: avatarSize,
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
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
                                    top: -6,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/icons/crown.png',
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Tooltip(
                            message: title,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        
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
         color: const Color(0xFF8B4513), // Dark brown wood
         borderRadius: BorderRadius.circular(20),
         border: Border.all(
           color: const Color(0xFFD2691E), // Lighter brown border
           width: 2,
         ),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withValues(alpha: 0.3),
             blurRadius: 15,
             offset: const Offset(0, 8),
           ),
         ],
       ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: otherRanks.length,
                 separatorBuilder: (context, index) => Divider(
           height: 1,
           color: const Color(0xFFD2691E), // Lighter brown for dividers
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
             child: Tooltip(
               message: title,
               child: Text(
                 title,
                 style: const TextStyle(
                   fontSize: 14,
                   fontWeight: FontWeight.w600,
                   color: Colors.white, // White text for better contrast
                 ),
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
               ),
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


