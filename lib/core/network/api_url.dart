class ApiUrl {
  static const baseURL = 'http://10.0.2.2:3001/api/';
  // static const baseURL = 'http://localhost:3001/api/';

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
}
