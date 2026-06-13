import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/services/auth_service.dart';

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
  final List<DailyRecord> dailyRecords;

  const AppState({
    this.isLoggedIn = false,
    this.birthInfo,
    this.dailyRecords = const [],
  });

  AppState copyWith({
    bool? isLoggedIn,
    BirthInfo? birthInfo,
    List<DailyRecord>? dailyRecords,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      birthInfo: birthInfo ?? this.birthInfo,
      dailyRecords: dailyRecords ?? this.dailyRecords,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(const AppState()) {
    _init();
  }

  Future<void> _init() async {
    final loggedIn = await AuthService.hasStoredToken();
    if (loggedIn) state = state.copyWith(isLoggedIn: true);
  }

  Future<void> loginWithGoogle() async {
    await AuthService.googleLogin();
    state = state.copyWith(isLoggedIn: true);
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = const AppState();
  }

  void setBirthInfo(BirthInfo info) => state = state.copyWith(birthInfo: info);

  void addDailyRecord(DailyRecord record) {
    state = state.copyWith(dailyRecords: [record, ...state.dailyRecords]);
  }
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>(
  (_) => AppNotifier(),
);
