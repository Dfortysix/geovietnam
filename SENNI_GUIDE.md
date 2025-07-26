# 🌸 Hướng dẫn sử dụng Linh vật Senni

## 🎀 Giới thiệu

**Bé Sen "Senni"** là linh vật chính của game GeoVietnam, được thiết kế để tạo trải nghiệm tương tác thân thiện và giáo dục cho người chơi.

## 🎨 Đặc điểm nhân vật

### Ngoại hình
- **Tuổi**: 7-9 tuổi
- **Trang phục**: Áo dài cách tân màu hồng nhạt với họa tiết hoa sen
- **Phụ kiện**: 
  - Nón lá nhỏ
  - Túi bản đồ
  - Tóc buộc 2 bên
- **Gương mặt**: Tròn, mắt to long lanh, cười tươi

### Tính cách
- **Năng động**: Luôn hứng khởi, nhảy nhót khi có sự kiện mới
- **Thông minh**: Gợi ý thông tin thú vị về từng vùng miền
- **Thân thiện**: Giao tiếp vui vẻ, gọi người chơi là "bạn đồng hành"
- **Yêu thiên nhiên**: Hay nhắc tới hoa sen, phong cảnh, di tích lịch sử

## 🎮 Cách sử dụng trong game

### 1. Tích hợp cơ bản

```dart
import '../widgets/senni_container_widget.dart';

// Sử dụng SenniHelper để dễ dàng thêm Senni vào màn hình
return SenniHelper.showSenniInScreen(
  situation: 'greeting',
  senniSize: 120,
  messageDuration: const Duration(seconds: 5),
  child: Scaffold(
    // Your screen content
  ),
);
```

### 2. Các tình huống (Situations)

| Tình huống | Mô tả | Mood | Action |
|------------|-------|------|--------|
| `greeting` | Chào mừng người chơi | Happy | Waving |
| `correct_answer` | Trả lời đúng | Excited | Cheering |
| `wrong_answer` | Trả lời sai | Thinking | Thinking |
| `province_unlock` | Mở khóa tỉnh mới | Excited | Cheering |
| `province_info` | Giới thiệu tỉnh | Happy | Greeting |
| `achievement` | Đạt thành tích | Celebrating | Dancing |
| `game_end` | Kết thúc game | Happy | Waving |

### 3. Sử dụng với thông điệp tùy chỉnh

```dart
SenniContainerWidget(
  situation: 'province_unlock',
  provinceName: 'Ha Noi',
  customMessage: 'Thông điệp tùy chỉnh của bạn',
  senniSize: 100,
  messageDuration: const Duration(seconds: 4),
  autoHide: true,
)
```

### 4. Tương tác với Senni

```dart
SenniContainerWidget(
  situation: 'greeting',
  onSenniTap: () {
    // Xử lý khi người chơi tap vào Senni
    print('Senni được tap!');
  },
  // ... other properties
)
```

## 🎯 Các tính năng chính

### 1. Animation tự động
- **Bounce**: Senni nhảy nhẹ nhàng
- **Wave**: Vẫy tay khi chào
- **Dance**: Nhảy múa khi chúc mừng
- **Sparkle**: Hiệu ứng lấp lánh khi vui

### 2. Thông điệp thông minh
- **Ngẫu nhiên**: Mỗi lần hiển thị thông điệp khác nhau
- **Tùy chỉnh**: Có thể set thông điệp riêng
- **Tự động ẩn**: Thông điệp tự động ẩn sau thời gian định sẵn

### 3. Responsive design
- **Adaptive size**: Kích thước thay đổi theo màn hình
- **Position**: Vị trí tự động điều chỉnh
- **Touch friendly**: Dễ dàng tương tác

## 🛠️ Tùy chỉnh nâng cao

### 1. Thêm thông điệp mới

```dart
// Trong SenniService
static const List<String> customMessages = [
  "Thông điệp 1",
  "Thông điệp 2",
  "Thông điệp 3",
];

String getCustomMessage() {
  return getRandomMessage(customMessages);
}
```

### 2. Tạo mood mới

```dart
// Trong SenniMood enum
enum SenniMood {
  happy,
  excited,
  thinking,
  sad,
  celebrating,
  // Thêm mood mới
  surprised,
}

// Trong SenniMascotWidget
Color _getMoodColor() {
  switch (widget.mood) {
    // ... existing cases
    case SenniMood.surprised:
      return Colors.yellow.shade400;
  }
}
```

### 3. Tạo action mới

```dart
// Trong SenniAction enum
enum SenniAction {
  greeting,
  cheering,
  thinking,
  pointing,
  dancing,
  waving,
  // Thêm action mới
  jumping,
}

// Trong _buildActionEffects()
case SenniAction.jumping:
  effects.add(
    // Custom jumping animation
  );
  break;
```

## 🎨 Thiết kế visual

### Màu sắc chủ đạo
- **Hồng nhạt**: Màu chính của Senni
- **Xanh lá**: Màu phụ, tượng trưng cho thiên nhiên
- **Vàng nhẹ**: Màu accent, tạo sự ấm áp

### Style
- **Vector art**: Mềm mại, dễ scale
- **Pastel colors**: Nhẹ nhàng, thân thiện
- **Animation**: Mượt mà, tự nhiên

## 📱 Tích hợp vào game

### 1. Màn hình chính (HomeScreen)
```dart
// Đã tích hợp sẵn với situation: 'greeting'
```

### 2. Màn hình game (GameScreen)
```dart
// Tự động thay đổi situation dựa trên:
// - correct_answer: Khi trả lời đúng
// - wrong_answer: Khi trả lời sai
// - game_end: Khi kết thúc game
```

### 3. Màn hình demo (SenniDemoScreen)
```dart
// Màn hình test tất cả tính năng của Senni
// Truy cập từ menu chính
```

## 🎯 Best Practices

### 1. Sử dụng đúng situation
- Chọn situation phù hợp với context
- Không lạm dụng quá nhiều animation

### 2. Thông điệp ngắn gọn
- Giữ thông điệp dưới 50 ký tự
- Sử dụng emoji để tăng tính sinh động

### 3. Performance
- Sử dụng `autoHide: true` để tiết kiệm tài nguyên
- Không tạo quá nhiều instance Senni cùng lúc

### 4. Accessibility
- Đảm bảo contrast đủ tốt
- Có thể tắt animation nếu cần

## 🐛 Troubleshooting

### 1. Senni không hiển thị
- Kiểm tra `showSenni: true`
- Đảm bảo widget được wrap trong Stack

### 2. Animation không hoạt động
- Kiểm tra `isAnimated: true`
- Đảm bảo đã import flutter_animate

### 3. Thông điệp không đúng
- Kiểm tra situation có đúng không
- Kiểm tra SenniService có method tương ứng

## 🎉 Kết luận

Linh vật Senni được thiết kế để tạo trải nghiệm game thân thiện và giáo dục. Với các tính năng linh hoạt và dễ tùy chỉnh, Senni sẽ giúp game GeoVietnam trở nên hấp dẫn hơn cho người chơi.

---

**Lưu ý**: Đây là phiên bản 1.0 của Senni. Các tính năng mới sẽ được thêm vào trong các phiên bản tiếp theo. 