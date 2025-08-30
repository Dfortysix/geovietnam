# Hướng Dẫn Cấu Hình Keystore - Debug & Release

## Tổng Quan
Dự án đã được cấu hình để hỗ trợ cả Debug và Release keystore.

## Bước 1: Tạo Release Keystore
Chạy script: `create_release_keystore.bat`

## Bước 2: Lấy Fingerprints
```bash
keytool -list -v -keystore "android/app/release.keystore" -alias release -storepass geovietnam123
```

## Bước 3: Cấu Hình Firebase
1. Vào Firebase Console > Project Settings
2. Thêm SHA1 fingerprint của release keystore
3. Tải google-services.json mới

## Build Commands
- Debug: `flutter build apk --debug`
- Release: `flutter build apk --release`

## Bảo Mật
- Không commit release.keystore vào git
- Backup keystore file
- Thêm vào .gitignore: `android/app/release.keystore`
