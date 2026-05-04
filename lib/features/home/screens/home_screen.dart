import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/app_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final todayRecord = state.dailyRecords.where((r) => r.date == todayStr).firstOrNull;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Greeting(name: state.birthInfo?.name ?? '사용자', today: today),
                  const SizedBox(height: 24),
                  _FortuneCard(),
                  const SizedBox(height: 16),
                  _TodayRecordCard(todayRecord: todayRecord, onTap: () => context.go('/home/daily-record')),
                  const SizedBox(height: 16),
                  _WeeklySummary(records: state.dailyRecords, onDetail: () => context.go('/home/weekly-report')),
                  const SizedBox(height: 16),
                  _RecentRecords(records: state.dailyRecords, onMore: () => context.go('/home/record-list')),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 24,
              right: 24,
              child: _BottomNav(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String name;
  final DateTime today;

  const _Greeting({required this.name, required this.today});

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatted, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
        const SizedBox(height: 4),
        Text('안녕하세요, $name님',
            style: const TextStyle(
                color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _FortuneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.accent.withValues(alpha: 0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('오늘의 운세',
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('✨ 창의력이 빛나는 날',
                      style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('목(木)',
                    style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '오늘은 새로운 아이디어가 떠오르기 좋은 날입니다. 직감을 믿고 행동하세요.',
            style: TextStyle(color: AppColors.foreground, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.chart1,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('행운색: 황금색',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              const SizedBox(width: 24),
              const Text('7',
                  style: TextStyle(
                      color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Text('행운의 숫자',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayRecordCard extends StatelessWidget {
  final DailyRecord? todayRecord;
  final VoidCallback onTap;

  const _TodayRecordCard({this.todayRecord, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: todayRecord != null
                  ? AppColors.chart2.withValues(alpha: 0.2)
                  : AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: todayRecord != null
                  ? const Text('✓', style: TextStyle(fontSize: 20, color: AppColors.chart2))
                  : const Icon(Icons.add, color: AppColors.mutedForeground),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todayRecord != null ? '오늘의 기록 완료' : '오늘의 기록',
                  style: const TextStyle(
                      color: AppColors.foreground, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  todayRecord != null ? '기록을 수정하려면 탭하세요' : '하루를 기록해보세요',
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

class _WeeklySummary extends StatelessWidget {
  final List<DailyRecord> records;
  final VoidCallback onDetail;

  const _WeeklySummary({required this.records, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    final avgMood = records.isEmpty ? 0.0 : records.map((r) => r.mood).reduce((a, b) => a + b) / records.length;
    final avgEnergy = records.isEmpty ? 0.0 : records.map((r) => r.energy).reduce((a, b) => a + b) / records.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('이번 주 요약',
                style: TextStyle(
                    color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 16)),
            GestureDetector(
              onTap: onDetail,
              child: const Text('자세히 보기',
                  style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(label: '평균 기분', value: avgMood.toStringAsFixed(1)),
            const SizedBox(width: 10),
            _StatCard(label: '평균 에너지', value: avgEnergy.toStringAsFixed(1)),
            const SizedBox(width: 10),
            _StatCard(label: '총 기록', value: records.length.toString()),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppColors.foreground, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _RecentRecords extends StatelessWidget {
  final List<DailyRecord> records;
  final VoidCallback onMore;

  const _RecentRecords({required this.records, required this.onMore});

  static const _moodEmojis = ['😔', '😕', '😐', '🙂', '😊'];

  @override
  Widget build(BuildContext context) {
    final recent = records.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('최근 기록',
                style: TextStyle(
                    color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 16)),
            GestureDetector(
              onTap: onMore,
              child: const Text('전체 보기',
                  style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('기록이 없습니다',
                  style: TextStyle(color: AppColors.mutedForeground)),
            ),
          )
        else
          ...recent.map((record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('M월 d일 (EEE)', 'ko').format(DateTime.parse(record.date)),
                            style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                          ),
                          Text(_moodEmojis[record.mood - 1], style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.foreground, fontSize: 14, height: 1.5),
                      ),
                      if (record.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: record.tags.take(3).map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('#$tag',
                                    style: const TextStyle(
                                        color: AppColors.mutedForeground, fontSize: 12)),
                              )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

class _BottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home, label: '홈', active: true, onTap: () => context.go('/home')),
          _NavItem(icon: Icons.folder_outlined, label: '기록', onTap: () => context.go('/home/record-list')),
          _NavAddButton(onTap: () => context.go('/home/daily-record')),
          _NavItem(icon: Icons.bar_chart, label: '리포트', onTap: () => context.go('/home/weekly-report')),
          _NavItem(icon: Icons.person_outline, label: '내정보', onTap: () => context.go('/home/settings')),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.mutedForeground, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: active ? AppColors.primary : AppColors.mutedForeground, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _NavAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NavAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          const Text('기록하기',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
        ],
      ),
    );
  }
}
