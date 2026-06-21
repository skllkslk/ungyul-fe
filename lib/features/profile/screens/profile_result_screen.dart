import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/app_card.dart';

class ProfileResultScreen extends ConsumerWidget {
  const ProfileResultScreen({super.key});

  static const _pillarLabels = ['년주', '월주', '일주', '시주'];
  static const _pillarColors = [
    AppColors.chart1,
    AppColors.chart2,
    Color(0xFF6366F1),
    Color(0xFFEC4899),
  ];

  static const _elementMap = {
    '갑': '목', '을': '목',
    '병': '화', '정': '화',
    '무': '토', '기': '토',
    '경': '금', '신': '금',
    '임': '수', '계': '수',
  };

  static const _elementNameMap = {
    '갑': '목(木)', '을': '목(木)',
    '병': '화(火)', '정': '화(火)',
    '무': '토(土)', '기': '토(土)',
    '경': '금(金)', '신': '금(金)',
    '임': '수(水)', '계': '수(水)',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final birthInfo = state.birthInfo;
    final sajuProfile = state.sajuProfile;

    if (birthInfo == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onDone: () => context.go('/home')),
            Expanded(
              child: sajuProfile == null
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _UserHeader(birthInfo: birthInfo),
                          const SizedBox(height: 24),
                          _SajuPillars(sajuRaw: sajuProfile.sajuRaw),
                          const SizedBox(height: 16),
                          _MainElement(
                            dayMaster: sajuProfile.dayMaster,
                            elementChar: _elementMap[sajuProfile.dayMaster] ?? '?',
                            elementName: _elementNameMap[sajuProfile.dayMaster] ?? '',
                          ),
                          const SizedBox(height: 16),
                          _DayMasterCard(description: sajuProfile.dayMasterDescription),
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

class _TopBar extends StatelessWidget {
  final VoidCallback onDone;
  const _TopBar({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('사주 프로필',
              style: TextStyle(color: AppColors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onDone,
            child: const Text('완료',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final BirthInfo birthInfo;
  const _UserHeader({required this.birthInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
          ),
          child: Center(
            child: Text(
              birthInfo.gender == 'male' ? '♂' : '♀',
              style: const TextStyle(fontSize: 32, color: AppColors.foreground),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(birthInfo.name,
            style: const TextStyle(
                color: AppColors.foreground, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          '${birthInfo.birthDate.replaceAll('-', '.')} ${birthInfo.lunarCalendar ? '(음력)' : '(양력)'}',
          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
        ),
      ],
    );
  }
}

class _SajuPillars extends StatelessWidget {
  final Map<String, dynamic> sajuRaw;
  const _SajuPillars({required this.sajuRaw});

  @override
  Widget build(BuildContext context) {
    final pillars = [
      sajuRaw['yearPillar'] as Map<String, dynamic>,
      sajuRaw['monthPillar'] as Map<String, dynamic>,
      sajuRaw['dayPillar'] as Map<String, dynamic>,
      sajuRaw['hourPillar'] as Map<String, dynamic>,
    ];

    return AppCard(
      child: Column(
        children: [
          const Text('사주 팔자',
              style: TextStyle(
                  color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (i) {
              final cheongan = pillars[i]['cheongan'] as String;
              final jiji = pillars[i]['jiji'] as String;
              final color = ProfileResultScreen._pillarColors[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                  child: Column(
                    children: [
                      Text(ProfileResultScreen._pillarLabels[i],
                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(cheongan,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(jiji,
                              style: const TextStyle(
                                  color: AppColors.foreground,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MainElement extends StatelessWidget {
  final String dayMaster;
  final String elementChar;
  final String elementName;

  const _MainElement({
    required this.dayMaster,
    required this.elementChar,
    required this.elementName,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(elementChar,
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(elementName,
                  style: const TextStyle(
                      color: AppColors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('일간 $dayMaster · 당신의 핵심 기운',
                  style: const TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayMasterCard extends StatelessWidget {
  final String description;
  const _DayMasterCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('일간 해석',
              style: TextStyle(
                  color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(description,
              style: const TextStyle(
                  color: AppColors.foreground, fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}
