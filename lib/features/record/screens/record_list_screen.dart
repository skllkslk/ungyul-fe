import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/app_card.dart';

class RecordListScreen extends ConsumerWidget {
  const RecordListScreen({super.key});

  static const _moodEmojis = ['😔', '😕', '😐', '🙂', '😊'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(appProvider).dailyRecords;

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
                  const Text('기록 목록',
                      style: TextStyle(
                          color: AppColors.foreground,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: records.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📝', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 16),
                          Text('아직 기록이 없습니다',
                              style: TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('오늘 하루를 기록해보세요',
                              style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                      itemCount: records.length,
                      itemBuilder: (context, i) {
                        final record = records[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('yyyy년 M월 d일 (EEE)', 'ko')
                                          .format(DateTime.parse(record.date)),
                                      style: const TextStyle(
                                          color: AppColors.mutedForeground, fontSize: 12),
                                    ),
                                    Row(
                                      children: [
                                        Text(_moodEmojis[record.mood - 1],
                                            style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Text('에너지 ${record.energy}/5',
                                            style: const TextStyle(
                                                color: AppColors.mutedForeground, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  record.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.foreground, fontSize: 14, height: 1.5),
                                ),
                                if (record.tags.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    children: record.tags
                                        .take(3)
                                        .map((tag) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text('#$tag',
                                                  style: const TextStyle(
                                                      color: AppColors.mutedForeground,
                                                      fontSize: 12)),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
