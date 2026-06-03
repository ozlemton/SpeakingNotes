import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../domain/models/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  String get _formattedDate {
    final d = note.createdAt;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete note'),
        content: const Text('This note will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<NoteBloc>().add(
                    DeleteNote(note.id, categoryId: note.categoryId),
                  );
              context.pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _resolveCategoryName(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20.r),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Note', style: AppTypography.heading3),
            if (categoryName != null)
              Text(
                categoryName,
                style: AppTypography.caption,
              ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: Icon(Icons.delete_outline,
                color: AppColors.error, size: 22.r),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 17.sp,
                    height: 1.65,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            const Divider(color: AppColors.divider, height: 1),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14.r, color: AppColors.textSecondary),
                SizedBox(width: 6.w),
                Text(_formattedDate, style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveCategoryName(BuildContext context) {
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryLoaded) {
      try {
        return state.categories
            .firstWhere((c) => c.id == note.categoryId)
            .name;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
