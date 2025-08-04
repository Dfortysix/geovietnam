import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';
import 'dart:ui' as ui;
import 'dart:math';
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
  
       // Zoom và pan variables
  double _scale = 1.0;
  double _minScale = 0.5; // Giới hạn zoom out để có thể thu nhỏ hơn
  double _maxScale = 3.0; // Giới hạn zoom in để có thể phóng to hơn
  Offset _offset = Offset.zero;
  Offset? _focalPoint;
  
  // Bản đồ bounds để căn giữa
  Rect? _mapBounds;
  Size? _containerSize;
  double? _initialFitScale; // Lưu scale ban đầu để có thể reset

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
       
       for (final path in paths) {
         final id = path.getAttribute('id');
         final d = path.getAttribute('d');
         
         if (id != null && d != null) {
           // Skip background/container elements
           if (id.contains('Vector') || 
               id.contains('vietnam_map_split_new_01_07')) {
             continue;
           }
           
           final polygons = _parseSvgPath(d);
           if (polygons.isNotEmpty) {
             provincePaths[id] = polygons;
           }
         }
       }
      
             // Parse g elements (groups that contain paths)
       final groups = document.findAllElements('g');
       
       for (final group in groups) {
         final groupId = group.getAttribute('id');
         if (groupId != null) {
           // Skip background/container layers
           if (groupId.contains('vietnam_map_split_new_01_07') || 
               groupId.contains('Vector')) {
             continue;
           }
           
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
           }
         }
       }
      
      
      
             if (mounted) {
         setState(() {
           _provincePaths = provincePaths;
           _isLoading = false;
         });
         
         // Tính toán bounds của bản đồ sau khi load xong
         _calculateMapBounds();
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

   void _calculateMapBounds() {
     if (_provincePaths == null || _provincePaths!.isEmpty) return;
     
     double minX = double.infinity;
     double minY = double.infinity;
     double maxX = -double.infinity;
     double maxY = -double.infinity;
     
     // Tìm bounds của tất cả tỉnh
     for (final polygons in _provincePaths!.values) {
       for (final polygon in polygons) {
         for (final point in polygon) {
           minX = min(minX, point.dx);
           minY = min(minY, point.dy);
           maxX = max(maxX, point.dx);
           maxY = max(maxY, point.dy);
         }
       }
     }
     
            _mapBounds = Rect.fromLTRB(minX, minY, maxX, maxY);
   }

       void _centerMapInContainer() {
      if (_mapBounds == null || _containerSize == null) return;
      
      final mapWidth = _mapBounds!.width;
      final mapHeight = _mapBounds!.height;
      final containerWidth = _containerSize!.width;
      final containerHeight = _containerSize!.height;
      
      // Tính scale để fit bản đồ vào container với margin
      final margin = 20.0;
      final scaleX = (containerWidth - margin * 2) / mapWidth;
      final scaleY = (containerHeight - margin * 2) / mapHeight;
      final fitScale = min(scaleX, scaleY);
      
      // Lưu scale ban đầu và cập nhật scale và offset để căn giữa
      _initialFitScale = fitScale;
      setState(() {
        _scale = fitScale;
        _offset = Offset(
          (containerWidth - mapWidth * fitScale) / 2 - _mapBounds!.left * fitScale,
          (containerHeight - mapHeight * fitScale) / 2 - _mapBounds!.top * fitScale,
        );
      });
    }

         void _resetToInitialView() {
       if (_initialFitScale == null || _mapBounds == null || _containerSize == null) return;
       
       final mapWidth = _mapBounds!.width;
       final mapHeight = _mapBounds!.height;
       final containerWidth = _containerSize!.width;
       final containerHeight = _containerSize!.height;
       
       setState(() {
         _scale = _initialFitScale!;
         _offset = Offset(
           (containerWidth - mapWidth * _initialFitScale!) / 2 - _mapBounds!.left * _initialFitScale!,
           (containerHeight - mapHeight * _initialFitScale!) / 2 - _mapBounds!.top * _initialFitScale!,
         );
       });
     }

     // Tính toán giới hạn pan dựa trên scale hiện tại
     PanLimits _calculatePanLimits() {
       if (_mapBounds == null || _containerSize == null) {
         return PanLimits(minX: -100, maxX: 100, minY: -100, maxY: 100);
       }
       
       final mapWidth = _mapBounds!.width * _scale;
       final mapHeight = _mapBounds!.height * _scale;
       final containerWidth = _containerSize!.width;
       final containerHeight = _containerSize!.height;
       
       // Tính toán giới hạn để bản đồ không bị di chuyển ra ngoài container
       final maxOffsetX = max(0, mapWidth - containerWidth);
       final maxOffsetY = max(0, mapHeight - containerHeight);
       final minOffsetX = min(0, containerWidth - mapWidth);
       final minOffsetY = min(0, containerHeight - mapHeight);
       
       // Thêm margin để có thể di chuyển một chút ra ngoài
       final margin = 50.0;
       
       return PanLimits(
         minX: minOffsetX - margin,
         maxX: maxOffsetX + margin,
         minY: minOffsetY - margin,
         maxY: maxOffsetY + margin,
       );
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
          child: Stack(
            children: [
              GestureDetector(
                onTapUp: widget.interactive ? _handleTap : null,
                onScaleStart: widget.interactive ? _handleScaleStart : null,
                onScaleUpdate: widget.interactive ? _handleScaleUpdate : null,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final containerSize = Size(constraints.maxWidth, constraints.maxHeight);
                    
                    // Lưu kích thước container và chỉ căn giữa bản đồ lần đầu
                    if (_containerSize != containerSize) {
                      _containerSize = containerSize;
                      if (_mapBounds != null && _initialFitScale == null) {
                        // Chỉ căn giữa lần đầu khi load, không reset khi thay đổi kích thước
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _centerMapInContainer();
                        });
                      }
                    }
                    
                    return CustomPaint(
                      size: containerSize,
                      painter: SvgVietnamMapPainter(
                        provincePaths: _provincePaths!,
                        selectedProvince: selectedProvince,
                        hoveredProvince: hoveredProvince,
                        unlockedProvinces: widget.unlockedProvinces,
                        scale: _scale,
                        offset: _offset,
                        containerSize: containerSize,
                      ),
                    );
                  },
                ),
              ),
              // Nút reset ở góc trên bên phải
              Positioned(
                top: 8,
                right: 8,
                child: FloatingActionButton.small(
                  onPressed: _resetToInitialView,
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.center_focus_strong),
                ),
              ),
            ],
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



  String? _getProvinceAtPosition(Offset position) {
    if (_provincePaths == null) return null;
    
    // Chuyển đổi vị trí tap từ screen coordinates sang map coordinates
    final mapPosition = (position - _offset) / _scale;
    
    List<String> foundProvinces = [];
    for (final entry in _provincePaths!.entries) {
      if (_isPointInPolygons(mapPosition, entry.value)) {
        foundProvinces.add(entry.key);
      }
    }
    
    // Nếu không tìm thấy tỉnh nào, thử tìm với vùng click mở rộng cho các đảo nhỏ
    if (foundProvinces.isEmpty) {
      final expandedPosition = mapPosition;
      final searchRadius = 5.0; // Bán kính tìm kiếm mở rộng
      
      for (final entry in _provincePaths!.entries) {
        // Chỉ áp dụng cho Hoàng Sa và Trường Sa
        if (entry.key == 'Hoang Sa' || entry.key == 'Truong Sa') {
          if (_isPointNearPolygons(expandedPosition, entry.value, searchRadius)) {
            foundProvinces.add(entry.key);
          }
        }
      }
    }
    
    if (foundProvinces.isNotEmpty) {
      // Nếu có nhiều tỉnh, chọn tỉnh có diện tích nhỏ nhất (tỉnh cụ thể)
      String selectedProvince = foundProvinces.first;
      double minArea = double.infinity;
      
      for (final provinceId in foundProvinces) {
        final polygons = _provincePaths![provinceId]!;
        double area = 0;
        
        for (final polygon in polygons) {
          // Tính diện tích polygon bằng công thức shoelace
          double polygonArea = 0;
          for (int i = 0; i < polygon.length; i++) {
            final j = (i + 1) % polygon.length;
            polygonArea += polygon[i].dx * polygon[j].dy;
            polygonArea -= polygon[j].dx * polygon[i].dy;
          }
          area += polygonArea.abs() / 2;
        }
        
        if (area < minArea) {
          minArea = area;
          selectedProvince = provinceId;
        }
      }
      
      return selectedProvince;
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

  // Kiểm tra điểm có gần với polygon không (cho các đảo nhỏ)
  bool _isPointNearPolygons(Offset point, List<List<Offset>> polygons, double radius) {
    for (final polygon in polygons) {
      if (_isPointNearPolygon(point, polygon, radius)) {
        return true;
      }
    }
    return false;
  }

  // Kiểm tra điểm có gần với polygon không
  bool _isPointNearPolygon(Offset point, List<Offset> polygon, double radius) {
    // Kiểm tra khoảng cách từ điểm đến các cạnh của polygon
    for (int i = 0; i < polygon.length; i++) {
      final j = (i + 1) % polygon.length;
      final p1 = polygon[i];
      final p2 = polygon[j];
      
      // Tính khoảng cách từ điểm đến đoạn thẳng
      final distance = _distanceToLineSegment(point, p1, p2);
      if (distance <= radius) {
        return true;
      }
    }
    
    // Kiểm tra khoảng cách đến các đỉnh
    for (final vertex in polygon) {
      final distance = (point - vertex).distance;
      if (distance <= radius) {
        return true;
      }
    }
    
    return false;
  }

  // Tính khoảng cách từ điểm đến đoạn thẳng
  double _distanceToLineSegment(Offset point, Offset p1, Offset p2) {
    final A = point.dx - p1.dx;
    final B = point.dy - p1.dy;
    final C = p2.dx - p1.dx;
    final D = p2.dy - p1.dy;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    
    if (lenSq == 0) {
      // p1 và p2 trùng nhau
      return (point - p1).distance;
    }
    
    final param = dot / lenSq;
    
    Offset closest;
    if (param < 0) {
      closest = p1;
    } else if (param > 1) {
      closest = p2;
    } else {
      closest = Offset(p1.dx + param * C, p1.dy + param * D);
    }
    
    return (point - closest).distance;
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

  // Zoom và pan handlers
  void _handleScaleStart(ScaleStartDetails details) {
    _focalPoint = details.focalPoint;
  }

           void _handleScaleUpdate(ScaleUpdateDetails details) {
      if (_focalPoint == null) return;
      
      setState(() {
                 if (details.pointerCount == 1) {
           // Pan (di chuyển) khi có 1 ngón tay
           final focalPointDelta = details.focalPoint - _focalPoint!;
           // Tăng tốc độ pan dựa trên scale - khi zoom in thì pan nhanh hơn
           final panSpeed = 1.0 + (_scale - 1.0) * 0.5; // Tăng tốc độ theo scale
           final newOffset = _offset + focalPointDelta * panSpeed;
          
          // Giới hạn pan dựa trên scale hiện tại và kích thước bản đồ
          final panLimits = _calculatePanLimits();
          
          _offset = Offset(
            newOffset.dx.clamp(panLimits.minX, panLimits.maxX),
            newOffset.dy.clamp(panLimits.minY, panLimits.maxY),
          );
          
          _focalPoint = details.focalPoint;
          
          // Xử lý hover
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.focalPoint);
          final hoveredProvince = _getProvinceAtPosition(localPosition);
          
          if (this.hoveredProvince != hoveredProvince) {
            this.hoveredProvince = hoveredProvince;
          }
                 } else if (details.pointerCount == 2) {
           // Zoom khi có 2 ngón tay
           final scaleFactor = 0.5; // Giảm tốc độ zoom
           final newScale = (_scale * (1 + (details.scale - 1) * scaleFactor)).clamp(_minScale, _maxScale);
           
           // Tính toán vị trí zoom chính xác
           final RenderBox renderBox = context.findRenderObject() as RenderBox;
           final localFocalPoint = renderBox.globalToLocal(_focalPoint!);
           
           // Chuyển đổi từ screen coordinates sang map coordinates (trước khi thay đổi scale)
           final mapFocalPoint = (localFocalPoint - _offset) / _scale;
           
           // Cập nhật scale
           final oldScale = _scale;
           _scale = newScale;
           
           // Tính toán offset mới để giữ nguyên vị trí focal point
           // Công thức: newOffset = localFocalPoint - (mapFocalPoint * newScale)
           final newOffset = localFocalPoint - (mapFocalPoint * _scale);
           
           // Giới hạn offset sau khi zoom
           final panLimits = _calculatePanLimits();
           
           _offset = Offset(
             newOffset.dx.clamp(panLimits.minX, panLimits.maxX),
             newOffset.dy.clamp(panLimits.minY, panLimits.maxY),
           );
           
           _focalPoint = details.focalPoint;
         }
      });
    }

  String _getProvinceName(String provinceId) {
    final provinceNames = {
      // Thành phố trực thuộc Trung ương
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
   final double scale;
   final Offset offset;
   final Size containerSize;

   SvgVietnamMapPainter({
     required this.provincePaths,
     this.selectedProvince,
     this.hoveredProvince,
     this.unlockedProvinces,
     this.scale = 1.0,
     this.offset = Offset.zero,
     required this.containerSize,
   });

     @override
   void paint(Canvas canvas, Size size) {
     // Giới hạn vùng vẽ trong container
     canvas.clipRect(Offset.zero & containerSize);
     
     // Áp dụng transform cho zoom và pan
     canvas.save();
     canvas.translate(offset.dx, offset.dy);
     canvas.scale(scale);
     
           // Không vẽ background - để trống để chỉ hiển thị bản đồ tỉnh
    
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
    
    // Restore canvas transform
    canvas.restore();
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

 // Class để lưu trữ giới hạn pan
 class PanLimits {
   final double minX;
   final double maxX;
   final double minY;
   final double maxY;

   PanLimits({
     required this.minX,
     required this.maxX,
     required this.minY,
     required this.maxY,
   });
 } 