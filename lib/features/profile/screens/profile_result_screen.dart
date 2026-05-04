import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/app_card.dart';

class ProfileResultScreen extends ConsumerWidget {
  const ProfileResultScreen({super.key});

  static const _pillars = [
    ('년주', AppColors.chart1),
    ('월주', AppColors.chart2),
    ('일주', Color(0xFF6366F1)),
    ('시주', Color(0xFFEC4899)),
  ];

  static const _mockHeavenly = ['甲', '丙', '戊', '庚'];
  static const _mockEarthly = ['子', '午', '辰', '申'];

  static const _personality = [
    '강한 추진력과 창의적인 사고방식을 지니고 있습니다',
    '감수성이 풍부하며 예술적 감각이 뛰어납니다',
    '책임감이 강하고 맡은 일을 끝까지 완수합니다',
  ];
  static const _strengths = [
    '뛰어난 리더십과 문제 해결 능력',
    '직관적인 판단력으로 빠른 결정을 내립니다',
    '주변 사람들에게 긍정적인 에너지를 전달합니다',
  ];
  static const _challenges = [
    '완벽주의 성향으로 스트레스를 받기 쉽습니다',
    '감정 기복을 잘 관리하는 연습이 필요합니다',
    '타인의 의견에 귀 기울이는 자세를 기르세요',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthInfo = ref.watch(appProvider).birthInfo;
    if (birthInfo == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onDone: () => context.go('/home')),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _UserHeader(birthInfo: birthInfo),
                    const SizedBox(height: 24),
                    _SajuPillars(),
                    const SizedBox(height: 16),
                    _MainElement(),
                    const SizedBox(height: 16),
                    _TraitSection(title: '성격 특성', items: _personality, color: AppColors.chart1, symbol: '✦'),
                    const SizedBox(height: 16),
                    _TraitSection(title: '타고난 강점', items: _strengths, color: AppColors.chart2, symbol: '↑'),
                    const SizedBox(height: 16),
                    _TraitSection(title: '성장 포인트', items: _challenges, color: const Color(0xFFEC4899), symbol: '◇'),
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
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Text('사주 팔자',
              style: TextStyle(
                  color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (i) {
              final pillar = ProfileResultScreen._pillars[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                  child: Column(
                    children: [
                      Text(pillar.$1,
                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: pillar.$2.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            ProfileResultScreen._mockHeavenly[i],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
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
                          child: Text(
                            ProfileResultScreen._mockEarthly[i],
                            style: const TextStyle(
                                color: AppColors.foreground,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
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
            child: const Center(
              child: Text('목',
                  style: TextStyle(
                      color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('목(木)', style: TextStyle(color: AppColors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('당신의 핵심 기운입니다',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TraitSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  final String symbol;

  const _TraitSection({
    required this.title,
    required this.items,
    required this.color,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(symbol,
                            style: TextStyle(color: color, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              color: AppColors.foreground, fontSize: 14, height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
