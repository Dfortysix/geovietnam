# 📊 Cấu trúc dữ liệu tỉnh thành

Thư mục này chứa dữ liệu chi tiết về các tỉnh thành Việt Nam sau đợt sáp nhập 1/7/2025.

## 📁 Cấu trúc thư mục

```
assets/data/
├── provinces/              # Dữ liệu chi tiết từng tỉnh
│   ├── hai_phong.json     # Dữ liệu Hải Phòng
│   ├── ha_noi.json        # Dữ liệu Hà Nội (sẽ tạo)
│   └── ...                # Các tỉnh khác
└── README.md              # File này
```

## 📋 Cấu trúc file JSON

Mỗi file JSON chứa thông tin chi tiết về một tỉnh với cấu trúc:

```json
{
  "id": "hai_phong",
  "nameVietnamese": "Hải Phòng",
  "overview": {
    "title": "Thành phố Cảng Biển Lớn Nhất Miền Bắc",
    "description": "Mô tả tổng quan...",
    "type": "Thành phố trực thuộc Trung ương",
    "region": "Duyên hải Bắc Bộ",
    "area": "1,520 km²",
    "population": "4.66 triệu người (2025)",
    "districts": {
      "cities": 7,
      "counties": 8
    },
    "nickname": "Thành phố Hoa Phượng Đỏ"
  },
  "geography": {
    "coordinates": {
      "latitude": 20.8449,
      "longitude": 106.6881
    },
    "borders": ["Quảng Ninh", "Hải Dương", "Thái Bình"],
    "landscape": "Đồng bằng ven biển, đồi núi thấp",
    "climate": "Nhiệt đới gió mùa",
    "coastline": "125 km",
    "islands": ["Cát Bà", "Cát Hải", "Bạch Long Vĩ"],
    "water_bodies": ["Sông Cấm", "Sông Lạch Tray", "Vịnh Bắc Bộ"]
  },
  "culture": {
    "famous_foods": ["Bánh đa cua", "Nem cua bể", "Hải sản tươi sống"],
    "festivals": ["Lễ hội đền Nghè", "Lễ hội chùa Dư Hàng"],
    "traditions": ["Văn hóa biển", "Nghề đánh cá truyền thống"],
    "landmarks": ["Đồ Sơn", "Cát Bà", "Đền Nghè", "Chùa Dư Hàng"],
    "flowers": {
      "symbol": "Hoa Phượng Đỏ",
      "description": "Nổi tiếng với các tuyến phố rợp hoa phượng mỗi mùa hè"
    }
  },
  "economy": {
    "main_industries": ["Cảng biển và logistics", "Công nghiệp đóng tàu"],
    "ports": ["Cảng Hải Phòng", "Cảng Cát Bà", "Cảng Đình Vũ"],
    "key_companies": ["Tổng công ty Hàng hải Việt Nam"],
    "economic_role": "Cửa ngõ ra biển quốc tế"
  },
  "history": {
    "founded": "1888",
    "historical_events": [
      "1888: Thành lập thành phố Hải Phòng",
      "1954: Giải phóng Hải Phòng"
    ],
    "famous_figures": ["Nguyễn Bỉnh Khiêm", "Lê Chân"],
    "historical_significance": "Thành phố cảng quan trọng..."
  },
  "facts": [
    "Thành phố Hoa Phượng Đỏ",
    "Có 7 quận và 8 huyện",
    "Diện tích: 1,520 km²"
  ],
  "images": {
    "background": "assets/images/provinces/hai_phong_bg.png",
    "landmarks": [
      "assets/images/provinces/hai_phong/do_son.jpg",
      "assets/images/provinces/hai_phong/cat_ba.jpg"
    ],
    "foods": [
      "assets/images/provinces/hai_phong/banh_da_cua.jpg",
      "assets/images/provinces/hai_phong/nem_cua_be.jpg"
    ],
    "culture": [
      "assets/images/provinces/hai_phong/hoa_phuong.jpg",
      "assets/images/provinces/hai_phong/cau_binh.jpg"
    ]
  },
  "transportation": {
    "airports": ["Sân bay Cát Bi"],
    "ports": ["Cảng Hải Phòng", "Cảng Cát Bà"],
    "highways": ["QL5", "QL10", "QL37"],
    "railways": ["Đường sắt Hà Nội - Hải Phòng"]
  },
  "education": {
    "universities": [
      "Đại học Hải Phòng",
      "Đại học Hàng hải Việt Nam"
    ],
    "research_institutes": [
      "Viện Nghiên cứu Hải sản",
      "Viện Nghiên cứu Biển"
    ]
  },
  "tourism": {
    "attractions": [
      "Đồ Sơn - Bãi biển đẹp",
      "Cát Bà - Đảo ngọc",
      "Vịnh Lan Hạ"
    ],
    "activities": [
      "Tắm biển",
      "Leo núi",
      "Khám phá đảo"
    ]
  }
}
```

## 🔧 Cách sử dụng trong code

### 1. Import service
```dart
import '../services/province_detail_service.dart';
```

### 2. Load dữ liệu tỉnh
```dart
// Load toàn bộ dữ liệu
final provinceData = await ProvinceDetailService.getProvinceDetail('hai_phong');

// Load từng phần cụ thể
final overview = await ProvinceDetailService.getProvinceOverview('hai_phong');
final culture = await ProvinceDetailService.getProvinceCulture('hai_phong');
final facts = await ProvinceDetailService.getProvinceFacts('hai_phong');
```

### 3. Sử dụng widget
```dart
ProvinceDetailWidget(
  provinceId: 'hai_phong',
  provinceName: 'Hải Phòng',
)
```

## 📝 Quy tắc đặt tên file

- Sử dụng snake_case cho tên file
- Ví dụ: `hai_phong.json`, `ha_noi.json`, `ho_chi_minh.json`
- ID trong file phải khớp với tên file (không có đuôi .json)

## 🖼️ Cấu trúc hình ảnh

```
assets/images/provinces/
├── hai_phong_bg.png           # Hình nền chính
├── hai_phong/                 # Thư mục con cho hình ảnh chi tiết
│   ├── do_son.jpg            # Danh lam thắng cảnh
│   ├── cat_ba.jpg
│   ├── banh_da_cua.jpg       # Ẩm thực
│   ├── nem_cua_be.jpg
│   ├── hoa_phuong.jpg        # Văn hóa
│   └── cau_binh.jpg
└── ...
```

## ✅ Checklist khi tạo file mới

- [ ] Tạo file JSON với đầy đủ các section
- [ ] Đảm bảo ID khớp với tên file
- [ ] Thêm hình ảnh vào thư mục tương ứng
- [ ] Cập nhật danh sách trong `ProvinceDetailService.getProvincesWithDetailedData()`
- [ ] Test load dữ liệu trong ứng dụng

## 📚 Nguồn dữ liệu

- Thông tin chính thức từ [sapnhap.bando.com.vn](https://sapnhap.bando.com.vn)
- Dữ liệu địa lý và hành chính cập nhật 2025
- Thông tin văn hóa, du lịch từ các nguồn đáng tin cậy 