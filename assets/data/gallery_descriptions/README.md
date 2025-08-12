# Cấu Trúc Gallery Descriptions

## Tổng Quan

File JSON này chứa mô tả cho các hình ảnh trong gallery của từng tỉnh. Mỗi tỉnh có một file JSON riêng với danh sách mô tả tương ứng với các hình ảnh.

## Cấu Trúc File

### Tên File
- Format: `{tên_tỉnh_snake_case}.json`
- Ví dụ: `ha_noi.json`, `hai_phong.json`

### Cấu Trúc JSON

```json
{
  "provinceId": "Tên tỉnh (tiếng Anh)",
  "provinceName": "Tên tỉnh (tiếng Việt)",
  "descriptions": [
    "Mô tả cho hình ảnh 1 (gallery_1.jpg)",
    "Mô tả cho hình ảnh 2 (gallery_2.jpg)",
    "Mô tả cho hình ảnh 3 (gallery_3.jpg)",
    "Mô tả cho hình ảnh 4 (gallery_4.jpg)",
    "Mô tả cho hình ảnh 5 (gallery_5.jpg)"
  ]
}
```

## Chi Tiết

### ProvinceId
- ID của tỉnh (giống với file JSON chính)
- Ví dụ: `"Ha Noi"`, `"Hai Phong"`

### ProvinceName
- Tên tiếng Việt của tỉnh
- Ví dụ: `"Hà Nội"`, `"Hải Phòng"`

### Descriptions
- Mảng chứa 5 mô tả tương ứng với 5 hình ảnh
- Mỗi mô tả nên ngắn gọn, súc tích (50-100 từ)
- Mô tả nên bao gồm:
  - Tên địa danh/món ăn/điểm đến
  - Đặc điểm nổi bật
  - Ý nghĩa văn hóa/lịch sử

## Quy Tắc Viết Mô Tả

### Độ Dài
- **Ngắn gọn**: 50-100 từ
- **Súc tích**: Tập trung vào điểm chính
- **Dễ đọc**: Sử dụng câu ngắn, rõ ràng

### Nội Dung
- **Tên chính**: Địa danh/món ăn/điểm đến
- **Đặc điểm**: Nét nổi bật, độc đáo
- **Ý nghĩa**: Giá trị văn hóa, lịch sử
- **Cảm xúc**: Tạo ấn tượng cho người đọc

### Cấu Trúc Câu
- Bắt đầu bằng tên chính
- Mô tả đặc điểm
- Kết thúc bằng ý nghĩa

## Ví Dụ Thực Tế

### Hà Nội (ha_noi.json)
```json
{
  "provinceId": "Ha Noi",
  "provinceName": "Hà Nội",
  "descriptions": [
    "Quảng trường Ba Đình & Lăng Chủ tịch Hồ Chí Minh – Biểu tượng trung tâm chính trị của Việt Nam, không gian trang nghiêm, giàu giá trị lịch sử – văn hóa, thu hút đông đảo người dân và du khách.",
    "Phố cổ Hà Nội – Những con phố như Hàng Đào, Hàng Mã với kiến trúc cổ, cửa hàng nhỏ, quán cà phê, nhịp sống đặc trưng và các lễ hội truyền thống của người Hà Thành.",
    "Phở Hà Nội – Biểu tượng ẩm thực thủ đô với bát phở nghi ngút, nước dùng trong, đậm vị; bánh phở mềm, ăn kèm rau thơm, chanh ớt tạo nên hương vị tinh tế, hấp dẫn.",
    "Văn Miếu - Quốc Tử Giám – Trường đại học đầu tiên của Việt Nam, kiến trúc cổ kính, không gian hiếu học gắn với Nho học; biểu tượng tri thức của Thăng Long – Hà Nội.",
    "Lễ hội Đền Gióng (Sóc Sơn) – Lễ hội truyền thống tái hiện chiến công Thánh Gióng, rước kiệu linh đình, di sản văn hóa phi vật thể thể hiện tinh thần yêu nước và tự hào dân tộc."
  ]
}
```

