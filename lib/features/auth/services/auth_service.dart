import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  static final _googleSignIn = GoogleSignIn(
    serverClientId:
        '996627141162-l37vqf212astp5d16t19m68q171kap1p.apps.googleusercontent.com',
  );
  static final _dio = ApiClient.create();

  static Future<void> googleLogin() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google 로그인이 취소되었습니다');

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('Google 인증 토큰을 가져올 수 없습니다');

    final response = await _dio.post(
      '/api/auth/google',
      data: {'idToken': idToken},
    );
    final data = response.data as Map<String, dynamic>;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['accessToken'] as String);
    await prefs.setString('refresh_token', data['refreshToken'] as String);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken != null) {
      try {
        await _dio.post('/api/auth/logout', data: {'refreshToken': refreshToken});
      } catch (_) {}
    }

    await _googleSignIn.signOut();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static Future<bool> hasStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }
}
