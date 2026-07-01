import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));
    authDio = Dio(BaseOptions(baseUrl: _baseUrl));
    _setupInterceptors();
  }

  // 테스트에서 Dio를 직접 주입할 수 있는 생성자
  ApiClient.forTest({required Dio dio, required Dio testAuthDio}) {
    _dio = dio;
    authDio = testAuthDio;
    _setupInterceptors();
  }

  static final ApiClient instance = ApiClient._();

  // Android 에뮬레이터: http://10.0.2.2:8080
  // iOS 시뮬레이터: http://localhost:8080
  static const _baseUrl = 'http://10.0.2.2:8080';

  late final Dio _dio;

  // 인터셉터 없는 Dio — 로그인/로그아웃/토큰갱신 전용
  late final Dio authDio;

  Dio get dio => _dio;

  // 갱신 중이면 Completer가 살아 있음, 완료 시 새 토큰(null이면 실패)
  Completer<String?>? _refreshCompleter;
  void Function()? _onLogout;

  void setLogoutCallback(void Function() callback) {
    _onLogout = callback;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _addAuthHeader,
        onError: _handleTokenExpired,
      ),
    );
  }

  Future<void> _addAuthHeader(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _handleTokenExpired(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode != 401) {
      handler.next(error);
      return;
    }

    // 이미 갱신 중이면 완료를 기다린 후 재시도
    if (_refreshCompleter != null) {
      final newToken = await _refreshCompleter!.future;
      if (newToken != null) {
        error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryResponse = await _dio.fetch(error.requestOptions);
          handler.resolve(retryResponse);
        } catch (e) {
          handler.next(error);
        }
      } else {
        handler.next(error);
      }
      return;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) throw Exception('refresh token 없음');

      final response = await authDio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final newToken = response.data['accessToken'] as String;
      await prefs.setString('access_token', newToken);

      _refreshCompleter!.complete(newToken);

      error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryResponse = await _dio.fetch(error.requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      _refreshCompleter!.complete(null);
      _onLogout?.call();
      handler.next(error);
    } finally {
      _refreshCompleter = null;
    }
  }
}