### Hải Phòng (hai_phong.json)
```json
{
  "provinceId": "Hai Phong",
  "provinceName": "Hải Phòng",
  "descriptions": [
    "Bản đồ Hải Phòng sau sáp nhập - Thành phố Cảng Biển lớn nhất miền Bắc Việt Nam sau khi sáp nhập với tỉnh Hải Dương theo Nghị quyết Quốc hội 2025, với diện tích 3.194,72km² và dân số 4.664.124 người.",
    "Cảng Hải Phòng - Cảng biển lớn nhất miền Bắc Việt Nam, cửa ngõ giao thương quốc tế quan trọng với các tàu container và hàng hóa đang hoạt động sôi động.",
    "Đảo Cát Bà - Di sản thiên nhiên thế giới với vịnh Lan Hạ xinh đẹp, rừng nguyên sinh và hệ sinh thái biển đa dạng, điểm du lịch sinh thái nổi tiếng.",
    "Bánh đa cua Hải Phòng - Món ăn đặc sản nổi tiếng với nước dùng đậm đà từ cua đồng, bánh đa dai giòn và các loại rau tươi ngon.",
    "Bánh đậu xanh Hải Dương (Nay là Hải Phòng) - Món bánh truyền thống nổi tiếng của vùng Hải Dương, nay thuộc Hải Phòng sau sáp nhập 2025, với hương vị thơm ngon và kỹ thuật làm bánh tinh xảo."
  ]
}
```

## Quy Tắc Đặt Tên Hình Ảnh

### Tên File Hình Ảnh
- Format: `gallery_{số}.jpg`
- Ví dụ: `gallery_1.jpg`, `gallery_2.jpg`, `gallery_3.jpg`, `gallery_4.jpg`, `gallery_5.jpg`

### Thư Mục
- Đặt trong: `assets/images/provinces/{tên_tỉnh}/`
- Ví dụ: `assets/images/provinces/ha_noi/gallery_1.jpg`

## Lưu Ý Quan Trọng

1. **Số lượng**: Luôn có đúng 5 mô tả tương ứng với 5 hình ảnh
2. **Thứ tự**: Mô tả phải khớp với thứ tự hình ảnh
3. **Nội dung**: Mô tả phải liên quan trực tiếp đến hình ảnh
4. **Ngôn ngữ**: Sử dụng tiếng Việt có dấu
5. **Độ dài**: Mỗi mô tả nên có độ dài tương đương nhau

## Cách Thêm Gallery Mới

1. Tạo file JSON mới theo cấu trúc trên
2. Đặt tên file theo quy tắc snake_case
3. Viết 5 mô tả tương ứng với 5 hình ảnh
4. Đảm bảo hình ảnh được đặt đúng thư mục
5. Cập nhật `pubspec.yaml` nếu cần

## Liên Kết Với Code

- **Service**: `lib/services/gallery_description_service.dart`
- **Widget**: `lib/widgets/gallery_full_screen.dart`
- **Fallback**: Nếu không có file JSON, sẽ sử dụng mô tả mặc định
- **Error Handling**: Nếu hình ảnh không tồn tại, sẽ hiển thị placeholder

## Mô Tả Mặc Định

Nếu không có file JSON riêng, hệ thống sẽ sử dụng mô tả mặc định:

```dart
[
  'Bản đồ {tên_tỉnh} sau sáp nhập 2025 - Thông tin về ranh giới, diện tích và dân số mới sau khi thực hiện sáp nhập theo Nghị quyết Quốc hội.',
  'Cảnh quan địa lý và thiên nhiên của {tên_tỉnh}',
  'Văn hóa và di sản truyền thống',
  'Du lịch và điểm đến nổi tiếng',
  'Ẩm thực đặc sắc và món ăn truyền thống',
  'Giao thông và hạ tầng hiện đại',
]
```
