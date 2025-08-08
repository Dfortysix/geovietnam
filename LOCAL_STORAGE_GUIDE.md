# Hướng dẫn Kiểm tra Local Storage

## 📱 **Local Storage đang lưu gì:**

### **1. Dữ liệu theo User (có User ID):**
```
{userId}_total_score          → int (tổng điểm)
{userId}_daily_streak         → int (chuỗi ngày chơi liên tiếp)
{userId}_last_play_date       → String (ngày chơi cuối)
{userId}_unlocked_provinces   → List<String> (danh sách tỉnh đã mở khóa)
{userId}_explored_provinces   → List<String> (danh sách tỉnh đã khám phá)
{userId}_province_score_{id}  → int (điểm của từng tỉnh)
```

### **2. Dữ liệu Anonymous (không có User ID):**
```
anonymous_total_score         → int
anonymous_daily_streak        → int
anonymous_last_play_date      → String
anonymous_unlocked_provinces  → List<String>
anonymous_explored_provinces  → List<String>
anonymous_province_score_{id} → int
```

## 🧪 **Cách kiểm tra:**

### **Test 1: Debug tất cả local storage**
```dart
await GameProgressService.debugAllLocalStorage();
```

### **Test 2: Debug tiến độ hiện tại**
```dart
await GameProgressService.debugCurrentProgress();
```

### **Test 3: Test lưu dữ liệu**
```dart
// Lưu dữ liệu test
await GameProgressService.updateScore(100);
await GameProgressService.unlockProvince('hanoi');
await GameProgressService.updateProvinceScore('hanoi', 50);
await GameProgressService.exploreProvince('hanoi');

// Kiểm tra lại
await GameProgressService.debugAllLocalStorage();
```

## 📝 **Ví dụ kết quả:**

### **Khi user đã đăng nhập:**
```
=== DEBUG ALL LOCAL STORAGE ===
User ID: 106794033101122696032
Firebase Auth Current User: 106794033101122696032
Total keys in SharedPreferences: 8

--- USER KEYS (6) ---
106794033101122696032_total_score: 150
106794033101122696032_daily_streak: 3
106794033101122696032_last_play_date: 2024-01-15T10:30:00.000Z
106794033101122696032_unlocked_provinces: [hanoi, haiphong]
106794033101122696032_explored_provinces: [hanoi]
106794033101122696032_province_score_hanoi: 50

--- OTHER KEYS (2) ---
some_other_key: some_value
another_key: another_value

--- DETAILED USER DATA ---
Total Score Key: 106794033101122696032_total_score = 150
Daily Streak Key: 106794033101122696032_daily_streak = 3
Last Play Date Key: 106794033101122696032_last_play_date = 2024-01-15T10:30:00.000Z
Unlocked Provinces Key: 106794033101122696032_unlocked_provinces = [hanoi, haiphong]
Explored Provinces Key: 106794033101122696032_explored_provinces = [hanoi]

--- PROVINCE SCORES (1) ---
106794033101122696032_province_score_hanoi: 50
=== END DEBUG ALL LOCAL STORAGE ===
```

### **Khi user chưa đăng nhập:**
```
=== DEBUG ALL LOCAL STORAGE ===
User ID: null
Firebase Auth Current User: null
Total keys in SharedPreferences: 5

--- USER KEYS (5) ---
anonymous_total_score: 0
anonymous_daily_streak: 0
anonymous_last_play_date: 2024-01-15T10:30:00.000Z
anonymous_unlocked_provinces: []
anonymous_explored_provinces: []

--- OTHER KEYS (0) ---
=== END DEBUG ALL LOCAL STORAGE ===
```

## 🔍 **Phân tích dữ liệu:**

### **Nếu có nhiều user keys:**
- ✅ Hệ thống đang lưu đúng theo user
- ✅ Mỗi user có dữ liệu riêng biệt

### **Nếu chỉ có anonymous keys:**
- ❌ User chưa đăng nhập
- ❌ Hoặc logic lưu có vấn đề

### **Nếu không có keys nào:**
- ❌ SharedPreferences không hoạt động
- ❌ Hoặc chưa có dữ liệu nào được lưu

### **Nếu có keys của user khác:**
- ❌ Logic xóa dữ liệu có vấn đề
- ❌ Cần kiểm tra `clearDataOnLogout()`

## 🚀 **Test scenarios:**

### **Scenario 1: User mới**
```dart
// Đăng nhập lần đầu
await GameProgressService.debugAllLocalStorage();
// Kết quả: Chỉ có keys của user hiện tại
```

### **Scenario 2: User đã có dữ liệu**
```dart
// Lưu một số dữ liệu
await GameProgressService.updateScore(100);
await GameProgressService.unlockProvince('hanoi');
await GameProgressService.debugAllLocalStorage();
// Kết quả: Có đầy đủ dữ liệu
```

### **Scenario 3: Đăng xuất**
```dart
// Đăng xuất
// Sau đó kiểm tra
await GameProgressService.debugAllLocalStorage();
// Kết quả: Không có keys của user đã đăng xuất
```

### **Scenario 4: Đăng nhập lại**
```dart
// Đăng nhập lại
await GameProgressService.debugAllLocalStorage();
// Kết quả: Có keys của user mới
```

## ⚠️ **Lưu ý quan trọng:**

1. **Key format**: `{userId}_{data_type}` hoặc `anonymous_{data_type}`
2. **Data types**: int, String, List<String>
3. **User isolation**: Mỗi user có keys riêng biệt
4. **Cleanup**: Dữ liệu được xóa khi đăng xuất
5. **Persistence**: Dữ liệu tồn tại cho đến khi app bị xóa hoặc clear data

Hãy chạy `await GameProgressService.debugAllLocalStorage();` và cho tôi biết kết quả! 🎯 