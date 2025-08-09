# 🌏 GeoVietnam - Game Địa Lý Việt Nam

> Ứng dụng game giáo dục về địa lý Việt Nam với dữ liệu cập nhật sau sáp nhập 1/7/2025

## 📋 Tổng quan

GeoVietnam là một ứng dụng game giáo dục được phát triển bằng Flutter, giúp người dùng khám phá và học hỏi về địa lý Việt Nam thông qua các hoạt động tương tác thú vị. Ứng dụng được cập nhật với dữ liệu chính xác về các tỉnh thành sau đợt sáp nhập 1/7/2025.

## 🎯 Tính năng chính

### 🗺️ Khám phá bản đồ tương tác
- **Bản đồ SVG tương tác**: Hiển thị bản đồ Việt Nam với khả năng tương tác
- **Trạng thái tỉnh**: Hiển thị các tỉnh đã mở khóa/chưa mở khóa
- **Thông tin chi tiết**: Xem thông tin, mô tả và sự kiện thú vị về từng tỉnh
- **Hình ảnh nền**: Hỗ trợ hình ảnh nền cho các tỉnh cụ thể

### 🎮 Hệ thống game
- **Daily Challenge**: Thử thách hàng ngày với câu hỏi về địa lý
- **Hệ thống điểm**: Tích lũy điểm để mở khóa tỉnh mới
- **Tiến độ khám phá**: Theo dõi số tỉnh đã khám phá
- **Streak hàng ngày**: Duy trì chuỗi chơi liên tục

### 👤 Hồ sơ người chơi
- **Thống kê chi tiết**: Tổng điểm, số tỉnh đã mở khóa, streak
- **Lịch sử chơi**: Theo dõi tiến độ theo thời gian
- **Thành tích**: Hiển thị các thành tích đạt được

### 🔐 Tích hợp đăng nhập
- **Google Play Games**: Đăng nhập và đồng bộ tiến độ
- **Firebase Authentication**: Xác thực người dùng an toàn
- **Cloud Firestore**: Lưu trữ và đồng bộ dữ liệu

### 🎨 Giao diện người dùng
- **Thiết kế hiện đại**: Material Design 3 với theme màu cam cam
- **Animation mượt mà**: Sử dụng Flutter Animate cho trải nghiệm tốt
- **Responsive**: Tương thích với nhiều kích thước màn hình
- **Accessibility**: Hỗ trợ người dùng khuyết tật

## 🏗️ Kiến trúc ứng dụng

### 📁 Cấu trúc thư mục
```
lib/
├── main.dart                 # Entry point của ứng dụng
├── models/                   # Data models
│   ├── province.dart         # Model tỉnh thành
│   └── game_progress.dart    # Model tiến độ game
├── screens/                  # Các màn hình chính
│   ├── home_screen.dart      # Màn hình chính
│   ├── map_exploration_screen.dart  # Khám phá bản đồ
│   ├── game_screen.dart      # Màn hình chơi game
│   ├── daily_challenge_screen.dart  # Thử thách hàng ngày
│   ├── profile_screen.dart   # Hồ sơ người chơi
│   └── progress_screen.dart  # Tiến độ chi tiết
├── services/                 # Business logic
│   ├── game_progress_service.dart    # Quản lý tiến độ
│   ├── daily_challenge_service.dart  # Quản lý thử thách
│   ├── auth_service.dart     # Xác thực
│   ├── google_play_games_service.dart  # Tích hợp Google Play
│   └── user_service.dart     # Quản lý người dùng
├── widgets/                  # Custom widgets
│   ├── svg_canvas_vietnam_map_widget.dart  # Widget bản đồ
│   ├── google_play_games_widget.dart       # Widget Google Play
│   └── user_avatar_widget.dart             # Widget avatar
├── data/                     # Dữ liệu tĩnh
│   └── provinces_data.dart   # Dữ liệu tỉnh thành
└── theme/                    # Theme và styling
    └── app_theme.dart        # Cấu hình theme
```

### 🔧 Công nghệ sử dụng

#### Core Framework
- **Flutter 3.8.1+**: Framework chính
- **Dart**: Ngôn ngữ lập trình

#### UI/UX
- **Material Design 3**: Design system
- **Google Fonts**: Typography
- **Flutter Animate**: Animation library
- **Lottie**: Animation files
- **Shimmer**: Loading effects

