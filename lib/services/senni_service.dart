import 'dart:math';

class SenniService {
  static final SenniService _instance = SenniService._internal();
  factory SenniService() => _instance;
  SenniService._internal();

  // Các thông điệp chào mừng
  static const List<String> greetingMessages = [
    "🗺️ Cùng Senni khám phá đất Việt yêu thương nào!",
    "🌸 Chào bạn! Senni rất vui được gặp bạn!",
    "🌏 Sẵn sàng khám phá địa lý Việt Nam chưa?",
    "💫 Chào mừng bạn đến với cuộc phiêu lưu địa lý!",
  ];

  // Thông điệp chúc mừng khi trả lời đúng
  static const List<String> correctAnswerMessages = [
    "🎉 Tuyệt vời! Bạn thật thông minh!",
    "🌟 Chính xác! Senni rất tự hào về bạn!",
    "💫 Hoàn hảo! Bạn đã hiểu rất rõ về Việt Nam!",
    "🏆 Xuất sắc! Bạn là chuyên gia địa lý!",
  ];

  // Thông điệp động viên khi trả lời sai
  static const List<String> wrongAnswerMessages = [
    "💪 Không sao đâu! Hãy thử lại nhé!",
    "🤔 Hmm... Hãy suy nghĩ kỹ hơn một chút!",
    "💡 Gợi ý: Hãy nhìn kỹ bản đồ!",
    "🌸 Đừng buồn! Senni tin bạn sẽ làm được!",
  ];

  // Thông điệp khi mở khóa tỉnh mới
  static const Map<String, String> provinceUnlockMessages = {
    'Ha Noi': "🎉 Chúc mừng bạn đã mở khóa Hà Nội – Thủ đô nghìn năm văn hiến!",
    'Ho Chi Minh': "🌟 Hoàn hảo! TP.HCM – Thành phố mang tên Bác!",
    'Da Nang': "🏖️ Tuyệt! Đà Nẵng – Thành phố đáng sống!",
    'Hai Phong': "⚓ Xuất sắc! Hải Phòng – Thành phố Cảng!",
    'Can Tho': "🌾 Tuyệt vời! Cần Thơ – Tây Đô xinh đẹp!",
    'Hue': "🏛️ Chúc mừng bạn đã mở khóa Huế – nơi có Kinh Thành cổ kính!",
    'Nha Trang': "🏝️ Hoàn hảo! Nha Trang – Thành phố biển xinh đẹp!",
    'Vung Tau': "⛰️ Tuyệt! Vũng Tàu – Thành phố biển miền Nam!",
  };

  // Thông điệp giới thiệu vùng miền
  static const Map<String, String> regionInfoMessages = {
    'Mien Bac': "🌸 Miền Bắc có mùa đông lạnh và mùa xuân với hoa đào nở rộ!",
    'Mien Trung': "🏖️ Miền Trung có những bãi biển đẹp và di tích lịch sử!",
    'Mien Nam': "🌾 Miền Nam có đồng bằng sông Cửu Long trù phú!",
    'Tay Nguyen': "☕ Tây Nguyên có cà phê thơm và văn hóa độc đáo!",
  };

  // Thông điệp khi đạt thành tích
  static const List<String> achievementMessages = [
    "🏆 Chúc mừng! Bạn đã đạt được thành tích mới!",
    "🌟 Tuyệt vời! Senni rất tự hào về bạn!",
    "💫 Hoàn hảo! Bạn là chuyên gia địa lý thực thụ!",
    "🎊 Xuất sắc! Bạn đã chinh phục được Việt Nam!",
  ];

  // Thông điệp khi kết thúc game
  static const List<String> gameEndMessages = [
    "🌸 Cảm ơn bạn đã chơi cùng Senni!",
    "🌟 Bạn đã hoàn thành xuất sắc cuộc phiêu lưu!",
    "💫 Hẹn gặp lại bạn trong lần chơi tiếp theo!",
    "🎊 Chúc bạn có một ngày tuyệt vời!",
  ];

  // Lấy thông điệp ngẫu nhiên từ danh sách
  String getRandomMessage(List<String> messages) {
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  // Lấy thông điệp chào mừng
  String getGreetingMessage() {
    return getRandomMessage(greetingMessages);
  }

  // Lấy thông điệp khi trả lời đúng
  String getCorrectAnswerMessage() {
    return getRandomMessage(correctAnswerMessages);
  }

  // Lấy thông điệp khi trả lời sai
  String getWrongAnswerMessage() {
    return getRandomMessage(wrongAnswerMessages);
  }

  // Lấy thông điệp khi mở khóa tỉnh
  String getProvinceUnlockMessage(String provinceName) {
    return provinceUnlockMessages[provinceName] ?? 
           "🎉 Chúc mừng bạn đã mở khóa $provinceName!";
  }

  // Lấy thông điệp giới thiệu vùng miền
  String getRegionInfoMessage(String regionName) {
    return regionInfoMessages[regionName] ?? 
           "🌸 $regionName có nhiều điều thú vị để khám phá!";
  }

  // Lấy thông điệp khi đạt thành tích
  String getAchievementMessage() {
    return getRandomMessage(achievementMessages);
  }

  // Lấy thông điệp khi kết thúc game
  String getGameEndMessage() {
    return getRandomMessage(gameEndMessages);
  }

  // Xác định mood của Senni dựa trên tình huống (trả về string)
  String getMoodForSituation(String situation) {
    switch (situation) {
      case 'greeting':
        return 'happy';
      case 'correct_answer':
        return 'excited';
      case 'wrong_answer':
        return 'thinking';
      case 'achievement':
        return 'celebrating';
      case 'game_end':
        return 'happy';
      default:
        return 'happy';
    }
  }

  // Tạo thông điệp tùy chỉnh cho tỉnh cụ thể
  String getCustomProvinceMessage(String provinceName) {
    switch (provinceName) {
      case 'Ha Noi':
        return "🌸 Senni thích nhất là phố cổ Hà Nội với những món ăn ngon!";
      case 'Ho Chi Minh':
        return "🌟 TP.HCM có nhà thờ Đức Bà và chợ Bến Thành nổi tiếng!";
      case 'Da Nang':
        return "🏖️ Đà Nẵng có bãi biển Mỹ Khê đẹp nhất thế giới!";
      case 'Hue':
        return "🏛️ Huế có cung điện và lăng tẩm cổ kính!";
      case 'Nha Trang':
        return "🏝️ Nha Trang có đảo Hòn Tre và tháp Bà Ponagar!";
      case 'Can Tho':
        return "🌾 Cần Thơ có chợ nổi Cái Răng độc đáo!";
      case 'Vung Tau':
        return "⛰️ Vũng Tàu có núi Tà Cú và bãi biển đẹp!";
      default:
        return "🌸 $provinceName có nhiều điều thú vị để khám phá!";
    }
  }
} 