import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Object?>? _cursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _myUserId;
  bool _usingMockData = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};
  int? _myApproxRank; // rank xấp xỉ của tôi
  Map<String, dynamic>? _myEntry; // entry của tôi để render modal

  void _log(String message) {
    // Bọc để sau này có thể tắt nhanh
    // ignore: avoid_print
    print('[Leaderboard] $message');
  }

     Future<void> _showMyPositionModal() async {
     try {
       _log('showMyPositionModal: usingMockData=$_usingMockData, myUserId=$_myUserId');
       
       if (_usingMockData) {
         // Với mock data, tính rank từ danh sách hiện tại
         _log('showMyPositionModal: searching in mock data, rows=${_rows.length}');
         final idx = _rows.indexWhere((e) => (e['userId'] as String?) == _myUserId);
         _log('showMyPositionModal: found index=$idx');
         if (idx >= 0) {
           _myApproxRank = idx + 1;
           _myEntry = _rows[idx];
           _log('showMyPositionModal: mock data - rank=$_myApproxRank, entry=$_myEntry');
         }
       } else {
         // Với real data, lấy từ service
         _log('showMyPositionModal: fetching from service');
         _myEntry = await _userService.getMyLeaderboardEntry();
         _myApproxRank = await _userService.getMyApproxRank();
         _log('showMyPositionModal: real data - rank=$_myApproxRank, entry=$_myEntry');
       }

               _log('showMyPositionModal: final check - rank=$_myApproxRank, entry=$_myEntry');
        if (_myEntry == null) {
          _log('showMyPositionModal: missing entry data, showing error');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy thông tin xếp hạng của bạn.')),
          );
          return;
        }
        
        // Nếu rank null, hiển thị "Đang tính toán..." hoặc tìm trong danh sách hiện tại
        if (_myApproxRank == null) {
          _log('showMyPositionModal: rank is null, trying to find in current list');
          final idx = _rows.indexWhere((e) => (e['userId'] as String?) == _myUserId);
          if (idx >= 0) {
            _myApproxRank = idx + 1;
            _log('showMyPositionModal: found in current list at rank $_myApproxRank');
          }
        }

      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Vị trí của bạn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
               Text('Xếp hạng: ${_myApproxRank != null ? '#${_myApproxRank}' : 'Đang tính toán...'}'),
               const SizedBox(height: 8),
               Text('Tên: ${(_myEntry!['displayName'] as String?) ?? 'Bạn'}'),
               const SizedBox(height: 8),
               Text('Điểm: ${(_myEntry!['totalScore'] as int?) ?? 0}'),
               const SizedBox(height: 8),
               Text('Tỉnh đã mở khóa: ${(_myEntry!['unlockedProvincesCount'] as int?) ?? 0}'),
             ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lấy thông tin vị trí của bạn.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Lấy người dùng hiện tại để highlight
    final current = FirebaseAuth.instance.currentUser;
    _myUserId = current?.uid;

    if (_usingMockData) {
      // Sử dụng mock data
      final mockData = _userService.getMockLeaderboardData();
      setState(() {
        _rows = mockData;
        _loading = false;
        _hasMore = false; // Mock data không có pagination
      });
    } else {
      // Trang đầu tiên bằng cursor-based paging
      final page = await _userService.getLeaderboardPageWithCursor(limit: 30);
      final rows = (page['items'] as List<Map<String, dynamic>>?) ?? [];
      _cursor = page['cursor'] as List<Object?>?;
      _hasMore = (page['hasMore'] as bool?) ?? false;
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    }
  }

  Future<void> _loadMoreIfNeeded() async {
    if (!_hasMore || _isLoadingMore || _loading || _usingMockData) return;
    setState(() {
      _isLoadingMore = true;
    });
    final page = await _userService.getLeaderboardPageWithCursor(limit: 30, startAfter: _cursor);
    final newItems = (page['items'] as List<Map<String, dynamic>>?) ?? [];
    final newCursor = page['cursor'] as List<Object?>?;
    final hasMore = (page['hasMore'] as bool?) ?? false;
    if (!mounted) return;
    setState(() {
      _rows.addAll(newItems);
      _cursor = newCursor;
      _hasMore = hasMore;
      _isLoadingMore = false;
    });
  }

  Future<void> _showMyPositionWindow() async {
    final approxRank = await _userService.getMyApproxRank();
    final window = await _userService.getWindowFromMyPosition(limit: 20);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF654321),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final myIndexInWindow = window.indexWhere((e) => e['userId'] == _myUserId);
        final int? myDisplayRank = approxRank != null
            ? (myIndexInWindow >= 0 ? approxRank + myIndexInWindow : approxRank)
            : (myIndexInWindow >= 0 ? myIndexInWindow + 1 : null);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Vị trí của bạn',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                if (myDisplayRank != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Hạng của bạn: #$myDisplayRank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: window.length,
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFFD2691E), height: 1),
                    itemBuilder: (_, index) {
                      final item = window[index];
                      final isMe = item['userId'] == _myUserId;
                      final title = item['displayName'] ?? 'Người chơi';
                      final value = item['totalScore'] ?? 0;
                      final photoUrl = item['photoUrl'] as String?;
                      final displayRank = approxRank != null ? approxRank + index : (index + 1);
                      return Container(
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.primaryOrange.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildOtherRankItem(
                          rank: displayRank,
                          title: title,
                          value: value,
                          photoUrl: photoUrl,
                          userId: item['userId'] as String?,
                          isCompact: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

     @override
   Widget build(BuildContext context) {
           return Scaffold(
        floatingActionButton: !_usingMockData
            ? FloatingActionButton.extended(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                onPressed: _showMyPositionModal,
                icon: const Icon(Icons.person_pin_circle),
                label: const Text('Vị trí của tôi'),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                         const Spacer(),
                         Tooltip(
                           message: 'Tạo 10 user test (300-400 điểm)',
                           child: ElevatedButton.icon(
                             onPressed: () async {
                               final scaffold = ScaffoldMessenger.of(context);
                               if (_usingMockData) {
                                 // Chuyển về dữ liệu thật
                                 scaffold.showSnackBar(
                                   const SnackBar(content: Text('Đang chuyển về dữ liệu thật...')),
                                 );
                                 setState(() {
                                   _usingMockData = false;
                                   _loading = true;
                                 });
                                 scaffold.hideCurrentSnackBar();
                                 scaffold.showSnackBar(
                                   const SnackBar(content: Text('Đã chuyển về dữ liệu thật')),
                                 );
                                 _load();
                               } else {
                                 // Chuyển sang mock data
                                 scaffold.showSnackBar(
                                   const SnackBar(content: Text('Đang tạo user test...')),
                                 );
                                 setState(() {
                                   _usingMockData = true;
                                   _loading = true;
                                 });
                                 final count = 10; // Số lượng mock users
                                 scaffold.hideCurrentSnackBar();
                                 scaffold.showSnackBar(
                                   SnackBar(content: Text('Đã tạo $count user test')),
                                 );
                                 _load();
                               }
                             },
                             icon: const Icon(Icons.add_circle_outline, size: 18),
                             label: Text(_usingMockData ? 'Real' : 'Test'),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: _usingMockData ? Colors.blue : Colors.green,
                               foregroundColor: Colors.white,
                               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                           ),
                         ),
                         // Nút "Vị trí của tôi" đã được chuyển xuống FloatingActionButton
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

  Future<void> _scrollToMyPosition() async {
    try {
      if (_myUserId == null) return;

      // Thử tìm key hiện có của user trong cây widget
      GlobalKey? key = _itemKeys[_myUserId!];

      // Nếu chưa thấy widget (chưa được build do chưa tải tới), liên tục load thêm cho đến khi thấy hoặc hết trang
      while (key?.currentContext == null && !_usingMockData && _hasMore) {
        await _loadMoreIfNeeded();
        await Future.delayed(const Duration(milliseconds: 60));
        key = _itemKeys[_myUserId!];
      }

      if (key?.currentContext != null) {
        await Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          alignment: 0.2,
          curve: Curves.easeOutCubic,
        );
      } else {
        // Không tìm thấy: thông báo cho người dùng
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chưa tìm thấy vị trí của bạn trong danh sách.')),
          );
        }
      }
    } catch (_) {}
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
         child: NotificationListener<ScrollNotification>(
           onNotification: (n) {
             if (n.metrics.pixels >= n.metrics.maxScrollExtent - 400) {
               _loadMoreIfNeeded();
             }
             return false;
           },
           child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top 3 Section
               if (data.length >= 3) _buildTop3Section(data.take(3).toList()),
               
               const SizedBox(height: 8),
               
               // Other Ranks Section
               if (data.length > 3) _buildOtherRanksSection(data.skip(3).toList()),
               if (_isLoadingMore)
                 const Padding(
                   padding: EdgeInsets.symmetric(vertical: 16),
                   child: Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
                 )
              ],
            ),
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
    final key = (item['userId'] as String?) != null
        ? (_itemKeys[item['userId']] ??= GlobalKey())
        : null;
    final title = item['displayName'] ?? 'Người chơi';
    final value = item['totalScore'] ?? 0;
    final photoUrl = item['photoUrl'] as String?;
    final isMe = (item['userId'] as String?) == _myUserId;
    
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
                      key: key,
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
                                        color: (isMe ? AppTheme.primaryOrange : rankColor).withValues(alpha: 0.5),
                                        blurRadius: isMe ? 20 : 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                    border: isMe ? Border.all(color: AppTheme.primaryOrange, width: 3) : null,
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
                                // "Bạn" badge for current user
                                if (isMe)
                                  Positioned(
                                    bottom: -10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryOrange,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                                        ],
                                      ),
                                      child: const Text(
                                        'Bạn',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
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
            userId: item['userId'] as String?,
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
    String? userId,
    bool isCompact = false,
  }) {
    final bool isMe = userId != null && userId == _myUserId;
    final key = userId != null ? (_itemKeys[userId] ??= GlobalKey()) : null;
    final tile = ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryOrange : AppTheme.primaryOrange,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            rank > 0 ? '$rank' : '',
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
                color: isMe ? AppTheme.primaryOrange : Colors.grey[300]!,
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
           if (isMe) ...[
             const SizedBox(width: 8),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                 color: AppTheme.primaryOrange,
                 borderRadius: BorderRadius.circular(12),
                 boxShadow: const [
                   BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                 ],
               ),
               child: const Text(
                 'Bạn',
                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
               ),
             ),
           ]
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isCompact ? 6 : 8),
    );
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryOrange.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isMe ? Border.all(color: AppTheme.primaryOrange, width: 1.5) : null,
        boxShadow: isMe
            ? const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]
            : null,
      ),
      child: tile,
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }
}


