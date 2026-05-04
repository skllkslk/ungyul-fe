import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/star_background.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(),
                _Logo(),
                const Spacer(),
                _SocialButtons(ref: ref),
                const SizedBox(height: 24),
                _TermsText(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Center(child: Text('☯', style: TextStyle(fontSize: 40))),
        ),
        const SizedBox(height: 24),
        const Text(
          '운명일기',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '사주로 읽는 나의 하루\n매일의 기록이 운명의 흐름이 됩니다',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.mutedForeground,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  final WidgetRef ref;
  const _SocialButtons({required this.ref});

  void _handleLogin(BuildContext context, String provider) {
    ref.read(appProvider.notifier).login();
    context.go('/birth-info');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          label: '카카오로 시작하기',
          backgroundColor: const Color(0xFFFEE500),
          textColor: const Color(0xFF191919),
          icon: '💬',
          onTap: () => _handleLogin(context, 'kakao'),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: '네이버로 시작하기',
          backgroundColor: const Color(0xFF03C75A),
          textColor: Colors.white,
          icon: 'N',
          isText: true,
          onTap: () => _handleLogin(context, 'naver'),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: 'Apple로 시작하기',
          backgroundColor: AppColors.foreground,
          textColor: AppColors.background,
          icon: '',
          onTap: () => _handleLogin(context, 'apple'),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: '이메일로 시작하기',
          backgroundColor: AppColors.secondary,
          textColor: AppColors.foreground,
          icon: '✉',
          onTap: () => _handleLogin(context, 'email'),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final String icon;
  final bool isText;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onTap,
    this.isText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isText
                ? Text(icon, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))
                : Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
        children: [
          TextSpan(text: '시작하기를 누르면 '),
          TextSpan(text: '이용약관', style: TextStyle(decoration: TextDecoration.underline)),
          TextSpan(text: ' 및 '),
          TextSpan(text: '개인정보처리방침', style: TextStyle(decoration: TextDecoration.underline)),
          TextSpan(text: '에 동의합니다'),
        ],
      ),
    );
  }
}
