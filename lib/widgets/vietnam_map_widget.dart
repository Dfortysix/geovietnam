import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'dart:async';
import '../services/svg_path_service.dart';

class VietnamMapWidget extends StatefulWidget {
  final Function(String)? onProvinceTap;
  final Map<String, Color>? provinceColors;
  final Map<String, bool>? unlockedProvinces;
  final bool interactive;

  const VietnamMapWidget({
    super.key,
    this.onProvinceTap,
    this.provinceColors,
    this.unlockedProvinces,
    this.interactive = true,
  });

  @override
  State<VietnamMapWidget> createState() => _VietnamMapWidgetState();
}

class _VietnamMapWidgetState extends State<VietnamMapWidget> with TickerProviderStateMixin {
  String? selectedProvince;
  String? hoveredProvince;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset? _startingFocalPoint;
  double? _startingScale;
  Offset? _startingOffset;
  
  // Cache cho SVG để tránh rebuild
  late final SvgPicture _svgPicture;
  
  // Animation controller cho smooth transitions
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  
  // Debounce cho hover để tránh lag
  Timer? _hoverTimer;
  
  Map<String, Color> defaultColors = {
    'Ha Noi': Colors.red.shade300,
    'Ho Chi Minh': Colors.blue.shade300,
    'Da Nang': Colors.green.shade300,
    'Hai Phong': Colors.orange.shade300,
    'Can Tho': Colors.purple.shade300,
    'Bac Ninh': Colors.teal.shade300,
    'Ca Mau': Colors.indigo.shade300,
    'Cao Bang': Colors.cyan.shade300,
    'Dien Bien': Colors.lime.shade300,
    'Dong Nai': Colors.amber.shade300,
    'Gia Lai': Colors.pink.shade300,
    'Ha Tinh': Colors.brown.shade300,
    'Lai Chau': Colors.deepOrange.shade300,
    'Lam Dong': Colors.lightGreen.shade300,
    'Lang Son': Colors.deepPurple.shade300,
    'Nghe An': Colors.blueGrey.shade300,
    'Ninh Binh': Colors.lightBlue.shade300,
    'Khanh Hoa': Colors.yellow.shade300,
    'Dak Lak': Colors.grey.shade300,
    'Quang Ngai': Colors.orange.shade300,
    'Quang Ninh': Colors.red.shade300,
    'Quang Tri': Colors.green.shade300,
    'Son La': Colors.blue.shade300,
    'Tay Ninh': Colors.purple.shade300,
    'Hung Yen': Colors.teal.shade300,
    'An Giang': Colors.indigo.shade300,
    'Truong Sa': Colors.cyan.shade300,
    'Hoang Sa': Colors.lime.shade300,
    'Thai Nguyen': Colors.deepOrange.shade300,
    'Thanh Hoa': Colors.brown.shade300,
    'Hue': Colors.pink.shade300,
    'Dong Thap': Colors.amber.shade300,
    'Vinh Long': Colors.lightGreen.shade300,
    'Phu Tho': Colors.deepPurple.shade300,
    'Tuyen Quang': Colors.blueGrey.shade300,
    'Lao Cai': Colors.lightBlue.shade300,
  };

