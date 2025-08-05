import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/google_play_games_service.dart';

class GooglePlayGamesWidget extends StatelessWidget {
  const GooglePlayGamesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GooglePlayGamesService>(
      builder: (context, gamesService, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.games,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Google Play Games',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Hiển thị trạng thái đăng nhập
                _buildSignInStatus(context, gamesService),
                
                const SizedBox(height: 16),
                
                // Nút đăng nhập/đăng xuất
                _buildSignInButton(context, gamesService),
                
                const SizedBox(height: 12),
                
                // Thông tin người dùng nếu đã đăng nhập
                if (gamesService.isSignedIn && gamesService.currentUser != null)
                  _buildUserInfo(gamesService.currentUser!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignInStatus(BuildContext context, GooglePlayGamesService gamesService) {
    return Row(
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
    );
  }

  Widget _buildSignInButton(BuildContext context, GooglePlayGamesService gamesService) {
    return SizedBox(
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
                  const SnackBar(
                    content: Text('Đăng nhập thành công!'),
                    backgroundColor: Colors.green,
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
              : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildUserInfo(dynamic currentUser) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin người chơi:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text('Email: ${currentUser.email}'),
          if (currentUser.displayName != null)
            Text('Tên: ${currentUser.displayName}'),
        ],
      ),
    );
  }
}

// Widget để hiển thị nút nhanh cho Google Play Games
class GooglePlayGamesQuickActions extends StatelessWidget {
  final int currentScore;
  final String? gameMode;

  const GooglePlayGamesQuickActions({
    super.key,
    required this.currentScore,
    this.gameMode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GooglePlayGamesService>(
      builder: (context, gamesService, child) {
        if (!gamesService.isSignedIn) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tích hợp Google Play Games',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await gamesService.logScore(
                            score: currentScore,
                            gameMode: gameMode,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Điểm số đã được ghi log!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.score),
                        label: const Text('Ghi log điểm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await gamesService.logGameEvent(
                            eventName: 'game_session_completed',
                            parameters: {
                              'score': currentScore,
                              'game_mode': gameMode ?? 'default',
                            },
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sự kiện game đã được ghi log!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.event),
                        label: const Text('Ghi log sự kiện'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 