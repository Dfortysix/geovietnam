# Hướng dẫn Test Hệ thống Lưu Tiến trình Theo User

## 🔧 **Các vấn đề đã sửa:**

### 1. **Lưu tiến trình theo user riêng biệt:**
- ✅ Mỗi user có key riêng trong SharedPreferences
- ✅ Format: `{userId}_{key}` (ví dụ: `user123_unlocked_provinces`)
- ✅ Anonymous user có key: `anonymous_{key}`

### 2. **Đồng bộ dữ liệu khi đăng nhập/đăng xuất:**
- ✅ `syncOnLogin()`: Lấy dữ liệu từ cloud về local
- ✅ `syncOnLogout()`: Lưu dữ liệu local lên cloud
- ✅ Tự động gọi khi đăng nhập/đăng xuất

### 3. **Lưu đầy đủ thông tin:**
- ✅ Total score
- ✅ Daily streak
- ✅ Unlocked provinces
- ✅ Explored provinces
- ✅ Province scores
- ✅ Last play date

## 🧪 **Cách test:**

### **Bước 1: Chạy ứng dụng và đăng nhập**
```bash
flutter run
```

### **Bước 2: Mở Debug Console và chạy test**
Trong Debug Console của Flutter, gõ:
```dart
import 'package:your_app/services/game_progress_service.dart';
await GameProgressService.debugCurrentProgress();
```

### **Bước 3: Test các chức năng**
```dart
// Test cập nhật score
await GameProgressService.updateScore(100);

// Test mở khóa tỉnh
await GameProgressService.unlockProvince('hanoi');

// Test cập nhật score tỉnh
await GameProgressService.updateProvinceScore('hanoi', 50);

// Test đánh dấu khám phá
await GameProgressService.exploreProvince('hanoi');

// Kiểm tra lại
await GameProgressService.debugCurrentProgress();
```

### **Bước 4: Test đăng xuất và đăng nhập lại**
1. Đăng xuất
2. Đăng nhập lại
3. Kiểm tra dữ liệu có được đồng bộ không

## 🔍 **Kiểm tra kết quả:**

### **Nếu hoạt động đúng:**
- ✅ Mỗi user có dữ liệu riêng
- ✅ Dữ liệu được lưu local và cloud
- ✅ Đồng bộ khi đăng nhập/đăng xuất
- ✅ Score và provinces được cập nhật đúng

### **Nếu có lỗi:**
- ❌ Kiểm tra Firebase Auth có hoạt động không
- ❌ Kiểm tra Firestore permissions
- ❌ Kiểm tra internet connection
- ❌ Xem log lỗi trong console

## 📝 **Log mẫu khi hoạt động đúng:**

```
=== DEBUG CURRENT PROGRESS ===
User ID: user123
Unlocked Provinces: [hanoi, haiphong]
Total Score: 150
Daily Streak: 3
Explored Provinces: [hanoi]
Province hanoi Score: 50
Province haiphong Score: 30
=============================
```

## 🚀 **Các method có thể sử dụng:**

```dart
// Lấy tiến độ hiện tại
GameProgress progress = await GameProgressService.getCurrentProgress();

// Cập nhật score
await GameProgressService.updateScore(100);

// Mở khóa tỉnh
await GameProgressService.unlockProvince('province_id');

// Cập nhật score tỉnh
await GameProgressService.updateProvinceScore('province_id', 50);

// Đánh dấu khám phá
await GameProgressService.exploreProvince('province_id');

// Đồng bộ từ cloud
await GameProgressService.syncFromCloud();

// Đồng bộ lên cloud
await GameProgressService.syncToCloud();

// Debug thông tin
await GameProgressService.debugCurrentProgress();

// Xóa dữ liệu local
await GameProgressService.clearLocalData();
```

## ⚠️ **Lưu ý quan trọng:**

1. **User ID**: Sử dụng Firebase Auth UID, không phải Google Sign-In ID
2. **Local Storage**: Dữ liệu được lưu theo user riêng biệt
3. **Cloud Sync**: Chỉ đồng bộ khi user đã đăng nhập
4. **Error Handling**: Các lỗi cloud không làm gián đoạn local storage
5. **Performance**: Local storage ưu tiên, cloud sync background

Hãy test và cho tôi biết kết quả! 🎯 