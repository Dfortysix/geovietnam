import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

class VietnamMapWidget extends StatefulWidget {
  final Function(String)? onProvinceTap;
  final Map<String, Color>? provinceColors;
  final Map<String, bool>? unlockedProvinces;
  final bool interactive;

  const VietnamMapWidget({
    Key? key,
    this.onProvinceTap,
    this.provinceColors,
    this.unlockedProvinces,
    this.interactive = true,
  }) : super(key: key);

  @override
  State<VietnamMapWidget> createState() => _VietnamMapWidgetState();
}

class _VietnamMapWidgetState extends State<VietnamMapWidget> {
  String? selectedProvince;
  String? hoveredProvince;
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
  };

  // Danh sách các tỉnh có thể tương tác
  final List<String> interactiveProvinces = [
    'Ha Noi', 'Ho Chi Minh', 'Da Nang', 'Hai Phong', 'Can Tho',
    'Bac Ninh', 'Ca Mau', 'Cao Bang', 'Dien Bien', 'Dong Nai',
    'Gia Lai', 'Ha Tinh', 'Lai Chau', 'Lam Dong', 'Lang Son',
    'Nghe An', 'Ninh Binh', 'Khanh Hoa', 'Dak Lak', 'Quang Ngai',
    'Quang Ninh', 'Quang Tri', 'Son La', 'Tay Ninh', 'Hung Yen',
    'An Giang', 'Truong Sa', 'Hoang Sa'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTapUp: widget.interactive ? _handleTap : null,
          onPanUpdate: widget.interactive ? _handlePanUpdate : null,
          child: Stack(
            children: [
              // Background SVG
              SvgPicture.asset(
                'assets/svg/vietnam_map_split_new.svg',
                fit: BoxFit.contain,
                allowDrawingOutsideViewBox: true,
                colorFilter: ColorFilter.mode(
                  Colors.grey.shade400,
                  BlendMode.srcIn,
                ),
              ),
              
              // Overlay cho các tỉnh đã mở khóa
              if (widget.unlockedProvinces != null)
                ...widget.unlockedProvinces!.entries.map((entry) {
                  if (entry.value) {
                    return _buildProvinceOverlay(entry.key);
                  }
                  return const SizedBox.shrink();
                }).toList(),
              
              // Overlay cho tỉnh đang hover
              if (hoveredProvince != null)
                _buildProvinceOverlay(hoveredProvince!, isHovered: true),
              
              // Overlay cho tỉnh được chọn
              if (selectedProvince != null)
                _buildProvinceOverlay(selectedProvince!, isSelected: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceOverlay(String provinceId, {bool isHovered = false, bool isSelected = false}) {
    final provinceArea = _getProvinceArea(provinceId);
    if (provinceArea == null) return const SizedBox.shrink();
    
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
      left: provinceArea.left,
      top: provinceArea.top,
      child: Container(
        width: provinceArea.width,
        height: provinceArea.height,
        decoration: BoxDecoration(
          color: overlayColor.withOpacity(opacity),
          borderRadius: BorderRadius.circular(4),
          border: isSelected || isHovered 
              ? Border.all(color: overlayColor, width: 2)
              : null,
        ),
      ),
    );
  }

  Rect? _getProvinceArea(String provinceId) {
    // Định nghĩa vùng cho từng tỉnh (tọa độ tương đối 0-1)
    final areas = {
      'Ha Noi': Rect.fromLTWH(0.25, 0.1, 0.1, 0.1),
      'Ho Chi Minh': Rect.fromLTWH(0.2, 0.7, 0.15, 0.15),
      'Da Nang': Rect.fromLTWH(0.4, 0.4, 0.1, 0.1),
      'Hai Phong': Rect.fromLTWH(0.3, 0.1, 0.1, 0.1),
      'Can Tho': Rect.fromLTWH(0.25, 0.75, 0.1, 0.1),
      'Bac Ninh': Rect.fromLTWH(0.3, 0.1, 0.05, 0.05),
      'Ca Mau': Rect.fromLTWH(0.2, 0.8, 0.1, 0.1),
      'Cao Bang': Rect.fromLTWH(0.3, 0.05, 0.1, 0.1),
      'Dien Bien': Rect.fromLTWH(0.1, 0.1, 0.1, 0.1),
      'Dong Nai': Rect.fromLTWH(0.35, 0.65, 0.1, 0.1),
      'Gia Lai': Rect.fromLTWH(0.45, 0.5, 0.1, 0.1),
      'Ha Tinh': Rect.fromLTWH(0.25, 0.25, 0.1, 0.1),
      'Lai Chau': Rect.fromLTWH(0.15, 0.05, 0.1, 0.1),
      'Lam Dong': Rect.fromLTWH(0.4, 0.6, 0.1, 0.1),
      'Lang Son': Rect.fromLTWH(0.35, 0.1, 0.1, 0.1),
      'Nghe An': Rect.fromLTWH(0.25, 0.2, 0.1, 0.1),
      'Ninh Binh': Rect.fromLTWH(0.25, 0.15, 0.1, 0.1),
      'Khanh Hoa': Rect.fromLTWH(0.45, 0.6, 0.1, 0.1),
      'Dak Lak': Rect.fromLTWH(0.45, 0.55, 0.1, 0.1),
      'Quang Ngai': Rect.fromLTWH(0.45, 0.45, 0.1, 0.1),
      'Quang Ninh': Rect.fromLTWH(0.35, 0.1, 0.1, 0.1),
      'Quang Tri': Rect.fromLTWH(0.25, 0.35, 0.1, 0.1),
      'Son La': Rect.fromLTWH(0.2, 0.1, 0.1, 0.1),
      'Tay Ninh': Rect.fromLTWH(0.3, 0.65, 0.1, 0.1),
      'Hung Yen': Rect.fromLTWH(0.3, 0.15, 0.05, 0.05),
      'An Giang': Rect.fromLTWH(0.2, 0.7, 0.1, 0.1),
      'Truong Sa': Rect.fromLTWH(0.6, 0.9, 0.2, 0.1),
      'Hoang Sa': Rect.fromLTWH(0.6, 0.4, 0.1, 0.1),
    };
    
    return areas[provinceId];
  }

  void _handleTap(TapUpDetails details) {
    // Xử lý tap để xác định tỉnh được chọn
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Tính toán vị trí tương đối trong SVG (0-1)
    final size = renderBox.size;
    final relativeX = localPosition.dx / size.width;
    final relativeY = localPosition.dy / size.height;
    
    // Xác định tỉnh dựa trên vị trí tap
    final provinceId = _getProvinceAtPosition(relativeX, relativeY);
    
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

  void _handlePanUpdate(DragUpdateDetails details) {
    // Xử lý hover khi di chuyển ngón tay
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    final size = renderBox.size;
    final relativeX = localPosition.dx / size.width;
    final relativeY = localPosition.dy / size.height;
    
    final provinceId = _getProvinceAtPosition(relativeX, relativeY);
    
    if (provinceId != null && interactiveProvinces.contains(provinceId)) {
      setState(() {
        hoveredProvince = provinceId;
      });
    } else {
      setState(() {
        hoveredProvince = null;
      });
    }
  }

  String? _getProvinceAtPosition(double x, double y) {
    // Logic đơn giản để xác định tỉnh dựa trên vị trí
    // Trong thực tế, bạn sẽ cần parse SVG path và kiểm tra point-in-polygon
    
    // Khu vực Hà Nội (khoảng giữa phía Bắc)
    if (x >= 0.25 && x <= 0.35 && y >= 0.1 && y <= 0.2) {
      return 'Ha Noi';
    }
    
    // Khu vực TP.HCM (phía Nam)
    if (x >= 0.2 && x <= 0.35 && y >= 0.7 && y <= 0.85) {
      return 'Ho Chi Minh';
    }
    
    // Khu vực Đà Nẵng (miền Trung)
    if (x >= 0.4 && x <= 0.5 && y >= 0.4 && y <= 0.5) {
      return 'Da Nang';
    }
    
    // Khu vực Hải Phòng (Đông Bắc)
    if (x >= 0.3 && x <= 0.4 && y >= 0.1 && y <= 0.2) {
      return 'Hai Phong';
    }
    
    // Khu vực Cần Thơ (ĐBSCL)
    if (x >= 0.25 && x <= 0.35 && y >= 0.75 && y <= 0.85) {
      return 'Can Tho';
    }
    
    // Khu vực Bắc Ninh
    if (x >= 0.3 && x <= 0.35 && y >= 0.1 && y <= 0.15) {
      return 'Bac Ninh';
    }
    
    // Khu vực Cà Mau (cực Nam)
    if (x >= 0.2 && x <= 0.3 && y >= 0.8 && y <= 0.9) {
      return 'Ca Mau';
    }
    
    // Khu vực Cao Bằng (cực Bắc)
    if (x >= 0.3 && x <= 0.4 && y >= 0.05 && y <= 0.15) {
      return 'Cao Bang';
    }
    
    // Khu vực Điện Biên (Tây Bắc)
    if (x >= 0.1 && x <= 0.2 && y >= 0.1 && y <= 0.2) {
      return 'Dien Bien';
    }
    
    // Khu vực Đồng Nai (Đông Nam Bộ)
    if (x >= 0.35 && x <= 0.45 && y >= 0.65 && y <= 0.75) {
      return 'Dong Nai';
    }
    
    // Khu vực Gia Lai (Tây Nguyên)
    if (x >= 0.45 && x <= 0.55 && y >= 0.5 && y <= 0.6) {
      return 'Gia Lai';
    }
    
    // Khu vực Hà Tĩnh
    if (x >= 0.25 && x <= 0.35 && y >= 0.25 && y <= 0.35) {
      return 'Ha Tinh';
    }
    
    // Khu vực Lai Châu
    if (x >= 0.15 && x <= 0.25 && y >= 0.05 && y <= 0.15) {
      return 'Lai Chau';
    }
    
    // Khu vực Lâm Đồng
    if (x >= 0.4 && x <= 0.5 && y >= 0.6 && y <= 0.7) {
      return 'Lam Dong';
    }
    
    // Khu vực Lạng Sơn
    if (x >= 0.35 && x <= 0.45 && y >= 0.1 && y <= 0.2) {
      return 'Lang Son';
    }
    
    // Khu vực Nghệ An
    if (x >= 0.25 && x <= 0.35 && y >= 0.2 && y <= 0.3) {
      return 'Nghe An';
    }
    
    // Khu vực Ninh Bình
    if (x >= 0.25 && x <= 0.35 && y >= 0.15 && y <= 0.25) {
      return 'Ninh Binh';
    }
    
    // Khu vực Khánh Hòa
    if (x >= 0.45 && x <= 0.55 && y >= 0.6 && y <= 0.7) {
      return 'Khanh Hoa';
    }
    
    // Khu vực Đắk Lắk
    if (x >= 0.45 && x <= 0.55 && y >= 0.55 && y <= 0.65) {
      return 'Dak Lak';
    }
    
    // Khu vực Quảng Ngãi
    if (x >= 0.45 && x <= 0.55 && y >= 0.45 && y <= 0.55) {
      return 'Quang Ngai';
    }
    
    // Khu vực Quảng Ninh
    if (x >= 0.35 && x <= 0.45 && y >= 0.1 && y <= 0.2) {
      return 'Quang Ninh';
    }
    
    // Khu vực Quảng Trị
    if (x >= 0.25 && x <= 0.35 && y >= 0.35 && y <= 0.45) {
      return 'Quang Tri';
    }
    
    // Khu vực Sơn La
    if (x >= 0.2 && x <= 0.3 && y >= 0.1 && y <= 0.2) {
      return 'Son La';
    }
    
    // Khu vực Tây Ninh
    if (x >= 0.3 && x <= 0.4 && y >= 0.65 && y <= 0.75) {
      return 'Tay Ninh';
    }
    
    // Khu vực Hưng Yên
    if (x >= 0.3 && x <= 0.35 && y >= 0.15 && y <= 0.2) {
      return 'Hung Yen';
    }
    
    // Khu vực An Giang
    if (x >= 0.2 && x <= 0.3 && y >= 0.7 && y <= 0.8) {
      return 'An Giang';
    }
    
    // Khu vực Trường Sa
    if (x >= 0.6 && x <= 0.8 && y >= 0.9 && y <= 1.0) {
      return 'Truong Sa';
    }
    
    // Khu vực Hoàng Sa
    if (x >= 0.6 && x <= 0.7 && y >= 0.4 && y <= 0.5) {
      return 'Hoang Sa';
    }
    
    return null;
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
    };
    
    return nameMap[provinceId] ?? provinceId;
  }
}

 