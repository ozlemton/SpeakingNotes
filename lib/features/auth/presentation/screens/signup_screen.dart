import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedLanguage = 'tr';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(SignUp(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            language: _selectedLanguage,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.h),
                    _buildLogo(),
                    SizedBox(height: 36.h),
                    _buildUsernameField(),
                    SizedBox(height: 16.h),
                    _buildEmailField(),
                    SizedBox(height: 16.h),
                    _buildPasswordField(),
                    SizedBox(height: 16.h),
                    _buildLanguageDropdown(),
                    SizedBox(height: 28.h),
                    _buildSignUpButton(),
                    SizedBox(height: 24.h),
                    _buildLoginLink(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.mic, color: AppColors.white, size: 36.r),
        ),
        SizedBox(height: 16.h),
        Text('SpeakingNotes', style: AppTypography.heading1),
        SizedBox(height: 6.h),
        Text(
          AppLocalizations.of(context)!.createAccount,
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _usernameController,
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(l10n.username, Icons.person_outline),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return l10n.validationEnterUsername;
        if (v.trim().length < 2) return l10n.validationUsernameLength;
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(l10n.email, Icons.email_outlined),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return l10n.validationEnterEmail;
        if (!v.contains('@')) return l10n.validationEmailInvalid;
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      decoration: _inputDecoration(
        l10n.password,
        Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.iconSecondary,
            size: 20.r,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return l10n.validationEnterPassword;
        if (v.length < 6) return l10n.validationPasswordLength;
        return null;
      },
    );
  }

  Widget _buildLanguageDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final languages = [
      ('tr', l10n.turkish),
      ('en', l10n.english),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.iconSecondary, size: 20.r),
          items: languages
              .map((lang) => DropdownMenuItem(
                    value: lang.$1,
                    child: Row(
                      children: [
                        Icon(Icons.language, color: AppColors.iconSecondary, size: 20.r),
                        SizedBox(width: 10.w),
                        Text(lang.$2, style: AppTypography.body2),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedLanguage = v);
          },
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SizedBox(
          height: 52.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            ),
            child: isLoading
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(AppLocalizations.of(context)!.signUp),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            l10n.login,
            style: AppTypography.body2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.iconSecondary, size: 20.r),
      suffixIcon: suffix,
    );
  }
}
