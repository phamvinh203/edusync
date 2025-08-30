import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_url.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(printer: PrettyPrinter(methodCount: 0, colors: true,printEmojis: true));

  @override
  void onError( DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath'); //Error log
    logger.d('Error type: ${err.error} \n '
        'Error message: ${err.message}'); //Debug log
    handler.next(err); //Continue with the Error
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath'); //Info log
    handler.next(options); // continue with the Request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('STATUSCODE: ${response.statusCode} \n '
        'STATUSMESSAGE: ${response.statusMessage} \n'
        'HEADERS: ${response.headers} \n'
        'Data: ${response.data}'); // Debug log
    handler.next(response); // continue with the Response
  }
}


class AuthorizationInterceptor extends Interceptor {
  AuthorizationInterceptor(this._dio);

  final Dio _dio;

  // Đảm bảo chỉ refresh một lần tại một thời điểm
  Future<void>? _refreshing;

  bool _isRefreshEndpoint(String path) {
    // path có thể là đầy đủ hoặc tương đối; chỉ cần contains là đủ an toàn
    return path.contains(ApiUrl.refreshToken);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode ?? 0;
    final req = err.requestOptions;

    if (status == 401 && !_isRefreshEndpoint(req.path)) {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        Logger().w('No refresh_token available');
        return handler.next(err);
      }

      // Nếu chưa có tiến trình refresh, tạo mới
      _refreshing ??= _performTokenRefresh(refreshToken);

      try {
        await _refreshing;
      } catch (e) {
        // Refresh thất bại: xoá token và trả về lỗi 401 để UI xử lý
        await prefs.remove('token');
        await prefs.remove('refresh_token');
        _refreshing = null;
        return handler.next(err);
      }

      // Sau khi refresh thành công: retry request với token mới
      _refreshing = null;
      final newToken = prefs.getString('token');
      if (newToken != null && newToken.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $newToken';
      }

      try {
        final response = await _dio.request<dynamic>(
          req.path,
          data: req.data,
          queryParameters: req.queryParameters,
          options: Options(
            method: req.method,
            headers: req.headers,
            responseType: req.responseType,
            contentType: req.contentType,
            sendTimeout: req.sendTimeout,
            receiveTimeout: req.receiveTimeout,
            followRedirects: req.followRedirects,
            validateStatus: req.validateStatus,
          ),
          cancelToken: req.cancelToken,
          onReceiveProgress: req.onReceiveProgress,
          onSendProgress: req.onSendProgress,
        );
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    // Không phải 401 hoặc là chính refresh-token: tiếp tục như cũ
    handler.next(err);
  }

  Future<void> _performTokenRefresh(String refreshToken) async {
    // Dùng Dio riêng để tránh đi vào interceptor (vòng lặp)
    final bare = Dio(BaseOptions(baseUrl: ApiUrl.baseURL, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    }));

    final resp = await bare.post(
      ApiUrl.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final body = resp.data;
    if (body is! Map<String, dynamic>) {
      throw DioException(requestOptions: resp.requestOptions, message: 'Bad refresh response');
    }
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    final newAccess = (data['access_token'] ?? '').toString();
    final newRefresh = (data['refresh_token'] ?? refreshToken).toString();

    if (newAccess.isEmpty) {
      throw DioException(requestOptions: resp.requestOptions, message: 'Empty access_token');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newAccess);
    await prefs.setString('refresh_token', newRefresh);

    // Cập nhật header mặc định của _dio để request sau có token mới
    _dio.options.headers['Authorization'] = 'Bearer $newAccess';
  }
}