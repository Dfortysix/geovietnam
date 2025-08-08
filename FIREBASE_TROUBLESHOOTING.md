# Hướng dẫn khắc phục lỗi Firebase và Google Sign-In

## Các lỗi thường gặp và cách khắc phục

### 1. Lỗi "Firebase Auth user is null"

**Nguyên nhân:**
- Firebase Auth chưa được khởi tạo đúng cách
- Google Sign-In chưa hoàn tất trước khi gọi Firestore
- Timing issue giữa Google Sign-In và Firebase Auth

**Cách khắc phục:**
1. Kiểm tra file `google-services.json` có đúng vị trí không
2. Đảm bảo Firebase được khởi tạo trong `main.dart`
3. Thêm delay và retry logic như đã implement
4. Kiểm tra log để xem quá trình đăng nhập

### 2. Lỗi "Permission denied" khi upload lên Firestore

**Nguyên nhân:**
- Firestore Security Rules quá nghiêm ngặt
- User chưa được authenticate đúng cách
- Thiếu quyền truy cập

**Cách khắc phục:**
1. Kiểm tra Firestore Security Rules trong Firebase Console
2. Đảm bảo user đã được authenticate
3. Test với rules tạm thời cho phép read/write

### 3. Lỗi "Google Sign-In failed"

**Nguyên nhân:**
- SHA-1 fingerprint không đúng
- Package name không khớp
- OAuth 2.0 credentials chưa được cấu hình

**Cách khắc phục:**
1. Kiểm tra SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Đảm bảo package name trong `google-services.json` khớp với `build.gradle.kts`
3. Kiểm tra OAuth 2.0 credentials trong Google Cloud Console

### 4. Lỗi "Network error" hoặc "Connection timeout"

**Nguyên nhân:**
- Kết nối internet không ổn định
- Firewall chặn kết nối
- Firebase project không đúng

**Cách khắc phục:**
1. Kiểm tra kết nối internet
2. Test trên thiết bị thật thay vì emulator
3. Kiểm tra Firebase project ID trong `google-services.json`

## Sử dụng Debug Screen

### Cách truy cập:
1. Chạy ứng dụng trong debug mode
2. Nhấn nút "Debug Firebase" trên màn hình chính
3. Sử dụng các chức năng debug để kiểm tra

### Các chức năng debug:

#### 1. Refresh Firebase Status
- Kiểm tra trạng thái Firebase Auth
- Kiểm tra kết nối Firestore
- Kiểm tra trạng thái Google Sign-In

#### 2. Test Google Sign-In
- Thử đăng nhập Google
- Xem log chi tiết quá trình đăng nhập
- Kiểm tra Firebase Auth sau đăng nhập

#### 3. Test Firestore Upload
- Thử upload dữ liệu test lên Firestore
- Kiểm tra quyền truy cập
- Xem log lỗi chi tiết

#### 4. Check Firestore Permissions
- Kiểm tra quyền đọc/ghi
- Test tạo subcollection
- Xác nhận user authentication

#### 5. Cleanup Test Data
- Xóa dữ liệu test
- Dọn dẹp Firestore

## Cấu hình Firestore Security Rules

### Rules cơ bản cho testing:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Cho phép đọc/ghi cho user đã authenticate
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Cho phép đọc/ghi subcollections
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Cho phép đọc/ghi collection test
    match /test/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Rules production:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User chỉ có thể đọc/ghi dữ liệu của mình
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /provinces/{provinceId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Không cho phép truy cập collection test trong production
    match /test/{document} {
      allow read, write: if false;
    }
  }
}
```

## Kiểm tra cấu hình

### 1. Kiểm tra file google-services.json:
```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_PROJECT_ID.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_APP_ID",
        "android_client_info": {
          "package_name": "com.tridug.geovietnam"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_OAUTH_CLIENT_ID",
          "client_type": 1,
          "android_info": {
            "package_name": "com.tridug.geovietnam",
            "certificate_hash": "YOUR_SHA1_FINGERPRINT"
          }
        }
      ]
    }
  ]
}
```

### 2. Kiểm tra build.gradle.kts:
```kotlin
android {
    namespace = "com.tridug.geovietnam"
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.tridug.geovietnam"
        // ...
    }
}
```

### 3. Kiểm tra pubspec.yaml:
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.6.12
  google_sign_in: ^6.2.1
```

## Log và Debug

### Các log quan trọng cần kiểm tra:

1. **Firebase initialization:**
   ```
   Firebase.initializeApp() completed
   ```

2. **Google Sign-In:**
   ```
   Google Sign-In successful: user@example.com
   Google Account ID: 123456789
   ```

3. **Firebase Auth:**
   ```
   Firebase Auth User ID: firebase_uid_here
   Firebase Auth Email: user@example.com
   ```

4. **Firestore upload:**
   ```
   User profile created/updated successfully
   Test upload successful to /users/firebase_uid_here
   ```

### Cách xem log:
1. Sử dụng `flutter logs` trong terminal
2. Xem log trong Android Studio/VS Code
3. Sử dụng Debug Screen trong ứng dụng

## Liên kết hữu ích

- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Console](https://console.firebase.google.com/)
- [Google Cloud Console](https://console.cloud.google.com/) 