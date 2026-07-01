import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungyul_app/core/network/api_client.dart';

/// 순서대로 응답을 반환하는 테스트용 HTTP 어댑터.
/// enqueue() 순서대로 응답이 소비된다.
class _SequentialAdapter implements HttpClientAdapter {
  final _queue = <ResponseBody>[];

  void enqueue(int statusCode, dynamic data) {
    _queue.add(
      ResponseBody.fromString(
        jsonEncode(data),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  int get remaining => _queue.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    if (_queue.isEmpty) {
      throw StateError(
        '등록된 mock 응답이 없습니다. '
        '경로: ${options.method} ${options.path}',
      );
    }
    return _queue.removeAt(0);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio mainDio;
  late Dio authDio;
  late _SequentialAdapter mainAdapter;
  late _SequentialAdapter authAdapter;
  late ApiClient client;
  late List<String> logoutCalls;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    mainDio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    authDio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    mainAdapter = _SequentialAdapter();
    authAdapter = _SequentialAdapter();
    mainDio.httpClientAdapter = mainAdapter;
    authDio.httpClientAdapter = authAdapter;

    client = ApiClient.forTest(dio: mainDio, testAuthDio: authDio);
    logoutCalls = [];
    client.setLogoutCallback(() => logoutCalls.add('logout'));
  });

  group('ApiClient 자동 토큰 갱신', () {
    test('정상 요청은 200 응답을 그대로 반환한다', () async {
      SharedPreferences.setMockInitialValues({'access_token': 'valid-token'});
      mainAdapter.enqueue(200, {'ok': true});

      final response = await client.dio.get('/api/data');

      expect(response.statusCode, 200);
      expect(response.data, {'ok': true});
      expect(logoutCalls, isEmpty);
    });

    test('401 → refresh 성공 → 원래 요청 재시도 후 200 반환', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'expired-token',
        'refresh_token': 'valid-refresh',
      });

      mainAdapter.enqueue(401, {'message': 'unauthorized'}); // 첫 요청
      authAdapter.enqueue(200, {'accessToken': 'new-token'}); // refresh
      mainAdapter.enqueue(200, {'data': 'ok'}); // 재시도

      final response = await client.dio.get('/api/data');

      expect(response.statusCode, 200);
      expect(logoutCalls, isEmpty);
    });

    test('401 → refresh 성공 → 새 access_token을 SharedPreferences에 저장한다', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'expired-token',
        'refresh_token': 'valid-refresh',
      });

      mainAdapter.enqueue(401, {'message': 'unauthorized'});
      authAdapter.enqueue(200, {'accessToken': 'new-saved-token'});
      mainAdapter.enqueue(200, {});

      await client.dio.get('/api/data');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('access_token'), 'new-saved-token');
    });

    test('401 → refresh_token이 없으면 logout을 호출하고 예외를 전파한다', () async {
      SharedPreferences.setMockInitialValues({'access_token': 'expired-token'});
      // refresh_token 미등록

      mainAdapter.enqueue(401, {'message': 'unauthorized'});

      await expectLater(
        client.dio.get('/api/data'),
        throwsA(isA<DioException>()),
      );
      expect(logoutCalls, ['logout']);
    });

    test('401 → refresh 서버 오류(401) → logout을 호출하고 예외를 전파한다', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'expired-token',
        'refresh_token': 'expired-refresh',
      });

      mainAdapter.enqueue(401, {'message': 'unauthorized'});
      authAdapter.enqueue(401, {'message': 'refresh token expired'});

      await expectLater(
        client.dio.get('/api/data'),
        throwsA(isA<DioException>()),
      );
      expect(logoutCalls, ['logout']);
    });

    test('401이 아닌 에러(404)는 logout 없이 그대로 전파된다', () async {
      SharedPreferences.setMockInitialValues({'access_token': 'valid-token'});
      mainAdapter.enqueue(404, {'message': 'not found'});

      DioException? caught;
      try {
        await client.dio.get('/api/data');
      } on DioException catch (e) {
        caught = e;
      }

      expect(caught?.response?.statusCode, 404);
      expect(logoutCalls, isEmpty);
    });

    test('동시 401 두 요청 → refresh는 한 번만, 두 요청 모두 재시도 성공', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'expired-token',
        'refresh_token': 'valid-refresh',
      });

      // 두 요청 각각 401 → refresh 1회 → 두 재시도 각각 200
      mainAdapter.enqueue(401, {'message': 'unauthorized'}); // 요청A 401
      mainAdapter.enqueue(401, {'message': 'unauthorized'}); // 요청B 401
      authAdapter.enqueue(200, {'accessToken': 'new-token'}); // refresh 1회
      mainAdapter.enqueue(200, {'data': 'A'}); // 요청A 재시도
      mainAdapter.enqueue(200, {'data': 'B'}); // 요청B 재시도

      final results = await Future.wait([
        client.dio.get('/api/data'),
        client.dio.get('/api/data'),
      ]);

      expect(results[0].statusCode, 200);
      expect(results[1].statusCode, 200);
      // refresh가 정확히 1번만 호출됐는지 — authAdapter 소비량으로 확인
      expect(authAdapter.remaining, 0);
      expect(logoutCalls, isEmpty);
    });
  });
}
