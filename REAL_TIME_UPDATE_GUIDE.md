# Hướng dẫn Test Cập nhật Real-time

## 🎯 **Tính năng mới:**

### **✅ Cập nhật real-time khi có thay đổi:**
- Điểm số thay đổi → UI cập nhật ngay lập tức
- Daily streak thay đổi → UI cập nhật ngay lập tức
- Mở khóa tỉnh → UI cập nhật ngay lập tức
- Thống kê game → UI cập nhật ngay lập tức

## 🔄 **Cách hoạt động:**

### **1. GameProgressService extends ChangeNotifier:**
- ✅ Singleton pattern để quản lý state
- ✅ Notify listeners khi có thay đổi
- ✅ Tất cả method đều notify khi cập nhật

### **2. HomeScreen & ProfileScreen:**
- ✅ Lắng nghe GameProgressService
- ✅ Refresh UI khi có thay đổi
- ✅ Hiển thị dữ liệu real-time

### **3. Các method được cập nhật:**
- ✅ updateScore() → Notify listeners
- ✅ updateDailyStreak() → Notify listeners
- ✅ unlockProvince() → Notify listeners
- ✅ updateProvinceScore() → Notify listeners
- ✅ exploreProvince() → Notify listeners
- ✅ syncOnLogin() → Notify listeners

## 🧪 **Test Scenarios:**

### **Test 1: Cập nhật điểm số real-time**
1. Đăng nhập và vào game
2. Chơi game và kiếm điểm
3. Quay lại HomeScreen

**Kết quả mong đợi:**
- ✅ Điểm số trên header cập nhật ngay lập tức
- ✅ Thống kê trong ProfileScreen cập nhật ngay lập tức
- ✅ Không cần restart app

### **Test 2: Cập nhật daily streak real-time**
1. Chơi game hàng ngày
2. Kiểm tra daily streak

**Kết quả mong đợi:**
- ✅ Daily streak tăng ngay lập tức
- ✅ UI hiển thị streak mới
- ✅ Thống kê cập nhật real-time

### **Test 3: Mở khóa tỉnh real-time**
1. Chơi game và đạt đủ điểm
2. Mở khóa tỉnh mới

**Kết quả mong đợi:**
- ✅ Số tỉnh đã khám phá tăng ngay lập tức
- ✅ Thống kê cập nhật real-time
- ✅ UI hiển thị tỉnh mới

### **Test 4: Chuyển đổi màn hình**
1. Chơi game ở màn hình A
2. Chuyển sang màn hình B
3. Quay lại màn hình A

**Kết quả mong đợi:**
- ✅ Tất cả màn hình đều hiển thị dữ liệu mới
- ✅ Không có dữ liệu cũ
- ✅ Đồng bộ hoàn toàn

## 🚀 **Test Commands:**

### **Test 1: Cập nhật điểm số**
```dart
// Cập nhật điểm số
await GameProgressService.updateScore(100);

// Kiểm tra UI đã cập nhật chưa
// Điểm số trên header và ProfileScreen sẽ thay đổi ngay lập tức
```

### **Test 2: Cập nhật daily streak**
```dart
// Cập nhật daily streak
await GameProgressService.updateDailyStreak();

// Kiểm tra UI đã cập nhật chưa
// Daily streak sẽ thay đổi ngay lập tức
```

### **Test 3: Mở khóa tỉnh**
```dart
// Mở khóa tỉnh
await GameProgressService.unlockProvince('hanoi');

// Kiểm tra UI đã cập nhật chưa
// Số tỉnh đã khám phá sẽ tăng ngay lập tức
```

### **Test 4: Cập nhật điểm tỉnh**
```dart
// Cập nhật điểm tỉnh
await GameProgressService.updateProvinceScore('hanoi', 75);

// Kiểm tra UI đã cập nhật chưa
// Điểm tỉnh sẽ thay đổi ngay lập tức
```

## 📝 **Kết quả mong đợi:**

### **Trước khi cập nhật:**
```
Header: Điểm số: 150 | Streak: 3
Profile: Tỉnh đã khám phá: 5/63
```

### **Sau khi cập nhật:**
```
Header: Điểm số: 250 | Streak: 4
Profile: Tỉnh đã khám phá: 6/63
```

### **Thời gian cập nhật:**
- ✅ Ngay lập tức (không có delay)
- ✅ Không cần restart app
- ✅ Không cần refresh thủ công

## 🔧 **Các thay đổi chính:**

### **1. GameProgressService:**
- ✅ Extends ChangeNotifier
- ✅ Singleton pattern
- ✅ Method notifyProgressChanged()
- ✅ Tất cả method đều notify

### **2. HomeScreen:**
- ✅ Lắng nghe GameProgressService
- ✅ Method _onGameProgressChanged()
- ✅ Refresh UI khi có thay đổi

### **3. ProfileScreen:**
- ✅ Lắng nghe GameProgressService
- ✅ Method _onGameProgressChanged()
- ✅ Refresh UI khi có thay đổi

### **4. Các method được cập nhật:**
- ✅ updateScore() → Notify listeners
- ✅ updateDailyStreak() → Notify listeners
- ✅ unlockProvince() → Notify listeners
- ✅ updateProvinceScore() → Notify listeners
- ✅ exploreProvince() → Notify listeners
- ✅ syncOnLogin() → Notify listeners

## ⚠️ **Lưu ý quan trọng:**

### **1. Performance:**
- UI chỉ refresh khi cần thiết
- Không refresh quá nhiều lần
- Tối ưu performance

### **2. User Experience:**
- Thay đổi mượt mà
- Không có lag
- Dữ liệu luôn chính xác

### **3. Consistency:**
- Tất cả màn hình đồng bộ
- Không có dữ liệu cũ
- State nhất quán

## 🎯 **Kết quả cuối cùng:**

### **✅ Real-time Updates:**
- Điểm số cập nhật ngay lập tức
- Daily streak cập nhật ngay lập tức
- Thống kê cập nhật ngay lập tức

### **✅ Smooth Experience:**
- Không có delay
- Không cần restart
- UI mượt mà

### **✅ Consistent State:**
- Tất cả màn hình đồng bộ
- Dữ liệu luôn chính xác
- State nhất quán

Hãy test và cho tôi biết kết quả! 🚀 