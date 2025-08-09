import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/province_detail_service.dart';
import '../models/province.dart';
import '../data/provinces_data.dart';
import 'province_detail_widget.dart';

class ProvinceOverviewWidget extends StatefulWidget {
  final Province province;
  final String? backgroundImagePath;
  final VoidCallback? onDetailPressed;

  const ProvinceOverviewWidget({
    super.key,
    required this.province,
    this.backgroundImagePath,
    this.onDetailPressed,
  });

  @override
  State<ProvinceOverviewWidget> createState() => _ProvinceOverviewWidgetState();
}

class _ProvinceOverviewWidgetState extends State<ProvinceOverviewWidget> {
  Map<String, dynamic>? _overviewData;
  bool _isLoading = true;
  bool _hasDetailedData = false;

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  Future<void> _loadOverviewData() async {
    try {
      // Kiểm tra xem có dữ liệu JSON chi tiết không (chỉ để biết có thể mở chi tiết)
      final hasData = await ProvinceDetailService.hasDetailedData(widget.province.id);
      
      setState(() {
        _hasDetailedData = hasData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasDetailedData = false;
        _isLoading = false;
      });
    }
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryOrange.withValues(alpha: 0.3),
            AppTheme.primaryOrange.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250, // Tăng từ 200 lên 250 để có thêm không gian
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            if (widget.backgroundImagePath != null)
              Positioned.fill(
                child: Image.asset(
                  widget.backgroundImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackBackground();
                  },
                ),
              ),
            // Fallback background
            if (widget.backgroundImagePath == null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            // Overlay để text dễ đọc
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : _buildBasicContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.province.isUnlocked 
                    ? Icons.check_circle 
                    : Icons.lock,
                color: widget.province.isUnlocked 
                    ? Colors.green 
                    : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.province.nameVietnamese,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!widget.province.isUnlocked) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Chưa mở khóa',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.province.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (widget.province.isUnlocked) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Thông tin thú vị:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onDetailPressed ?? () {
                    // Default navigation if no callback provided
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProvinceDetailWidget(
                          provinceId: widget.province.id,
                          provinceName: widget.province.nameVietnamese,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Chi tiết'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...widget.province.facts.map((fact) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppTheme.primaryOrange)),
                  Expanded(
                    child: Text(
                      fact,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedContent() {
    // Luôn sử dụng thông tin từ province data cho phần tổng quan
    final title = widget.province.nameVietnamese;
    final description = widget.province.description;
    final facts = widget.province.facts;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.province.isUnlocked 
                    ? Icons.check_circle 
                    : Icons.lock,
                color: widget.province.isUnlocked 
                    ? Colors.green 
                    : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!widget.province.isUnlocked) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Chưa mở khóa',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (widget.province.isUnlocked) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Thông tin thú vị:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onDetailPressed ?? () {
                    // Default navigation if no callback provided
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProvinceDetailWidget(
                          provinceId: widget.province.id,
                          provinceName: widget.province.nameVietnamese,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Chi tiết'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Hiển thị facts từ province data
            ...facts.map((fact) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppTheme.primaryOrange)),
                  Expanded(
                    child: Text(
                      fact,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
} 