# Hướng dẫn cấu hình Firebase cho Google Play Games Services

## Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Nhấn "Create a project" hoặc "Add project"
3. Đặt tên project: `geovietnam-game`
4. Chọn "Enable Google Analytics" (khuyến nghị)
5. Chọn Analytics account hoặc tạo mới
6. Nhấn "Create project"

## Bước 2: Thêm ứng dụng Android

1. Trong Firebase Console, nhấn biểu tượng Android
2. Nhập package name: `com.example.geovietnam`
3. Nhập app nickname: `GeoVietnam`
4. Nhấn "Register app"

## Bước 3: Tải file cấu hình

1. Tải file `google-services.json`
2. Đặt file vào thư mục `android/app/` trong project Flutter
3. Nhấn "Next" và "Continue to console"

## Bước 4: Cấu hình Google Sign-In

### 4.1. Trong Firebase Console
1. Vào "Authentication" > "Sign-in method"
2. Bật "Google" provider
3. Nhập "Project support email"
4. Lưu cấu hình

### 4.2. Trong Google Cloud Console
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project Firebase của bạn
3. Vào "APIs & Services" > "Credentials"
4. Tạo "OAuth 2.0 Client IDs" cho Android
5. Nhập package name và SHA-1 fingerprint

## Bước 5: Lấy SHA-1 Fingerprint

### Debug SHA-1:
```bash
cd android
./gradlew signingReport
```

### Release SHA-1:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Bước 6: Cập nhật google-services.json

Thay thế các giá trị trong file `android/app/google-services.json`:

```json
{
  "project_info": {
    "project_number": "123456789012",  // Thay bằng project number thực
    "project_id": "geovietnam-game",
    "storage_bucket": "geovietnam-game.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abcdef1234567890",  // Thay bằng app ID thực
        "android_client_info": {
          "package_name": "com.example.geovietnam"
        }
      },
      "oauth_client": [
        {
          "client_id": "123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com",  // Thay bằng client ID thực
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyC_abcdefghijklmnopqrstuvwxyz1234567890"  // Thay bằng API key thực
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com",  // Thay bằng client ID thực
              "client_type": 3
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

## Bước 7: Kiểm tra cấu hình

1. Chạy `flutter clean`
2. Chạy `flutter pub get`
3. Build ứng dụng: `flutter build apk --debug`

## Bước 8: Test Google Sign-In

1. Chạy ứng dụng trên thiết bị thật (không phải emulator)
2. Nhấn nút "Đăng nhập Google Play Games"
3. Chọn tài khoản Google
4. Kiểm tra log để đảm bảo đăng nhập thành công

## Troubleshooting

### Lỗi "Google Sign In failed"
- Kiểm tra SHA-1 fingerprint đúng
- Đảm bảo package name khớp
- Kiểm tra OAuth 2.0 credentials

### Lỗi "Firebase not initialized"
- Đảm bảo file `google-services.json` đúng vị trí
- Kiểm tra dependencies trong `pubspec.yaml`
- Clean và rebuild project

### Lỗi "Network error"
- Kiểm tra internet connection
- Đảm bảo thiết bị có Google Play Services
- Test trên thiết bị thật thay vì emulator

## Cấu hình cho Production

### 1. Tạo keystore cho release
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Lấy SHA-1 cho release keystore
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

### 3. Thêm SHA-1 release vào Google Cloud Console

### 4. Cấu hình signing trong `android/app/build.gradle.kts`
```kotlin
android {
    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "your-key-password"
            storeFile = file("~/upload-keystore.jks")
            storePassword = "your-store-password"
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## Liên kết hữu ích

- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Google Play Games Services](https://developers.google.com/games/services) 