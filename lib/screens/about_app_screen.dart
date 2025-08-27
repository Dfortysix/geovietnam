import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      // Fallback to default values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Về ứng dụng'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Icon và tên
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: const Icon(
                          Icons.map,
                          size: 60,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GeoVietnam',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Game Địa Lý Việt Nam',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Phiên bản $_version ($_buildNumber)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Mô tả ứng dụng
                _buildSection(
                  title: 'Giới thiệu',
                  content: 'GeoVietnam là một ứng dụng game giáo dục được thiết kế để giúp người dùng khám phá và học hỏi về địa lý Việt Nam một cách thú vị và tương tác. Ứng dụng cung cấp trải nghiệm học tập thông qua các thử thách hàng ngày, khám phá bản đồ tương tác và hệ thống thành tích hấp dẫn.',
                ),
                
                const SizedBox(height: 24),
                
                                 // Tính năng chính
                 _buildSection(
                   title: 'Tính năng chính',
                   content: '• Khám phá bản đồ tương tác với 34 tỉnh thành\n'
                           '• Thử thách hàng ngày với câu hỏi địa lý\n'
                           '• Hệ thống điểm và mở khóa tỉnh mới\n'
                           '• Thống kê tiến độ và thành tích cá nhân',
                 ),
                
                const SizedBox(height: 24),
                
                                 // Dữ liệu cập nhật
                 _buildSection(
                   title: 'Dữ liệu cập nhật',
                   content: 'Ứng dụng sử dụng dữ liệu chính xác về 34 tỉnh thành Việt Nam sau đợt sáp nhập 1/7/2025, bao gồm thông tin chi tiết về địa lý, lịch sử, văn hóa và các sự kiện nổi bật của từng tỉnh thành.',
                 ),
                
                const SizedBox(height: 24),
                
                                 // Nhà phát triển
                 _buildSection(
                   title: 'Nhà phát triển',
                   content: 'Nguyễn Trí Dũng\n'
                           'Email: tridug04062003@gmail.com',
                 ),
                
                const SizedBox(height: 24),
                
                // Bản quyền
                _buildSection(
                  title: 'Bản quyền',
                  content: '© 2025 Nguyễn Trí Dũng. Tất cả quyền được bảo lưu.\n\n'
                          'Ứng dụng này được phát triển cho mục đích giáo dục và giải trí. Dữ liệu địa lý được thu thập từ các nguồn chính thức và được cập nhật thường xuyên.',
                ),
                
                const SizedBox(height: 32),
                
                // Nút liên hệ
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Mở email hoặc trang liên hệ
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Liên hệ nhà phát triển'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
