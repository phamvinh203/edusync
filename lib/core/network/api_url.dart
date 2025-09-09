class ApiUrl {
  static const baseURL = 'http://10.0.2.2:3001/api/';
  // static const baseURL = 'http://localhost:3001/api/';
  // static const baseURL = 'https://be-edusync.onrender.com';

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
  static const getStudentClass = 'classes/getStudentsByClass/:classId';
  static const getPendingStudentClass =
      'classes/:classId/getPendingStudentsByClass';
  static const postApproveStudent =
      'classes/:classId/approveStudent/:studentId';
}
