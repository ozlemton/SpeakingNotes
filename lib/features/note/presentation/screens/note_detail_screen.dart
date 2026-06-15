import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../domain/models/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  int get _wordCount =>
      note.content.trim().isEmpty ? 0 : note.content.trim().split(RegExp(r'\s+')).length;

  int get _charCount => note.content.length;

  String? _resolveCategoryName(BuildContext context) {
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryLoaded) {
      try {
        return state.categories.firstWhere((c) => c.id == note.categoryId).name;
      } catch (_) {}
    }
    return null;
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<NoteBloc>().add(
                    DeleteNote(note.id, categoryId: note.categoryId),
                  );
              context.pop();
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _resolveCategoryName(context);
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDate =
        DateFormat('dd MMM yyyy  HH:mm', locale).format(note.createdAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 20.r),
        ),
        title: Text(formattedDate, style: AppTypography.heading3),
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: Icon(Icons.delete_outline,
                color: AppColors.error, size: 22.r),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryName != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_outlined,
                                color: AppColors.primary, size: 16.r),
                            SizedBox(width: 6.w),
                            Text(
                              categoryName,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          note.content,
                          style: AppTypography.body1.copyWith(
                            height: 1.65,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                AppLocalizations.of(context)!.wordCharCount(_wordCount, _charCount),
                style: AppTypography.caption,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
