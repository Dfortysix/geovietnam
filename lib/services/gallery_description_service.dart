import 'dart:convert';
import 'package:flutter/services.dart';

class GalleryDescriptionService {
  static Map<String, List<String>> _descriptions = {};

  static Future<List<String>> getGalleryDescriptions(String provinceId) async {
    // Nếu đã load rồi thì trả về cache
    if (_descriptions.containsKey(provinceId)) {
      return _descriptions[provinceId]!;
    }

    try {
      // Tạo tên file dựa trên provinceId
      final fileName = provinceId.toLowerCase().replaceAll(' ', '_');
      final String jsonString = await rootBundle.loadString('assets/data/gallery_descriptions/$fileName.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      final List<String> descriptions = List<String>.from(data['descriptions'] ?? []);
      _descriptions[provinceId] = descriptions;
      
      return descriptions;
    } catch (e) {
      // Nếu không có file JSON, trả về description mặc định
      return _getDefaultDescriptions(provinceId);
    }
  }

  static List<String> _getDefaultDescriptions(String provinceId) {
    // Description mặc định cho từng ảnh
    return [
      'Cảnh quan địa lý và thiên nhiên của $provinceId',
      'Văn hóa và di sản truyền thống',
      'Du lịch và điểm đến nổi tiếng',
      'Ẩm thực đặc sắc và món ăn truyền thống',
      'Giao thông và hạ tầng hiện đại',
    ];
  }

  static List<String> getDefaultDescriptions(String provinceId) {
    return _getDefaultDescriptions(provinceId);
  }

  static Future<bool> hasCustomDescriptions(String provinceId) async {
    try {
      final fileName = provinceId.toLowerCase().replaceAll(' ', '_');
      await rootBundle.loadString('assets/data/gallery_descriptions/$fileName.json');
      return true;
    } catch (e) {
      return false;
    }
  }
} 