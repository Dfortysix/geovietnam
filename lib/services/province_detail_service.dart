import 'dart:convert';
import 'package:flutter/services.dart';

class ProvinceDetailService {
  static final Map<String, Map<String, dynamic>> _cache = {};

  /// Load dữ liệu chi tiết của một tỉnh từ file JSON
  static Future<Map<String, dynamic>?> getProvinceDetail(String provinceId) async {
    // Kiểm tra cache trước
    if (_cache.containsKey(provinceId)) {
      return _cache[provinceId];
    }

    try {
      // Convert provinceId to snake_case for file name
      final fileName = provinceId.toLowerCase().replaceAll(' ', '_');
      
      // Load file JSON từ assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/provinces/$fileName.json',
      );
      
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // Cache dữ liệu
      _cache[provinceId] = data;
      
      return data;
    } catch (e) {
      print('Error loading province detail for $provinceId: $e');
      return null;
    }
  }

  /// Load overview của tỉnh (thông tin cơ bản)
  static Future<Map<String, dynamic>?> getProvinceOverview(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['overview'];
  }

  /// Load thông tin sáp nhập 2025
  static Future<Map<String, dynamic>?> getProvinceSapNhap2025(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['sapNhap2025'];
  }

  /// Load thông tin lịch sử
  static Future<Map<String, dynamic>?> getProvinceLichSu(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['lichSu'];
  }

  /// Load thông tin văn hóa
  static Future<Map<String, dynamic>?> getProvinceVanHoa(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['vanHoa'];
  }

  /// Load thông tin ẩm thực
  static Future<Map<String, dynamic>?> getProvinceAmThuc(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['amThuc'];
  }

  /// Load thông tin địa danh
  static Future<Map<String, dynamic>?> getProvinceDiaDanh(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['diaDanh'];
  }

  /// Load thông tin kết luận
  static Future<Map<String, dynamic>?> getProvinceKetLuan(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['ketLuan'];
  }

  // Các method cũ để tương thích ngược
  /// Load thông tin địa lý
  static Future<Map<String, dynamic>?> getProvinceGeography(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['geography'];
  }

  /// Load thông tin văn hóa (cũ)
  static Future<Map<String, dynamic>?> getProvinceCulture(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['culture'];
  }

  /// Load thông tin kinh tế
  static Future<Map<String, dynamic>?> getProvinceEconomy(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['economy'];
  }

  /// Load thông tin lịch sử (cũ)
  static Future<Map<String, dynamic>?> getProvinceHistory(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['history'];
  }

  /// Load danh sách facts
  static Future<List<String>?> getProvinceFacts(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    final facts = detail?['facts'];
    return facts != null ? List<String>.from(facts) : null;
  }

  /// Load thông tin hình ảnh
  static Future<Map<String, dynamic>?> getProvinceImages(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['images'];
  }

  /// Load thông tin du lịch
  static Future<Map<String, dynamic>?> getProvinceTourism(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['tourism'];
  }

  /// Load thông tin giao thông
  static Future<Map<String, dynamic>?> getProvinceTransportation(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['transportation'];
  }

  /// Load thông tin giáo dục
  static Future<Map<String, dynamic>?> getProvinceEducation(String provinceId) async {
    final detail = await getProvinceDetail(provinceId);
    return detail?['education'];
  }

  /// Clear cache
  static void clearCache() {
    _cache.clear();
  }

  /// Clear cache cho một tỉnh cụ thể
  static void clearCacheForProvince(String provinceId) {
    _cache.remove(provinceId);
  }

  /// Kiểm tra xem tỉnh có file JSON chi tiết không
  static Future<bool> hasDetailedData(String provinceId) async {
    try {
      // Convert provinceId to snake_case for file name
      final fileName = provinceId.toLowerCase().replaceAll(' ', '_');
      await rootBundle.loadString('assets/data/provinces/$fileName.json');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get danh sách tất cả tỉnh có dữ liệu chi tiết
  static Future<List<String>> getProvincesWithDetailedData() async {
    // Có thể implement để load danh sách từ một file index
    // Hoặc scan thư mục assets/data/provinces/
    // Tạm thời return danh sách hardcode
    return ['hai_phong', 'ha_noi', 'quang_ninh', 'hue', 'dien_bien', 'cao_bang', 'lai_chau', 'son_la', 'lang_son', 'nghe_an', 'thanh_hoa', 'ha_tinh', 'phu_tho', 'tuyen_quang', 'bac_ninh', 'ninh_binh', 'hung_yen', 'quang_tri', 'quang_ngai']; // Thêm các tỉnh khác khi có file JSON
  }
} 