# Hướng dẫn triển khai chuyển đổi ngôn ngữ (Tiếng Việt / Tiếng Anh)

## Các file đã tạo/cập nhật:

### 1. Locale Bloc (Quản lý trạng thái ngôn ngữ)

- `lib/blocs/locale/locale_bloc.dart` - Bloc quản lý ngôn ngữ
- `lib/blocs/locale/locale_event.dart` - Events cho locale
- `lib/blocs/locale/locale_state.dart` - State cho locale

### 2. Localization Files (Bản dịch)

- `lib/l10n/app_vi.arb` - Bản dịch tiếng Việt
- `lib/l10n/app_en.arb` - Bản dịch tiếng Anh
- `l10n.yaml` - Cấu hình localization

### 3. Cấu hình

- `pubspec.yaml` - Thêm `flutter_localizations` và `generate: true`

### 4. Cập nhật Main App

- `lib/main.dart` - Thêm LocaleBloc và cấu hình localization

### 5. Profile Screen

- `lib/screens/profile/profile_screen.dart` - Thêm dialog chọn ngôn ngữ và localization

### 6. Navigation Bar

- `lib/screens/main_screen.dart` - Cập nhật navbar với localization

## Cách sử dụng:

### 1. Chuyển đổi ngôn ngữ

Người dùng có thể chuyển đổi ngôn ngữ bằng cách:

1. Vào màn hình **Cá nhân** (Profile)
2. Nhấn vào **Ngôn ngữ** trong phần **Cài đặt**
3. Chọn **Tiếng Việt** 🇻🇳 hoặc **English** 🇬🇧
4. Ngôn ngữ sẽ tự động thay đổi và được lưu lại

### 2. Thêm bản dịch mới

Để thêm text mới cần dịch:

1. Mở `lib/l10n/app_vi.arb` và thêm:

```json
{
  "keyName": "Văn bản tiếng Việt"
}
```

2. Mở `lib/l10n/app_en.arb` và thêm:

```json
{
  "keyName": "English text"
}
```

3. Chạy lệnh generate:

```bash
flutter gen-l10n
```

4. Sử dụng trong code:

```dart
AppLocalizations.of(context)!.keyName
```

### 3. Ngôn ngữ hiện hỗ trợ

- **vi**: Tiếng Việt (mặc định)
- **en**: English

## Các text đã được dịch:

### Navigation

- Trang chủ / Home
- Lớp học / Classes
- Bài tập / Exercises
- Cá nhân / Profile

### Profile Screen

- Thông tin cá nhân / Personal Information
- Thông tin học tập / Academic Information
- Quản lý học phí / Fee Management
- Đổi mật khẩu / Change Password
- Cài đặt / Settings
- Giao diện / Theme
- Thông báo / Notifications
- Ngôn ngữ / Language
- Hỗ trợ / Support
- Về ứng dụng / About
- Phản hồi / Feedback
- Đăng xuất / Logout

### Roles

- Học sinh / Student
- Giáo viên / Teacher
- Quản trị viên / Administrator
- Người dùng / User

### Dialogs

- Chọn ngôn ngữ / Select Language
- Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng? / Are you sure you want to logout?
- Huỷ / Cancel
- Xác nhận / Confirm

## Lưu ý kỹ thuật:

1. **Lưu trữ**: Ngôn ngữ được lưu trong SharedPreferences và tự động load khi khởi động app
2. **State Management**: Sử dụng Bloc pattern để quản lý state ngôn ngữ
3. **Hot Reload**: Khi thay đổi ngôn ngữ, UI tự động rebuild với ngôn ngữ mới
4. **Reserved Keywords**: Tránh sử dụng Dart keywords (class, if, else...) làm key trong ARB files

## Mở rộng trong tương lai:

1. Thêm ngôn ngữ mới (ví dụ: Tiếng Trung, Tiếng Nhật):

   - Tạo file `app_zh.arb`, `app_ja.arb`
   - Thêm `Locale('zh')`, `Locale('ja')` vào `supportedLocales`
   - Thêm vào dialog chọn ngôn ngữ

2. Localize toàn bộ app:

   - Thêm các text còn lại vào ARB files
   - Thay thế hard-coded strings bằng `AppLocalizations.of(context)!.key`

3. Format số, ngày tháng theo locale:
   - Sử dụng `NumberFormat` và `DateFormat` từ package `intl`
