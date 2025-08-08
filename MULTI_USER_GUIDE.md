# Hướng dẫn Test Multi-User trên cùng thiết bị

## 🎯 **Cách hoạt động mới:**

### **✅ Trước đây (Single User):**
- Đăng xuất → Xóa dữ liệu local
- Chỉ lưu được 1 user tại một thời điểm

### **✅ Bây giờ (Multi User):**
- Đăng xuất → Giữ dữ liệu local
- Có thể lưu nhiều user cùng lúc
- Chuyển đổi giữa các user dễ dàng

## 🧪 **Test Multi-User:**

### **Test 1: Kiểm tra tất cả user hiện có**
```dart
await GameProgressService.debugAllUsers();
```

### **Test 2: Test scenario nhiều user**

#### **Bước 1: User A đăng nhập và lưu dữ liệu**
```dart
// Giả sử User A đã đăng nhập
await GameProgressService.updateScore(100);
await GameProgressService.unlockProvince('hanoi');
await GameProgressService.updateProvinceScore('hanoi', 50);
await GameProgressService.debugAllUsers();
```

#### **Bước 2: User A đăng xuất**
```dart
// Đăng xuất User A
// Dữ liệu vẫn được giữ lại
await GameProgressService.debugAllUsers();
```

#### **Bước 3: User B đăng nhập và lưu dữ liệu**
```dart
// User B đăng nhập
await GameProgressService.updateScore(200);
await GameProgressService.unlockProvince('haiphong');
await GameProgressService.updateProvinceScore('haiphong', 75);
await GameProgressService.debugAllUsers();
```

#### **Bước 4: Kiểm tra cả 2 user**
```dart
await GameProgressService.debugAllUsers();
```

## 📝 **Kết quả mong đợi:**

### **Sau khi User A chơi:**
```
=== DEBUG ALL USERS ===
Total keys in SharedPreferences: 6

--- User: 123456 ---
Total Score: 100
Daily Streak: 1
Unlocked Provinces: [hanoi]
Explored Provinces: []
=== END DEBUG ALL USERS ===
```

### **Sau khi User B chơi:**
```
=== DEBUG ALL USERS ===
Total keys in SharedPreferences: 12

--- User: 123456 ---
Total Score: 100
Daily Streak: 1
Unlocked Provinces: [hanoi]
Explored Provinces: []

--- User: 789012 ---
Total Score: 200
Daily Streak: 1
Unlocked Provinces: [haiphong]
Explored Provinces: []
=== END DEBUG ALL USERS ===
```

## 🔄 **Cách chuyển đổi user:**

### **Method 1: Đăng xuất và đăng nhập**
1. User A đăng xuất
2. User B đăng nhập
3. Dữ liệu tự động chuyển đổi

### **Method 2: Sử dụng switchToUser (nếu có UI)**
```dart
await GameProgressService.switchToUser('user_id');
```

## 📊 **Lợi ích của Multi-User:**

### **✅ Cho gia đình:**
- Bố mẹ và con cái có thể chơi cùng thiết bị
- Mỗi người có tiến trình riêng
- Không cần đăng xuất/đăng nhập liên tục

### **✅ Cho bạn bè:**
- Chia sẻ thiết bị để chơi
- Mỗi người có dữ liệu riêng
- Dễ dàng so sánh tiến độ

### **✅ Cho testing:**
- Test nhiều user scenarios
- Debug dữ liệu của từng user
- Kiểm tra tính năng đồng bộ

## ⚠️ **Lưu ý quan trọng:**

### **1. Storage Space:**
- Mỗi user chiếm khoảng 1-5KB dữ liệu
- 10 user = khoảng 50KB
- Không đáng kể so với dung lượng thiết bị

### **2. Privacy:**
- Dữ liệu local chỉ lưu trên thiết bị
- Không chia sẻ giữa các thiết bị
- Mỗi user vẫn có dữ liệu riêng trên cloud

### **3. Sync:**
- Khi đăng nhập → Sync từ cloud về local
- Khi đăng xuất → Sync từ local lên cloud
- Dữ liệu luôn được đồng bộ

## 🚀 **Test Commands:**

```dart
// 1. Kiểm tra tất cả user
await GameProgressService.debugAllUsers();

// 2. Lấy danh sách user
final users = await GameProgressService.getAllLocalUsers();
print('Users: $users');

// 3. Debug user hiện tại
await GameProgressService.debugCurrentProgress();

// 4. Debug tất cả local storage
await GameProgressService.debugAllLocalStorage();
```

## 🔧 **Troubleshooting:**

### **Nếu không thấy user nào:**
- Chưa có user nào đăng nhập
- Hoặc chưa lưu dữ liệu

### **Nếu chỉ thấy 1 user:**
- Chỉ có 1 user đã chơi
- Hoặc user khác chưa lưu dữ liệu

### **Nếu thấy nhiều user:**
- ✅ Hệ thống hoạt động đúng
- ✅ Multi-user được hỗ trợ

Hãy test và cho tôi biết kết quả! 🎯 