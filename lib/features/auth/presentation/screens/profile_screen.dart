import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_event.dart';
import '../../../note/presentation/bloc/note_bloc.dart';
import '../../../note/presentation/bloc/note_event.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class _SpeechLang {
  final String code;
  final String nameTr;
  final String nameEn;
  const _SpeechLang(this.code, this.nameTr, this.nameEn);
}

const _kSpeechLanguages = [
  _SpeechLang('tr-TR', 'Türkçe', 'Turkish'),
  _SpeechLang('en-US', 'İngilizce (ABD)', 'English (US)'),
  _SpeechLang('en-GB', 'İngilizce (İngiltere)', 'English (UK)'),
  _SpeechLang('de-DE', 'Almanca', 'German'),
  _SpeechLang('fr-FR', 'Fransızca', 'French'),
  _SpeechLang('it-IT', 'İtalyanca', 'Italian'),
  _SpeechLang('es-ES', 'İspanyolca', 'Spanish'),
  _SpeechLang('ja-JP', 'Japonca', 'Japanese'),
  _SpeechLang('ko-KR', 'Korece', 'Korean'),
  _SpeechLang('zh-CN', 'Çince', 'Chinese'),
  _SpeechLang('ru-RU', 'Rusça', 'Russian'),
  _SpeechLang('ar-SA', 'Arapça', 'Arabic'),
  _SpeechLang('pt-BR', 'Portekizce (Brezilya)', 'Portuguese (Brazil)'),
  _SpeechLang('nl-NL', 'Felemenkçe', 'Dutch'),
  _SpeechLang('pl-PL', 'Lehçe', 'Polish'),
  _SpeechLang('sv-SE', 'İsveççe', 'Swedish'),
  _SpeechLang('nb-NO', 'Norveççe', 'Norwegian'),
  _SpeechLang('da-DK', 'Danca', 'Danish'),
  _SpeechLang('fi-FI', 'Fince', 'Finnish'),
  _SpeechLang('el-GR', 'Yunanca', 'Greek'),
  _SpeechLang('he-IL', 'İbranice', 'Hebrew'),
  _SpeechLang('hi-IN', 'Hintçe', 'Hindi'),
  _SpeechLang('id-ID', 'Endonezce', 'Indonesian'),
  _SpeechLang('ms-MY', 'Malayca', 'Malay'),
  _SpeechLang('ro-RO', 'Romence', 'Romanian'),
  _SpeechLang('sk-SK', 'Slovakça', 'Slovak'),
  _SpeechLang('th-TH', 'Tayca', 'Thai'),
  _SpeechLang('uk-UA', 'Ukraynaca', 'Ukrainian'),
  _SpeechLang('vi-VN', 'Vietnamca', 'Vietnamese'),
  _SpeechLang('ca-ES', 'Katalanca', 'Catalan'),
  _SpeechLang('hr-HR', 'Hırvatça', 'Croatian'),
  _SpeechLang('cs-CZ', 'Çekçe', 'Czech'),
  _SpeechLang('hu-HU', 'Macarca', 'Hungarian'),
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20.r),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: AppTypography.heading3,
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) context.go('/login');
        },
        child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox();
          final user = state.user;
          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                _Avatar(username: user.username),
                SizedBox(height: 16.h),
                Text(user.username, style: AppTypography.heading2),
                SizedBox(height: 4.h),
                Text(
                  user.email,
                  style: AppTypography.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 36.h),
                _SettingsCard(
                  children: [
                    _LanguageSelector(currentLanguage: user.language),
                    Divider(
                        height: 1, indent: 20.w, endIndent: 20.w,
                        color: AppColors.divider),
                    const _SpeechLanguageSelectorRow(),
                  ],
                ),
                SizedBox(height: 24.h),
                _LogoutButton(userId: user.id),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String username;
  const _Avatar({required this.username});

  @override
  Widget build(BuildContext context) {
    final initials = username.isNotEmpty
        ? username
            .trim()
            .split(' ')
            .map((w) => w[0].toUpperCase())
            .take(2)
            .join()
        : '?';
    return Container(
      width: 88.r,
      height: 88.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  const _LanguageSelector({required this.currentLanguage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Icon(Icons.language, color: AppColors.primary, size: 22.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(l10n.language, style: AppTypography.body1),
          ),
          _LanguageToggle(currentLanguage: currentLanguage),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final String currentLanguage;
  const _LanguageToggle({required this.currentLanguage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangButton(
            label: l10n.english,
            code: 'en',
            selected: currentLanguage == 'en',
          ),
          _LangButton(
            label: l10n.turkish,
            code: 'tr',
            selected: currentLanguage == 'tr',
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;
  const _LangButton({
    required this.label,
    required this.code,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: selected
          ? null
          : () {
              context.read<AuthBloc>().add(UpdateLanguage(code));
              getIt<SpeechService>().setLocale(code);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? AppColors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SpeechLanguageSelectorRow extends StatefulWidget {
  const _SpeechLanguageSelectorRow();

  @override
  State<_SpeechLanguageSelectorRow> createState() =>
      _SpeechLanguageSelectorRowState();
}

class _SpeechLanguageSelectorRowState
    extends State<_SpeechLanguageSelectorRow> {
  String _selectedCode = 'tr-TR';

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('speech_language');
    if (saved != null && mounted) {
      setState(() => _selectedCode = saved);
    }
  }

  Future<void> _onChanged(String? code) async {
    if (code == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('speech_language', code);
    getIt<SpeechService>().setLocale(code);
    if (mounted) setState(() => _selectedCode = code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(Icons.mic_none, color: AppColors.primary, size: 22.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(l10n.speechLanguage, style: AppTypography.body1),
          ),
          DropdownButton<String>(
            value: _selectedCode,
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.keyboard_arrow_down,
                color: AppColors.primary, size: 20.r),
            style: AppTypography.body2.copyWith(color: AppColors.textPrimary),
            dropdownColor: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            items: _kSpeechLanguages
                .map((lang) => DropdownMenuItem(
                      value: lang.code,
                      child: Text(
                        isEn ? lang.nameEn : lang.nameTr,
                        style: AppTypography.body2
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ))
                .toList(),
            onChanged: _onChanged,
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final String userId;
  const _LogoutButton({required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: Icon(Icons.logout, color: AppColors.white, size: 20.r),
        label: Text(l10n.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(l10n.logout),
        content: Text(
          l10n.logoutConfirm,
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: AppTypography.body2
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await clearLocalDatabase();
              if (context.mounted) {
                context.read<CategoryBloc>().add(LoadCategories());
                context.read<NoteBloc>().add(LoadAllNotes());
                context.read<AuthBloc>().add(SignOut());
              }
            },
            child: Text(l10n.logout,
                style: AppTypography.body2.copyWith(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
