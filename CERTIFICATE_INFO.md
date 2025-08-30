# Thông Tin Certificate - GeoVietnam

## Debug Keystore
- **SHA1:** `71:08:DD:7C:A6:BC:0A:66:BA:83:9E:7E:19:38:C7:B3:B1:C0:E4:B2`
- **SHA256:** `75:40:92:C9:88:A3:91:D8:1B:FC:9D:9E:71:23:3A:F2:2B:5A:FF:36:8E:7A:9A:75:15:6E:B1:FF:A3:76:B2:A8`
- **Vị trí:** `C:\Users\ADMIN\.android\debug.keystore`
- **Đã cấu hình:** ✅ Firebase

## Release Keystore
- **SHA1:** `29:FB:E4:1D:94:29:74:1B:37:C7:6C:AA:4F:82:C2:87:41:7F:BD:29`
- **SHA256:** `67:83:8E:59:61:F2:AB:C4:0A:68:D1:20:8D:06:2D:D4:26:EB:71:94:CD:CF:66:64:26:13:EA:C1:F9:1D:78:40`
- **Vị trí:** `android/app/release.keystore`
- **Password:** `geovietnam123`
- **Alias:** `release`
- **Cần cấu hình:** Firebase + Google Play Console

## Khi Upload Google Play Store

### 1. Firebase Console
- Thêm SHA1: `29:FB:E4:1D:94:29:74:1B:37:C7:6C:AA:4F:82:C2:87:41:7F:BD:29`

### 2. Google Play Console
- Thêm SHA256: `67:83:8E:59:61:F2:AB:C4:0A:68:D1:20:8D:06:2D:D4:26:EB:71:94:CD:CF:66:64:26:13:EA:C1:F9:1D:78:40`

### 3. Build Commands
```bash
# Release APK
flutter build apk --release

# App Bundle (khuyến nghị cho Google Play)
flutter build appbundle --release
```

## Lưu Ý Bảo Mật
- **Backup** release.keystore file
- **Không commit** keystore vào git
- **Lưu trữ an toàn** password và keystore
