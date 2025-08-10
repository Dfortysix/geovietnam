import '../models/province.dart';

class ProvincesData {
  static List<Province> getAllProvinces() {
    return [
      // 11 TỈNH/THÀNH GIỮ NGUYÊN
      Province(
        id: 'Ha Noi',
        name: 'Ha Noi',
        nameVietnamese: 'Hà Nội',
        description: 'Thủ đô của Việt Nam, trung tâm chính trị, văn hóa và kinh tế',
        facts: [
          'Thành lập năm 1010 dưới triều Lý',
          'Diện tích: 3,359.84 km²',
          'Dân số: 8,807,523 người (2025)',
          'Có 75 xã và 51 phường',
          'Nổi tiếng với phở Hà Nội và bánh mì',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Hue',
        name: 'Hue',
        nameVietnamese: 'Huế',
        description: 'Cố đô của Việt Nam, thành phố di sản văn hóa thế giới',
        facts: [
          'Cố đô của triều Nguyễn (1802-1945)',
          'Diện tích: 4,947.11 km²',
          'Dân số: 1,432,986 người (2025)',
          'Có 19 xã và 21 phường',
          'Nổi tiếng với cung đình Huế và ẩm thực cung đình',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Lai Chau',
        name: 'Lai Chau',
        nameVietnamese: 'Lai Châu',
        description: 'Tỉnh miền núi Tây Bắc với thiên nhiên hoang dã',
        facts: [
          'Vùng đất của nhiều dân tộc thiểu số',
          'Diện tích: 9,068.73 km²',
          'Dân số: 512,601 người (2025)',
          'Có 36 xã và 2 phường',
          'Nổi tiếng với ruộng bậc thang',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Dien Bien',
        name: 'Dien Bien',
        nameVietnamese: 'Điện Biên',
        description: 'Tỉnh miền núi Tây Bắc với lịch sử hào hùng',
        facts: [
          'Nơi diễn ra chiến thắng Điện Biên Phủ (1954)',
          'Diện tích: 9,539.93 km²',
          'Dân số: 673,091 người (2025)',
          'Có 42 xã và 3 phường',
          'Nổi tiếng với xôi nếp nương',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Son La',
        name: 'Son La',
        nameVietnamese: 'Sơn La',
        description: 'Tỉnh miền núi Tây Bắc với văn hóa đa dạng',
        facts: [
          'Vùng đất của nhiều dân tộc',
          'Diện tích: 14,109.83 km²',
          'Dân số: 1,404,587 người (2025)',
          'Có 67 xã và 8 phường',
          'Nổi tiếng với nhãn Sơn La',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Lang Son',
        name: 'Lang Son',
        nameVietnamese: 'Lạng Sơn',
        description: 'Tỉnh biên giới phía Bắc với nhiều danh lam thắng cảnh',
        facts: [
          'Có động Tam Thanh nổi tiếng',
          'Diện tích: 8,310.18 km²',
          'Dân số: 881,384 người (2025)',
          'Có 61 xã và 4 phường',
          'Nổi tiếng với vịt quay Lạng Sơn',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Quang Ninh',
        name: 'Quang Ninh',
        nameVietnamese: 'Quảng Ninh',
        description: 'Tỉnh ven biển với Vịnh Hạ Long nổi tiếng',
        facts: [
          'Có Vịnh Hạ Long - di sản thế giới',
          'Diện tích: 6,207.93 km²',
          'Dân số: 1,497,447 người (2025)',
          'Có 22 xã và 30 phường',
          'Nổi tiếng với hải sản tươi ngon',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Thanh Hoa',
        name: 'Thanh Hoa',
        nameVietnamese: 'Thanh Hóa',
        description: 'Tỉnh ven biển miền Trung với nhiều di tích lịch sử',
        facts: [
          'Quê hương của nhiều vị vua',
          'Diện tích: 11,114.71 km²',
          'Dân số: 4,324,783 người (2025)',
          'Có 147 xã và 19 phường',
          'Nổi tiếng với nem chua Thanh Hóa',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Nghe An',
        name: 'Nghe An',
        nameVietnamese: 'Nghệ An',
        description: 'Tỉnh lớn nhất Việt Nam với truyền thống văn hóa lâu đời',
        facts: [
          'Quê hương của Chủ tịch Hồ Chí Minh',
          'Diện tích: 16,486.49 km²',
          'Dân số: 3,831,694 người (2025)',
          'Có 119 xã và 11 phường',
          'Nổi tiếng với cam Vinh',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Ha Tinh',
        name: 'Ha Tinh',
        nameVietnamese: 'Hà Tĩnh',
        description: 'Tỉnh ven biển miền Trung với nhiều di tích lịch sử',
        facts: [
          'Quê hương của nhiều danh nhân',
          'Diện tích: 5,994.45 km²',
          'Dân số: 1,622,901 người (2025)',
          'Có 60 xã và 9 phường',
          'Nổi tiếng với cam bù Hương Sơn',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),
      Province(
        id: 'Cao Bang',
        name: 'Cao Bang',
        nameVietnamese: 'Cao Bằng',
        description: 'Tỉnh miền núi phía Bắc với nhiều danh lam thắng cảnh',
        facts: [
          'Có thác Bản Giốc nổi tiếng',
          'Diện tích: 6,700.39 km²',
          'Dân số: 573,119 người (2025)',
          'Có 53 xã và 3 phường',
          'Nổi tiếng với phở chua',
          'Thuộc 11 tỉnh/thành không thực hiện sáp nhập 2025',
        ],
      ),

      // 23 TỈNH/THÀNH SÁP NHẬP
      Province(
        id: 'Tuyen Quang',
        name: 'Tuyen Quang',
        nameVietnamese: 'Tuyên Quang',
        description: 'Tỉnh miền núi phía Bắc với nhiều di tích lịch sử',
        facts: [
          'Thủ đô kháng chiến thời kỳ 1946-1954',
          'Diện tích: 13,795.60 km²',
          'Dân số: 1,865,270 người (2025)',
          'Có 117 xã và 7 phường',
          'Nổi tiếng với cam sành Hàm Yên',
          'Sáp nhập: Tuyên Quang + Hà Giang',
        ],
      ),
      Province(
        id: 'Lao Cai',
        name: 'Lao Cai',
        nameVietnamese: 'Lào Cai',
        description: 'Tỉnh biên giới phía Bắc với nhiều danh lam thắng cảnh',
        facts: [
          'Có Sa Pa - điểm du lịch nổi tiếng',
          'Diện tích: 13,257.00 km²',
          'Dân số: 1,778,785 người (2025)',
          'Có 89 xã và 10 phường',
          'Nổi tiếng với thịt lợn cắp nách',
          'Sáp nhập: Lào Cai + Yên Bái',
        ],
      ),
      Province(
        id: 'Thai Nguyen',
        name: 'Thai Nguyen',
        nameVietnamese: 'Thái Nguyên',
        description: 'Tỉnh trung du miền núi phía Bắc',
        facts: [
          'Thủ phủ của vùng Trung du và miền núi Bắc Bộ',
          'Diện tích: 8,375.30 km²',
          'Dân số: 1,799,489 người (2025)',
          'Có 77 xã và 15 phường',
          'Nổi tiếng với chè Tân Cương',
          'Sáp nhập: Thái Nguyên + Bắc Kạn',
        ],
      ),
      Province(
        id: 'Phu Tho',
        name: 'Phu Tho',
        nameVietnamese: 'Phú Thọ',
        description: 'Tỉnh có nhiều di tích lịch sử và văn hóa',
        facts: [
          'Đất Tổ Hùng Vương',
          'Diện tích: 9,361.40 km²',
          'Dân số: 4,022,638 người (2025)',
          'Có 133 xã và 15 phường',
          'Nổi tiếng với bưởi Đoan Hùng',
          'Sáp nhập: Phú Thọ + Vĩnh Phúc + Hòa Bình',
        ],
      ),
      Province(
        id: 'Bac Ninh',
        name: 'Bac Ninh',
        nameVietnamese: 'Bắc Ninh',
        description: 'Tỉnh có truyền thống văn hóa lâu đời',
        facts: [
          'Quê hương quan họ',
          'Diện tích: 4,718.60 km²',
          'Dân số: 3,619,433 người (2025)',
          'Có 66 xã và 33 phường',
          'Nổi tiếng với dân ca quan họ',
          'Sáp nhập: Bắc Ninh + Bắc Giang',
        ],
      ),
      Province(
        id: 'Hung Yen',
        name: 'Hung Yen',
        nameVietnamese: 'Hưng Yên',
        description: 'Tỉnh đồng bằng sông Hồng với truyền thống văn hóa',
        facts: [
          'Vùng đất học nổi tiếng',
          'Diện tích: 2,514.80 km²',
          'Dân số: 3,567,943 người (2025)',
          'Có 93 xã và 11 phường',
          'Nổi tiếng với nhãn lồng Hưng Yên',
          'Sáp nhập: Hưng Yên + Thái Bình',
        ],
      ),
      Province(
        id: 'Hai Phong',
        name: 'Hai Phong',
        nameVietnamese: 'Hải Phòng',
        description: 'Thành phố cảng lớn nhất miền Bắc',
        facts: [
          'Thành phố Hoa Phượng Đỏ',
          'Diện tích: 3,527.00 km²',
          'Dân số: 2,800,000 người (2025)',
          'Có 67 xã và 45 phường',
          'Nổi tiếng với bánh đa cua',
          'Sáp nhập: Hải Phòng + Hải Dương',
        ],
      ),
      Province(
        id: 'Ninh Binh',
        name: 'Ninh Binh',
        nameVietnamese: 'Ninh Bình',
        description: 'Tỉnh có nhiều di tích lịch sử và danh lam thắng cảnh',
        facts: [
          'Cố đô Hoa Lư xưa',
          'Diện tích: 3,942.60 km²',
          'Dân số: 4,412,264 người (2025)',
          'Có 97 xã và 32 phường',
          'Nổi tiếng với Tràng An và chùa Bái Đính',
          'Sáp nhập: Ninh Bình + Hà Nam + Nam Định',
        ],
      ),
      Province(
        id: 'Quang Tri',
        name: 'Quang Tri',
        nameVietnamese: 'Quảng Trị',
        description: 'Tỉnh có nhiều di tích lịch sử quan trọng',
        facts: [
          'Nơi diễn ra nhiều trận đánh ác liệt',
          'Diện tích: 12,700.00 km²',
          'Dân số: 1,870,845 người (2025)',
          'Có 69 xã và 8 phường',
          'Nổi tiếng với bánh bèo',
          'Sáp nhập: Quảng Trị + Quảng Bình',
        ],
      ),
      Province(
        id: 'Da Nang',
        name: 'Da Nang',
        nameVietnamese: 'Đà Nẵng',
        description: 'Thành phố biển xinh đẹp, trung tâm du lịch quan trọng',
        facts: [
          'Thành phố trực thuộc trung ương',
          'Diện tích: 11,859.60 km²',
          'Dân số: 3,065,628 người (2025)',
          'Có 70 xã và 23 phường',
          'Nổi tiếng với bãi biển Mỹ Khê',
          'Sáp nhập: Đà Nẵng + Quảng Nam',
        ],
      ),
      Province(
        id: 'Quang Ngai',
        name: 'Quang Ngai',
        nameVietnamese: 'Quảng Ngãi',
        description: 'Tỉnh ven biển miền Trung với nhiều di tích lịch sử',
        facts: [
          'Quê hương của nhiều anh hùng',
          'Diện tích: 14,832.60 km²',
          'Dân số: 2,161,755 người (2025)',
          'Có 86 xã và 9 phường',
          'Nổi tiếng với mì Quảng',
          'Sáp nhập: Quảng Ngãi + Kon Tum',
        ],
      ),
      Province(
        id: 'Gia Lai',
        name: 'Gia Lai',
        nameVietnamese: 'Gia Lai',
        description: 'Tỉnh Tây Nguyên với văn hóa đặc sắc',
        facts: [
          'Vùng đất của người Jrai',
          'Diện tích: 21,576.50 km²',
          'Dân số: 3,583,693 người (2025)',
          'Có 110 xã và 25 phường',
          'Nổi tiếng với cà phê Buôn Ma Thuột',
          'Sáp nhập: Gia Lai + Bình Định',
        ],
      ),
      Province(
        id: 'Khanh Hoa',
        name: 'Khanh Hoa',
        nameVietnamese: 'Khánh Hòa',
        description: 'Tỉnh ven biển miền Trung với nhiều đảo đẹp',
        facts: [
          'Có Nha Trang - thành phố biển nổi tiếng',
          'Diện tích: 8,555.90 km²',
          'Dân số: 2,243,554 người (2025)',
          'Có 48 xã và 16 phường',
          'Nổi tiếng với bánh căn Nha Trang',
          'Sáp nhập: Khánh Hòa + Ninh Thuận',
        ],
      ),
      Province(
        id: 'Lam Dong',
        name: 'Lam Dong',
        nameVietnamese: 'Lâm Đồng',
        description: 'Tỉnh cao nguyên với khí hậu mát mẻ',
        facts: [
          'Thủ phủ của Tây Nguyên',
          'Diện tích: 24,233.10 km²',
          'Dân số: 3,872,999 người (2025)',
          'Có 103 xã và 20 phường',
          'Nổi tiếng với Đà Lạt và hoa',
          'Sáp nhập: Lâm Đồng + Đắk Nông + Bình Thuận',
        ],
      ),
      Province(
        id: 'Dak Lak',
        name: 'Dak Lak',
        nameVietnamese: 'Đắk Lắk',
        description: 'Tỉnh Tây Nguyên với văn hóa đặc sắc',
        facts: [
          'Vùng đất của người Êđê',
          'Diện tích: 18,096.40 km²',
          'Dân số: 3,346,853 người (2025)',
          'Có 88 xã và 14 phường',
          'Nổi tiếng với cà phê Buôn Ma Thuột',
          'Sáp nhập: Đắk Lắk + Phú Yên',
        ],
      ),
      Province(
        id: 'Ho Chi Minh',
        name: 'Ho Chi Minh',
        nameVietnamese: 'Thành phố Hồ Chí Minh',
        description: 'Thành phố lớn nhất Việt Nam, trung tâm kinh tế và tài chính',
        facts: [
          'Trước đây gọi là Sài Gòn',
          'Diện tích: 6,772.60 km²',
          'Dân số: 14,002,598 người (2025)',
          'Có 54 xã và 113 phường',
          'Nổi tiếng với ẩm thực đa dạng',
          'Sáp nhập: TP.HCM + Bình Dương + Bà Rịa-Vũng Tàu',
        ],
      ),
      Province(
        id: 'Dong Nai',
        name: 'Dong Nai',
        nameVietnamese: 'Đồng Nai',
        description: 'Tỉnh công nghiệp phát triển ở miền Đông Nam Bộ',
        facts: [
          'Trung tâm công nghiệp lớn',
          'Diện tích: 12,737.20 km²',
          'Dân số: 4,491,408 người (2025)',
          'Có 72 xã và 23 phường',
          'Nổi tiếng với bưởi Tân Triều',
          'Sáp nhập: Đồng Nai + Bình Phước',
        ],
      ),
      Province(
        id: 'Tay Ninh',
        name: 'Tay Ninh',
        nameVietnamese: 'Tây Ninh',
        description: 'Tỉnh có núi Bà Đen và nhiều di tích tôn giáo',
        facts: [
          'Có núi Bà Đen nổi tiếng',
          'Diện tích: 8,536.50 km²',
          'Dân số: 3,254,170 người (2025)',
          'Có 82 xã và 14 phường',
          'Nổi tiếng với bánh tráng phơi sương',
          'Sáp nhập: Tây Ninh + Long An',
        ],
      ),
      Province(
        id: 'Can Tho',
        name: 'Can Tho',
        nameVietnamese: 'Cần Thơ',
        description: 'Thành phố lớn nhất Đồng bằng sông Cửu Long',
        facts: [
          'Tây Đô - thủ phủ miền Tây',
          'Diện tích: 6,360.80 km²',
          'Dân số: 4,199,824 người (2025)',
          'Có 72 xã và 31 phường',
          'Nổi tiếng với chợ nổi Cái Răng',
          'Sáp nhập: Cần Thơ + Sóc Trăng + Hậu Giang',
        ],
      ),
      Province(
        id: 'Vinh Long',
        name: 'Vinh Long',
        nameVietnamese: 'Vĩnh Long',
        description: 'Tỉnh đồng bằng sông Cửu Long với văn hóa sông nước',
        facts: [
          'Vùng đất trù phú miền Tây',
          'Diện tích: 6,296.20 km²',
          'Dân số: 4,257,581 người (2025)',
          'Có 105 xã và 19 phường',
          'Nổi tiếng với bưởi Năm Roi',
          'Sáp nhập: Vĩnh Long + Bến Tre + Trà Vinh',
        ],
      ),
      Province(
        id: 'Dong Thap',
        name: 'Dong Thap',
        nameVietnamese: 'Đồng Tháp',
        description: 'Tỉnh đồng bằng sông Cửu Long với nhiều di tích lịch sử',
        facts: [
          'Quê hương của cụ Phó bảng Nguyễn Sinh Sắc',
          'Diện tích: 5,938.70 km²',
          'Dân số: 4,370,046 người (2025)',
          'Có 82 xã và 20 phường',
          'Nổi tiếng với sen Đồng Tháp',
          'Sáp nhập: Đồng Tháp + Tiền Giang',
        ],
      ),
      Province(
        id: 'Ca Mau',
        name: 'Ca Mau',
        nameVietnamese: 'Cà Mau',
        description: 'Tỉnh cực nam của Việt Nam',
        facts: [
          'Điểm cực nam của Tổ quốc',
          'Diện tích: 7,942.40 km²',
          'Dân số: 2,606,672 người (2025)',
          'Có 55 xã và 9 phường',
          'Nổi tiếng với rừng ngập mặn',
          'Sáp nhập: Cà Mau + Bạc Liêu',
        ],
      ),
      Province(
        id: 'An Giang',
        name: 'An Giang',
        nameVietnamese: 'An Giang',
        description: 'Tỉnh đồng bằng sông Cửu Long với nhiều di tích tôn giáo',
        facts: [
          'Có núi Sam và chùa Tây An',
          'Diện tích: 9,888.90 km²',
          'Dân số: 4,952,238 người (2025)',
          'Có 85 xã và 14 phường',
          'Nổi tiếng với bún nước lèo',
          'Sáp nhập: An Giang + Kiên Giang',
        ],
      ),
      Province(
        id: 'Truong Sa',
        name: 'Truong Sa',
        nameVietnamese: 'Trường Sa',
        description: 'Quần đảo Trường Sa thuộc chủ quyền Việt Nam',
        facts: [
          'Quần đảo xa nhất của Việt Nam',
          'Có nhiều đảo và bãi đá',
          'Diện tích: khoảng 5 km²',
          'Dân số: khoảng 200 người',
          'Có tầm quan trọng chiến lược',
        ],
      ),
      Province(
        id: 'Hoang Sa',
        name: 'Hoang Sa',
        nameVietnamese: 'Hoàng Sa',
        description: 'Quần đảo Hoàng Sa thuộc chủ quyền Việt Nam',
        facts: [
          'Quần đảo có tầm quan trọng chiến lược',
          'Có nhiều đảo và bãi cạn',
          'Diện tích: khoảng 8 km²',
          'Dân số: không có dân cư thường trú',
          'Có tiềm năng về thủy sản và dầu khí',
        ],
      ),
    ];
  }

  // Lấy tỉnh theo ID
  static Province? getProvinceById(String id) {
    return getAllProvinces().firstWhere(
      (province) => province.id == id,
      orElse: () => getAllProvinces().first,
    );
  }

  // Lấy danh sách tỉnh đã mở khóa
  static List<Province> getUnlockedProvinces(List<Province> provinces) {
    return provinces.where((province) => province.isUnlocked).toList();
  }

  // Lấy danh sách tỉnh chưa mở khóa
  static List<Province> getLockedProvinces(List<Province> provinces) {
    return provinces.where((province) => !province.isUnlocked).toList();
  }

  /// Lấy đường dẫn background image cho tỉnh
  static String? getProvinceBackgroundImage(String provinceId) {
    final backgroundMap = {
      'Ha Noi': 'assets/images/provinces/ha_noi_bg.jpg',
      'Hai Phong': 'assets/images/provinces/hai_phong_bg.jpg',
      // Thêm các tỉnh khác khi có background image
    };
    return backgroundMap[provinceId];
  }

  /// Kiểm tra xem tỉnh có background image không
  static bool hasBackgroundImage(String provinceId) {
    return getProvinceBackgroundImage(provinceId) != null;
  }

  /// Lấy danh sách tất cả tỉnh có background image
  static List<String> getProvincesWithBackgroundImage() {
    final provinces = <String>[];
    if (getProvinceBackgroundImage('Ha Noi') != null) provinces.add('Ha Noi');
    if (getProvinceBackgroundImage('Hai Phong') != null) provinces.add('Hai Phong');
    return provinces;
  }

  /// Lấy thông tin hiển thị cho tỉnh (tổng hợp từ province data và background)
  static Map<String, dynamic> getProvinceDisplayInfo(String provinceId) {
    final province = getProvinceById(provinceId);
    if (province == null) {
      return {};
    }

    return {
      'id': province.id,
      'nameVietnamese': province.nameVietnamese,
      'description': province.description,
      'facts': province.facts,
      'isUnlocked': province.isUnlocked,
      'backgroundImage': getProvinceBackgroundImage(provinceId),
      'hasBackgroundImage': hasBackgroundImage(provinceId),
    };
  }
} 