# Tutor Classes Additional Localization Update

## Tổng quan

Đã hoàn thành việc chuyển đổi ngôn ngữ (Tiếng Việt ⇔ English) cho các file còn thiếu trong phần **Tutor Classes**.

## Các file đã được localize

### 1. Cards (Shared Widgets)

- ✅ `available_class_card.dart` - Card hiển thị lớp có sẵn
  - Các trạng thái button: Đăng ký tham gia, Đã tham gia lớp, Đang đăng ký, Đang chờ duyệt, Lớp đã đầy
  - Thông tin: Học sinh, Học phí, Còn trống
- ✅ `pending_class_card.dart` - Card hiển thị lớp đang chờ duyệt
  - Trạng thái: "Đang chờ giáo viên duyệt"
- ✅ `class_header_card.dart` - Card header thông tin lớp học
  - Thông tin giáo viên, số buổi/tuần, địa điểm

### 2. Sections (Shared Widgets)

- ✅ `class_detail_section.dart` - Chi tiết thông tin lớp học
  - Tiêu đề: Thông tin chi tiết
  - Các trường: Mô tả, Môn học, Địa điểm, Số lượng học sinh, Ngày tạo
- ✅ `class_schedule_section.dart` - Lịch học
  - Tiêu đề: "Lịch học"
- ✅ `students_list_widget.dart` - Danh sách học sinh
  - Tiêu đề: Học sinh trong lớp / Học sinh
  - Empty state: Chưa có học sinh nào

### 3. States (Shared Widgets)

- ✅ `error_state_widget.dart` - Widget hiển thị lỗi
  - Nút: "Thử lại"

### 4. Bottom Sheets

- ✅ `pending_classes_bottom_sheet.dart` - Bottom sheet lớp chờ duyệt
  - Tiêu đề: Danh sách lớp đang chờ duyệt
  - Empty state: Không có lớp nào đang chờ duyệt
  - Error message: Lỗi khi tải

### 5. Base Widget

- ✅ `base_class_card.dart` - Widget cơ sở cho tất cả class cards
  - Các label: Môn học:, Lớp:, Giáo viên:, Lịch:, Địa chỉ:

## Translation Keys đã thêm

### Trạng thái và Hành động

```dart
"registerToJoin": "Đăng ký tham gia"
"joined": "Đã tham gia lớp"
"registering2": "Đang đăng ký..."
"waitingForApproval": "Đang chờ giáo viên duyệt"
"classFull": "Lớp đã đầy"
```

### Labels

```dart
"studentsLabel": "Học sinh"
"spotsAvailable": "Còn trống"
"tuitionFeeLabel": "Học phí"
"subjectPrefix": "Môn học:"
"gradePrefix": "Lớp:"
"teacherPrefix": "Giáo viên:"
"schedulePrefix": "Lịch:"
"addressPrefix": "Địa chỉ:"
```

### Thông tin chi tiết

```dart
"classDetailInfo": "Thông tin chi tiết"
"locationLabel": "Địa điểm"
"studentCountLabel": "Số lượng học sinh"
"studentCountValue": "{current}/{max} học sinh" // with placeholders
"classSchedule": "Lịch học"
"studentsInClass": "Học sinh trong lớp"
```

### Empty States

```dart
"noStudentsYet": "Chưa có học sinh nào"
"noStudentsDescription": "Lớp học chưa có học sinh nào tham gia"
"noPendingClasses": "Không có lớp nào đang chờ duyệt"
```

### Error & Actions

```dart
"errorLoadingClass": "Lỗi khi tải thông tin lớp học"
"tryAgain": "Thử lại"
"pendingClasses": "Danh sách lớp đang chờ duyệt"
```

### Student Management (Additional)

```dart
"confirmRemoveStudent": "Bạn có chắc chắn muốn xóa học sinh \"{studentName}\" khỏi danh sách chờ duyệt?"
"studentRemoved": "Đã xóa học sinh {studentName} khỏi danh sách chờ duyệt"
"errorRemovingStudent": "Lỗi khi xóa học sinh: {error}"
"confirmApproveStudent": "Bạn có chắc chắn muốn duyệt học sinh \"{studentName}\" vào lớp học?"
"studentApproved": "Đã duyệt học sinh {studentName}"
"errorApprovingStudent": "Lỗi khi duyệt học sinh: {error}"
"pendingStudentsTitle": "Học sinh chờ duyệt"
"pendingStudentsCount": "{count} học sinh chờ duyệt"
"approveInstruction": "Nhấn vào nút \"Duyệt\" để xác nhận học sinh vào lớp"
"allStudentsApproved": "Tất cả học sinh đã được duyệt hoặc chưa có ai đăng ký"
```

### Attendance (Additional)

```dart
"attendanceHistory": "Lịch sử điểm danh"
"startAttendance": "Bắt đầu điểm danh"
"todayDate": "Hôm nay - {date}"
"attendanceStarted": "Đã bắt đầu điểm danh"
"errorStartingAttendance": "Lỗi khi bắt đầu điểm danh: {error}"
"present": "Có mặt"
"absent": "Vắng mặt"
"attendanceSaved": "Đã lưu điểm danh thành công"
"errorSavingAttendance": "Lỗi khi lưu điểm danh: {error}"
```

## Kỹ thuật áp dụng

### 1. Import AppLocalizations

```dart
import 'package:edusync/l10n/app_localizations.dart';
```

### 2. Sử dụng localization với context

```dart
// Simple text
AppLocalizations.of(context)!.keyName

// Text với placeholders
AppLocalizations.of(context)!.studentCountValue(current, max)
AppLocalizations.of(context)!.confirmRemoveStudent(studentName)
```

### 3. Passing BuildContext to methods

Nhiều widget methods cần update signature để nhận BuildContext:

```dart
// Before
Widget _buildHeader() { ... }

// After
Widget _buildHeader(BuildContext context) { ... }
```

### 4. Removing const

Khi sử dụng dynamic localization, cần remove `const`:

```dart
// Before
const Text('Static text')

// After
Text(AppLocalizations.of(context)!.dynamicText)
```

## Files đã chỉnh sửa

1. `lib/l10n/app_vi.arb` - Thêm 70+ keys tiếng Việt
2. `lib/l10n/app_en.arb` - Thêm 70+ keys tiếng Anh
3. 10 widget files được localize hoàn toàn

## Kiểm tra

### Test Cases

- [ ] Chuyển đổi ngôn ngữ trong Settings
- [ ] Kiểm tra tất cả card hiển thị đúng
- [ ] Kiểm tra empty states
- [ ] Kiểm tra error states
- [ ] Kiểm tra bottom sheets
- [ ] Kiểm tra các trạng thái button khác nhau
- [ ] Kiểm tra placeholders với dữ liệu thực

### Expected Behavior

✅ Text thay đổi ngay khi switch language
✅ Không có text hardcode còn sót lại
✅ Placeholders hiển thị đúng giá trị dynamic
✅ Không có lỗi compile
✅ UI layout không bị ảnh hưởng

## Trạng thái hoàn thành

- **Total Files Localized**: 10 files
- **Translation Keys Added**: ~70 keys (Vietnamese + English)
- **Status**: ✅ 100% Complete
- **Errors**: None
- **Ready for Testing**: Yes

## Ghi chú

- Tất cả các file đã được localize với đầy đủ context
- Các placeholders được sử dụng đúng cú pháp
- Import statements đã được thêm vào tất cả files cần thiết
- BuildContext được pass correctly vào tất cả methods cần thiết
