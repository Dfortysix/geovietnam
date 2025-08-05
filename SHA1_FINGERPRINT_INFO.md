# Thông tin SHA-1 Fingerprint cho GeoVietnam

## Package Name: `com.tridug.geovietnam`

### Debug SHA-1 Fingerprint:
```
71:08:DD:7C:A6:BC:0A:66:BA:83:9E:7E:19:38:C7:B3:B1:C0:E4:B2
```

### SHA-256 Fingerprint:
```
75:40:92:C9:88:A3:91:D8:1B:FC:9D:9E:71:23:3A:F2:2B:5A:FF:36:8E:7A:9A:75:15:6E:B1:FF:A3:76:B2:A8
```

### MD5 Fingerprint:
```
1B:28:AA:3F:60:61:61:F9:B5:24:11:AC:E1:97:00:45
```

## Cách sử dụng SHA-1:

### 1. Trong Firebase Console:
1. Vào project Firebase của bạn
2. Chọn "Project settings" (biểu tượng bánh răng)
3. Tab "General" > "Your apps" > Chọn app Android
4. Nhấn "Add fingerprint"
5. Dán SHA-1: `71:08:DD:7C:A6:BC:0A:66:BA:83:9E:7E:19:38:C7:B3:B1:C0:E4:B2`

### 2. Trong Google Cloud Console:
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project Firebase của bạn
3. Vào "APIs & Services" > "Credentials"
4. Tìm OAuth 2.0 Client ID cho Android
5. Nhấn "Edit" và thêm SHA-1 fingerprint

### 3. Trong Google Play Console (khi publish):
1. Vào "Setup" > "App signing"
2. Thêm SHA-1 fingerprint cho release signing

## Lưu ý quan trọng:

⚠️ **SHA-1 này chỉ dành cho debug build**. Khi publish lên Google Play Store, bạn cần:
- Tạo keystore riêng cho release
- Lấy SHA-1 của keystore release
- Cập nhật SHA-1 trong Google Cloud Console

## Lệnh để lấy SHA-1:

### Debug (hiện tại):
```bash
cd android
./gradlew signingReport
```

### Release (khi có keystore):
```bash
keytool -list -v -keystore your-release-keystore.jks -alias your-alias
```

## Thông tin keystore hiện tại:
- **Store**: `C:\Users\ADMIN\.android\debug.keystore`
- **Alias**: `AndroidDebugKey`
- **Valid until**: 18 tháng 6, 2055

---
*Lưu ý: Đây là debug keystore mặc định của Android Studio. Chỉ sử dụng cho development và testing.* 