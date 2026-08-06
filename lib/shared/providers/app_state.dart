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

class WeeklyInsight {
  final String id;
  final String title;
  final String summary;
  final String interpretation;
  final List<String> actionSuggestions;
  final String periodStartDate;
  final String periodEndDate;

  const WeeklyInsight({
    required this.id,
    required this.title,
    required this.summary,
    required this.interpretation,
    required this.actionSuggestions,
    required this.periodStartDate,
    required this.periodEndDate,
  });
}

class AppState {
  final bool isLoggedIn;
  final BirthInfo? birthInfo;
  final SajuProfile? sajuProfile;
  final List<DailyRecord> dailyRecords;
  final WeeklyInsight? weeklyInsight;

  const AppState({
    this.isLoggedIn = false,
    this.birthInfo,
    this.sajuProfile,
    this.dailyRecords = const [],
    this.weeklyInsight,
  });

  AppState copyWith({
    bool? isLoggedIn,
    BirthInfo? birthInfo,
    SajuProfile? sajuProfile,
    List<DailyRecord>? dailyRecords,
    WeeklyInsight? weeklyInsight,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      birthInfo: birthInfo ?? this.birthInfo,
      sajuProfile: sajuProfile ?? this.sajuProfile,
      dailyRecords: dailyRecords ?? this.dailyRecords,
      weeklyInsight: weeklyInsight ?? this.weeklyInsight,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState()) {
    ApiClient.instance.setLogoutCallback(_forceLogout);
    _init();
  }

  final _dio = ApiClient.instance.dio;

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

      try {
        await fetchDailyRecords();
      } on DioException {
        // 기록 로드 실패, 무시
      }

      try {
        await fetchLatestWeeklyInsight();
      } on DioException {
        // 리포트 로드 실패, 무시
      }
    } on DioException {
      // 404 = 아직 생년월일 미등록, isLoggedIn=true birthInfo=null 유지
      // 401 = 인터셉터가 refresh 시도 후 실패 시 _forceLogout 호출
    }
  }

  // 인터셉터에서 refresh 실패 시 호출
  void _forceLogout() {
    AuthService.logout();
    state = const AppState();
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

  Future<void> addDailyRecord(DailyRecord record) async {
    const moodLabels = ['', '우울', '별로', '보통', '좋음', '최고'];
    final response = await _dio.post('/api/daily-reports', data: {
      'reportDate': record.date,
      'mood': moodLabels[record.mood],
      'content': record.content,
    });
    final data = response.data as Map<String, dynamic>;
    final saved = _parseDailyReport(data);
    state = state.copyWith(dailyRecords: [saved, ...state.dailyRecords]);
  }

  Future<void> fetchDailyRecords() async {
    final response = await _dio.get('/api/daily-reports');
    final list = (response.data as List)
        .map((e) => _parseDailyReport(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    state = state.copyWith(dailyRecords: list);
  }

  Future<void> fetchLatestWeeklyInsight() async {
    try {
      final response = await _dio.get('/api/insights/weekly/latest');
      state = state.copyWith(
        weeklyInsight: _parseWeeklyInsight(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      // 404 = 아직 생성된 리포트 없음
      if (e.response?.statusCode == 404) return;
      rethrow;
    }
  }

  Future<void> generateWeeklyInsight() async {
    final response = await _dio.post('/api/insights/weekly/generate');
    state = state.copyWith(
      weeklyInsight: _parseWeeklyInsight(response.data as Map<String, dynamic>),
    );
  }

  WeeklyInsight _parseWeeklyInsight(Map<String, dynamic> data) {
    return WeeklyInsight(
      id: (data['id'] as num).toString(),
      title: data['title'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      interpretation: data['interpretation'] as String? ?? '',
      actionSuggestions: (data['actionSuggestions'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      periodStartDate: data['periodStartDate'] as String? ?? '',
      periodEndDate: data['periodEndDate'] as String? ?? '',
    );
  }

  static const _moodMap = {
    '우울': 1, '별로': 2, '보통': 3, '좋음': 4, '최고': 5,
  };

  DailyRecord _parseDailyReport(Map<String, dynamic> data) {
    return DailyRecord(
      id: (data['id'] as num).toString(),
      date: data['reportDate'] as String,
      mood: _moodMap[data['mood']] ?? 3,
      energy: 0,
      content: data['content'] as String? ?? '',
      tags: const [],
    );
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>(
  (_) => AppNotifier(),
);
