# Cập nhật Localization cho Home Screen

## Các thay đổi mới:

### 1. Files đã cập nhật:

#### Home Screen

- `lib/screens/home/home_screen.dart`
  - Thêm import `AppLocalizations`
  - Localize "Xin chào!" → `hello`
  - Localize "Lỗi tải thông tin người dùng" → `errorLoadingUserInfo`
  - Localize "Không thể tải dữ liệu" → `cannotLoadData`
  - Localize "Tải lại" → `reload`
  - Localize các SnackBar messages

#### Student Home Widgets

- `lib/screens/home/widgets/student_home_widgets.dart`

  - **Stats Cards:**

    - "Bài tập hôm nay" → `todayAssignments`
    - "Lớp học tham gia" → `classesJoined`

  - **Activities Section:**

    - "Hoạt động gần đây" → `recentActivities`
    - "Chưa có hoạt động nào" → `noActivities`

  - **Assignment Status:**

    - "Đã nộp" → `submitted`
    - "Quá hạn" → `overdue`
    - "Chưa nộp" → `notSubmitted`
    - "Hạn" → `deadline`

  - **Time Format:**

    - "Vừa xong" → `justNow`
    - "X phút trước" → `minutesAgo(X)`
    - "X giờ trước" → `hoursAgo(X)`
    - "X ngày trước" → `daysAgo(X)`

  - **Section Titles:**
    - "Bài tập hôm nay (X)" → `todayAssignmentsCount(X)`

#### Teacher Home Widgets

- `lib/screens/home/widgets/teacher_home_widgets.dart`

  - **Stats Cards:**

    - "Lớp phụ trách" → `managedClasses`
    - "Học sinh" → `students`
    - "Bài tập chờ chấm" → `pendingGrading`
    - "Tiết học hôm nay" → `todayClasses`

  - **Quick Actions:**

    - "Thao tác nhanh" → `quickActions`
    - "Tạo bài tập" → `createExercise`
    - "Điểm danh" → `takeAttendance`

  - **Schedule Section:**

    - "Lịch dạy hôm nay (X)" → `todaySchedule(X)`
    - "X học sinh" → `studentCount(X)`
    - "X bài nộp" → `submissionCount(X)`

  - **Activities:**
    - "Hoạt động gần đây" → `recentActivities`
    - "Chưa có hoạt động nào" → `noActivities`
    - Time formatting (giống Student)

### 2. Các key localization mới đã thêm vào ARB files:

```json
{
  // Common
  "hello": "Xin chào!" / "Hello!",
  "errorLoadingUserInfo": "Lỗi tải thông tin người dùng" / "Error loading user info",
  "cannotLoadData": "Không thể tải dữ liệu" / "Cannot load data",
  "reload": "Tải lại" / "Reload",

  // Student Dashboard
  "todayAssignments": "Bài tập hôm nay" / "Today's Assignments",
  "classesJoined": "Lớp học tham gia" / "Classes Joined",
  "recentActivities": "Hoạt động gần đây" / "Recent Activities",
  "noActivities": "Chưa có hoạt động nào" / "No activities yet",
  "todayAssignmentsCount": "Bài tập hôm nay ({count})" / "Today's Assignments ({count})",
  "submitted": "Đã nộp" / "Submitted",
  "overdue": "Quá hạn" / "Overdue",
  "notSubmitted": "Chưa nộp" / "Not Submitted",
  "deadline": "Hạn" / "Due",

  // Time Formatting
  "justNow": "Vừa xong" / "Just now",
  "minutesAgo": "{minutes} phút trước" / "{minutes} minutes ago",
  "hoursAgo": "{hours} giờ trước" / "{hours} hours ago",
  "daysAgo": "{days} ngày trước" / "{days} days ago",

  // Teacher Dashboard
  "managedClasses": "Lớp phụ trách" / "Managed Classes",
  "students": "Học sinh" / "Students",
  "pendingGrading": "Bài tập chờ chấm" / "Pending Grading",
  "todayClasses": "Tiết học hôm nay" / "Today's Classes",
  "quickActions": "Thao tác nhanh" / "Quick Actions",
  "createExercise": "Tạo bài tập" / "Create Exercise",
  "takeAttendance": "Điểm danh" / "Take Attendance",
  "todaySchedule": "Lịch dạy hôm nay ({count})" / "Today's Schedule ({count})",
  "studentCount": "{count} học sinh" / "{count} students",
  "submissionCount": "{count} bài nộp" / "{count} submissions",

  // Feature Messages
  "createExerciseFeatureInDevelopment": "Chức năng tạo bài tập đang được phát triển" / "Create exercise feature is under development",
  "takeAttendanceFeatureInDevelopment": "Chức năng điểm danh đang được phát triển" / "Take attendance feature is under development"
}
```

### 3. Các thay đổi kỹ thuật:

#### Placeholder Parameters

Sử dụng placeholders cho dynamic values:

```dart
// Trước:
Text('Bài tập hôm nay (${assignments.length})')

// Sau:
Text(AppLocalizations.of(context)!.todayAssignmentsCount(assignments.length))
```

#### BuildContext trong Helper Methods

Một số helper methods cần BuildContext để access localization:

```dart
// Trước:
String _formatTimestamp() {
  return 'Vừa xong';
}

// Sau:
String _formatTimestamp(BuildContext context) {
  return AppLocalizations.of(context)!.justNow;
}
```

### 4. Tính năng đã localize:

#### Student View:

✅ Header greeting
✅ Stats cards (Today's assignments, Classes joined)
✅ Today's assignments list with status
✅ Recent activities with time formatting
✅ Error messages

#### Teacher View:

✅ Header greeting
✅ Stats cards (Managed classes, Students, Pending grading, Today's classes)
✅ Quick actions (Create exercise, Take attendance)
✅ Today's schedule with student count
✅ Recent activities with submission count
✅ Error messages

### 5. Cách test:

1. Chạy `flutter gen-l10n` để generate localization files
2. Khởi động app
3. Đăng nhập với account Student hoặc Teacher
4. Vào Home screen
5. Vào Profile → Language → Chọn English
6. Quay lại Home screen và kiểm tra tất cả text đã được dịch

### 6. Lưu ý:

- Tất cả các text hard-coded đã được thay thế bằng localization keys
- Time formatting sử dụng placeholders cho dynamic values
- BuildContext được pass vào các helper methods khi cần
- SnackBar messages cũng đã được localize

## Tổng kết:

✅ Home Screen hoàn toàn hỗ trợ đa ngôn ngữ (Tiếng Việt / English)
✅ Cả Student và Teacher dashboard đều đã được localize
✅ Tất cả dynamic values sử dụng placeholders đúng cách
✅ Error handling và loading states đã được localize
