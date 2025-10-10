# Danh Sách File Classes Cần Localize

## ✅ Đã Hoàn Thành

1. ✅ `class_screen.dart` - Main screen với tabs
2. ✅ `quick_info_card_widget.dart` - Card hiển thị thông tin lớp/trường
3. ✅ `school_Classes/students/student_subject.dart` - View môn học của học sinh
4. ✅ `school_Classes/teacher/teacher_subject.dart` - View môn học của giáo viên
5. ✅ `school_Classes/widgets/join_class_dialog.dart` - Dialog nhập mã lớp
6. ✅ `school_Classes/widgets/join_class_form.dart` - Form nhập mã lớp
7. ✅ `school_Classes/widgets/subject_card.dart` - Card hiển thị môn học
8. ✅ `tutor_classes/shared/widgets/states/empty_state_widget.dart` - Empty state
9. ✅ `tutor_classes/student/widgets/buttons/student_action_buttons_widget.dart` - Nút tìm lớp/đơn đăng ký
10. ✅ `tutor_classes/shared/widgets/cards/class_card_widget.dart` - Card lớp gia sư

## 🔄 Cần Localize (Theo Thứ Tự Ưu Tiên)

### High Priority - Student Tutor Classes

11. `tutor_classes/student/widgets/bottom_sheets/available_classes_bottom_sheet.dart`
    - "Lọc theo lớp", "Tất cả lớp", "Lỗi: ..."
12. `tutor_classes/student/widgets/dialogs/show_register_dialog.dart`
    - "Đăng ký lớp gia sư", "Giáo viên:", "Lịch học:", "Địa chỉ:", "Hủy", "Đăng ký", "Chưa có lịch học"

### High Priority - Teacher Tutor Classes

13. `tutor_classes/teacher/screens/create_class_screen.dart`

    - "Tạo lớp học mới", "Thông tin cơ bản", "Thêm lịch học", "Giờ học:", "Tạo lớp học thành công!"
    - "Giờ bắt đầu", "Giờ kết thúc", "Giờ kết thúc phải sau giờ bắt đầu", "Lưu", "Hủy"

14. `tutor_classes/teacher/screens/class_detail_screen.dart`

    - "Không tìm thấy thông tin lớp học", "Thử lại", "Tính năng đang phát triển"
    - "Xác nhận xóa", "Bạn có chắc chắn muốn xóa lớp học này không?", "Xóa"
    - "Lỗi khi xóa lớp học: ..."

15. `tutor_classes/teacher/screens/pending_students_screen.dart`

    - "Xác nhận xóa", "Bạn có chắc chắn muốn xóa học sinh này khỏi danh sách chờ duyệt?"
    - "Xác nhận duyệt", "Bạn có chắc chắn muốn duyệt học sinh này vào lớp?"
    - "Đang tải danh sách học sinh chờ duyệt...", "Không có học sinh nào đang chờ duyệt"
    - "Duyệt", "Hủy", "Xóa", "Thử lại"

16. `tutor_classes/teacher/widgets/attendance_widget.dart`
    - "Điểm danh", "Chưa có lịch sử", "Điểm danh lớp học", "Lưu điểm danh", "Hủy"

### Medium Priority - Shared Components

17. `tutor_classes/shared/widgets/sections/class_detail_section.dart`

    - "Mô tả", "Môn học", "Địa điểm", "Số lượng học sinh", "Ngày tạo"

18. `tutor_classes/shared/widgets/sections/students_list_widget.dart`

    - "Học sinh {number}", "ID:", "Email:", "Lớp:"

19. `tutor_classes/shared/widgets/states/error_state_widget.dart`

    - "Thử lại"

20. `school_Classes/widgets/joined_class_list_section.dart`
    - "Môn học", "Mã lớp", "Giáo viên"

### Low Priority - Info Chips & Minor Components

21. `school_Classes/widgets/info_chip.dart`
22. `school_Classes/widgets/join_class_section.dart`
23. `tutor_classes/widgets/base_class_card.dart`
24. `tutor_classes/shared/mixins/class_tab_mixin.dart`

## 📝 Translation Keys Đã Thêm

Đã thêm 60+ keys mới vào `app_vi.arb` và `app_en.arb`:

### Basic Labels

- `created`, `joined`, `teacherLabel`, `tutor`, `exercises`, `detail`
- `classCodeLabel`, `classCodeHint`, `pleaseEnterClassCode`
- `joining`, `joinSuccess`

### Filter & Selection

- `filterByGrade`, `allGrades`, `errorPrefix`

### Tutor Registration

- `registerTutorClass`, `scheduleLabel`, `addressLabel`
- `cancel`, `register`, `noScheduleYet`

### Admin Actions

- `confirmDelete`, `confirmDeleteMessage`, `delete`
- `confirmApprove`, `confirmApproveMessage`, `approve`
- `loadingPendingStudents`, `noPendingStudents`

### Class Management

- `classInfoNotFound`, `featureInDevelopment`
- `confirmDeleteClass`, `deleteClassError`
- `createNewClass`, `createClassSuccess`

### Schedule

- `addScheduleDialog`, `startTime`, `endTime`
- `endTimeMustBeAfterStart`, `save`
- `dayLabel`, `classTimeLabel`

### Attendance

- `attendance`, `noAttendanceHistory`
- `attendanceDialog`, `saveAttendance`

### Student Info

- `studentNumber`, `idLabel`, `emailLabel`, `classGrade`

### Details

- `descriptionLabel`, `subjectLabel`, `studentCount2`, `createdDate`

## 🎯 Next Steps

1. Localize các file High Priority trước (11-16)
2. Localize các file Medium Priority (17-20)
3. Test toàn bộ flow student và teacher
4. Kiểm tra các dialog/bottom sheet
5. Verify tất cả placeholders hoạt động đúng

## 📊 Tiến Độ

- **Đã hoàn thành**: 10/24 files (42%)
- **Còn lại**: 14 files quan trọng
- **ARB Keys**: 60+ keys đã được thêm
