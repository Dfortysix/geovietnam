import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';
import 'dart:ui' as ui;
import '../theme/app_theme.dart';

class SvgCanvasVietnamMapWidget extends StatefulWidget {
  final Function(String)? onProvinceTap;
  final Map<String, bool>? unlockedProvinces;
  final bool interactive;
  final String svgAssetPath;

  const SvgCanvasVietnamMapWidget({
    super.key,
    this.onProvinceTap,
    this.unlockedProvinces,
    this.interactive = true,
    this.svgAssetPath = 'assets/svg/vietnam_map_split_new.svg',
  });

  @override
  State<SvgCanvasVietnamMapWidget> createState() => _SvgCanvasVietnamMapWidgetState();
}

class _SvgCanvasVietnamMapWidgetState extends State<SvgCanvasVietnamMapWidget> {
  String? selectedProvince;
  String? hoveredProvince;
  Map<String, List<List<Offset>>>? _provincePaths;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSvgData();
  }

  Future<void> _loadSvgData() async {
    try {
      final svgString = await DefaultAssetBundle.of(context).loadString(widget.svgAssetPath);
      final document = XmlDocument.parse(svgString);
      
      final Map<String, List<List<Offset>>> provincePaths = {};
      
      // Parse path elements
      final paths = document.findAllElements('path');
      print('Tìm thấy ${paths.length} path elements');
      
      for (final path in paths) {
        final id = path.getAttribute('id');
        final d = path.getAttribute('d');
        
        if (id != null && d != null) {
          final polygons = _parseSvgPath(d);
          if (polygons.isNotEmpty) {
            provincePaths[id] = polygons;
            print('Đã parse tỉnh: $id với ${polygons.length} polygons');
          } else {
            print('Không parse được tỉnh: $id');
          }
        }
      }
      
      // Parse g elements (groups that contain paths)
      final groups = document.findAllElements('g');
      print('Tìm thấy ${groups.length} group elements');
      
      for (final group in groups) {
        final groupId = group.getAttribute('id');
        if (groupId != null) {
          // Find all path elements within this group
          final groupPaths = group.findAllElements('path');
          final List<List<Offset>> allPolygons = [];
          
          for (final path in groupPaths) {
            final d = path.getAttribute('d');
            if (d != null) {
              final polygons = _parseSvgPath(d);
              allPolygons.addAll(polygons);
            }
          }
          
          if (allPolygons.isNotEmpty) {
            provincePaths[groupId] = allPolygons;
            print('Đã parse tỉnh group: $groupId với ${allPolygons.length} polygons');
          } else {
            print('Không parse được tỉnh group: $groupId');
          }
        }
      }
      
      print('Tổng cộng parse được ${provincePaths.length} tỉnh');
      print('Danh sách tỉnh: ${provincePaths.keys.toList()}');
      
      if (mounted) {
        setState(() {
          _provincePaths = provincePaths;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi parse SVG: $e');
      if (mounted) {
        setState(() {
          _error = 'Lỗi tải SVG: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<List<Offset>> _parseSvgPath(String pathData) {
    final List<List<Offset>> polygons = [];
    final List<Offset> currentPolygon = [];
    
    // Parse SVG path commands
    final commands = _parsePathCommands(pathData);
    
    for (final command in commands) {
      switch (command.type) {
        case 'M': // Move to
          if (currentPolygon.isNotEmpty) {
            polygons.add(List.from(currentPolygon));
            currentPolygon.clear();
          }
          currentPolygon.add(Offset(command.x, command.y));
          break;
        case 'L': // Line to
          currentPolygon.add(Offset(command.x, command.y));
          break;
        case 'Z': // Close path
        case 'z':
          if (currentPolygon.isNotEmpty) {
            currentPolygon.add(currentPolygon.first); // Close the polygon
            polygons.add(List.from(currentPolygon));
            currentPolygon.clear();
          }
          break;
        case 'H': // Horizontal line
          if (currentPolygon.isNotEmpty) {
            final lastPoint = currentPolygon.last;
            currentPolygon.add(Offset(command.x, lastPoint.dy));
          }
          break;
        case 'V': // Vertical line
          if (currentPolygon.isNotEmpty) {
            final lastPoint = currentPolygon.last;
            currentPolygon.add(Offset(lastPoint.dx, command.y));
          }
          break;
      }
    }
    
    // Add remaining polygon
    if (currentPolygon.isNotEmpty) {
      polygons.add(List.from(currentPolygon));
    }
    
    return polygons;
  }

  List<PathCommand> _parsePathCommands(String pathData) {
    final List<PathCommand> commands = [];
    
    // Improved regex to handle more complex path data
    final RegExp commandRegex = RegExp(r'([MLHVZmlhvz])\s*([^MLHVZmlhvz]*)');
    
    for (final match in commandRegex.allMatches(pathData)) {
      final command = match.group(1)!;
      final params = match.group(2)?.trim() ?? '';
      
      if (command == 'M' || command == 'L') {
        final numbers = _parseNumbers(params);
        for (int i = 0; i < numbers.length; i += 2) {
          if (i + 1 < numbers.length) {
            commands.add(PathCommand(
              type: command,
              x: numbers[i],
              y: numbers[i + 1],
            ));
          }
        }
      } else if (command == 'H') {
        final numbers = _parseNumbers(params);
        for (final number in numbers) {
          commands.add(PathCommand(
            type: command,
            x: number,
            y: 0,
          ));
        }
      } else if (command == 'V') {
        final numbers = _parseNumbers(params);
        for (final number in numbers) {
          commands.add(PathCommand(
            type: command,
            x: 0,
            y: number,
          ));
        }
      } else if (command == 'Z' || command == 'z') {
        commands.add(PathCommand(
          type: 'Z',
          x: 0,
          y: 0,
        ));
      }
    }
    
    return commands;
  }

  List<double> _parseNumbers(String text) {
    // Improved regex to handle scientific notation and more number formats
    final RegExp numberRegex = RegExp(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');
    return numberRegex.allMatches(text).map((match) {
      try {
        return double.parse(match.group(0)!);
      } catch (e) {
        print('Lỗi parse số: ${match.group(0)} - $e');
        return 0.0;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 600,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        height: 600,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_provincePaths == null || _provincePaths!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 600,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Không có dữ liệu tỉnh'),
        ),
      );
    }

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
          onPanUpdate: widget.interactive ? _handleHover : null,
          child: CustomPaint(
            size: const Size(800, 600),
            painter: SvgVietnamMapPainter(
              provincePaths: _provincePaths!,
              selectedProvince: selectedProvince,
              hoveredProvince: hoveredProvince,
              unlockedProvinces: widget.unlockedProvinces,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    if (_provincePaths == null) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    final tappedProvince = _getProvinceAtPosition(localPosition);
    
    if (tappedProvince != null) {
      setState(() {
        selectedProvince = tappedProvince;
        hoveredProvince = null;
      });
      
      if (widget.onProvinceTap != null) {
        widget.onProvinceTap!(tappedProvince);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn đã chọn: ${_getProvinceName(tappedProvince)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleHover(DragUpdateDetails details) {
    if (_provincePaths == null) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    final hoveredProvince = _getProvinceAtPosition(localPosition);
    
    if (this.hoveredProvince != hoveredProvince) {
      setState(() {
        this.hoveredProvince = hoveredProvince;
      });
    }
  }

  String? _getProvinceAtPosition(Offset position) {
    if (_provincePaths == null) return null;
    
    for (final entry in _provincePaths!.entries) {
      if (_isPointInPolygons(position, entry.value)) {
        return entry.key;
      }
    }
    return null;
  }

  bool _isPointInPolygons(Offset point, List<List<Offset>> polygons) {
    for (final polygon in polygons) {
      if (_isPointInPolygon(point, polygon)) {
        return true;
      }
    }
    return false;
  }

  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    
    bool inside = false;
    int j = polygon.length - 1;
    
    for (int i = 0; i < polygon.length; i++) {
      if (((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy)) &&
          (point.dx < (polygon[j].dx - polygon[i].dx) * (point.dy - polygon[i].dy) / 
           (polygon[j].dy - polygon[i].dy) + polygon[i].dx)) {
        inside = !inside;
      }
      j = i;
    }
    
    return inside;
  }

  String _getProvinceName(String provinceId) {
    final provinceNames = {
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
    
    return provinceNames[provinceId] ?? provinceId;
  }
}

class PathCommand {
  final String type;
  final double x;
  final double y;

  PathCommand({
    required this.type,
    required this.x,
    required this.y,
  });
}

class SvgVietnamMapPainter extends CustomPainter {
  final Map<String, List<List<Offset>>> provincePaths;
  final String? selectedProvince;
  final String? hoveredProvince;
  final Map<String, bool>? unlockedProvinces;

  SvgVietnamMapPainter({
    required this.provincePaths,
    this.selectedProvince,
    this.hoveredProvince,
    this.unlockedProvinces,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ background gradient
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.lightBlue.shade50,
        Colors.lightGreen.shade50,
      ],
    );
    
    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Offset.zero & size, backgroundPaint);
    
    // Vẽ các tỉnh từ SVG data
    for (final entry in provincePaths.entries) {
      final provinceId = entry.key;
      final polygons = entry.value;
      
      final isSelected = provinceId == selectedProvince;
      final isHovered = provinceId == hoveredProvince;
      final isUnlocked = unlockedProvinces?[provinceId] ?? false;
      
      // Xác định màu sắc
      Color fillColor;
      Color borderColor;
      double borderWidth;
      
      if (isSelected) {
        fillColor = AppTheme.primaryOrange.withOpacity(0.7);
        borderColor = AppTheme.primaryOrange;
        borderWidth = 3.0;
      } else if (isHovered) {
        fillColor = Colors.yellow.withOpacity(0.5);
        borderColor = Colors.yellow.shade700;
        borderWidth = 2.5;
      } else if (isUnlocked) {
        fillColor = AppTheme.primaryOrange.withOpacity(0.4);
        borderColor = AppTheme.primaryOrange;
        borderWidth = 1.5;
      } else {
        fillColor = Colors.grey.withOpacity(0.3);
        borderColor = Colors.grey.shade600;
        borderWidth = 1.0;
      }
      
      // Vẽ fill cho tất cả polygons của tỉnh
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      
      for (final polygon in polygons) {
        final path = _createPathFromPolygon(polygon);
        canvas.drawPath(path, fillPaint);
      }
      
      // Vẽ border cho tất cả polygons của tỉnh
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      for (final polygon in polygons) {
        final path = _createPathFromPolygon(polygon);
        canvas.drawPath(path, borderPaint);
      }
      
      // Vẽ tên tỉnh nếu được chọn hoặc hover
      if (isSelected || isHovered) {
        _drawProvinceLabel(canvas, provinceId, polygons.first);
      }
    }
  }

  Path _createPathFromPolygon(List<Offset> polygon) {
    final path = Path();
    if (polygon.isNotEmpty) {
      path.moveTo(polygon.first.dx, polygon.first.dy);
      for (int i = 1; i < polygon.length; i++) {
        path.lineTo(polygon[i].dx, polygon[i].dy);
      }
      path.close();
    }
    return path;
  }

  void _drawProvinceLabel(Canvas canvas, String provinceId, List<Offset> polygon) {
    // Tính center của polygon
    double centerX = 0, centerY = 0;
    for (final point in polygon) {
      centerX += point.dx;
      centerY += point.dy;
    }
    centerX /= polygon.length;
    centerY /= polygon.length;
    
    final provinceNames = {
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
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: provinceNames[provinceId] ?? provinceId,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 2,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        centerY - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
} 