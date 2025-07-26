import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VietnamMapWidget extends StatefulWidget {
  final Function(String)? onProvinceTap;
  final Map<String, Color>? provinceColors;
  final bool interactive;

  const VietnamMapWidget({
    Key? key,
    this.onProvinceTap,
    this.provinceColors,
    this.interactive = true,
  }) : super(key: key);

  @override
  State<VietnamMapWidget> createState() => _VietnamMapWidgetState();
}

class _VietnamMapWidgetState extends State<VietnamMapWidget> {
  String? selectedProvince;
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
          child: SvgPicture.asset(
            'assets/svg/vietnam_map_split_new.svg',
            fit: BoxFit.contain,
            allowDrawingOutsideViewBox: true,
            colorFilter: ColorFilter.mode(
              Colors.grey.shade400,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    // Xử lý tap để xác định tỉnh được chọn
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Đây là logic đơn giản để demo
    // Trong thực tế, bạn sẽ cần parse SVG path và kiểm tra point-in-polygon
    setState(() {
      selectedProvince = 'Ha Noi'; // Tạm thời chọn Hà Nội
    });
    
    if (widget.onProvinceTap != null) {
      widget.onProvinceTap!('Ha Noi');
    }
    
    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bạn đã chọn: Hà Nội'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Model cho thông tin tỉnh
class Province {
  final String id;
  final String name;
  final String pathData;
  final Color color;

  Province({
    required this.id,
    required this.name,
    required this.pathData,
    required this.color,
  });
}

// Service để parse SVG và quản lý bản đồ
class VietnamMapService {
  static List<Province> parseProvincesFromSvg(String svgContent) {
    List<Province> provinces = [];
    
    // Parse SVG content để extract các path của tỉnh
    // Đây là implementation cơ bản, bạn có thể cải thiện
    
    return provinces;
  }

  static bool isPointInProvince(Offset point, String pathData) {
    // Kiểm tra xem một điểm có nằm trong path của tỉnh không
    // Sử dụng thuật toán point-in-polygon
    return false; // Placeholder
  }
} 