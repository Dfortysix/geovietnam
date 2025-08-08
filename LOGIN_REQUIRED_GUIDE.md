# Hướng dẫn Test Tính năng Yêu cầu Đăng nhập

## 🎯 **Tính năng mới:**

### **✅ Bắt buộc đăng nhập để chơi game:**
- Khi vào game mà chưa đăng nhập → Hiện popup yêu cầu đăng nhập
- Tất cả tính năng game đều yêu cầu đăng nhập
- Hiển thị trạng thái đăng nhập trên màn hình chính

## 🧪 **Test Scenarios:**

### **Test 1: Chưa đăng nhập và thử vào game**
1. Đảm bảo chưa đăng nhập Google
2. Mở app
3. Thử nhấn vào các nút:
   - 🎯 Daily Challenge
   - 🗺️ Khám phá bản đồ
   - 🏆 Tiến độ & Thành tích
   - 👤 Hồ sơ người chơi

**Kết quả mong đợi:**
- ✅ Hiện popup "Yêu cầu đăng nhập"
- ✅ Có 2 lựa chọn: "Để sau" và "Đăng nhập ngay"
- ✅ Nếu chọn "Để sau" → Không vào được game
- ✅ Nếu chọn "Đăng nhập ngay" → Mở Google Sign-In

### **Test 2: Đăng nhập thành công**
1. Chọn "Đăng nhập ngay" trong popup
2. Chọn tài khoản Google
3. Hoàn tất đăng nhập

**Kết quả mong đợi:**
- ✅ Hiện thông báo "Đăng nhập thành công!"
- ✅ Hiển thị tên người dùng
- ✅ Có thể vào các tính năng game
- ✅ Header hiển thị "Đã đăng nhập" màu xanh
- ✅ Hiển thị avatar và tên người dùng

### **Test 3: Đã đăng nhập và vào game**
1. Đảm bảo đã đăng nhập
2. Thử vào các tính năng game

**Kết quả mong đợi:**
- ✅ Vào được game ngay lập tức
- ✅ Không hiện popup đăng nhập
- ✅ Header hiển thị thông tin user

### **Test 4: Đăng xuất và thử lại**
1. Vào Profile → Đăng xuất
2. Thử vào game lại

**Kết quả mong đợi:**
- ✅ Hiện popup yêu cầu đăng nhập
- ✅ Header hiển thị "Chưa đăng nhập" màu cam

## 📱 **Giao diện mới:**

### **Header mới:**
```
[🔴 Chưa đăng nhập]                    [👤 Tên User]
```

### **Popup đăng nhập:**
```
┌─────────────────────────────────────┐
│ 🔑 Yêu cầu đăng nhập                │
│                                     │
│ Để chơi game và lưu tiến trình,    │
│ bạn cần đăng nhập bằng tài khoản    │
│ Google.                             │
│                                     │
│ Lợi ích khi đăng nhập:              │
│ • Lưu tiến trình game trên cloud    │
│ • Đồng bộ dữ liệu giữa các thiết bị │
│ • Tham gia bảng xếp hạng            │
│ • Nhận thành tích và phần thưởng    │
│                                     │
│ [Để sau]        [Đăng nhập ngay]    │
└─────────────────────────────────────┘
```

## 🔧 **Các tính năng được bảo vệ:**

### **✅ Yêu cầu đăng nhập:**
- 🎯 Daily Challenge
- 🗺️ Khám phá bản đồ
- 🏆 Tiến độ & Thành tích
- 👤 Hồ sơ người chơi

### **❌ Không yêu cầu đăng nhập:**
- Xem màn hình chính
- Xem thông tin cơ bản

## 🚀 **Test Commands:**

```dart
// 1. Kiểm tra trạng thái đăng nhập
final authService = AuthService();
print('Đã đăng nhập: ${authService.isLoggedIn}');
print('User hiện tại: ${authService.currentUser?.email}');

// 2. Test popup đăng nhập
await AuthService.showLoginRequiredDialog(context);

// 3. Test yêu cầu đăng nhập
final isLoggedIn = await AuthService.requireLogin(context);
print('Kết quả đăng nhập: $isLoggedIn');
```

## ⚠️ **Lưu ý quan trọng:**

### **1. Trải nghiệm người dùng:**
- Popup không thể đóng bằng cách nhấn bên ngoài
- Phải chọn một trong hai lựa chọn
- Thông báo rõ ràng về lợi ích đăng nhập

### **2. Bảo mật:**
- Kiểm tra cả Firebase Auth và Google Sign-In
- Đảm bảo user đã đăng nhập hoàn toàn
- Sync dữ liệu sau khi đăng nhập

### **3. UI/UX:**
- Header hiển thị trạng thái rõ ràng
- Màu sắc phân biệt: xanh (đã đăng nhập) / cam (chưa đăng nhập)
- Avatar và tên user khi đã đăng nhập

## 🎯 **Kết quả mong đợi:**

### **✅ Khi chưa đăng nhập:**
- Header: "🔴 Chưa đăng nhập"
- Nhấn game → Popup yêu cầu đăng nhập
- Không thể vào game nếu không đăng nhập

### **✅ Khi đã đăng nhập:**
- Header: "🟢 Đã đăng nhập" + Avatar + Tên
- Vào game ngay lập tức
- Thông báo chào mừng

Hãy test và cho tôi biết kết quả! 🚀 