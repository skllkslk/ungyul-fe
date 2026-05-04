import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/app_card.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final records = state.dailyRecords;
    final name = state.birthInfo?.name ?? '사용자';

    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    final weekRecords = records.where((r) {
      final d = DateTime.parse(r.date);
      return d.isAfter(weekStart.subtract(const Duration(days: 1))) && d.isBefore(today.add(const Duration(days: 1)));
    }).toList();

    final avgMood = weekRecords.isEmpty
        ? 0.0
        : weekRecords.map((r) => r.mood).reduce((a, b) => a + b) / weekRecords.length;
    final avgEnergy = weekRecords.isEmpty
        ? 0.0
        : weekRecords.map((r) => r.energy).reduce((a, b) => a + b) / weekRecords.length;

    final tagFreq = <String, int>{};
    for (final r in weekRecords) {
      for (final t in r.tags) {
        tagFreq[t] = (tagFreq[t] ?? 0) + 1;
      }
    }
    final topTags = (tagFreq.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();

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
                  const Text('주간 리포트',
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
                    _InterpretationCard(name: name),
                    const SizedBox(height: 16),
                    _StatsRow(avgMood: avgMood, avgEnergy: avgEnergy, count: weekRecords.length),
                    const SizedBox(height: 16),
                    _MoodChart(records: weekRecords),
                    const SizedBox(height: 16),
                    if (topTags.isNotEmpty) _TopTagsCard(tags: topTags),
                    const SizedBox(height: 16),
                    _InsightsCard(),
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

class _InterpretationCard extends StatelessWidget {
  final String name;
  const _InterpretationCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.2),
          AppColors.accent.withValues(alpha: 0.1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이번 주 사주 해석',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
          const SizedBox(height: 8),
          const Text('창의성과 직관력이 빛나는 한 주',
              style: TextStyle(
                  color: AppColors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            '$name님의 목(木) 기운과 이번 주의 운행이 조화를 이루며, 새로운 아이디어와 통찰력이 빛나는 시기입니다.',
            style: const TextStyle(color: AppColors.foreground, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final double avgMood;
  final double avgEnergy;
  final int count;

  const _StatsRow({required this.avgMood, required this.avgEnergy, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(label: '평균 기분', value: avgMood.toStringAsFixed(1)),
        const SizedBox(width: 10),
        _StatBox(label: '평균 에너지', value: avgEnergy.toStringAsFixed(1)),
        const SizedBox(width: 10),
        _StatBox(label: '기록 수', value: count.toString()),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

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
            Text(label, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MoodChart extends StatelessWidget {
  final List<DailyRecord> records;
  const _MoodChart({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return AppCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('이번 주 기록이 없습니다',
                style: TextStyle(color: AppColors.mutedForeground)),
          ),
        ),
      );
    }

    final spots = records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.mood.toDouble());
    }).toList();

    final energySpots = records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.energy.toDouble());
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('기분 & 에너지 트렌드',
              style: TextStyle(
                  color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _Legend(color: AppColors.primary, label: '기분'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.chart2, label: '에너지'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 1,
                maxY: 5,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: energySpots,
                    isCurved: true,
                    color: AppColors.chart2,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.chart2.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
      ],
    );
  }
}

class _TopTagsCard extends StatelessWidget {
  final List<MapEntry<String, int>> tags;
  const _TopTagsCard({required this.tags});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('자주 쓴 태그',
              style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text('#${e.key} ${e.value}',
                      style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                )).toList(),
          ),
        ],
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  static const _insights = [
    ('💡', '직관 활용하기', '이번 주는 논리보다 직감을 믿어보세요. 예상치 못한 좋은 결과가 있을 수 있습니다.'),
    ('🤝', '관계 확장', '새로운 사람들과의 만남이 긍정적인 기회로 이어질 수 있는 시기입니다.'),
    ('⚖️', '균형 유지', '활동적인 에너지와 충분한 휴식 사이의 균형을 유지하는 것이 중요합니다.'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이번 주 인사이트',
              style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._insights.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$2,
                              style: const TextStyle(
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(item.$3,
                              style: const TextStyle(
                                  color: AppColors.mutedForeground, fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
