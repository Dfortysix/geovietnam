import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/gallery_description_service.dart';

class GalleryFullScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String provinceName;
  final String provinceId;

  const GalleryFullScreen({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.provinceName,
    required this.provinceId,
  });

  @override
  State<GalleryFullScreen> createState() => _GalleryFullScreenState();
}

class _GalleryFullScreenState extends State<GalleryFullScreen> {
  late PageController _pageController;
  late int _currentIndex;
  List<String> _validImages = [];
  List<String> _imageDescriptions = [];
  bool _isLoadingDescriptions = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _filterValidImages();
    _loadImageDescriptions();
  }

  void _filterValidImages() {
    // Tạm thời giữ nguyên tất cả ảnh, Flutter sẽ xử lý lỗi tự động
    _validImages = List.from(widget.images);
  }

  Future<void> _loadImageDescriptions() async {
    try {
      final descriptions = await GalleryDescriptionService.getGalleryDescriptions(widget.provinceId);
      setState(() {
        _imageDescriptions = descriptions;
        _isLoadingDescriptions = false;
      });
    } catch (e) {
      setState(() {
        _imageDescriptions = GalleryDescriptionService.getDefaultDescriptions(widget.provinceId);
        _isLoadingDescriptions = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_validImages.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          elevation: 0,
          title: Text(
            '${widget.provinceName} - Gallery',
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: Colors.white,
                size: 80,
              ),
              SizedBox(height: 16),
              Text(
                'Chưa có ảnh trong gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        elevation: 0,
        title: Text(
          '${widget.provinceName} - Ảnh ${_currentIndex + 1}/${_validImages.length}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _validImages.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Expanded(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: Center(
                          child: Image.asset(
                            _validImages[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade800,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Không thể tải ảnh',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    // Description section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.9),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mô tả ảnh',
                                style: TextStyle(
                                  color: AppTheme.primaryOrange,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isLoadingDescriptions)
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Đang tải mô tả...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              _currentIndex < _imageDescriptions.length 
                                  ? _imageDescriptions[_currentIndex]
                                  : 'Mô tả cho ảnh ${_currentIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Thumbnail navigation
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _validImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndex == index 
                            ? AppTheme.primaryOrange 
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        _validImages[index],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade700,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 