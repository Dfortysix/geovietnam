import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/province_detail_service.dart';
import 'gallery_full_screen.dart';

class ProvinceDetailWidget extends StatefulWidget {
  final String provinceId;
  final String provinceName;

  const ProvinceDetailWidget({
    super.key,
    required this.provinceId,
    required this.provinceName,
  });

  @override
  State<ProvinceDetailWidget> createState() => _ProvinceDetailWidgetState();
}

class _ProvinceDetailWidgetState extends State<ProvinceDetailWidget> {
  Map<String, dynamic>? _provinceData;
  bool _isLoading = true;
  bool _hasDetailedData = false;

  @override
  void initState() {
    super.initState();
    _loadProvinceData();
  }

  Future<void> _loadProvinceData() async {
    try {
      // Kiểm tra xem có dữ liệu chi tiết không
      final hasData = await ProvinceDetailService.hasDetailedData(widget.provinceId);
      
      if (hasData) {
        final data = await ProvinceDetailService.getProvinceDetail(widget.provinceId);
        setState(() {
          _provinceData = data;
          _hasDetailedData = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasDetailedData = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasDetailedData = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ${widget.provinceName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryOrange,
                ),
              )
            : !_hasDetailedData
                ? _buildBasicInfo()
                : _buildDetailedInfo(),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.provinceName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thông tin chi tiết sẽ được cập nhật sớm',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo() {
    if (_provinceData == null) return _buildBasicInfo();

    final overview = _provinceData!['overview'] as Map<String, dynamic>?;
    final sapNhap2025 = _provinceData!['sapNhap2025'] as Map<String, dynamic>?;
    final lichSu = _provinceData!['lichSu'] as Map<String, dynamic>?;
    final vanHoa = _provinceData!['vanHoa'] as Map<String, dynamic>?;
    final amThuc = _provinceData!['amThuc'] as Map<String, dynamic>?;
    final diaDanh = _provinceData!['diaDanh'] as Map<String, dynamic>?;
    final ketLuan = _provinceData!['ketLuan'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overview
          if (overview != null) ...[
            _buildInfoCard(
              overview['title'] ?? 'Tổng quan',
              Icons.info_outline,
              [
                overview['description'] ?? 'N/A',
                'Diện tích: ${overview['area'] ?? 'N/A'}',
                'Dân số: ${overview['population'] ?? 'N/A'}',
                'Vùng: ${overview['region'] ?? 'N/A'}',
                'Loại: ${overview['type'] ?? 'N/A'}',
                'Biệt danh: ${overview['nickname'] ?? 'N/A'}',
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Sáp nhập 2025
          if (sapNhap2025 != null) ...[
            _buildInfoCard(
              sapNhap2025['title'] ?? 'Sáp nhập 2025',
              Icons.merge_type,
              [
                sapNhap2025['description'] ?? 'N/A',
                if (sapNhap2025['details'] != null) ...[
                  '',
                  'Chi tiết:',
                  ...(sapNhap2025['details'] as List<dynamic>).map((detail) => '  • $detail'),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Lịch sử
          if (lichSu != null) ...[
            _buildInfoCard(
              lichSu['title'] ?? 'Lịch sử',
              Icons.history,
              [
                lichSu['description'] ?? 'N/A',
                if (lichSu['details'] != null) ...[
                  '',
                  'Chi tiết:',
                  ...(lichSu['details'] as List<dynamic>).map((detail) => '  • $detail'),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Văn hóa
          if (vanHoa != null) ...[
            _buildInfoCard(
              vanHoa['title'] ?? 'Văn hóa',
              Icons.theater_comedy,
              [
                vanHoa['description'] ?? 'N/A',
                if (vanHoa['details'] != null) ...[
                  '',
                  'Chi tiết:',
                  ...(vanHoa['details'] as List<dynamic>).map((detail) => '  • $detail'),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Ẩm thực
          if (amThuc != null) ...[
            _buildInfoCard(
              amThuc['title'] ?? 'Ẩm thực',
              Icons.restaurant,
              [
                amThuc['description'] ?? 'N/A',
                if (amThuc['details'] != null) ...[
                  '',
                  'Các món ăn:',
                  ...(amThuc['details'] as List<dynamic>).map((detail) => '  • $detail'),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Địa danh
          if (diaDanh != null) ...[
            _buildInfoCard(
              diaDanh['title'] ?? 'Địa danh nổi bật',
              Icons.place,
              [
                diaDanh['description'] ?? 'N/A',
                if (diaDanh['details'] != null) ...[
                  '',
                  'Các địa danh:',
                  ...(diaDanh['details'] as List<dynamic>).map((detail) => '  • $detail'),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Kết luận
          if (ketLuan != null) ...[
            _buildInfoCard(
              ketLuan['title'] ?? 'Kết luận',
              Icons.summarize,
              [
                ketLuan['description'] ?? 'N/A',
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Button hiển thị Gallery
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showFullScreenGallery(_getGalleryImages(), 0),
              icon: const Icon(Icons.photo_library, size: 20),
              label: const Text('Xem Gallery ảnh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  List<String> _getGalleryImages() {
    final provinceId = widget.provinceId.toLowerCase().replaceAll(' ', '_');
    final List<String> possibleImages = [
      'assets/images/provinces/$provinceId/gallery_1.jpg',
      'assets/images/provinces/$provinceId/gallery_2.jpg',
      'assets/images/provinces/$provinceId/gallery_3.jpg',
      'assets/images/provinces/$provinceId/gallery_4.jpg',
      'assets/images/provinces/$provinceId/gallery_5.jpg',
    ];
    
    // Trả về tất cả ảnh có thể có (Flutter sẽ tự động xử lý lỗi nếu file không tồn tại)
    return possibleImages;
  }

  void _showFullScreenGallery(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryFullScreen(
          images: images,
          initialIndex: initialIndex,
          provinceName: widget.provinceName,
          provinceId: widget.provinceId,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryOrange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 16)),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
} 