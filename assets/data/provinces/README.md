# Cấu Trúc JSON Thông Tin Tỉnh Thành

## Tổng Quan

File JSON này chứa thông tin chi tiết về các tỉnh thành Việt Nam sau sáp nhập 2025. Mỗi tỉnh có một file JSON riêng với cấu trúc thống nhất để dễ quản lý và mở rộng.

## Cấu Trúc File

### Tên File
- Format: `{tên_tỉnh_snake_case}.json`
- Ví dụ: `ha_noi.json`, `hai_phong.json`, `hue.json`

### Cấu Trúc JSON

```json
{
  "id": "Tên tỉnh (tiếng Anh)",
  "nameVietnamese": "Tên tỉnh (tiếng Việt)",
  "overview": {
    "title": "Tiêu đề tổng quan",
    "description": "Mô tả tổng quan về tỉnh",
    "area": "Diện tích (km²)",
    "population": "Dân số (người)",
    "region": "Vùng miền",
    "type": "Loại đơn vị hành chính",
    "nickname": "Biệt danh"
  },
  "sapNhap2025": {
    "title": "Tiêu đề phần sáp nhập",
    "description": "Mô tả về sáp nhập 2025",
    "details": [
      "Chi tiết 1",
      "Chi tiết 2",
      "Chi tiết 3"
    ]
  },
  "lichSu": {
    "title": "Tiêu đề phần lịch sử",
    "description": "Mô tả lịch sử tỉnh",
    "details": [
      "Giai đoạn lịch sử 1",
      "Giai đoạn lịch sử 2",
      "Giai đoạn lịch sử 3"
    ]
  },
  "vanHoa": {
    "title": "Tiêu đề phần văn hóa",
    "description": "Mô tả văn hóa tỉnh",
    "details": [
      "Di sản văn hóa 1",
      "Lễ hội truyền thống 2",
      "Nghệ thuật truyền thống 3"
    ]
  },
  "amThuc": {
    "title": "Tiêu đề phần ẩm thực",
    "description": "Mô tả ẩm thực tỉnh",
    "details": [
      "Món ăn đặc sản 1",
      "Món ăn đặc sản 2",
      "Món ăn đặc sản 3"
    ]
  },
  "diaDanh": {
    "title": "Tiêu đề phần địa danh",
    "description": "Mô tả địa danh du lịch",
    "details": [
      "Địa danh nổi tiếng 1",
      "Địa danh nổi tiếng 2",
      "Địa danh nổi tiếng 3"
    ]
  },
  "ketLuan": {
    "title": "Tiêu đề kết luận",
    "description": "Phần kết luận tổng hợp"
  }
}
```

## Chi Tiết Các Phần

### 1. Overview (Tổng Quan)
- **title**: Tiêu đề ngắn gọn về tỉnh
- **description**: Mô tả tổng quan, đặc điểm nổi bật
- **area**: Diện tích sau sáp nhập 2025
- **population**: Dân số sau sáp nhập 2025
- **region**: Vùng miền (Bắc Bộ, Trung Bộ, Nam Bộ)
- **type**: Loại đơn vị (Tỉnh/Thành phố trực thuộc Trung ương)
- **nickname**: Biệt danh nổi tiếng

### 2. SapNhap2025 (Sáp Nhập 2025)
- **title**: Tiêu đề về sáp nhập
- **description**: Mô tả quá trình và kết quả sáp nhập
- **details**: Danh sách chi tiết về:
  - Trung tâm hành chính mới
  - Thay đổi diện tích, dân số
  - Số đơn vị hành chính cấp xã
  - Thông tin kinh tế sau sáp nhập

### 3. LichSu (Lịch Sử)
- **title**: Tiêu đề phần lịch sử
- **description**: Mô tả tổng quan lịch sử
- **details**: Các giai đoạn lịch sử quan trọng:
  - Thời cổ đại
  - Thời Pháp thuộc
  - Phát triển hiện đại
  - Trước và sau sáp nhập

