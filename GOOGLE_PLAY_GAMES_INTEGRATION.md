# Hướng dẫn tích hợp Google Play Games Services

## Tổng quan

Dự án GeoVietnam đã được tích hợp Google Play Games Services để tăng tính tương tác và giữ chân người chơi. Tích hợp này bao gồm:

- **Google Sign In**: Đăng nhập bằng tài khoản Google
- **Firebase Analytics**: Theo dõi hành vi người dùng và sự kiện game
- **Game Events Logging**: Ghi log các sự kiện quan trọng trong game

## Các tính năng đã tích hợp

### 1. Đăng nhập Google Play Games
- Người chơi có thể đăng nhập bằng tài khoản Google
- Lưu trữ thông tin người chơi
- Hiển thị trạng thái đăng nhập

### 2. Ghi log sự kiện game
- **Điểm số**: Ghi log điểm số sau mỗi lần chơi
- **Khám phá tỉnh**: Ghi log khi người chơi mở khóa tỉnh mới
- **Hoàn thành thử thách**: Ghi log khi hoàn thành daily challenge
- **Achievements**: Ghi log khi đạt được thành tích

### 3. Analytics
- Theo dõi thời gian chơi
- Phân tích hành vi người dùng
- Thống kê điểm số và tiến độ

## Cấu hình cần thiết

### 1. Firebase Console
1. Tạo project mới trên [Firebase Console](https://console.firebase.google.com/)
2. Thêm ứng dụng Android với package name: `com.example.geovietnam`
3. Tải file `google-services.json` và đặt vào `android/app/`
4. Cập nhật các giá trị trong file `google-services.json`:
   - `YOUR_PROJECT_NUMBER`
   - `YOUR_APP_ID`
   - `YOUR_CLIENT_ID`
   - `YOUR_API_KEY`

### 2. Google Cloud Console
1. Tạo project trên [Google Cloud Console](https://console.cloud.google.com/)
2. Bật Google Sign-In API
3. Tạo OAuth 2.0 credentials
4. Cấu hình SHA-1 fingerprint cho ứng dụng

### 3. Google Play Console (Tùy chọn)
1. Tạo ứng dụng trên Google Play Console
2. Cấu hình Leaderboards và Achievements
3. Thêm Google Play Games Services

## Cách sử dụng

### 1. Khởi tạo service
```dart
// Trong main.dart
await GooglePlayGamesService().initialize();
```

### 2. Đăng nhập/Đăng xuất
```dart
final gamesService = GooglePlayGamesService();

// Đăng nhập
bool success = await gamesService.signIn();

// Đăng xuất
await gamesService.signOut();
```

### 3. Ghi log sự kiện
```dart
// Ghi log điểm số
await gamesService.logScore(
  score: 100,
  gameMode: 'daily_challenge',
);

// Ghi log khám phá tỉnh
await gamesService.logProvinceExplored(
  provinceName: 'Hà Nội',
  provinceId: 'ha_noi',
);

// Ghi log achievement
await gamesService.logAchievement(
  achievementId: 'first_province',
  achievementName: 'Tỉnh đầu tiên',
);
```

### 4. Sử dụng trong UI
```dart
// Widget đăng nhập
GooglePlayGamesWidget()

// Widget nút nhanh
GooglePlayGamesQuickActions(
  currentScore: score,
  gameMode: 'daily_challenge',
)
```

## Cấu trúc file

```
lib/
├── services/
│   └── google_play_games_service.dart    # Service chính
├── widgets/
│   └── google_play_games_widget.dart     # UI components
└── screens/
    ├── home_screen.dart                  # Tích hợp vào home
    └── game_screen.dart                  # Tích hợp vào game

android/
├── app/
│   ├── google-services.json             # Cấu hình Firebase
│   └── build.gradle.kts                 # Dependencies
└── build.gradle.kts                     # Google Services plugin
```

## Dependencies đã thêm

```yaml
dependencies:
  google_sign_in: ^6.2.1
  firebase_core: ^3.6.0
  firebase_analytics: ^11.3.3
```

## Bước tiếp theo

### 1. Tích hợp Leaderboards
- Tạo leaderboards trên Google Play Console
- Sử dụng Google Play Games Services API để submit scores
- Hiển thị leaderboards trong game

### 2. Tích hợp Achievements
- Tạo achievements trên Google Play Console
- Unlock achievements khi người chơi đạt điều kiện
- Hiển thị achievements UI

### 3. Cloud Save
- Lưu trữ tiến độ game trên cloud
- Đồng bộ dữ liệu giữa các thiết bị
- Backup và restore dữ liệu

### 4. Multiplayer Features
- Tạo phòng chơi
- Chơi cùng bạn bè
- Chat và tương tác

## Troubleshooting

### Lỗi thường gặp

1. **"Google Sign In failed"**
   - Kiểm tra SHA-1 fingerprint
   - Đảm bảo OAuth 2.0 credentials đúng
   - Kiểm tra package name

2. **"Firebase not initialized"**
   - Đảm bảo file `google-services.json` đúng vị trí
   - Kiểm tra Firebase project configuration

3. **"Analytics not working"**
   - Kiểm tra internet connection
   - Đảm bảo Firebase Analytics được enable
   - Kiểm tra log để debug

### Debug
```dart
// Bật debug mode
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Kiểm tra trạng thái đăng nhập
print('Is signed in: ${gamesService.isSignedIn}');
print('Current user: ${gamesService.currentUser?.email}');
```

## Liên hệ

Nếu có vấn đề hoặc cần hỗ trợ, vui lòng:
1. Kiểm tra logs trong console
2. Đọc documentation của Google Play Games Services
3. Tạo issue trên GitHub repository 