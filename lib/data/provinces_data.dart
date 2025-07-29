import '../models/province.dart';

class ProvincesData {
  static List<Province> getAllProvinces() {
    return [
      Province(
        id: 'Ha Noi',
        name: 'Ha Noi',
        nameVietnamese: 'Hà Nội',
        description: 'Thủ đô của Việt Nam, trung tâm chính trị, văn hóa và kinh tế',
        facts: [
          'Thành lập năm 1010 dưới triều Lý',
          'Có 12 quận và 17 huyện',
          'Diện tích: 3,359 km²',
          'Dân số: khoảng 8.4 triệu người',
          'Nổi tiếng với phở Hà Nội và bánh mì',
        ],
      ),
      Province(
        id: 'Ho Chi Minh',
        name: 'Ho Chi Minh',
        nameVietnamese: 'Thành phố Hồ Chí Minh',
        description: 'Thành phố lớn nhất Việt Nam, trung tâm kinh tế và tài chính',
        facts: [
          'Trước đây gọi là Sài Gòn',
          'Có 19 quận và 5 huyện',
          'Diện tích: 2,095 km²',
          'Dân số: khoảng 9.3 triệu người',
          'Nổi tiếng với ẩm thực đa dạng',
        ],
      ),
      Province(
        id: 'Da Nang',
        name: 'Da Nang',
        nameVietnamese: 'Đà Nẵng',
        description: 'Thành phố biển xinh đẹp, trung tâm du lịch quan trọng',
        facts: [
          'Thành phố trực thuộc trung ương',
          'Có 6 quận và 2 huyện',
          'Diện tích: 1,285 km²',
          'Dân số: khoảng 1.2 triệu người',
          'Nổi tiếng với bãi biển Mỹ Khê',
        ],
      ),
      Province(
        id: 'Hai Phong',
        name: 'Hai Phong',
        nameVietnamese: 'Hải Phòng',
        description: 'Thành phố cảng lớn nhất miền Bắc',
        facts: [
          'Thành phố Hoa Phượng Đỏ',
          'Có 7 quận và 8 huyện',
          'Diện tích: 1,527 km²',
          'Dân số: khoảng 2.1 triệu người',
          'Nổi tiếng với bánh đa cua',
        ],
      ),
      Province(
        id: 'Can Tho',
        name: 'Can Tho',
        nameVietnamese: 'Cần Thơ',
        description: 'Thành phố lớn nhất Đồng bằng sông Cửu Long',
        facts: [
          'Tây Đô - thủ phủ miền Tây',
          'Có 5 quận và 4 huyện',
          'Diện tích: 1,409 km²',
          'Dân số: khoảng 1.3 triệu người',
          'Nổi tiếng với chợ nổi Cái Răng',
        ],
      ),
      Province(
        id: 'Bac Ninh',
        name: 'Bac Ninh',
        nameVietnamese: 'Bắc Ninh',
        description: 'Tỉnh có truyền thống văn hóa lâu đời',
        facts: [
          'Quê hương quan họ',
          'Có 2 thành phố và 6 huyện',
          'Diện tích: 822 km²',
          'Dân số: khoảng 1.4 triệu người',
          'Nổi tiếng với dân ca quan họ',
        ],
      ),
      Province(
        id: 'Ca Mau',
        name: 'Ca Mau',
        nameVietnamese: 'Cà Mau',
        description: 'Tỉnh cực nam của Việt Nam',
        facts: [
          'Điểm cực nam của Tổ quốc',
          'Có 1 thành phố và 8 huyện',
          'Diện tích: 5,294 km²',
          'Dân số: khoảng 1.2 triệu người',
          'Nổi tiếng với rừng ngập mặn',
        ],
      ),
      Province(
        id: 'Cao Bang',
        name: 'Cao Bang',
        nameVietnamese: 'Cao Bằng',
        description: 'Tỉnh miền núi phía Bắc với nhiều danh lam thắng cảnh',
        facts: [
          'Có thác Bản Giốc nổi tiếng',
          'Có 1 thành phố và 10 huyện',
          'Diện tích: 6,700 km²',
          'Dân số: khoảng 530 nghìn người',
          'Nổi tiếng với phở chua',
        ],
      ),
      Province(
        id: 'Dien Bien',
        name: 'Dien Bien',
        nameVietnamese: 'Điện Biên',
        description: 'Tỉnh miền núi Tây Bắc với lịch sử hào hùng',
        facts: [
          'Nơi diễn ra chiến thắng Điện Biên Phủ',
          'Có 1 thành phố và 8 huyện',
          'Diện tích: 9,541 km²',
          'Dân số: khoảng 580 nghìn người',
          'Nổi tiếng với xôi nếp nương',
        ],
      ),
      Province(
        id: 'Dong Nai',
        name: 'Dong Nai',
        nameVietnamese: 'Đồng Nai',
        description: 'Tỉnh công nghiệp phát triển ở miền Đông Nam Bộ',
        facts: [
          'Trung tâm công nghiệp lớn',
          'Có 2 thành phố và 9 huyện',
          'Diện tích: 5,864 km²',
          'Dân số: khoảng 3.1 triệu người',
          'Nổi tiếng với bưởi Tân Triều',
        ],
      ),
      Province(
        id: 'Gia Lai',
        name: 'Gia Lai',
        nameVietnamese: 'Gia Lai',
        description: 'Tỉnh Tây Nguyên với văn hóa đặc sắc',
        facts: [
          'Vùng đất của người Jrai',
          'Có 1 thành phố và 17 huyện',
          'Diện tích: 15,511 km²',
          'Dân số: khoảng 1.5 triệu người',
          'Nổi tiếng với cà phê Buôn Ma Thuột',
        ],
      ),
      Province(
        id: 'Ha Tinh',
        name: 'Ha Tinh',
        nameVietnamese: 'Hà Tĩnh',
        description: 'Tỉnh ven biển miền Trung với nhiều di tích lịch sử',
        facts: [
          'Quê hương của nhiều danh nhân',
          'Có 1 thành phố và 12 huyện',
          'Diện tích: 6,026 km²',
          'Dân số: khoảng 1.3 triệu người',
          'Nổi tiếng với cam bù Hương Sơn',
        ],
      ),
      Province(
        id: 'Lai Chau',
        name: 'Lai Chau',
        nameVietnamese: 'Lai Châu',
        description: 'Tỉnh miền núi Tây Bắc với thiên nhiên hoang dã',
        facts: [
          'Vùng đất của nhiều dân tộc thiểu số',
          'Có 1 thành phố và 7 huyện',
          'Diện tích: 9,068 km²',
          'Dân số: khoảng 460 nghìn người',
          'Nổi tiếng với ruộng bậc thang',
        ],
      ),
      Province(
        id: 'Lam Dong',
        name: 'Lam Dong',
        nameVietnamese: 'Lâm Đồng',
        description: 'Tỉnh cao nguyên với khí hậu mát mẻ',
        facts: [
          'Thủ phủ của Tây Nguyên',
          'Có 2 thành phố và 10 huyện',
          'Diện tích: 9,773 km²',
          'Dân số: khoảng 1.3 triệu người',
          'Nổi tiếng với Đà Lạt và hoa',
        ],
      ),
      Province(
        id: 'Lang Son',
        name: 'Lang Son',
        nameVietnamese: 'Lạng Sơn',
        description: 'Tỉnh biên giới phía Bắc với nhiều danh lam thắng cảnh',
        facts: [
          'Có động Tam Thanh nổi tiếng',
          'Có 1 thành phố và 10 huyện',
          'Diện tích: 8,310 km²',
          'Dân số: khoảng 780 nghìn người',
          'Nổi tiếng với vịt quay Lạng Sơn',
        ],
      ),
      Province(
        id: 'Nghe An',
        name: 'Nghe An',
        nameVietnamese: 'Nghệ An',
        description: 'Tỉnh lớn nhất Việt Nam với truyền thống văn hóa lâu đời',
        facts: [
          'Quê hương của Chủ tịch Hồ Chí Minh',
          'Có 1 thành phố và 20 huyện',
          'Diện tích: 16,487 km²',
          'Dân số: khoảng 3.3 triệu người',
          'Nổi tiếng với cam Vinh',
        ],
      ),
      Province(
        id: 'Ninh Binh',
        name: 'Ninh Binh',
        nameVietnamese: 'Ninh Bình',
        description: 'Tỉnh có nhiều di tích lịch sử và danh lam thắng cảnh',
        facts: [
          'Cố đô Hoa Lư xưa',
          'Có 2 thành phố và 6 huyện',
          'Diện tích: 1,387 km²',
          'Dân số: khoảng 980 nghìn người',
          'Nổi tiếng với Tràng An và chùa Bái Đính',
        ],
      ),
      Province(
        id: 'Khanh Hoa',
        name: 'Khanh Hoa',
        nameVietnamese: 'Khánh Hòa',
        description: 'Tỉnh ven biển miền Trung với nhiều đảo đẹp',
        facts: [
          'Có Nha Trang - thành phố biển nổi tiếng',
          'Có 2 thành phố và 6 huyện',
          'Diện tích: 5,197 km²',
          'Dân số: khoảng 1.2 triệu người',
          'Nổi tiếng với bánh căn Nha Trang',
        ],
      ),
      Province(
        id: 'Dak Lak',
        name: 'Dak Lak',
        nameVietnamese: 'Đắk Lắk',
        description: 'Tỉnh Tây Nguyên với văn hóa đặc sắc',
        facts: [
          'Vùng đất của người Êđê',
          'Có 1 thành phố và 14 huyện',
          'Diện tích: 13,125 km²',
          'Dân số: khoảng 1.9 triệu người',
          'Nổi tiếng với cà phê Buôn Ma Thuột',
        ],
      ),
      Province(
        id: 'Quang Ngai',
        name: 'Quang Ngai',
        nameVietnamese: 'Quảng Ngãi',
        description: 'Tỉnh ven biển miền Trung với nhiều di tích lịch sử',
        facts: [
          'Quê hương của nhiều anh hùng',
          'Có 1 thành phố và 13 huyện',
          'Diện tích: 5,152 km²',
          'Dân số: khoảng 1.2 triệu người',
          'Nổi tiếng với mì Quảng',
        ],
      ),
      Province(
        id: 'Quang Ninh',
        name: 'Quang Ninh',
        nameVietnamese: 'Quảng Ninh',
        description: 'Tỉnh ven biển với Vịnh Hạ Long nổi tiếng',
        facts: [
          'Có Vịnh Hạ Long - di sản thế giới',
          'Có 4 thành phố và 8 huyện',
          'Diện tích: 6,178 km²',
          'Dân số: khoảng 1.3 triệu người',
          'Nổi tiếng với hải sản tươi ngon',
        ],
      ),
      Province(
        id: 'Quang Tri',
        name: 'Quang Tri',
        nameVietnamese: 'Quảng Trị',
        description: 'Tỉnh có nhiều di tích lịch sử quan trọng',
        facts: [
          'Nơi diễn ra nhiều trận đánh ác liệt',
          'Có 1 thành phố và 9 huyện',
          'Diện tích: 4,746 km²',
          'Dân số: khoảng 620 nghìn người',
          'Nổi tiếng với bánh bèo',
        ],
      ),
      Province(
        id: 'Son La',
        name: 'Son La',
        nameVietnamese: 'Sơn La',
        description: 'Tỉnh miền núi Tây Bắc với văn hóa đa dạng',
        facts: [
          'Vùng đất của nhiều dân tộc',
          'Có 1 thành phố và 11 huyện',
          'Diện tích: 14,123 km²',
          'Dân số: khoảng 1.2 triệu người',
          'Nổi tiếng với nhãn Sơn La',
        ],
      ),
      Province(
        id: 'Tay Ninh',
        name: 'Tay Ninh',
        nameVietnamese: 'Tây Ninh',
        description: 'Tỉnh có núi Bà Đen và nhiều di tích tôn giáo',
        facts: [
          'Có núi Bà Đen nổi tiếng',
          'Có 1 thành phố và 8 huyện',
          'Diện tích: 4,041 km²',
          'Dân số: khoảng 1.1 triệu người',
          'Nổi tiếng với bánh tráng phơi sương',
        ],
      ),
      Province(
        id: 'Hung Yen',
        name: 'Hung Yen',
        nameVietnamese: 'Hưng Yên',
        description: 'Tỉnh đồng bằng sông Hồng với truyền thống văn hóa',
        facts: [
          'Vùng đất học nổi tiếng',
          'Có 1 thành phố và 9 huyện',
          'Diện tích: 930 km²',
          'Dân số: khoảng 1.2 triệu người',
          'Nổi tiếng với nhãn lồng Hưng Yên',
        ],
      ),
      Province(
        id: 'An Giang',
        name: 'An Giang',
        nameVietnamese: 'An Giang',
        description: 'Tỉnh đồng bằng sông Cửu Long với nhiều di tích tôn giáo',
        facts: [
          'Có núi Sam và chùa Tây An',
          'Có 2 thành phố và 9 huyện',
          'Diện tích: 3,537 km²',
          'Dân số: khoảng 1.9 triệu người',
          'Nổi tiếng với bún nước lèo',
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
} 