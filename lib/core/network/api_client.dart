import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Android 에뮬레이터: http://10.0.2.2:8080
  // iOS 시뮬레이터: http://localhost:8080
  static const _baseUrl = 'http://10.0.2.2:8080';

  static Dio create() {
    final dio = Dio(BaseOptions(baseUrl: _baseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    return dio;
  }
}