#### Backend & Storage
- **Firebase Core**: Backend services
- **Cloud Firestore**: Database
- **Firebase Auth**: Authentication
- **Firebase Analytics**: Analytics

#### Game Services
- **Google Play Games**: Achievement & leaderboard
- **Google Sign-In**: Social login

#### Utilities
- **Shared Preferences**: Local storage
- **Provider**: State management
- **Audio Players**: Sound effects
- **Flutter SVG**: SVG rendering
- **Cached Network Image**: Image caching

## 🚀 Cài đặt và chạy

### Yêu cầu hệ thống
- Flutter SDK 3.8.1+
- Dart SDK
- Android Studio / VS Code
- Android SDK (cho Android)
- Xcode (cho iOS)

### Bước 1: Clone repository
```bash
git clone <repository-url>
cd geovietnam
```

### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 3: Cấu hình Firebase
1. Tạo project Firebase mới
2. Thêm ứng dụng Android/iOS
3. Tải file cấu hình `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS)
4. Đặt file vào thư mục tương ứng

### Bước 4: Cấu hình Google Play Games
1. Tạo project trong Google Play Console
2. Cấu hình Google Play Games Services
3. Thêm SHA-1 fingerprint vào Firebase

### Bước 5: Chạy ứng dụng
```bash
flutter run
```

## 📊 Dữ liệu tỉnh thành

Ứng dụng sử dụng dữ liệu chính xác về 63 tỉnh thành Việt Nam sau đợt sáp nhập 1/7/2025, bao gồm:

### Thông tin mỗi tỉnh:
- **ID và tên**: Mã định danh và tên tiếng Việt
- **Mô tả**: Thông tin tổng quan về tỉnh
- **Sự kiện thú vị**: 5 sự kiện nổi bật
- **Trạng thái**: Đã mở khóa/chưa mở khóa
- **Điểm số**: Điểm đạt được và điểm yêu cầu

### Nguồn dữ liệu:
- Thông tin chính thức từ [sapnhap.bando.com.vn](https://sapnhap.bando.com.vn)
- Dữ liệu địa lý và hành chính cập nhật
- Thông tin văn hóa và du lịch

## 🎮 Cách chơi

### 1. Khám phá bản đồ
- Chạm vào các tỉnh trên bản đồ để xem thông tin
- Các tỉnh đã mở khóa sẽ có màu khác biệt
- Xem mô tả và sự kiện thú vị về từng tỉnh

### 2. Daily Challenge
- Tham gia thử thách hàng ngày
- Trả lời 7 câu hỏi về địa lý
- Đạt điểm cao để mở khóa tỉnh mới

### 3. Tích lũy điểm
- Hoàn thành thử thách để nhận điểm
- Duy trì streak hàng ngày để nhận bonus
- Mở khóa tỉnh mới khi đạt đủ điểm

### 4. Theo dõi tiến độ
- Xem tổng số tỉnh đã khám phá
- Kiểm tra thành tích và điểm số
- Đồng bộ tiến độ với Google Play Games

## 🔧 Cấu hình và tùy chỉnh

### Theme
Ứng dụng sử dụng theme màu cam cam với các màu chính:
- **Primary Orange**: #FFA726
- **Secondary Yellow**: #FFEE58
- **Background Gradient**: Từ #FFF8E1 đến #FFECB3

### Animation
- Sử dụng Flutter Animate cho smooth transitions
- Animation duration: 300ms
- Curve: Curves.easeInOut

### Localization
- Hỗ trợ tiếng Việt
- Có thể mở rộng cho đa ngôn ngữ

## 📱 Hỗ trợ nền tảng

- ✅ Android (API 21+)
- ✅ iOS (iOS 12.0+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows (Windows 10+)
- ✅ macOS (macOS 10.14+)
- ✅ Linux (Ubuntu 18.04+)

## 🤝 Đóng góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng:

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 Giấy phép

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

## 📞 Liên hệ

- **Email**: [your-email@example.com]
- **Website**: [your-website.com]
- **GitHub**: [your-github-profile]

## 🙏 Lời cảm ơn

- Dữ liệu địa lý từ [sapnhap.bando.com.vn](https://sapnhap.bando.com.vn)
- Cộng đồng Flutter và Dart
- Tất cả contributors đã đóng góp cho dự án

---

**GeoVietnam** - Khám phá Việt Nam qua game! 🇻🇳
