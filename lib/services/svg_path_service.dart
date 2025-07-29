import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class SvgPathService {
  static final Map<String, List<Offset>> _provincePaths = {};
  static bool _isInitialized = false;

  // Parse SVG file và extract paths cho từng tỉnh
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Đọc SVG content từ assets
      final svgContent = await _loadSvgContent();
      final document = XmlDocument.parse(svgContent);
      
      // Parse tất cả path elements
      final paths = document.findAllElements('path');
      
      for (final path in paths) {
        final id = path.getAttribute('id');
        final pathData = path.getAttribute('d');
        
        if (id != null && pathData != null) {
          final points = _parseSvgPath(pathData);
          if (points.isNotEmpty) {
            _provincePaths[id] = points;
          }
        }
      }
      
      // Parse group elements (cho các tỉnh có mask)
      final groups = document.findAllElements('g');
      for (final group in groups) {
        final id = group.getAttribute('id');
        if (id != null) {
          final groupPaths = group.findAllElements('path');
          final allPoints = <Offset>[];
          
          for (final path in groupPaths) {
            final pathData = path.getAttribute('d');
            if (pathData != null) {
              final points = _parseSvgPath(pathData);
              allPoints.addAll(points);
            }
          }
          
          if (allPoints.isNotEmpty) {
            _provincePaths[id] = allPoints;
          }
        }
      }
      
      _isInitialized = true;
      print('SVG Path Service initialized with ${_provincePaths.length} provinces');
    } catch (e) {
      print('Error initializing SVG Path Service: $e');
    }
  }

  // Load SVG content từ assets
  static Future<String> _loadSvgContent() async {
    try {
      return await rootBundle.loadString('assets/svg/vietnam_map_split_new.svg');
    } catch (e) {
      print('Error loading SVG file: $e');
      // Fallback to hardcoded content if file loading fails
      return '''
      <svg width="800" height="800" viewBox="0 0 800 800">
        <path id="Ha Noi" d="M223.76 100.043L224.452 102.414L224.462 102.448L224.496 102.45L225.778 102.548L227.352 104.024L227.744 106.567L226.281 107.154L226.243 107.169L226.251 107.209L227.146 111.685L226.562 112.368L226.538 112.396L226.558 112.427L227.858 114.427L227.87 114.445L227.89 114.449L230.869 115.044L231.643 116.305L230.761 118.559L228.885 119.153L228.843 119.165L228.85 119.209L229.038 120.243L226.506 119.951L226.448 119.944L226.45 120.001L226.549 122.681L225.762 123.567L225.734 123.599L225.761 123.631L227.531 125.794L226.467 126.763L226.442 126.785L226.452 126.815L227.152 129.015L227.16 129.037L227.181 129.046L229.153 129.834L229.551 133.406L229.556 133.457L229.607 133.45L230.793 133.267L229.583 135.035L228.022 134.255L227.996 134.243L227.971 134.259L225.784 135.75L222.799 135.85L222.784 135.851L222.771 135.859L221.771 136.559L221.757 136.57L221.752 136.587L220.859 139.856L219.821 140.045L218.54 138.37L218.525 138.35H216.833L215.057 134.406L215.64 133.63L215.663 133.6L215.639 133.57L213.948 131.381L213.65 127.197L213.647 127.164L213.617 127.153L211.718 126.453L211.69 126.443L211.668 126.461L210.024 127.83L210.946 125.62L210.96 125.587L210.933 125.563L209.759 124.486L210.746 122.12L210.775 122.05H207.011L204.332 120.76L201.539 117.369L201.52 117.346L201.491 117.351L198.124 117.945L197.055 116.196L198.346 113.019L198.356 112.994L198.341 112.971L196.757 110.694L197.339 109.435L199.324 108.344L199.344 108.333L199.348 108.312L200.34 104.245L202.284 104.052L203.957 105.529L205.352 109.816L205.357 109.83L205.37 109.84L206.57 110.74L206.581 110.748L206.594 110.749L209.794 111.15L209.807 111.152L209.82 111.146L212.62 109.946L212.655 109.931L212.649 109.893L212.453 108.522L214.81 106.853L217.588 107.548L217.653 107.565L217.65 107.497L217.551 105.619L219.436 103.634L219.443 103.627L219.446 103.619L220.547 100.819L221.225 99.6547L223.76 100.043Z"/>
        <path id="Ho Chi Minh" d="M160 560L280 560L280 680L160 680Z"/>
        <path id="Da Nang" d="M320 320L400 320L400 400L320 400Z"/>
        <path id="Hai Phong" d="M240 80L320 80L320 160L240 160Z"/>
        <path id="Can Tho" d="M200 600L280 600L280 680L200 680Z"/>
        <path id="Bac Ninh" d="M240 80L280 80L280 120L240 120Z"/>
        <path id="Ca Mau" d="M160 640L240 640L240 720L160 720Z"/>
        <path id="Cao Bang" d="M240 40L320 40L320 120L240 120Z"/>
        <path id="Dien Bien" d="M80 80L160 80L160 160L80 160Z"/>
        <path id="Dong Nai" d="M280 520L360 520L360 600L280 600Z"/>
        <path id="Gia Lai" d="M360 400L440 400L440 480L360 480Z"/>
        <path id="Ha Tinh" d="M200 200L280 200L280 280L200 280Z"/>
        <path id="Lai Chau" d="M120 40L200 40L200 120L120 120Z"/>
        <path id="Lam Dong" d="M320 480L400 480L400 560L320 560Z"/>
        <path id="Lang Son" d="M280 80L360 80L360 160L280 160Z"/>
        <path id="Nghe An" d="M200 160L280 160L280 240L200 240Z"/>
        <path id="Ninh Binh" d="M200 120L280 120L280 200L200 200Z"/>
        <path id="Khanh Hoa" d="M360 480L440 480L440 560L360 560Z"/>
        <path id="Dak Lak" d="M360 440L440 440L440 520L360 520Z"/>
        <path id="Quang Ngai" d="M360 360L440 360L440 440L360 440Z"/>
        <path id="Quang Ninh" d="M280 80L360 80L360 160L280 160Z"/>
        <path id="Quang Tri" d="M200 280L280 280L280 360L200 360Z"/>
        <path id="Son La" d="M160 80L240 80L240 160L160 160Z"/>
        <path id="Tay Ninh" d="M240 520L320 520L320 600L240 600Z"/>
        <path id="Hung Yen" d="M240 120L280 120L280 160L240 160Z"/>
        <path id="An Giang" d="M160 560L240 560L240 640L160 640Z"/>
        <path id="Truong Sa" d="M480 720L640 720L640 800L480 800Z"/>
        <path id="Hoang Sa" d="M480 320L560 320L560 400L480 400Z"/>
      </svg>
      ''';
    }
  }

  // Parse SVG path data thành list of points
  static List<Offset> _parseSvgPath(String pathData) {
    final points = <Offset>[];
    
    // Split path data into commands and parameters
    final regex = RegExp(r'([MLHVCSQTAZmlhvcsqtaz])\s*([^MLHVCSQTAZmlhvcsqtaz]*)');
    final matches = regex.allMatches(pathData);
    
    double currentX = 0;
    double currentY = 0;
    double startX = 0;
    double startY = 0;
    
    for (final match in matches) {
      final command = match.group(1)!;
      final params = match.group(2)?.trim() ?? '';
      
      if (params.isEmpty) continue;
      
      final numbers = params.split(RegExp(r'[\s,]+')).where((s) => s.isNotEmpty).toList();
      
      switch (command) {
        case 'M': // Move to (absolute)
          if (numbers.length >= 2) {
            currentX = double.tryParse(numbers[0]) ?? 0;
            currentY = double.tryParse(numbers[1]) ?? 0;
            startX = currentX;
            startY = currentY;
            points.add(Offset(currentX, currentY));
            
            // Handle multiple coordinates after M
            for (int i = 2; i < numbers.length; i += 2) {
              if (i + 1 < numbers.length) {
                currentX = double.tryParse(numbers[i]) ?? 0;
                currentY = double.tryParse(numbers[i + 1]) ?? 0;
                points.add(Offset(currentX, currentY));
              }
            }
          }
          break;
          
        case 'L': // Line to (absolute)
          for (int i = 0; i < numbers.length; i += 2) {
            if (i + 1 < numbers.length) {
              currentX = double.tryParse(numbers[i]) ?? 0;
              currentY = double.tryParse(numbers[i + 1]) ?? 0;
              points.add(Offset(currentX, currentY));
            }
          }
          break;
          
        case 'H': // Horizontal line to (absolute)
          for (final number in numbers) {
            currentX = double.tryParse(number) ?? 0;
            points.add(Offset(currentX, currentY));
          }
          break;
          
        case 'V': // Vertical line to (absolute)
          for (final number in numbers) {
            currentY = double.tryParse(number) ?? 0;
            points.add(Offset(currentX, currentY));
          }
          break;
          
        case 'Z': // Close path
        case 'z': // Close path
          if (points.isNotEmpty) {
            points.add(Offset(startX, startY));
          }
          break;
          
        // Relative commands
        case 'm': // Move to (relative)
          if (numbers.length >= 2) {
            currentX += double.tryParse(numbers[0]) ?? 0;
            currentY += double.tryParse(numbers[1]) ?? 0;
            startX = currentX;
            startY = currentY;
            points.add(Offset(currentX, currentY));
            
            // Handle multiple coordinates after m
            for (int i = 2; i < numbers.length; i += 2) {
              if (i + 1 < numbers.length) {
                currentX += double.tryParse(numbers[i]) ?? 0;
                currentY += double.tryParse(numbers[i + 1]) ?? 0;
                points.add(Offset(currentX, currentY));
              }
            }
          }
          break;
          
        case 'l': // Line to (relative)
          for (int i = 0; i < numbers.length; i += 2) {
            if (i + 1 < numbers.length) {
              currentX += double.tryParse(numbers[i]) ?? 0;
              currentY += double.tryParse(numbers[i + 1]) ?? 0;
              points.add(Offset(currentX, currentY));
            }
          }
          break;
          
        case 'h': // Horizontal line to (relative)
          for (final number in numbers) {
            currentX += double.tryParse(number) ?? 0;
            points.add(Offset(currentX, currentY));
          }
          break;
          
        case 'v': // Vertical line to (relative)
          for (final number in numbers) {
            currentY += double.tryParse(number) ?? 0;
            points.add(Offset(currentX, currentY));
          }
          break;
      }
    }
    
    return points;
  }

  // Check if point is inside province path
  static bool isPointInProvince(Offset point, String provinceId) {
    if (!_isInitialized) {
      print('SVG Path Service not initialized');
      return false;
    }
    
    final path = _provincePaths[provinceId];
    if (path == null || path.isEmpty) {
      return false;
    }
    
    return _isPointInPolygon(point, path);
  }

  // Ray casting algorithm để check point in polygon
  static bool _isPointInPolygon(Offset point, List<Offset> polygon) {
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

  // Get province at position
  static String? getProvinceAtPosition(Offset point) {
    if (!_isInitialized) {
      print('SVG Path Service not initialized');
      return null;
    }
    
    // Check từng tỉnh theo thứ tự ưu tiên
    for (final entry in _provincePaths.entries) {
      if (_isPointInPolygon(point, entry.value)) {
        return entry.key;
      }
    }
    
    return null;
  }

  // Get all available province IDs
  static List<String> getAvailableProvinces() {
    return _provincePaths.keys.toList();
  }

  // Get bounding box của province
  static Rect? getProvinceBounds(String provinceId) {
    final path = _provincePaths[provinceId];
    if (path == null || path.isEmpty) return null;
    
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;
    
    for (final point in path) {
      minX = math.min(minX, point.dx);
      minY = math.min(minY, point.dy);
      maxX = math.max(maxX, point.dx);
      maxY = math.max(maxY, point.dy);
    }
    
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // Debug: Print all loaded provinces
  static void debugPrintProvinces() {
    print('Loaded ${_provincePaths.length} provinces:');
    for (final entry in _provincePaths.entries) {
      final bounds = getProvinceBounds(entry.key);
      print('${entry.key}: ${entry.value.length} points, bounds: $bounds');
    }
  }
} 