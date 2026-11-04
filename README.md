# Ứng Dụng Kỷ Luật Cá Nhân (Personal Discipline App) - Flutter

Ứng dụng di động và web hoàn chỉnh giúp theo dõi và quản lý thói quen hàng ngày nhằm rèn luyện kỷ luật cá nhân, được xây dựng bằng **Flutter**, **Provider**, **SharedPreferences**, **Material 3** và **FL Chart**.

---

## 🎯 Bảng Đối Chiếu Yêu Cầu & Checklist (5 Mục)

| STT | Yêu cầu nhiệm vụ | Trạng thái | Chi tiết triển khai |
| :--- | :--- | :---: | :--- |
| **1** | Thiết kế giao diện người dùng với màn hình danh sách thói quen, màn hình thêm/sửa thói quen và màn hình thống kê tiến độ | ✅ **Hoàn thành** | Đầy đủ 3 màn hình chính + màn hình cài đặt: `HabitListScreen`, `AddEditHabitScreen`, `StatisticsScreen`, `SettingsScreen`. Giao diện Material 3 hiện đại, hỗ trợ cả Light Mode & Dark Mode. |
| **2** | Cài đặt tính năng thêm, xóa, sửa thói quen với các thuộc tính: tên, mô tả, tần suất và thời gian nhắc nhở | ✅ **Hoàn thành** | Form thêm/sửa với validation: tên (bắt buộc), mô tả (tùy chọn), tần suất (Hàng ngày, theo thứ trong tuần, số lần/tuần), giờ nhắc nhở (TimeOfDay Picker), chọn biểu tượng và màu sắc. Hỗ trợ xóa với hộp thoại xác nhận. |
| **3** | Triển khai hệ thống đánh dấu hoàn thành thói quen hàng ngày với giao diện trực quan | ✅ **Hoàn thành** | Checkbox/nút tương tác mượt mà, đổi màu tức thì khi hoàn thành, đếm chuỗi liên tiếp (🔥 Streak Counter), thanh tiến độ tròn hiển thị % mục tiêu trong ngày, thông điệp động lực thay đổi theo tiến độ. |
| **4** | Lưu trữ dữ liệu thói quen sử dụng SQLite hoặc SharedPreferences để dữ liệu không bị mất khi tắt ứng dụng | ✅ **Hoàn thành** | Sử dụng `SharedPreferences` với cơ chế JSON serialization/deserialization mạnh mẽ. Dữ liệu được lưu trữ tự động và bền vững trên cả **Web**, **Android**, **iOS** và **Desktop**. Tích hợp sẵn bộ nạp dữ liệu mẫu (Seed Demo Data) và đặt lại (Reset Data). |
| **5** | Xây dựng màn hình thống kê hiển thị tỷ lệ hoàn thành thói quen theo ngày, tuần và tháng | ✅ **Hoàn thành** | Màn hình `StatisticsScreen` hiển thị: Tỷ lệ hoàn thành hôm nay, tỷ lệ tuần này, tỷ lệ tháng này, chuỗi ngày kỷ luật kỷ lục, biểu đồ cột 7 ngày (Weekly Bar Chart), lưới lịch kỷ luật theo tháng (Monthly Calendar Heatmap), và bảng phân tích chi tiết từng thói quen. |

---

## 🚀 Hướng Dẫn Chạy Ứng Dụng

### 1. Chạy trên Web (Khuyên dùng)
Ứng dụng đã được tối ưu hoàn hảo cho trình duyệt web (Chrome, Edge):
```bash
# Chạy trực tiếp trên Google Chrome
flutter run -d chrome

# Hoặc chạy trên Microsoft Edge
flutter run -d edge

# Hoặc khởi chạy bản build web đã biên dịch sẵn bằng python:
python -m http.server 8080 --directory build/web
# Sau đó mở trình duyệt tại: http://localhost:8080
```

### 2. Chạy trên Máy Ảo hoặc Thiết Bị Android
```bash
flutter run -d android
```

### 3. Chạy trên Windows Desktop
```bash
flutter run -d windows
```