### 4. VanHoa (Văn Hóa)
- **title**: Tiêu đề phần văn hóa
- **description**: Mô tả nét văn hóa đặc trưng
- **details**: Các yếu tố văn hóa:
  - Di tích văn hóa, lịch sử
  - Lễ hội truyền thống
  - Nghệ thuật truyền thống
  - Làng nghề
  - Di sản UNESCO

### 5. AmThuc (Ẩm Thực)
- **title**: Tiêu đề phần ẩm thực
- **description**: Mô tả nét ẩm thực đặc trưng
- **details**: Danh sách các món ăn đặc sản:
  - Món ăn truyền thống
  - Đặc sản địa phương
  - Món ăn nổi tiếng

### 6. DiaDanh (Địa Danh)
- **title**: Tiêu đề phần địa danh
- **description**: Mô tả du lịch và địa danh
- **details**: Danh sách địa danh nổi tiếng:
  - Di tích lịch sử
  - Danh lam thắng cảnh
  - Điểm du lịch
  - Công trình kiến trúc

### 7. KetLuan (Kết Luận)
- **title**: Tiêu đề kết luận
- **description**: Phần tổng kết, đánh giá tổng quan về tỉnh

## Quy Tắc Đặt Tên

### Tên File
- Sử dụng snake_case
- Không dấu tiếng Việt
- Ví dụ: `ha_noi.json`, `hai_phong.json`

### ID Tỉnh
- Sử dụng PascalCase
- Không dấu tiếng Việt
- Ví dụ: `"Ha Noi"`, `"Hai Phong"`

### NameVietnamese
- Tên tiếng Việt có dấu
- Ví dụ: `"Hà Nội"`, `"Hải Phòng"`

## Ví Dụ Thực Tế

### Hà Nội (ha_noi.json)
```json
{
  "id": "Ha Noi",
  "nameVietnamese": "Hà Nội",
  "overview": {
    "title": "Thủ Đô Nghìn Năm Văn Hiến",
    "description": "Thủ đô của Việt Nam, trung tâm chính trị, văn hóa và kinh tế hàng đầu...",
    "area": "3.345 km²",
    "population": "8.000.000 người (2025)",
    "region": "Đồng bằng sông Hồng",
    "type": "Thành phố trực thuộc Trung ương",
    "nickname": "Thủ đô nghìn năm văn hiến"
  }
}
```

### Hải Phòng (hai_phong.json)
```json
{
  "id": "Hai Phong",
  "nameVietnamese": "Hải Phòng",
  "overview": {
    "title": "Thành phố Cảng Biển Lớn Nhất Miền Bắc",
    "description": "Trực thuộc Trung ương, trung tâm kinh tế – công nghiệp – cảng biển...",
    "area": "3.194,72 km²",
    "population": "4.664.124 người (2025)",
    "region": "Duyên hải Bắc Bộ",
    "type": "Thành phố trực thuộc Trung ương",
    "nickname": "Thành phố Hoa Phượng Đỏ"
  }
}
```

## Lưu Ý Quan Trọng

1. **Tính nhất quán**: Tất cả file JSON phải tuân theo cấu trúc này
2. **Dữ liệu chính xác**: Thông tin phải cập nhật theo sáp nhập 2025
3. **Nội dung phong phú**: Mỗi phần nên có ít nhất 3-5 chi tiết
4. **Ngôn ngữ**: Sử dụng tiếng Việt có dấu cho nội dung
5. **Định dạng**: JSON phải hợp lệ, không có lỗi syntax

## Cách Thêm Tỉnh Mới

1. Tạo file JSON mới theo cấu trúc trên
2. Đặt tên file theo quy tắc snake_case
3. Cập nhật `ProvinceDetailService` để nhận diện tỉnh mới
4. Thêm background image nếu có
5. Tạo gallery descriptions nếu cần

## Liên Kết Với Code

- **Service**: `lib/services/province_detail_service.dart`
- **Widget**: `lib/widgets/province_detail_widget.dart`
- **Gallery**: `assets/data/gallery_descriptions/`
- **Images**: `assets/images/provinces/{tên_tỉnh}/`
