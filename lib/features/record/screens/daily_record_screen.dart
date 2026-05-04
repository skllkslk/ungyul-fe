import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';

class DailyRecordScreen extends ConsumerStatefulWidget {
  const DailyRecordScreen({super.key});

  @override
  ConsumerState<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends ConsumerState<DailyRecordScreen> {
  int _mood = 3;
  int _energy = 3;
  final _contentController = TextEditingController();
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  static const _moodEmojis = [
    ('😔', '우울'), ('😕', '별로'), ('😐', '보통'), ('🙂', '좋음'), ('😊', '최고'),
  ];
  static const _energyLabels = ['방전', '낮음', '보통', '충전', '풀충전'];
  static const _suggestedTags = ['업무', '운동', '독서', '여행', '가족', '친구', '휴식', '공부', '취미', '건강'];

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final t = tag.trim();
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() => _tags.add(t));
      _tagController.clear();
    }
  }

  void _submit() {
    if (_contentController.text.trim().isEmpty) return;
    ref.read(appProvider.notifier).addDailyRecord(DailyRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          mood: _mood,
          energy: _energy,
          content: _contentController.text.trim(),
          tags: List.from(_tags),
        ));
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onClose: () => context.go('/home'),
              canSave: _contentController.text.trim().isNotEmpty,
              onSave: _submit,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(DateTime.now()),
                style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MoodSelector(mood: _mood, onChanged: (v) => setState(() => _mood = v)),
                    const SizedBox(height: 28),
                    _EnergySelector(energy: _energy, onChanged: (v) => setState(() => _energy = v)),
                    const SizedBox(height: 28),
                    _ContentInput(controller: _contentController, onChanged: (_) => setState(() {})),
                    const SizedBox(height: 28),
                    _TagInput(
                      tags: _tags,
                      controller: _tagController,
                      suggestedTags: _suggestedTags,
                      onAdd: _addTag,
                      onRemove: (t) => setState(() => _tags.remove(t)),
                    ),
                    const SizedBox(height: 40),
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

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  final bool canSave;
  final VoidCallback onSave;

  const _Header({required this.onClose, required this.canSave, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close, color: AppColors.foreground, size: 20),
            ),
          ),
          const Text('오늘의 기록',
              style: TextStyle(color: AppColors.foreground, fontSize: 17, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: canSave ? onSave : null,
            child: Text('저장',
                style: TextStyle(
                    color: canSave ? AppColors.primary : AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  final int mood;
  final ValueChanged<int> onChanged;

  const _MoodSelector({required this.mood, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('오늘 기분은 어땠나요?',
            style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final selected = mood == i + 1;
            return GestureDetector(
              onTap: () => onChanged(i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(_DailyRecordScreenState._moodEmojis[i].$1,
                        style: TextStyle(fontSize: selected ? 28 : 24)),
                    const SizedBox(height: 4),
                    Text(_DailyRecordScreenState._moodEmojis[i].$2,
                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _EnergySelector extends StatelessWidget {
  final int energy;
  final ValueChanged<int> onChanged;

  const _EnergySelector({required this.energy, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('에너지 레벨은요?',
            style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final selected = energy == i + 1;
            final fillFraction = (i + 1) / 5;
            return GestureDetector(
              onTap: () => onChanged(i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 36,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.mutedForeground),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 36 * fillFraction,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.chart2,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_DailyRecordScreenState._energyLabels[i],
                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ContentInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ContentInput({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('오늘 하루를 기록해보세요',
            style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 6,
          style: const TextStyle(color: AppColors.foreground, fontSize: 14, height: 1.6),
          decoration: const InputDecoration(
            hintText: '오늘 있었던 일, 느낀 감정, 감사한 일 등을 자유롭게 적어보세요...',
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${controller.text.length}자',
              style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
        ),
      ],
    );
  }
}

class _TagInput extends StatelessWidget {
  final List<String> tags;
  final TextEditingController controller;
  final List<String> suggestedTags;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _TagInput({
    required this.tags,
    required this.controller,
    required this.suggestedTags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('태그 추가',
            style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 12),
        if (tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => GestureDetector(
                  onTap: () => onRemove(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('#$tag',
                            style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                        const SizedBox(width: 6),
                        const Icon(Icons.close, color: AppColors.primary, size: 14),
                      ],
                    ),
                  ),
                )).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.foreground),
                decoration: const InputDecoration(hintText: '태그 입력 후 추가'),
                onSubmitted: onAdd,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onAdd(controller.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedTags.map((tag) => GestureDetector(
                onTap: () => onAdd(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('#$tag',
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                ),
              )).toList(),
        ),
      ],
    );
  }
}
