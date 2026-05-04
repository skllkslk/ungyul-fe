import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final birthInfo = state.birthInfo;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.chevron_left, color: AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('내 정보',
                      style: TextStyle(
                          color: AppColors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                child: Column(
                  children: [
                    _ProfileCard(birthInfo: birthInfo),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: '앱 설정',
                      items: const [
                        _SettingsItem(icon: Icons.notifications_outlined, label: '알림 설정'),
                        _SettingsItem(icon: Icons.dark_mode_outlined, label: '테마'),
                        _SettingsItem(icon: Icons.language, label: '언어'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: '계정',
                      items: const [
                        _SettingsItem(icon: Icons.lock_outline, label: '개인정보 처리방침'),
                        _SettingsItem(icon: Icons.description_outlined, label: '이용약관'),
                        _SettingsItem(icon: Icons.help_outline, label: '고객센터'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      onTap: () {
                        ref.read(appProvider.notifier).logout();
                        context.go('/login');
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                          SizedBox(width: 8),
                          Text('로그아웃',
                              style: TextStyle(
                                  color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final BirthInfo? birthInfo;
  const _ProfileCard({this.birthInfo});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                birthInfo?.gender == 'male' ? '♂' : '♀',
                style: const TextStyle(fontSize: 28, color: AppColors.foreground),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  birthInfo?.name ?? '사용자',
                  style: const TextStyle(
                      color: AppColors.foreground, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  birthInfo != null
                      ? '${birthInfo!.birthDate.replaceAll('-', '.')} ${birthInfo!.lunarCalendar ? '(음력)' : '(양력)'}'
                      : '',
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title,
              style: const TextStyle(
                  color: AppColors.mutedForeground, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(e.value.icon, color: AppColors.mutedForeground, size: 20),
                        const SizedBox(width: 14),
                        Text(e.value.label,
                            style: const TextStyle(color: AppColors.foreground, fontSize: 15)),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: AppColors.mutedForeground, size: 18),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(color: AppColors.border, height: 1, indent: 54),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  const _SettingsItem({required this.icon, required this.label});
}
