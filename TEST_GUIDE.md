# Hướng dẫn Test và Debug Hệ thống

## 🎯 **Mục tiêu:**
- Kiểm tra Firestore Rules có hoạt động không
- Kiểm tra việc lưu tiến trình theo user
- Kiểm tra việc xóa dữ liệu khi đăng xuất

## 🔧 **Bước 1: Deploy Firestore Rules**

### **Cách nhanh nhất:**
1. Mở [Firebase Console](https://console.firebase.google.com)
2. Chọn project của bạn
3. Vào **Firestore Database** > **Rules**
4. Copy toàn bộ nội dung từ file `firestore.rules` và paste vào
5. Click **Publish**

## 🧪 **Bước 2: Test từng bước**

### **Test 1: Kiểm tra Firebase Auth**
```dart
// Trong Debug Console của Flutter
print('Firebase Auth Current User: ${FirebaseAuth.instance.currentUser?.uid}');
print('Firebase Auth Email: ${FirebaseAuth.instance.currentUser?.email}');
```

**Kết quả mong đợi:**
```
Firebase Auth Current User: 106794033101122696032
Firebase Auth Email: user@gmail.com
```

### **Test 2: Test Firestore Connection**
```dart
await GameProgressService.testFirestoreConnection();
```

**Kết quả mong đợi:**
```
=== TESTING FIRESTORE CONNECTION ===
Current User ID: 106794033101122696032
Firebase Auth Current User: 106794033101122696032
Firebase Auth Email: user@gmail.com
Testing read user document...
✅ User document read successful: true
Testing write test data...
✅ Test write successful
Testing write user profile...
✅ User profile write successful
Testing write province data...
✅ Province data write successful
🎉 All Firestore tests passed!
=== FIRESTORE TEST COMPLETED ===
```

### **Test 3: Debug tiến độ hiện tại**
```dart
await GameProgressService.debugCurrentProgress();
```

**Kết quả mong đợi:**
```
=== DEBUG CURRENT PROGRESS ===
User ID: 106794033101122696032
Firebase Auth Current User: 106794033101122696032
Firebase Auth Email: user@gmail.com
Unlocked Provinces: []
Total Score: 0
Daily Streak: 0
Explored Provinces: []
=============================
```

### **Test 4: Test lưu và load dữ liệu**
```dart
await GameProgressService.testSaveAndLoad();
```

**Kết quả mong đợi:**
```
=== TESTING SAVE AND LOAD ===
Current User ID: 106794033101122696032
Saved test progress to local storage
Loaded Progress - Total Score: 500
Loaded Progress - Unlocked Provinces: 1
Loaded Progress - Test Province Score: 100
=== SAVE AND LOAD TEST COMPLETED ===
```

### **Test 5: Test toàn bộ hệ thống**
```dart
await GameProgressService.testUserProgress();
```

## 🔍 **Phân tích kết quả:**

### **Nếu Test 1 thất bại:**
- ❌ Firebase Auth không hoạt động
- ❌ User chưa đăng nhập
- **Giải pháp:** Đăng nhập lại

### **Nếu Test 2 thất bại:**
- ❌ Firestore Rules chưa được deploy
- ❌ Internet connection có vấn đề
- ❌ Firebase project configuration sai
- **Giải pháp:** 
  1. Deploy Firestore Rules
  2. Kiểm tra internet
  3. Kiểm tra `google-services.json`

### **Nếu Test 3 thất bại:**
- ❌ SharedPreferences không hoạt động
- ❌ User ID null
- **Giải pháp:** Kiểm tra logic lưu local

### **Nếu Test 4 thất bại:**
- ❌ Logic lưu/load có vấn đề
- **Giải pháp:** Kiểm tra code lưu local

## 🚀 **Test đăng xuất:**

### **Bước 1: Lưu dữ liệu trước**
```dart
await GameProgressService.updateScore(100);
await GameProgressService.unlockProvince('hanoi');
await GameProgressService.updateProvinceScore('hanoi', 50);
await GameProgressService.exploreProvince('hanoi');
await GameProgressService.debugCurrentProgress();
```

### **Bước 2: Đăng xuất**
- Click nút đăng xuất trong app

### **Bước 3: Kiểm tra dữ liệu đã bị xóa**
```dart
await GameProgressService.debugCurrentProgress();
```

**Kết quả mong đợi:**
```
=== DEBUG CURRENT PROGRESS ===
User ID: null
Firebase Auth Current User: null
Firebase Auth Email: null
User not logged in
=============================
```

### **Bước 4: Đăng nhập lại và kiểm tra**
```dart
await GameProgressService.debugCurrentProgress();
```

## ⚠️ **Các lỗi thường gặp:**

### **Lỗi Permission Denied:**
```
❌ Firestore test failed: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```
**Nguyên nhân:** Firestore Rules chưa deploy hoặc sai
**Giải pháp:** Deploy lại Firestore Rules

### **Lỗi Network:**
```
❌ Firestore test failed: [cloud_firestore/unavailable] The service is currently unavailable.
```
**Nguyên nhân:** Internet connection hoặc Firebase service down
**Giải pháp:** Kiểm tra internet và thử lại

### **Lỗi User ID null:**
```
User ID: null
❌ No user logged in
```
**Nguyên nhân:** User chưa đăng nhập hoặc Firebase Auth có vấn đề
**Giải pháp:** Đăng nhập lại

## 📝 **Log mẫu khi hoạt động đúng:**

```
=== TESTING FIRESTORE CONNECTION ===
Current User ID: 106794033101122696032
Firebase Auth Current User: 106794033101122696032
Firebase Auth Email: user@gmail.com
Testing read user document...
✅ User document read successful: true
Testing write test data...
✅ Test write successful
Testing write user profile...
✅ User profile write successful
Testing write province data...
✅ Province data write successful
🎉 All Firestore tests passed!
=== FIRESTORE TEST COMPLETED ===

=== DEBUG CURRENT PROGRESS ===
User ID: 106794033101122696032
Firebase Auth Current User: 106794033101122696032
Firebase Auth Email: user@gmail.com
Unlocked Provinces: [hanoi]
Total Score: 100
Daily Streak: 1
Explored Provinces: [hanoi]
Province hanoi Score: 50
=============================
```

Hãy chạy từng test và cho tôi biết kết quả cụ thể! 🎯 