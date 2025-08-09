import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/google_play_games_service.dart';
import '../services/game_progress_service.dart';
import '../services/auth_service.dart';
import '../models/game_progress.dart';
import '../widgets/user_avatar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GameProgress? _gameProgress;
  bool _isLoading = true;
  final AuthService _authService = AuthService();
  final GameProgressService _gameProgressService = GameProgressService();

  @override
  void initState() {
    super.initState();
    _loadGameProgress();
    // Lắng nghe thay đổi trạng thái đăng nhập
    _authService.addListener(_onAuthStateChanged);
    // Lắng nghe thay đổi tiến độ game
    _gameProgressService.addListener(_onGameProgressChanged);
    // Refresh trạng thái đăng nhập khi khởi tạo
    _refreshLoginStatus();
  }

  Future<void> _refreshLoginStatus() async {
    await _authService.refreshLoginStatus();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    _gameProgressService.removeListener(_onGameProgressChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    // Refresh UI khi trạng thái đăng nhập thay đổi
    setState(() {});
  }

  void _onGameProgressChanged() {
    // Refresh UI khi tiến độ game thay đổi
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

   Widget _buildGooglePlayGamesSection() {
     return Consumer<GooglePlayGamesService>(
       builder: (context, gamesService, child) {
         return Container(
           padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(20),
             boxShadow: [
               BoxShadow(
                 color: Colors.black.withOpacity(0.1),
                 blurRadius: 20,
                 offset: const Offset(0, 10),
               ),
             ],
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Header
               Row(
                 children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: AppTheme.primaryOrange.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: const Icon(
                       Icons.games,
                       color: AppTheme.primaryOrange,
                       size: 24,
                     ),
                   ),
                   const SizedBox(width: 12),
                   const Text(
                     'Google Play Games',
                     style: TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 20),
               
               // Trạng thái đăng nhập
               Row(
                 children: [
                   Icon(
                     gamesService.isSignedIn ? Icons.check_circle : Icons.cancel,
                     color: gamesService.isSignedIn ? Colors.green : Colors.red,
                     size: 20,
                   ),
                   const SizedBox(width: 8),
                   Text(
                     gamesService.isSignedIn ? 'Đã đăng nhập' : 'Chưa đăng nhập',
                     style: TextStyle(
                       color: gamesService.isSignedIn ? Colors.green : Colors.red,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 16),
               
               // Nút đăng nhập/đăng xuất
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                   onPressed: () async {
                     if (gamesService.isSignedIn) {
                       await gamesService.signOut();
                       if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                             content: Text('Đã đăng xuất khỏi Google Play Games'),
                             backgroundColor: Colors.orange,
                           ),
                         );
                       }
                     } else {
                       final success = await gamesService.signIn();
                       if (context.mounted) {
                         if (success) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Text('Đăng nhập thành công! Email: ${gamesService.currentUser?.email ?? 'N/A'}'),
                               backgroundColor: Colors.green,
                               duration: const Duration(seconds: 3),
                             ),
                           );
                         } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(
                               content: Text('Đăng nhập thất bại. Vui lòng thử lại.'),
                               backgroundColor: Colors.red,
                             ),
                           );
                         }
                       }
                     }
                   },
                   icon: Icon(
                     gamesService.isSignedIn ? Icons.logout : Icons.login,
                   ),
                   label: Text(
                     gamesService.isSignedIn ? 'Đăng xuất' : 'Đăng nhập Google Play Games',
                   ),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: gamesService.isSignedIn 
                         ? Colors.orange 
                         : AppTheme.primaryOrange,
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 12),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                 ),
               ),
               
               // Thông tin người dùng nếu đã đăng nhập
               if (gamesService.isSignedIn && gamesService.currentUser != null) ...[
                 const SizedBox(height: 16),
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: Colors.grey[100],
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(
                       color: Colors.grey[300]!,
                       width: 1,
                     ),
                   ),
                   child: UserAvatarWithNameWidget(
                     photoUrl: gamesService.currentUser!.photoUrl,
                     displayName: gamesService.currentUser!.displayName,
                     email: gamesService.currentUser!.email,
                     avatarSize: 40,
                   ),
                 ),
               ],
             ],
           ),
         ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(delay: 100.ms);
       },
     );
   }
 } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
          ),
          
          // Animated background elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryOrange.withOpacity(0.1),
              ),
            ).animate().scale(duration: 3.seconds).then().scale(duration: 3.seconds),
          ),
          
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryYellow.withOpacity(0.1),
              ),
            ).animate().scale(duration: 4.seconds).then().scale(duration: 4.seconds),
          ),

          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryOrange,
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      // Custom App Bar
                      SliverAppBar(
                        expandedHeight: 200,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                                                 colors: [
                                   AppTheme.primaryOrange.withOpacity(0.8),
                                   AppTheme.secondaryYellow.withOpacity(0.6),
                                 ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Consumer<GooglePlayGamesService>(
                                  builder: (context, gamesService, child) {
                                    return Column(
                                      children: [
                                        // Avatar với hiệu ứng
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: UserAvatarWidget(
                                            photoUrl: gamesService.currentUser?.photoUrl,
                                            size: 80,
                                            borderColor: Colors.white,
                                            borderWidth: 4,
                                          ),
                                        ).animate().scale(duration: 600.ms),
                                        
                                        const SizedBox(height: 16),
                                        
                                        // Tên người dùng
                                        Text(
                                          gamesService.currentUser?.displayName ?? 'Người chơi',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ).animate().fadeIn(delay: 200.ms),
                                        
                                        // Email
                                        if (gamesService.currentUser?.email != null)
                                          Text(
                                            gamesService.currentUser!.email!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                          ).animate().fadeIn(delay: 400.ms),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        leading: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        actions: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onPressed: () {
                              // TODO: Implement edit profile
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tính năng chỉnh sửa profile sẽ sớm ra mắt!'),
                                  backgroundColor: AppTheme.primaryOrange,
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Profile Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                                                             // Phần đăng nhập Google Play Games
                               _buildGooglePlayGamesSection(),
                               const SizedBox(height: 24),
                               
                               // Thống kê game
                               _buildGameStats(),
                               const SizedBox(height: 24),
                               
                               // Menu options
                               _buildMenuOptions(),
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

  Widget _buildGameStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: AppTheme.primaryOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thống kê Game',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  title: 'Điểm số',
                  value: '${_gameProgress?.totalScore ?? 0}',
                  color: AppTheme.primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                                 child: _buildStatCard(
                   icon: Icons.explore,
                   title: 'Tỉnh đã khám phá',
                   value: '${_gameProgress?.unlockedCount ?? 0}/63',
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
                   title: 'Streak',
                   value: '${_gameProgress?.dailyStreak ?? 0} ngày',
                   color: Colors.red,
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: _buildStatCard(
                   icon: Icons.emoji_events,
                   title: 'Thành tựu',
                   value: '${_gameProgress?.completedDailyChallenges.length ?? 0}',
                   color: Colors.amber,
                 ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(delay: 200.ms);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

    Widget _buildMenuOptions() {
    final menuItems = <Map<String, dynamic>>[
      {
        'icon': Icons.person,
        'title': 'Thông tin cá nhân',
        'subtitle': 'Chỉnh sửa thông tin profile',
        'color': AppTheme.secondaryYellow,
        'onTap': () {
          // TODO: Navigate to personal info
        },
      },
      {
        'icon': Icons.notifications,
        'title': 'Thông báo',
        'subtitle': 'Cài đặt thông báo game',
        'color': AppTheme.primaryOrange,
        'onTap': () {
          // TODO: Navigate to notifications
        },
      },
      {
        'icon': Icons.settings,
        'title': 'Cài đặt',
        'subtitle': 'Tùy chỉnh game',
        'color': Colors.green,
        'onTap': () {
          // TODO: Navigate to settings
        },
      },
      {
        'icon': Icons.help,
        'title': 'Trợ giúp',
        'subtitle': 'Hướng dẫn và FAQ',
        'color': Colors.purple,
        'onTap': () {
          // TODO: Navigate to help
        },
      },
      {
        'icon': Icons.info,
        'title': 'Về ứng dụng',
        'subtitle': 'Phiên bản và thông tin',
        'color': Colors.teal,
        'onTap': () {
          // TODO: Navigate to about
        },
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                                   child: Icon(
                   item['icon'] as IconData,
                   color: item['color'] as Color,
                   size: 24,
                 ),
                ),
                                 title: Text(
                   item['title'] as String,
                   style: const TextStyle(
                     fontWeight: FontWeight.w600,
                     fontSize: 16,
                   ),
                 ),
                 subtitle: Text(
                   item['subtitle'] as String,
                   style: TextStyle(
                     color: Colors.grey[600],
                     fontSize: 14,
                   ),
                 ),
                 trailing: const Icon(
                   Icons.arrow_forward_ios,
                   size: 16,
                   color: Colors.grey,
                 ),
                 onTap: item['onTap'] as VoidCallback?,
              ),
              if (index < menuItems.length - 1)
                Divider(
                  height: 1,
                  indent: 70,
                  endIndent: 20,
                  color: Colors.grey[200],
                ),
            ],
          );
        }).toList(),
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(delay: 400.ms);
  }

  Widget _buildGooglePlayGamesSection() {
    return Consumer<GooglePlayGamesService>(
      builder: (context, gamesService, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.games,
                      color: AppTheme.primaryOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Google Play Games',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Trạng thái đăng nhập
              Row(
                children: [
                  Icon(
                    gamesService.isSignedIn ? Icons.check_circle : Icons.cancel,
                    color: gamesService.isSignedIn ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    gamesService.isSignedIn ? 'Đã đăng nhập' : 'Chưa đăng nhập',
                    style: TextStyle(
                      color: gamesService.isSignedIn ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Nút đăng nhập/đăng xuất
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (gamesService.isSignedIn) {
                      await gamesService.signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã đăng xuất khỏi Google Play Games'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } else {
                      final success = await gamesService.signIn();
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đăng nhập thành công! Email: ${gamesService.currentUser?.email ?? 'N/A'}'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đăng nhập thất bại. Vui lòng thử lại.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: Icon(
                    gamesService.isSignedIn ? Icons.logout : Icons.login,
                  ),
                  label: Text(
                    gamesService.isSignedIn ? 'Đăng xuất' : 'Đăng nhập Google Play Games',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gamesService.isSignedIn 
                        ? Colors.orange 
                        : AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              // Thông tin người dùng nếu đã đăng nhập
              if (gamesService.isSignedIn && gamesService.currentUser != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: UserAvatarWithNameWidget(
                    photoUrl: gamesService.currentUser!.photoUrl,
                    displayName: gamesService.currentUser!.displayName,
                    email: gamesService.currentUser!.email,
                    avatarSize: 40,
                  ),
                ),
              ],
            ],
          ),
        ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(delay: 100.ms);
      },
    );
  }
} 