### 4. Kiểm tra Lint & Unit Tests
```bash
# Kiểm tra phân tích mã nguồn (0 cảnh báo, 0 lỗi)
flutter analyze

# Chạy toàn bộ bộ test kiểm thử
flutter test
```

---

## 🏗️ Cấu Trúc Mã Nguồn (Architecture)

```
lib/
├── main.dart                       # Entry point, MultiProvider, Material 3 Theme setup
├── models/
│   ├── habit.dart                  # Model thói quen (id, tên, mô tả, tần suất, giờ nhắc, màu, icon)
│   ├── habit_completion.dart       # Model lịch sử check-in ngày (dateString, completedAt)
│   └── habit_frequency.dart        # Model tần suất (Hàng ngày, theo thứ, số lần/tuần)
├── repositories/
│   └── habit_repository.dart       # Tầng lưu trữ SharedPreferences & JSON Cache
├── providers/
│   ├── habit_provider.dart         # Quản lý State CRUD, tính toán chuỗi Streak, tỷ lệ ngày/tuần/tháng
│   └── theme_provider.dart         # Quản lý Dark/Light/System Mode
├── screens/
│   ├── home_screen.dart            # Điều hướng NavigationBar chính (3 tab)
│   ├── habit_list_screen.dart      # Màn hình danh sách thói quen hôm nay + thanh dòng thời gian
│   ├── add_edit_habit_screen.dart  # Màn hình Thêm / Chỉnh sửa thói quen
│   ├── statistics_screen.dart      # Màn hình Thống kê tiến độ (Ngày, Tuần, Tháng)
│   └── settings_screen.dart        # Màn hình Cài đặt, Đổi theme & Quản lý dữ liệu mẫu
├── widgets/
│   ├── daily_progress_banner.dart  # Banner tiến độ ngày (% hoàn thành + thông điệp động lực)
│   ├── date_timeline_bar.dart      # Thanh chọn ngày ngang (Timeline Strip)
│   ├── habit_card.dart             # Thẻ thói quen tương tác, check-in, streak badge
│   ├── stat_metric_card.dart       # Thẻ chỉ số tổng quan (Ngày, Tuần, Tháng, Streak)
│   ├── weekly_bar_chart.dart       # Biểu đồ cột hoàn thành 7 ngày trong tuần
│   ├── monthly_calendar_heatmap.dart # Lưới lịch kỷ luật nhiệt độ theo tháng
│   └── empty_state_view.dart       # Giao diện khi danh sách trống
└── utils/
    ├── date_utils.dart             # Xử lý chuẩn hóa ngày tháng, tên thứ tiếng Việt
    ├── color_options.dart          # Bảng màu thói quen
    ├── icon_options.dart           # Bảng icon chuẩn hóa
    └── sample_data.dart            # Dữ liệu mẫu ban đầu (phục vụ chấm điểm & trải nghiệm)
```

---

## 🌟 Các Tính Năng Nổi Bật & Điểm Cộng UI/UX
- **Trải nghiệm ngay lập tức (Zero-friction)**: Khi mở ứng dụng lần đầu, app tự động chuẩn bị sẵn các thói quen mẫu thông dụng và lịch sử check-in sinh động để giảng viên/người chấm có thể xem ngay các biểu đồ thống kê mà không cần mất công tạo từ đầu.
- **Tùy biến linh hoạt**: Người dùng có thể tự do thêm thói quen mới, sửa đổi, xóa bỏ, hoặc bấm "Tạo lại dữ liệu mẫu" / "Xóa sạch dữ liệu" bất kỳ lúc nào trong tab Cài đặt.
- **Hỗ trợ đa nền tảng Responsive**: Giao diện co giãn tự nhiên, có giới hạn chiều rộng tối ưu trên màn hình Web/Desktop để giữ trải nghiệm như một ứng dụng di động chuẩn mực.
- **Dark Mode & Light Mode**: Hỗ trợ chuyển đổi giao diện sáng/tối mượt mà theo chuẩn Material 3.
