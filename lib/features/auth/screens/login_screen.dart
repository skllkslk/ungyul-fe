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

class _SocialButtons extends StatefulWidget {
  final WidgetRef ref;
  const _SocialButtons({required this.ref});

  @override
  State<_SocialButtons> createState() => _SocialButtonsState();
}

class _SocialButtonsState extends State<_SocialButtons> {
  bool _loading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);
    try {
      await widget.ref.read(appProvider.notifier).loginWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          label: 'Google로 시작하기',
          backgroundColor: Colors.white,
          textColor: const Color(0xFF1F1F1F),
          icon: 'G',
          isText: true,
          onTap: _loading ? null : _handleGoogleLogin,
          loading: _loading,
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: '카카오로 시작하기',
          backgroundColor: const Color(0xFFFEE500),
          textColor: const Color(0xFF191919),
          icon: '💬',
          onTap: null,
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: 'Apple로 시작하기',
          backgroundColor: AppColors.foreground,
          textColor: AppColors.background,
          icon: '',
          onTap: null,
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
  final VoidCallback? onTap;
  final bool loading;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onTap,
    this.isText = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? backgroundColor.withValues(alpha: 0.4) : backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: loading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
              )
            : Row(
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
