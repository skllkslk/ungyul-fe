import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';

class BirthInfoScreen extends ConsumerStatefulWidget {
  const BirthInfoScreen({super.key});

  @override
  ConsumerState<BirthInfoScreen> createState() => _BirthInfoScreenState();
}

class _BirthInfoScreenState extends ConsumerState<BirthInfoScreen> {
  int _step = 1;
  String _name = '';
  String _gender = '';
  DateTime? _birthDate;
  String _birthTime = '';
  bool _lunarCalendar = false;

  static const _timeSlots = [
    ('23:00-01:00', '자시 (子時)', '23:00 ~ 01:00'),
    ('01:00-03:00', '축시 (丑時)', '01:00 ~ 03:00'),
    ('03:00-05:00', '인시 (寅時)', '03:00 ~ 05:00'),
    ('05:00-07:00', '묘시 (卯時)', '05:00 ~ 07:00'),
    ('07:00-09:00', '진시 (辰時)', '07:00 ~ 09:00'),
    ('09:00-11:00', '사시 (巳時)', '09:00 ~ 11:00'),
    ('11:00-13:00', '오시 (午時)', '11:00 ~ 13:00'),
    ('13:00-15:00', '미시 (未時)', '13:00 ~ 15:00'),
    ('15:00-17:00', '신시 (申時)', '15:00 ~ 17:00'),
    ('17:00-19:00', '유시 (酉時)', '17:00 ~ 19:00'),
    ('19:00-21:00', '술시 (戌時)', '19:00 ~ 21:00'),
    ('21:00-23:00', '해시 (亥時)', '21:00 ~ 23:00'),
    ('unknown', '모름', '정확한 시간을 모름'),
  ];

  bool get _canProceed {
    if (_step == 1) return _name.length >= 2;
    if (_step == 2) return _gender.isNotEmpty;
    if (_step == 3) return _birthDate != null;
    if (_step == 4) return _birthTime.isNotEmpty;
    return false;
  }

  void _onBack() {
    if (_step > 1) {
      setState(() => _step--);
    } else {
      context.go('/login');
    }
  }

  void _onNext() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _submit() {
    final date = _birthDate!;
    ref.read(appProvider.notifier).setBirthInfo(BirthInfo(
          name: _name,
          birthDate:
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          birthTime: _birthTime,
          gender: _gender,
          lunarCalendar: _lunarCalendar,
        ));
    context.go('/profile-result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(step: _step, onBack: _onBack),
            _ProgressBar(step: _step),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStep(),
              ),
            ),
            _NextButton(
              enabled: _canProceed,
              label: _step == 4 ? '완료' : '다음',
              onTap: _canProceed ? _onNext : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return SingleChildScrollView(
      key: ValueKey(_step),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: switch (_step) {
        1 => _StepName(name: _name, onChanged: (v) => setState(() => _name = v)),
        2 => _StepGender(gender: _gender, onChanged: (v) => setState(() => _gender = v)),
        3 => _StepBirthDate(
            date: _birthDate,
            lunarCalendar: _lunarCalendar,
            onDateChanged: (d) => setState(() => _birthDate = d),
            onLunarChanged: (v) => setState(() => _lunarCalendar = v),
          ),
        4 => _StepBirthTime(
            timeSlots: _timeSlots,
            selected: _birthTime,
            onChanged: (v) => setState(() => _birthTime = v),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _Header extends StatelessWidget {
  final int step;
  final VoidCallback onBack;

  const _Header({required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: onBack,
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
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;

  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: i < step ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback? onTap;

  const _NextButton({required this.enabled, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? AppColors.primary : AppColors.secondary,
            foregroundColor: enabled ? Colors.white : AppColors.mutedForeground,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _StepName extends StatelessWidget {
  final String name;
  final ValueChanged<String> onChanged;

  const _StepName({required this.name, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이름을 알려주세요',
            style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('사주 분석에 사용됩니다',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
        const SizedBox(height: 32),
        TextField(
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.foreground, fontSize: 18),
          decoration: const InputDecoration(hintText: '이름 입력'),
          autofocus: true,
        ),
      ],
    );
  }
}

class _StepGender extends StatelessWidget {
  final String gender;
  final ValueChanged<String> onChanged;

  const _StepGender({required this.gender, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('성별을 선택해주세요',
            style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('음양 조화를 파악하기 위해 필요합니다',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
        const SizedBox(height: 32),
        Row(
          children: [
            _GenderCard(
              label: '남성',
              symbol: '♂',
              selected: gender == 'male',
              onTap: () => onChanged('male'),
            ),
            const SizedBox(width: 16),
            _GenderCard(
              label: '여성',
              symbol: '♀',
              selected: gender == 'female',
              onTap: () => onChanged('female'),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String symbol;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.symbol,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(symbol, style: const TextStyle(fontSize: 40, color: AppColors.foreground)),
              const SizedBox(height: 12),
              Text(label,
                  style: const TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBirthDate extends StatelessWidget {
  final DateTime? date;
  final bool lunarCalendar;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<bool> onLunarChanged;

  const _StepBirthDate({
    required this.date,
    required this.lunarCalendar,
    required this.onDateChanged,
    required this.onLunarChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('생년월일을 입력해주세요',
            style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('정확한 사주 분석의 기반이 됩니다',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (picked != null) onDateChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.mutedForeground, size: 20),
                const SizedBox(width: 12),
                Text(
                  date == null
                      ? '날짜를 선택하세요'
                      : '${date!.year}년 ${date!.month}월 ${date!.day}일',
                  style: TextStyle(
                    color: date == null ? AppColors.mutedForeground : AppColors.foreground,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => onLunarChanged(!lunarCalendar),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: lunarCalendar ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: lunarCalendar ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: lunarCalendar
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('음력입니다', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600)),
                    Text('음력으로 입력한 경우 체크해주세요',
                        style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepBirthTime extends StatelessWidget {
  final List<(String, String, String)> timeSlots;
  final String selected;
  final ValueChanged<String> onChanged;

  const _StepBirthTime({
    required this.timeSlots,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('태어난 시간을 선택해주세요',
            style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('시주 분석에 사용됩니다',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
        const SizedBox(height: 24),
        ...timeSlots.map((slot) {
          final isSelected = selected == slot.$1;
          return GestureDetector(
            onTap: () => onChanged(slot.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(slot.$2,
                      style: const TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600)),
                  Text(slot.$3,
                      style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