  // Danh sách các tỉnh có thể tương tác
  final List<String> interactiveProvinces = [
    'Ha Noi', 'Ho Chi Minh', 'Da Nang', 'Hai Phong', 'Can Tho',
    'Bac Ninh', 'Ca Mau', 'Cao Bang', 'Dien Bien', 'Dong Nai',
    'Gia Lai', 'Ha Tinh', 'Lai Chau', 'Lam Dong', 'Lang Son',
    'Nghe An', 'Ninh Binh', 'Khanh Hoa', 'Dak Lak', 'Quang Ngai',
    'Quang Ninh', 'Quang Tri', 'Son La', 'Tay Ninh', 'Hung Yen',
    'An Giang', 'Truong Sa', 'Hoang Sa', 'Thai Nguyen', 'Thanh Hoa',
    'Hue', 'Dong Thap', 'Vinh Long', 'Phu Tho', 'Tuyen Quang', 'Lao Cai'
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize SVG Path Service
    _initializeSvgPathService();
    
    // Cache SVG picture
    _svgPicture = SvgPicture.asset(
      'assets/svg/vietnam_map_split_new.svg',
      width: 800,
      height: 600,
      fit: BoxFit.contain,
      allowDrawingOutsideViewBox: true,
      colorFilter: ColorFilter.mode(
        Colors.grey.shade400,
        BlendMode.srcIn,
      ),
    );
    
    // Setup animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeSvgPathService() async {
    await SvgPathService.initialize();
    // Debug: Print loaded provinces
    SvgPathService.debugPrintProvinces();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 600,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTapUp: widget.interactive ? _handleTap : null,
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            alignment: Alignment.center,
            child: SizedBox(
              width: 800,
              height: 600,
              child: Stack(
                children: [
                  // Background SVG (cached)
                  _svgPicture,
                  
                  // Chỉ render overlay cho tỉnh được chọn hoặc hover
                  if (selectedProvince != null)
                    _buildProvinceOverlay(selectedProvince!, isSelected: true),
                  
                  if (hoveredProvince != null && hoveredProvince != selectedProvince)
                    _buildProvinceOverlay(hoveredProvince!, isHovered: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _startingFocalPoint = details.focalPoint;
    _startingScale = _scale;
    _startingOffset = _offset;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_startingScale == null || _startingOffset == null) return;
    
    setState(() {
      _scale = (_startingScale! * details.scale).clamp(0.5, 4.0);
      
      final Offset normalizedOffset = details.focalPoint - _startingFocalPoint!;
      _offset = _startingOffset! + normalizedOffset;
    });
    
    // Debounce hover detection để tránh lag
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(milliseconds: 50), () {
      _updateHoverState(details.focalPoint);
    });
  }

  void _updateHoverState(Offset globalPosition) {
    if (!mounted) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(globalPosition);
    
    // Convert to SVG coordinates
    final svgPosition = _convertToSvgCoordinates(localPosition);
    
    // Use SVG Path Service for detection
    final provinceId = SvgPathService.getProvinceAtPosition(svgPosition);
    
    if (provinceId != null && interactiveProvinces.contains(provinceId)) {
      if (hoveredProvince != provinceId) {
        setState(() {
          hoveredProvince = provinceId;
        });
        _animationController.forward();
      }
    } else {
      if (hoveredProvince != null) {
        setState(() {
          hoveredProvince = null;
        });
        _animationController.reverse();
      }
    }
  }

  Widget _buildProvinceOverlay(String provinceId, {bool isHovered = false, bool isSelected = false}) {
    final provinceBounds = SvgPathService.getProvinceBounds(provinceId);
    if (provinceBounds == null) return const SizedBox.shrink();
    
    // Convert SVG bounds to relative coordinates
    final relativeBounds = Rect.fromLTWH(
      provinceBounds.left / 800,
      provinceBounds.top / 600,
      provinceBounds.width / 800,
      provinceBounds.height / 600,
    );
    
    Color overlayColor;
    double opacity;
    
    if (isSelected) {
      overlayColor = Colors.orange;
      opacity = 0.6;
    } else if (isHovered) {
      overlayColor = Colors.yellow;
      opacity = 0.4;
    } else {
      final baseColor = widget.provinceColors?[provinceId] ?? defaultColors[provinceId] ?? Colors.blue;
      overlayColor = baseColor;
      opacity = 0.3;
    }
    
    return Positioned(
      left: relativeBounds.left * 800,
      top: relativeBounds.top * 600,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: relativeBounds.width * 800,
              height: relativeBounds.height * 600,
              decoration: BoxDecoration(
                color: overlayColor.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(4),
                border: isSelected || isHovered 
                    ? Border.all(color: overlayColor, width: 2)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Convert to SVG coordinates
    final svgPosition = _convertToSvgCoordinates(localPosition);
    
    // Use SVG Path Service for detection
    final provinceId = SvgPathService.getProvinceAtPosition(svgPosition);
    
    if (provinceId != null && interactiveProvinces.contains(provinceId)) {
      setState(() {
        selectedProvince = provinceId;
        hoveredProvince = null;
      });
      
      if (widget.onProvinceTap != null) {
        widget.onProvinceTap!(provinceId);
      }
      
      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn đã chọn: ${_getProvinceName(provinceId)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Convert local coordinates to SVG coordinates
  Offset _convertToSvgCoordinates(Offset localPosition) {
    // Apply inverse transform
    final inverseScale = 1.0 / _scale;
    final inverseOffset = Offset(-_offset.dx * inverseScale, -_offset.dy * inverseScale);
    
    final transformedPosition = Offset(
      (localPosition.dx * inverseScale) + inverseOffset.dx,
      (localPosition.dy * inverseScale) + inverseOffset.dy,
    );
    
    // Convert to SVG coordinate system (800x600)
    return Offset(
      transformedPosition.dx * 800 / 600, // Assuming widget width is 600
      transformedPosition.dy * 600 / 600,  // Assuming widget height is 600
    );
  }

  String _getProvinceName(String provinceId) {
    final nameMap = {
      'Ha Noi': 'Hà Nội',
      'Ho Chi Minh': 'Thành phố Hồ Chí Minh',
      'Da Nang': 'Đà Nẵng',
      'Hai Phong': 'Hải Phòng',
      'Can Tho': 'Cần Thơ',
      'Bac Ninh': 'Bắc Ninh',
      'Ca Mau': 'Cà Mau',
      'Cao Bang': 'Cao Bằng',
      'Dien Bien': 'Điện Biên',
      'Dong Nai': 'Đồng Nai',
      'Gia Lai': 'Gia Lai',
      'Ha Tinh': 'Hà Tĩnh',
      'Lai Chau': 'Lai Châu',
      'Lam Dong': 'Lâm Đồng',
      'Lang Son': 'Lạng Sơn',
      'Nghe An': 'Nghệ An',
      'Ninh Binh': 'Ninh Bình',
      'Khanh Hoa': 'Khánh Hòa',
      'Dak Lak': 'Đắk Lắk',
      'Quang Ngai': 'Quảng Ngãi',
      'Quang Ninh': 'Quảng Ninh',
      'Quang Tri': 'Quảng Trị',
      'Son La': 'Sơn La',
      'Tay Ninh': 'Tây Ninh',
      'Hung Yen': 'Hưng Yên',
      'An Giang': 'An Giang',
      'Truong Sa': 'Trường Sa',
      'Hoang Sa': 'Hoàng Sa',
      'Thai Nguyen': 'Thái Nguyên',
      'Thanh Hoa': 'Thanh Hóa',
      'Hue': 'Huế',
      'Dong Thap': 'Đồng Tháp',
      'Vinh Long': 'Vĩnh Long',
      'Phu Tho': 'Phú Thọ',
      'Tuyen Quang': 'Tuyên Quang',
      'Lao Cai': 'Lào Cai',
    };
    
    return nameMap[provinceId] ?? provinceId;
  }
}

 