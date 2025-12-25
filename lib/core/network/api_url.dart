class ApiUrl {
  static const baseURL = 'http://10.0.2.2:3001/api/';
  // static const baseURL = 'http://localhost:3001/api/';
  //   static const baseURL = 'https://be-edusync.onrender.com/api/';

  // Auth endpoints
  static const login = 'auth/login';
  static const register = 'auth/register';
  static const logout = 'auth/logout';
  static const refreshToken = 'auth/refresh-token';

  // User endpoints
  static const getUserProfile = 'users/me';
  static const updateUserProfile = 'users/me/update';
  static const updateAvatar = 'users/me/avatar';

  // Class endpoints
  static const createClass = 'classes/createclass';
  static const getListClasses = 'classes/getallclasses';
  static const getClassDetails = 'classes/getclass';
  // lớp học học sinh đã đăng ký thành công
  static const getMyRegisteredClasses = 'classes/my-registered-classes';
  // xóa lớp học
  static const deleteClass = 'classes/deleteclass/:id';
  // join class
  static const joinClassStudent = 'classes/joinclass/:id';

  // lớp học học sinh đang chờ duyệt
  static const getMyPendingClasses = 'classes/my-pending-classes';

  // xóa học sinh chờ duyệt
  static const removePendingStudent =
      'classes/:classId/removePendingStudent/:studentId';

  static const getStudentClass = 'classes/getStudentsByClass/:classId';
  static const getPendingStudentClass =
      'classes/:classId/getPendingStudentsByClass';
  static const postApproveStudent =
      'classes/:classId/approveStudent/:studentId';
  // học sinh rời khỏi lớp học
  static const postLeaveClass = 'classes/leave-class/:classId';

  // học sinh tham gia lớp học chính khóa bằng mã lớp
  static const joinRegularClass = 'classes/join-by-code';

  // giáo viên lấy danh sách lớp học do admin tạo
  static const getMyCreatedClasses = 'admin/classes-by-teacher/:teacherId';

  // lịch học endpoints
  static const createSchedule = 'classes/schedules';

  // exercise endpoints
  // tạo bài tập cho lớp học- giáo viên
  static const createExercise = 'exercises/:classId/create';

  // danh sách bài tập của lớp học
  static const getExercisesByClass = 'exercises/:classId/classAssignments';

  // xem chi tiết bài tập
  static const getExerciseDetails = 'exercises/:classId/:exerciseId';

  // nộp bài tập - học sinh
  static const submitExercise = 'exercises/:classId/:exerciseId/student_Submit';

  // danh sách học sinh đã nộp bài tập
  static const getSubmissions = 'exercises/:classId/:exerciseId/submissions';

  // chấm điểm bài nộp
  static const gradeSubmission =
      'exercises/:classId/:exerciseId/submissions/:submissionId/grade';

  // xóa bài nộp (học sinh làm lại / huỷ bài nộp)
  static const deleteSubmission =
      'exercises/:classId/:exerciseId/submissions/:submissionId';

  // danh sách bài tập đã nộp của học sinh
  static const getMySubmissions = 'exercises/my-submissions/all';

  // danh sách bài tập đã được tạo bởi giáo viên
  static const getMyCreatedExercises = 'exercises/teacher/overview';

  // giáo viên bắt đầu điểm danh
  static const takeAttendance = 'attendance/:classId/start';

  // giáo viên điểm danh
  static const markAttendance = 'attendance/:sessionId/mark';

  // lịch sử điểm danh của lớp học
  static const getAttendanceHistory = 'attendance/:classId/history';
}
