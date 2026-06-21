import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/services/auth_service.dart';

class SajuProfile {
  final String dayMaster;
  final String dayMasterDescription;
  final String profileText;
  final Map<String, dynamic> sajuRaw;

  const SajuProfile({
    required this.dayMaster,
    required this.dayMasterDescription,
    required this.profileText,
    required this.sajuRaw,
  });
}

class BirthInfo {
  final String name;
  final String birthDate;
  final String birthTime;
  final String gender;
  final bool lunarCalendar;

  const BirthInfo({
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.gender,
    required this.lunarCalendar,
  });
}

class DailyRecord {
  final String id;
  final String date;
  final int mood;
  final int energy;
  final String content;
  final List<String> tags;

  const DailyRecord({
    required this.id,
    required this.date,
    required this.mood,
    required this.energy,
    required this.content,
    required this.tags,
  });
}

class AppState {
  final bool isLoggedIn;
  final BirthInfo? birthInfo;
  final SajuProfile? sajuProfile;
  final List<DailyRecord> dailyRecords;

  const AppState({
    this.isLoggedIn = false,
    this.birthInfo,
    this.sajuProfile,
    this.dailyRecords = const [],
  });

  AppState copyWith({
    bool? isLoggedIn,
    BirthInfo? birthInfo,
    SajuProfile? sajuProfile,
    List<DailyRecord>? dailyRecords,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      birthInfo: birthInfo ?? this.birthInfo,
      sajuProfile: sajuProfile ?? this.sajuProfile,
      dailyRecords: dailyRecords ?? this.dailyRecords,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState()) {
    _init();
  }

  final _dio = ApiClient.create();

  Future<void> _init() async {
    final hasToken = await AuthService.hasStoredToken();
    if (!hasToken) return;

    state = state.copyWith(isLoggedIn: true);

    try {
      final response = await _dio.get('/api/birth-profile');
      final data = response.data as Map<String, dynamic>;
      state = state.copyWith(
        birthInfo: BirthInfo(
          name: '',
          birthDate: data['birthDate'] as String,
          birthTime: data['birthTime'] as String? ?? 'unknown',
          gender: data['gender'] as String,
          lunarCalendar: data['isLunar'] as bool? ?? false,
        ),
      );

      try {
        final sajuResp = await _dio.get('/api/saju-profile/me');
        state = state.copyWith(
          sajuProfile: _parseSajuProfile(sajuResp.data as Map<String, dynamic>),
        );
      } on DioException {
        // 사주 프로필 없음, 무시
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await AuthService.logout();
        state = const AppState();
      }
      // 404 = 아직 생년월일 미등록, isLoggedIn=true birthInfo=null 유지
    }
  }

  Future<void> loginWithGoogle() async {
    await AuthService.googleLogin();
    state = state.copyWith(isLoggedIn: true);
  }

  Future<void> saveBirthInfo(BirthInfo info) async {
    await _dio.post('/api/birth-profile', data: {
      'birthDate': info.birthDate,
      'birthTime': info.birthTime == 'unknown'
          ? null
          : '${info.birthTime.split('-')[0]}:00',
      'isLunar': info.lunarCalendar,
      'gender': info.gender,
    });
    state = state.copyWith(birthInfo: info);

    final sajuResp = await _dio.post('/api/saju-profile/generate');
    state = state.copyWith(
      sajuProfile: _parseSajuProfile(sajuResp.data as Map<String, dynamic>),
    );
  }

  SajuProfile _parseSajuProfile(Map<String, dynamic> data) {
    final raw = jsonDecode(data['sajuRawJson'] as String) as Map<String, dynamic>;
    return SajuProfile(
      dayMaster: data['dayMaster'] as String,
      dayMasterDescription: raw['dayMasterDescription'] as String? ?? '',
      profileText: data['profileText'] as String,
      sajuRaw: raw,
    );
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = const AppState();
  }

  void addDailyRecord(DailyRecord record) {
    state = state.copyWith(dailyRecords: [record, ...state.dailyRecords]);
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>(
  (_) => AppNotifier(),
);
