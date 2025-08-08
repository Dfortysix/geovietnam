# Hướng dẫn Test Reset Tiến trình khi Đăng xuất

## 🎯 **Tính năng mới:**

### **✅ Reset tiến trình về ban đầu khi đăng xuất:**
- Khi đăng xuất → Xóa tất cả dữ liệu local
- Khi đăng nhập lại → Load dữ liệu từ cloud hoặc tạo mới
- Mỗi user có tiến trình riêng biệt, không bị ảnh hưởng bởi user khác

## 🔄 **Cách hoạt động:**

### **1. Khi đăng nhập:**
```
1. Xóa dữ liệu local cũ (nếu có)
2. Load dữ liệu từ cloud (nếu có)
3. Nếu không có dữ liệu cloud → Tạo mới với provinces từ data
4. Lưu vào local storage
```

### **2. Khi đăng xuất:**
```
1. Sync dữ liệu local lên cloud
2. Xóa tất cả dữ liệu local
3. Reset về trạng thái ban đầu
```

### **3. Khi đăng nhập lại:**
```
1. Load dữ liệu từ cloud (tiến trình đã lưu)
2. Nếu không có → Tạo mới hoàn toàn
```

## 🧪 **Test Scenarios:**

### **Test 1: Đăng nhập lần đầu**
1. Đăng nhập với user mới
2. Chơi game và lưu tiến trình
3. Đăng xuất

**Kết quả mong đợi:**
- ✅ Tiến trình được lưu lên cloud
- ✅ Dữ liệu local bị xóa
- ✅ Reset về ban đầu

### **Test 2: Đăng nhập lại**
1. Đăng nhập lại với user đã có tiến trình
2. Kiểm tra tiến trình

**Kết quả mong đợi:**
- ✅ Load tiến trình từ cloud
- ✅ Hiển thị đúng dữ liệu đã lưu

### **Test 3: User mới**
1. Đăng nhập với user khác
2. Kiểm tra tiến trình

**Kết quả mong đợi:**
- ✅ Tạo tiến trình mới hoàn toàn
- ✅ Không bị ảnh hưởng bởi user trước

### **Test 4: Đăng xuất và đăng nhập liên tục**
1. User A đăng nhập → Chơi game → Đăng xuất
2. User B đăng nhập → Chơi game → Đăng xuất
3. User A đăng nhập lại

**Kết quả mong đợi:**
- ✅ User A thấy tiến trình của mình
- ✅ User B thấy tiến trình của mình
- ✅ Không bị lẫn lộn dữ liệu

## 🚀 **Test Commands:**

### **Test 1: Debug tiến trình hiện tại**
```dart
await GameProgressService.debugCurrentProgress();
```

### **Test 2: Debug tất cả local storage**
```dart
await GameProgressService.debugAllLocalStorage();
```

### **Test 3: Test đăng nhập/đăng xuất**
```dart
// 1. Đăng nhập
await GameProgressService.syncOnLogin();

// 2. Lưu một số dữ liệu
await GameProgressService.updateScore(100);
await GameProgressService.unlockProvince('hanoi');

// 3. Debug tiến trình
await GameProgressService.debugCurrentProgress();

// 4. Đăng xuất
await GameProgressService.syncOnLogout();
await GameProgressService.clearDataOnLogout();

// 5. Debug lại (sẽ thấy dữ liệu trống)
await GameProgressService.debugAllLocalStorage();
```

## 📝 **Kết quả mong đợi:**

### **Sau khi đăng nhập và chơi game:**
```
=== DEBUG CURRENT PROGRESS ===
User ID: 123456
Total Score: 150
Daily Streak: 3
Unlocked Provinces: [hanoi, haiphong]
Explored Provinces: [hanoi]
=== END DEBUG CURRENT PROGRESS ===
```

### **Sau khi đăng xuất:**
```
=== DEBUG ALL LOCAL STORAGE ===
User ID: null
Firebase Auth Current User: null
Total keys in SharedPreferences: 0
--- USER KEYS (0) ---
--- OTHER KEYS (0) ---
=== END DEBUG ALL LOCAL STORAGE ===
```

### **Sau khi đăng nhập lại:**
```
=== DEBUG CURRENT PROGRESS ===
User ID: 123456
Total Score: 150 (được load từ cloud)
Daily Streak: 3
Unlocked Provinces: [hanoi, haiphong]
Explored Provinces: [hanoi]
=== END DEBUG CURRENT PROGRESS ===
```

## 🔧 **Các thay đổi chính:**

### **1. GameProgressService.syncOnLogin():**
- ✅ Xóa dữ liệu local cũ trước
- ✅ Load từ cloud hoặc tạo mới
- ✅ Đảm bảo reset hoàn toàn

### **2. GameProgressService.clearDataOnLogout():**
- ✅ Xóa tất cả dữ liệu local
- ✅ Reset về trạng thái ban đầu

### **3. GameProgress.initial():**
- ✅ Factory method tạo GameProgress mới
- ✅ Load provinces từ ProvincesData

## ⚠️ **Lưu ý quan trọng:**

### **1. Bảo mật dữ liệu:**
- Dữ liệu được sync lên cloud trước khi xóa
- Mỗi user có dữ liệu riêng biệt
- Không bị lẫn lộn giữa các user

### **2. Trải nghiệm người dùng:**
- Đăng nhập → Thấy tiến trình của mình
- Đăng xuất → Reset hoàn toàn
- Đăng nhập lại → Khôi phục tiến trình

### **3. Performance:**
- Xóa dữ liệu local giúp tiết kiệm bộ nhớ
- Load từ cloud khi cần thiết
- Không lưu trữ dữ liệu không cần thiết

## 🎯 **Kết quả cuối cùng:**

### **✅ Khi đăng xuất:**
- Dữ liệu được sync lên cloud
- Local storage được xóa sạch
- Reset về trạng thái ban đầu

### **✅ Khi đăng nhập:**
- Load dữ liệu từ cloud (nếu có)
- Tạo mới hoàn toàn (nếu chưa có)
- Mỗi user có tiến trình riêng

### **✅ Bảo mật:**
- Không lưu dữ liệu local sau khi đăng xuất
- Mỗi user có dữ liệu riêng biệt
- Sync an toàn với cloud

Hãy test và cho tôi biết kết quả! 🚀 