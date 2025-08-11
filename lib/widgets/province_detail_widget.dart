import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/province_detail_service.dart';

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
    final overview = _provinceData!['overview'];
    final culture = _provinceData!['culture'];
    final facts = _provinceData!['facts'] as List<dynamic>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header với title
        Container(
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
                overview['title'] ?? widget.provinceName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                overview['description'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 16),

        // Thông tin cơ bản
        _buildInfoCard(
          'Thông tin cơ bản',
          Icons.info_outline,
          [
            'Diện tích: ${overview['area']}',
            'Dân số: ${overview['population']}',
            'Vùng: ${overview['region']}',
            'Loại: ${overview['type']}',
          ],
        ),

        const SizedBox(height: 16),

        // Văn hóa và ẩm thực
        if (culture != null) ...[
          _buildInfoCard(
            'Văn hóa & Ẩm thực',
            Icons.restaurant,
            [
              'Biệt danh: ${overview['nickname']}',
              'Món ăn nổi tiếng: ${(culture['famous_foods'] as List<dynamic>).take(3).join(', ')}',
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Sự kiện thú vị
        _buildInfoCard(
          'Sự kiện thú vị',
          Icons.star,
          facts.take(5).map((fact) => fact.toString()).toList(),
        ),
      ],
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
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