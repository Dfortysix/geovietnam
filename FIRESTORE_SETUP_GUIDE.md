# Hướng dẫn Setup Firestore và Test Hệ thống

## 🔧 **Bước 1: Deploy Firestore Rules**

### **Cách 1: Sử dụng Firebase Console**
1. Mở [Firebase Console](https://console.firebase.google.com)
2. Chọn project của bạn
3. Vào **Firestore Database** > **Rules**
4. Copy nội dung từ file `firestore.rules` và paste vào
5. Click **Publish**

### **Cách 2: Sử dụng Firebase CLI**
```bash
# Cài đặt Firebase CLI nếu chưa có
npm install -g firebase-tools

# Login vào Firebase
firebase login

# Deploy rules
firebase deploy --only firestore:rules
```

## 🧪 **Bước 2: Test Hệ thống**

### **Test 1: Kiểm tra Firestore Rules**
```dart
// Trong Debug Console của Flutter
await GameProgressService.debugCurrentProgress();
```

### **Test 2: Test lưu và load dữ liệu**
```dart
// Test save và load
await GameProgressService.testSaveAndLoad();
```

### **Test 3: Test toàn bộ hệ thống**
```dart
// Test đầy đủ
await GameProgressService.testUserProgress();
```

### **Test 4: Test đăng xuất**
1. Đăng nhập vào app
2. Lưu một số tiến trình
3. Đăng xuất
4. Kiểm tra dữ liệu đã bị xóa chưa
5. Đăng nhập lại và kiểm tra dữ liệu có được đồng bộ không

## 🔍 **Kiểm tra Log**

### **Nếu Firestore Rules hoạt động đúng:**
```
=== DEBUG CURRENT PROGRESS ===
User ID: 106794033101122696032
Unlocked Provinces: [hanoi, haiphong]
Total Score: 150
Daily Streak: 3
Explored Provinces: [hanoi]
Province hanoi Score: 50
Province haiphong Score: 30
=============================
```

### **Nếu vẫn có lỗi Permission Denied:**
1. Kiểm tra Firebase Auth có hoạt động không
2. Kiểm tra User ID có đúng không
3. Kiểm tra Firestore Rules đã được deploy chưa
4. Kiểm tra internet connection

## 🚀 **Các lệnh test nhanh:**

```dart
// 1. Debug hiện tại
await GameProgressService.debugCurrentProgress();

// 2. Test save/load
await GameProgressService.testSaveAndLoad();

// 3. Test đầy đủ
await GameProgressService.testUserProgress();

// 4. Cập nhật score
await GameProgressService.updateScore(100);

// 5. Mở khóa tỉnh
await GameProgressService.unlockProvince('hanoi');

// 6. Cập nhật score tỉnh
await GameProgressService.updateProvinceScore('hanoi', 50);

// 7. Đánh dấu khám phá
await GameProgressService.exploreProvince('hanoi');

// 8. Đồng bộ lên cloud
await GameProgressService.syncToCloud();

// 9. Đồng bộ từ cloud
await GameProgressService.syncFromCloud();
```

## ⚠️ **Lưu ý quan trọng:**

1. **Firestore Rules**: Phải deploy trước khi test
2. **User Authentication**: Phải đăng nhập để test cloud sync
3. **Local Storage**: Hoạt động ngay cả khi không có internet
4. **Error Handling**: Các lỗi cloud không làm gián đoạn local storage

## 🔧 **Troubleshooting:**

### **Lỗi Permission Denied:**
- Kiểm tra Firestore Rules đã deploy chưa
- Kiểm tra User ID có đúng không
- Kiểm tra Firebase Auth có hoạt động không

### **Dữ liệu không được lưu:**
- Kiểm tra SharedPreferences có hoạt động không
- Kiểm tra User ID có null không
- Kiểm tra logic lưu có đúng không

### **Dữ liệu không được xóa khi đăng xuất:**
- Kiểm tra `clearDataOnLogout()` có được gọi không
- Kiểm tra User ID có đúng không
- Kiểm tra logic xóa có đúng không

Hãy test và cho tôi biết kết quả! 🎯 