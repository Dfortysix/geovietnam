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
    final geography = _provinceData!['geography'];
    final culture = _provinceData!['culture'];
    final economy = _provinceData!['economy'];
    final history = _provinceData!['history'];
    final tourism = _provinceData!['tourism'];
    final transportation = _provinceData!['transportation'];
    final education = _provinceData!['education'];
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
            'Diện tích: ${overview['area'] ?? 'N/A'}',
            'Dân số: ${overview['population'] ?? 'N/A'}',
            'Vùng: ${overview['region'] ?? 'N/A'}',
            'Loại: ${overview['type'] ?? 'N/A'}',
            'Biệt danh: ${overview['nickname'] ?? 'N/A'}',
          ],
        ),

        const SizedBox(height: 16),

        // Địa lý
        if (geography != null) ...[
          _buildInfoCard(
            'Địa lý',
            Icons.location_on,
            [
              'Vị trí: ${geography['location'] ?? 'N/A'}',
              'Địa hình: ${geography['terrain'] ?? 'N/A'}',
              'Khí hậu: ${geography['climate'] ?? 'N/A'}',
              'Tài nguyên: ${geography['natural_resources'] ?? 'N/A'}',
              if (geography['administrative_units'] != null) ...[
                'Đơn vị hành chính: ${geography['administrative_units']['total'] ?? 'N/A'}',
                if (geography['administrative_units']['details'] != null)
                  ...(geography['administrative_units']['details'] as List<dynamic>).map((detail) => '  - $detail'),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Kinh tế
        if (economy != null) ...[
          _buildInfoCard(
            'Kinh tế',
            Icons.business,
            [
              'GRDP: ${economy['grdp'] ?? 'N/A'}',
              'Thu ngân sách: ${economy['budget_revenue'] ?? 'N/A'}',
              if (economy['key_industries'] != null) ...[
                'Ngành kinh tế chính:',
                ...(economy['key_industries'] as List<dynamic>).map((industry) => '  - $industry'),
              ],
              if (economy['infrastructure'] != null) ...[
                'Hạ tầng:',
                ...(economy['infrastructure'] as List<dynamic>).map((infra) => '  - $infra'),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Lịch sử
        if (history != null) ...[
          _buildInfoCard(
            'Lịch sử',
            Icons.history,
            [
              'Thời kỳ cổ đại: ${history['ancient_period'] ?? 'N/A'}',
              'Thời Pháp thuộc: ${history['french_colonial'] ?? 'N/A'}',
              'Phát triển hiện đại: ${history['modern_development'] ?? 'N/A'}',
              'Trước sáp nhập: ${history['pre_merger'] ?? 'N/A'}',
              'Sau sáp nhập 2025: ${history['post_merger_2025'] ?? 'N/A'}',
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Văn hóa
        if (culture != null) ...[
          _buildInfoCard(
            'Văn hóa',
            Icons.theater_comedy,
            [
              if (culture['heritage'] != null) ...[
                'Di sản:',
                ...(culture['heritage'] as List<dynamic>).map((heritage) => '  - $heritage'),
              ],
              if (culture['festivals'] != null) ...[
                'Lễ hội:',
                ...(culture['festivals'] as List<dynamic>).map((festival) => '  - $festival'),
              ],
              if (culture['traditional_arts'] != null) ...[
                'Nghệ thuật truyền thống:',
                ...(culture['traditional_arts'] as List<dynamic>).map((art) => '  - $art'),
              ],
              if (culture['craft_villages'] != null) ...[
                'Làng nghề:',
                ...(culture['craft_villages'] as List<dynamic>).map((village) => '  - $village'),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Ẩm thực
          if (culture['famous_foods'] != null) ...[
            _buildInfoCard(
              'Ẩm thực',
              Icons.restaurant,
              (culture['famous_foods'] as List<dynamic>).map((food) => food.toString()).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ],

        // Du lịch
        if (tourism != null) ...[
          _buildInfoCard(
            'Du lịch',
            Icons.beach_access,
            [
              if (tourism['famous_landmarks'] != null) ...[
                'Địa danh nổi tiếng:',
                ...(tourism['famous_landmarks'] as List<dynamic>).map((landmark) => '  - $landmark'),
              ],
              if (tourism['beaches_islands'] != null) ...[
                'Biển đảo:',
                ...(tourism['beaches_islands'] as List<dynamic>).map((beach) => '  - $beach'),
              ],
              'Đặc điểm: ${tourism['attractions'] ?? 'N/A'}',
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Giao thông
        if (transportation != null) ...[
          _buildInfoCard(
            'Giao thông',
            Icons.directions_car,
            [
              if (transportation['ports'] != null) ...[
                'Cảng biển:',
                ...(transportation['ports'] as List<dynamic>).map((port) => '  - $port'),
              ],
              if (transportation['airports'] != null) ...[
                'Sân bay:',
                ...(transportation['airports'] as List<dynamic>).map((airport) => '  - $airport'),
              ],
              if (transportation['highways'] != null) ...[
                'Đường cao tốc:',
                ...(transportation['highways'] as List<dynamic>).map((highway) => '  - $highway'),
              ],
              if (transportation['railways'] != null) ...[
                'Đường sắt:',
                ...(transportation['railways'] as List<dynamic>).map((railway) => '  - $railway'),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Giáo dục
        if (education != null) ...[
          _buildInfoCard(
            'Giáo dục',
            Icons.school,
            [
              if (education['universities'] != null) ...[
                'Đại học:',
                ...(education['universities'] as List<dynamic>).map((university) => '  - $university'),
              ],
              if (education['research_institutes'] != null) ...[
                'Viện nghiên cứu:',
                ...(education['research_institutes'] as List<dynamic>).map((institute) => '  - $institute'),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Sự kiện thú vị
        _buildInfoCard(
          'Sự kiện thú vị',
          Icons.star,
          facts.map((fact) => fact.toString()).toList(),
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