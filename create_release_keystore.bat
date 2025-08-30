@echo off
echo Creating Release Keystore for GeoVietnam...
echo.

REM Tạo release keystore
keytool -genkey -v -keystore "android/app/release.keystore" -alias release -keyalg RSA -keysize 2048 -validity 10000 -storepass geovietnam123 -keypass geovietnam123 -dname "CN=GeoVietnam, OU=Development, O=Tridug, L=Hanoi, S=Hanoi, C=VN"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Release keystore created successfully!
    echo Location: android/app/release.keystore
    echo.
    echo Getting certificate fingerprints...
    echo.
    
    REM Lấy SHA1 và SHA256 fingerprints
    keytool -list -v -keystore "android/app/release.keystore" -alias release -storepass geovietnam123 -keypass geovietnam123
    
    echo.
    echo IMPORTANT: Add the SHA1 fingerprint to your Firebase project for release builds!
    echo.
) else (
    echo.
    echo Failed to create release keystore!
    echo.
)

pause
