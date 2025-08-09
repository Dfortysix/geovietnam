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

        const SizedBox(height: 16),

        // Nút xem chi tiết đầy đủ
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showDetailedModal(context);
            },
            icon: const Icon(Icons.visibility),
            label: const Text('Xem chi tiết đầy đủ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
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

  void _showDetailedModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Expanded(
                      child: Text(
                        'Chi tiết ${widget.provinceName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the close button
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDetailedSection('Địa lý', _provinceData!['geography']),
                    _buildDetailedSection('Văn hóa', _provinceData!['culture']),
                    _buildDetailedSection('Kinh tế', _provinceData!['economy']),
                    _buildDetailedSection('Lịch sử', _provinceData!['history']),
                    _buildDetailedSection('Du lịch', _provinceData!['tourism']),
                    _buildDetailedSection('Giao thông', _provinceData!['transportation']),
                    _buildDetailedSection('Giáo dục', _provinceData!['education']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedSection(String title, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...data.entries.map((entry) {
            if (entry.value is List) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...(entry.value as List).map((item) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppTheme.primaryOrange)),
                        Expanded(child: Text(item.toString())),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Text(entry.value.toString())),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }
} 