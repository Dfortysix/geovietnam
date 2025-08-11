@echo off
echo Creating province folders for gallery images...

cd assets\images\provinces

mkdir hai_phong 2>nul
mkdir ha_noi 2>nul
mkdir ho_chi_minh 2>nul
mkdir da_nang 2>nul
mkdir hue 2>nul
mkdir lai_chau 2>nul
mkdir quang_ninh 2>nul
mkdir lang_son 2>nul
mkdir son_la 2>nul
mkdir dien_bien 2>nul
mkdir ha_tinh 2>nul
mkdir nghe_an 2>nul
mkdir thanh_hoa 2>nul
mkdir bac_ninh 2>nul
mkdir phu_tho 2>nul
mkdir thai_nguyen 2>nul
mkdir lao_cai 2>nul
mkdir tuyen_quang 2>nul
mkdir cao_bang 2>nul
mkdir quang_tri 2>nul
mkdir ninh_binh 2>nul
mkdir hung_yen 2>nul
mkdir lam_dong 2>nul
mkdir khanh_hoa 2>nul
mkdir gia_lai 2>nul
mkdir quang_ngai 2>nul
mkdir dak_lak 2>nul
mkdir an_giang 2>nul
mkdir ca_mau 2>nul
mkdir dong_thap 2>nul
mkdir vinh_long 2>nul
mkdir can_tho 2>nul
mkdir tay_ninh 2>nul
mkdir dong_nai 2>nul

echo.
echo Province folders created successfully!
echo.
echo To add gallery images for a province:
echo 1. Go to assets\images\provinces\[province_name]\
echo 2. Add files: gallery_1.jpg, gallery_2.jpg, gallery_3.jpg, etc.
echo 3. Run: flutter clean && flutter pub get
echo.
pause 