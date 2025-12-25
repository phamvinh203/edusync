// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'EduSync';

  @override
  String get home => 'Trang chủ';

  @override
  String get classes => 'Lớp học';

  @override
  String get exercises => 'Bài tập';

  @override
  String get profile => 'Cá nhân';

  @override
  String get personalInfo => 'Thông tin cá nhân';

  @override
  String get academicInfo => 'Thông tin học tập';

  @override
  String get feeManagement => 'Quản lý học phí';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get settings => 'Cài đặt';

  @override
  String get theme => 'Giao diện';

  @override
  String get notifications => 'Thông báo';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get support => 'Hỗ trợ';

  @override
  String get about => 'Về ứng dụng';

  @override
  String get feedback => 'Phản hồi';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutConfirm => 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get student => 'Học sinh';

  @override
  String get teacher => 'Giáo viên';

  @override
  String get admin => 'Quản trị viên';

  @override
  String get user => 'Người dùng';

  @override
  String get classLabel => 'Lớp';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get hello => 'Xin chào!';

  @override
  String get errorLoadingUserInfo => 'Lỗi tải thông tin người dùng';

  @override
  String get cannotLoadData => 'Không thể tải dữ liệu';

  @override
  String get reload => 'Tải lại';

  @override
  String get todayAssignments => 'Bài tập hôm nay';

  @override
  String get classesJoined => 'Lớp học tham gia';

  @override
  String get recentActivities => 'Hoạt động gần đây';

  @override
  String get noActivities => 'Chưa có hoạt động nào';

  @override
  String todayAssignmentsCount(int count) {
    return 'Bài tập hôm nay ($count)';
  }

  @override
  String get submitted => 'Đã nộp';

  @override
  String get overdue => 'Đã quá hạn';

  @override
  String get notSubmitted => 'Chưa nộp';

  @override
  String get deadline => 'Hạn';

  @override
  String get justNow => 'Vừa xong';

  @override
  String minutesAgo(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours giờ trước';
  }

  @override
  String daysAgo(int days) {
    return '$days ngày trước';
  }

  @override
  String get managedClasses => 'Lớp phụ trách';

  @override
  String get students => 'Học sinh';

  @override
  String get pendingGrading => 'Bài tập chờ chấm';

  @override
  String get todayClasses => 'Tiết học hôm nay';

  @override
  String get quickActions => 'Thao tác nhanh';

  @override
  String get createExercise => 'Tạo bài tập';

  @override
  String get takeAttendance => 'Điểm danh';

  @override
  String todaySchedule(int count) {
    return 'Lịch dạy hôm nay ($count)';
  }

  @override
  String studentCount(int count) {
    return '$count học sinh';
  }

  @override
  String submissionCount(int count) {
    return '$count bài nộp';
  }

  @override
  String get createExerciseFeatureInDevelopment =>
      'Chức năng tạo bài tập đang được phát triển';

  @override
  String get takeAttendanceFeatureInDevelopment =>
      'Chức năng điểm danh đang được phát triển';

  @override
  String get classNotUpdated => 'Chưa cập nhật lớp';

  @override
  String get schoolNotUpdated => 'Chưa cập nhật trường';

  @override
  String get tutorClasses => 'lớp gia sư';

  @override
  String get createdClasses => 'lớp đã tạo';

  @override
  String classCreatedSuccess(String className) {
    return 'Đã tạo lớp \"$className\" thành công!';
  }

  @override
  String get schoolSubjects => 'Môn học trường';

  @override
  String get tutorClassesTab => 'Lớp gia sư';

  @override
  String get schedule => 'Lịch học';

  @override
  String get classInfo => 'Thông tin lớp:';

  @override
  String get schoolInfo => 'Trường';

  @override
  String get subjects => 'môn học';

  @override
  String get createNewClass => 'Tạo lớp học mới';

  @override
  String get subject => 'Môn học';

  @override
  String get gradeLevel => 'Lớp';

  @override
  String get teacherName => 'Giáo viên';

  @override
  String get scheduleLabel => 'Lịch học:';

  @override
  String get location => 'Địa chỉ';

  @override
  String get todayAttendance => 'Điểm danh hôm nay';

  @override
  String get date => 'Ngày';

  @override
  String get attendanceHistory => 'Lịch sử điểm danh';

  @override
  String get noHistory => 'Chưa có lịch sử';

  @override
  String get present => 'Có mặt';

  @override
  String get classAttendance => 'Điểm danh lớp học';

  @override
  String get email => 'Email';

  @override
  String get saveAttendance => 'Lưu điểm danh';

  @override
  String get createClass => 'Tạo lớp học mới';

  @override
  String get basicInfo => 'Thông tin cơ bản';

  @override
  String get className => 'Tên lớp học *';

  @override
  String get enterClassName => 'Nhập tên lớp học';

  @override
  String get pleaseEnterClassName => 'Vui lòng nhập tên lớp học';

  @override
  String get subjectName => 'Môn học *';

  @override
  String get enterSubject => 'Nhập môn học';

  @override
  String get pleaseEnterSubject => 'Vui lòng nhập môn học';

  @override
  String get extraClass => 'Lớp dạy thêm';

  @override
  String get extraClassHint => 'Ví dụ: Lớp 12, Lớp 10, ...';

  @override
  String get pricePerSession => 'Giá tiền cho 1 buổi học (VNĐ)';

  @override
  String get priceHint => 'Ví dụ: 20.000';

  @override
  String get pleaseEnterValidPrice => 'Vui lòng nhập số tiền hợp lệ';

  @override
  String get description => 'Mô tả';

  @override
  String get descriptionHint => 'Mô tả chi tiết về bài tập...';

  @override
  String get locationLabel => 'Địa điểm';

  @override
  String get locationHint => 'Nhập địa điểm học';

  @override
  String get maxStudents => 'Số học viên tối đa';

  @override
  String get maxStudentsHint => 'Nhập số học viên tối đa';

  @override
  String get pleaseEnterValidNumber => 'Vui lòng nhập số hợp lệ';

  @override
  String get addSchedule => 'Thêm lịch học';

  @override
  String scheduleNumber(int number) {
    return 'Lịch học $number';
  }

  @override
  String get enterClassCode => 'Nhập mã lớp';

  @override
  String get enterClassCodeDescription =>
      'Nhập mã lớp do giáo viên cung cấp để tham gia lớp học chính khóa.';

  @override
  String get joinClass => 'Tham gia lớp học';

  @override
  String get noSubjectsYet => 'Chưa có môn học nào';

  @override
  String get enterCodeToJoin =>
      'Nhập mã lớp do giáo viên cung cấp để bắt đầu tham gia các môn học chính khóa';

  @override
  String get enterClassCodeButton => 'Nhập mã lớp học';

  @override
  String classesCreated(int count) {
    return '$count lớp học đã tạo';
  }

  @override
  String get noClassesYet => 'Chưa có lớp học nào';

  @override
  String get createFirstClass =>
      'Bạn chưa tạo lớp học chính khóa nào. Tạo lớp học mới để bắt đầu.';

  @override
  String get dataLoadError => 'Lỗi tải dữ liệu';

  @override
  String get retry => 'Thử lại';

  @override
  String get noTutorRegistered => 'Chưa đăng ký lớp gia sư nào';

  @override
  String get noTutorCreated => 'Chưa có lớp gia sư nào';

  @override
  String get findTutorClasses => 'Tìm và đăng ký lớp gia sư phù hợp';

  @override
  String get createFirstTutorClass => 'Tạo lớp gia sư đầu tiên của bạn';

  @override
  String get findTutorButton => 'Tìm lớp gia sư';

  @override
  String get registrationApplications => 'Đơn đăng ký';

  @override
  String get noTeacherIdError =>
      'Không tìm thấy Teacher ID. Vui lòng đăng nhập lại.';

  @override
  String get created => 'Đã tạo';

  @override
  String get joined => 'Đã tham gia lớp';

  @override
  String get teacherLabel => 'GV';

  @override
  String youSelectedClass(String className) {
    return 'Bạn đã chọn lớp $className';
  }

  @override
  String get tutor => 'Gia sư';

  @override
  String get detail => 'Chi tiết';

  @override
  String get classCodeLabel => 'Mã lớp học';

  @override
  String get classCodeHint => 'Ví dụ: 5LG9HA';

  @override
  String get pleaseEnterClassCode => 'Vui lòng nhập mã lớp học';

  @override
  String get joining => 'Đang tham gia...';

  @override
  String get joinSuccess => 'Tham gia lớp học thành công';

  @override
  String get filterByGrade => 'Lọc theo lớp';

  @override
  String get allGrades => 'Tất cả lớp';

  @override
  String get errorPrefix => 'Lỗi';

  @override
  String get registerTutorClass => 'Đăng ký lớp gia sư';

  @override
  String get addressLabel => 'Địa chỉ';

  @override
  String get register => 'Đăng ký';

  @override
  String get noScheduleYet => 'Chưa có lịch học';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String get confirmDeleteMessage =>
      'Bạn có chắc chắn muốn xóa học sinh này khỏi danh sách chờ duyệt?';

  @override
  String get delete => 'Xóa';

  @override
  String get confirmApprove => 'Xác nhận duyệt';

  @override
  String get confirmApproveMessage =>
      'Bạn có chắc chắn muốn duyệt học sinh này vào lớp?';

  @override
  String get approve => 'Duyệt';

  @override
  String get loadingPendingStudents =>
      'Đang tải danh sách học sinh chờ duyệt...';

  @override
  String get noPendingStudents => 'Không có học sinh nào đang chờ duyệt';

  @override
  String get classInfoNotFound => 'Không tìm thấy thông tin lớp học';

  @override
  String get featureInDevelopment => 'Tính năng đang phát triển';

  @override
  String get confirmDeleteClass =>
      'Bạn có chắc chắn muốn xóa lớp học này không?';

  @override
  String deleteClassError(String error) {
    return 'Lỗi khi xóa lớp học: $error';
  }

  @override
  String dayLabel(String day) {
    return '$day';
  }

  @override
  String classTimeLabel(String startTime, String endTime) {
    return 'Giờ học: $startTime - $endTime';
  }

  @override
  String get createClassSuccess => 'Tạo lớp học thành công!';

  @override
  String get addScheduleDialog => 'Thêm lịch học';

  @override
  String get startTime => 'Giờ bắt đầu';

  @override
  String get endTime => 'Giờ kết thúc';

  @override
  String get endTimeMustBeAfterStart => 'Giờ kết thúc phải sau giờ bắt đầu';

  @override
  String get save => 'Lưu';

  @override
  String get attendance => 'Điểm danh';

  @override
  String get noAttendanceHistory => 'Chưa có lịch sử';

  @override
  String get attendanceDialog => 'Điểm danh lớp học';

  @override
  String studentNumber(int number) {
    return 'Học sinh $number';
  }

  @override
  String get idLabel => 'ID';

  @override
  String get emailLabel => 'Email';

  @override
  String get classGrade => 'Lớp';

  @override
  String get descriptionLabel => 'Mô tả (tùy chọn)';

  @override
  String get subjectLabel => 'Môn học';

  @override
  String get studentCount2 => 'Số lượng học sinh';

  @override
  String get createdDate => 'Ngày tạo';

  @override
  String get availableTutorClasses => 'Danh sách lớp gia sư';

  @override
  String get noTutorClassesAvailable => 'Hiện tại chưa có lớp gia sư nào';

  @override
  String get registerSuccess =>
      'Đăng ký lớp thành công! Vui lòng chờ giáo viên duyệt.';

  @override
  String get registerError => 'Lỗi khi đăng ký';

  @override
  String get registering => 'Đang đăng ký...';

  @override
  String get tuitionFee => 'Học phí';

  @override
  String get perSession => 'VNĐ/buổi';

  @override
  String get alreadyRegistered => 'Bạn đã đăng ký lớp này';

  @override
  String confirmRegister(String className) {
    return 'Bạn có muốn đăng ký vào lớp \"$className\"?';
  }

  @override
  String get createClassButton => 'Tạo lớp học';

  @override
  String get classNameRequired => 'Tên lớp học *';

  @override
  String get subjectRequired => 'Môn học *';

  @override
  String get registerToJoin => 'Đăng ký tham gia';

  @override
  String get registering2 => 'Đang đăng ký...';

  @override
  String get waitingForApproval => 'Đang chờ giáo viên duyệt';

  @override
  String get classFull => 'Lớp đã đầy';

  @override
  String get studentsLabel => 'Học sinh';

  @override
  String get spotsAvailable => 'Còn trống';

  @override
  String get tuitionFeeLabel => 'Học phí';

  @override
  String get subjectPrefix => 'Môn học:';

  @override
  String get gradePrefix => 'Lớp:';

  @override
  String get teacherPrefix => 'Giáo viên:';

  @override
  String get schedulePrefix => 'Lịch:';

  @override
  String get addressPrefix => 'Địa chỉ:';

  @override
  String get classDetailInfo => 'Thông tin chi tiết';

  @override
  String get studentCountLabel => 'Số lượng học sinh';

  @override
  String studentCountValue(int current, int max) {
    return '$current/$max học sinh';
  }

  @override
  String get classSchedule => 'Lịch học';

  @override
  String get studentsInClass => 'Học sinh trong lớp';

  @override
  String get noStudentsYet => 'Chưa có học sinh nào';

  @override
  String get noStudentsDescription => 'Lớp học chưa có học sinh nào tham gia';

  @override
  String get errorLoadingClass => 'Lỗi khi tải thông tin lớp học';

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get pendingClasses => 'Danh sách lớp đang chờ duyệt';

  @override
  String get noPendingClasses => 'Không có lớp nào đang chờ duyệt';

  @override
  String confirmRemoveStudent(String studentName) {
    return 'Bạn có chắc chắn muốn xóa học sinh \"$studentName\" khỏi danh sách chờ duyệt?';
  }

  @override
  String studentRemoved(String studentName) {
    return 'Đã xóa học sinh $studentName khỏi danh sách chờ duyệt';
  }

  @override
  String errorRemovingStudent(String error) {
    return 'Lỗi khi xóa học sinh: $error';
  }

  @override
  String confirmApproveStudent(String studentName) {
    return 'Bạn có chắc chắn muốn duyệt học sinh \"$studentName\" vào lớp học?';
  }

  @override
  String studentApproved(String studentName) {
    return 'Đã duyệt học sinh $studentName';
  }

  @override
  String errorApprovingStudent(String error) {
    return 'Lỗi khi duyệt học sinh: $error';
  }

  @override
  String get pendingStudentsTitle => 'Học sinh chờ duyệt';

  @override
  String pendingStudentsCount(int count) {
    return '$count học sinh chờ duyệt';
  }

  @override
  String get approveInstruction =>
      'Nhấn vào nút \"Duyệt\" để xác nhận học sinh vào lớp';

  @override
  String get allStudentsApproved =>
      'Tất cả học sinh đã được duyệt hoặc chưa có ai đăng ký';

  @override
  String get startAttendance => 'Bắt đầu điểm danh';

  @override
  String todayDate(String date) {
    return 'Hôm nay - $date';
  }

  @override
  String get attendanceStarted => 'Đã bắt đầu điểm danh';

  @override
  String errorStartingAttendance(String error) {
    return 'Lỗi khi bắt đầu điểm danh: $error';
  }

  @override
  String get absent => 'Vắng mặt';

  @override
  String get attendanceSaved => 'Đã lưu điểm danh thành công';

  @override
  String errorSavingAttendance(String error) {
    return 'Lỗi khi lưu điểm danh: $error';
  }

  @override
  String get essayExercise => 'Bài tập tự luận';

  @override
  String get submitExercise => 'Nộp bài';

  @override
  String get submitting => 'Đang nộp...';

  @override
  String get pleaseAnswerAllQuestions => 'Vui lòng trả lời tất cả câu hỏi';

  @override
  String get mcqSummaryTitle => 'Bài làm trắc nghiệm';

  @override
  String submitSuccessScore(String score, String max) {
    return 'Nộp bài thành công! Điểm: $score/$max';
  }

  @override
  String submitError(String error) {
    return 'Lỗi nộp bài: $error';
  }

  @override
  String get enterContentOrFile => 'Vui lòng nhập nội dung hoặc chọn tệp.';

  @override
  String get enterValidGrade => 'Vui lòng nhập điểm hợp lệ';

  @override
  String gradeRange(String max) {
    return 'Điểm phải nằm trong khoảng 0 - $max';
  }

  @override
  String downloaded(String fileName) {
    return 'Đã tải xuống: $fileName';
  }

  @override
  String fileDownloadError(String error) {
    return 'Lỗi tải tệp: $error';
  }

  @override
  String get submissionsListTitle => 'Danh sách học sinh đã nộp';

  @override
  String get noSubmissionsYet => 'Chưa có học sinh nào nộp';

  @override
  String get unknown => 'Không rõ';

  @override
  String get unknownTime => 'Không rõ thời gian';

  @override
  String get essay => 'Tự luận';

  @override
  String get multipleChoice => 'Trắc nghiệm';

  @override
  String timeLeftDays(int days) {
    return 'Còn $days ngày';
  }

  @override
  String timeLeftHours(int hours) {
    return 'Còn $hours giờ';
  }

  @override
  String timeLeftMinutes(int minutes) {
    return 'Còn $minutes phút';
  }

  @override
  String get noExercises => 'Không có bài tập';

  @override
  String get noQuestionsInMcq => 'Bài tập trắc nghiệm chưa có câu hỏi';

  @override
  String get mcqExercise => 'Làm bài trắc nghiệm';

  @override
  String questionCount(int count) {
    return '$count câu';
  }

  @override
  String questionLabel(int number) {
    return 'Câu $number';
  }

  @override
  String get multipleAnswers => 'Nhiều đáp án';

  @override
  String get enterContentLabel => 'Nhập nội dung';

  @override
  String get contentHint => 'Viết câu trả lời... (có thể để trống nếu nộp tệp)';

  @override
  String get pickFile => 'Chọn tệp';

  @override
  String get submitSuccessMessage => 'Nộp bài thành công';

  @override
  String get manage => 'Quản lý';

  @override
  String get viewResult => 'Xem kết quả';

  @override
  String get viewDetail => 'Xem chi tiết';

  @override
  String get doExercise => 'Làm bài';

  @override
  String get submittedStudentsTitle => 'Danh sách học sinh đã nộp';

  @override
  String get errorLoadingList => 'Lỗi tải danh sách';

  @override
  String get unknownStudent => 'Không rõ';

  @override
  String get scorePrefix => 'Điểm';

  @override
  String get hasFeedback => 'Đã nhận xét';

  @override
  String get notGraded => 'Chưa chấm';

  @override
  String get invalidGrade => 'Vui lòng nhập điểm hợp lệ';

  @override
  String get graded => 'Đã chấm';

  @override
  String get points => 'điểm';

  @override
  String get gradeError => 'Lỗi chấm điểm';

  @override
  String get submittedAt => 'Nộp lúc';

  @override
  String get lateSubmission => 'Nộp muộn';

  @override
  String get submissionContent => 'Đã nộp';

  @override
  String get attachments => 'Tệp đính kèm';

  @override
  String get createdAt => 'Tạo lúc';

  @override
  String yourScore(String score, String max) {
    return 'Điểm của bạn: $score/$max';
  }

  @override
  String get yourSubmissionNotGraded => 'Bài nộp của bạn: Chưa chấm';

  @override
  String get redoExercise => 'Làm lại bài tập';

  @override
  String get redoConfirmationContent =>
      'Bạn có chắc chắn muốn làm lại?\n\nBài nộp trước đó sẽ bị xóa hoàn toàn.';

  @override
  String get submissionNotFound => 'Không tìm thấy bài nộp để xóa';

  @override
  String get deletingOldSubmission => 'Đang xóa bài nộp cũ...';

  @override
  String get fileUpload => 'Nộp file';

  @override
  String get statusClosed => 'Đã đóng';

  @override
  String get statusOpen => 'Đang mở';

  @override
  String get submission => 'Bài nộp';

  @override
  String get upcomingClassTitle => 'Lớp học sắp diễn ra';

  @override
  String get assignmentDueTitle => 'Bài tập sắp hết hạn';

  @override
  String assignmentDueDescription(String title, String hours) {
    return '$title - còn $hours giờ';
  }

  @override
  String get newExerciseCreatedTitle => 'Bài tập vừa tạo';

  @override
  String newExerciseCreatedDescription(String title, String count) {
    return '$title - $count học sinh đã nộp';
  }

  @override
  String get pleaseSelectDueDate => 'Vui lòng chọn hạn nộp bài';

  @override
  String get pleaseAddAtLeastOneQuestion => 'Vui lòng thêm ít nhất một câu hỏi';

  @override
  String get createExerciseSuccess => 'Tạo bài tập thành công!';

  @override
  String get exerciseTitleLabel => 'Tiêu đề bài tập';

  @override
  String get enterExerciseTitle => 'Nhập tiêu đề cho bài tập...';

  @override
  String get subjectHintExamples => 'Toán, Văn, Anh...';

  @override
  String get createExerciseButton => 'Tạo bài tập';

  @override
  String get pleaseEnterTitle => 'Vui lòng nhập tiêu đề';

  @override
  String get positiveIntegerError => 'Phải là số nguyên dương';

  @override
  String get exerciseSettings => 'Cài đặt bài tập';

  @override
  String get all => 'Tất cả';

  @override
  String get manageExercises => 'Quản lý bài tập';

  @override
  String get exerciseDetailTitle => 'Chi tiết bài tập';
}
