import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/birth/screens/birth_info_screen.dart';
import '../../features/profile/screens/profile_result_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/record/screens/daily_record_screen.dart';
import '../../features/record/screens/record_list_screen.dart';
import '../../features/report/screens/weekly_report_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../shared/providers/app_state.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final appState = ref.watch(appProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = appState.isLoggedIn;
      final hasBirthInfo = appState.birthInfo != null;
      final path = state.uri.path;

      if (!isLoggedIn && path != '/login') return '/login';
      if (isLoggedIn && !hasBirthInfo && path != '/birth-info') return '/birth-info';
      if (isLoggedIn && hasBirthInfo && (path == '/login' || path == '/birth-info')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/birth-info', builder: (_, __) => const BirthInfoScreen()),
      GoRoute(path: '/profile-result', builder: (_, __) => const ProfileResultScreen()),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(path: 'daily-record', builder: (_, __) => const DailyRecordScreen()),
          GoRoute(path: 'record-list', builder: (_, __) => const RecordListScreen()),
          GoRoute(path: 'weekly-report', builder: (_, __) => const WeeklyReportScreen()),
          GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
