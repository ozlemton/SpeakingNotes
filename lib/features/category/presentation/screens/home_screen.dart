import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../note/domain/models/note.dart';
import '../../../note/presentation/bloc/note_bloc.dart';
import '../../../note/presentation/bloc/note_event.dart';
import '../../../note/presentation/bloc/note_state.dart';
import '../../domain/models/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';


class HomeScreen extends StatefulWidget {
  final bool showFirebaseError;

  const HomeScreen({super.key, this.showFirebaseError = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<NoteBloc>().add(LoadAllNotes());
    if (widget.showFirebaseError) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showFirebaseErrorDialog());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFirebaseErrorDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.syncUnavailable),
        content: Text(l10n.syncUnavailableMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _selectCategory(Category? category) {
    context.read<NoteBloc>().add(SelectCategory(category?.id));
  }

  void _showCategorySheet() {
    final categoryBloc = context.read<CategoryBloc>();
    final noteBloc = context.read<NoteBloc>();
    final selectedId = noteBloc.state.selectedCategoryId;
    Category? selectedCategory;
    if (selectedId != null && categoryBloc.state is CategoryLoaded) {
      final categories = (categoryBloc.state as CategoryLoaded).categories;
      try {
        selectedCategory = categories.firstWhere((c) => c.id == selectedId);
      } catch (_) {}
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: categoryBloc,
        child: _CategoryBottomSheet(
          selectedCategory: selectedCategory,
          onSelect: (category) {
            Navigator.pop(context);
            _selectCategory(category);
          },
        ),
      ),
    );
  }

  void _showRecordingSheet() {
    final noteBloc = context.read<NoteBloc>();
    final categoryState = context.read<CategoryBloc>().state;
    final selectedId = noteBloc.state.selectedCategoryId;
    Category? selectedCategory;
    if (selectedId != null && categoryState is CategoryLoaded) {
      try {
        selectedCategory = categoryState.categories.firstWhere((c) => c.id == selectedId);
      } catch (_) {}
    }
    if (selectedCategory == null) {
      _showCategoryPickerThenRecording();
    } else {
      _openRecordingSheet(selectedCategory);
    }
  }

  void _showCategoryPickerThenRecording() {
    final categoryBloc = context.read<CategoryBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: categoryBloc,
        child: _CategoryBottomSheet(
          selectedCategory: null,
          onSelect: (category) {
            Navigator.pop(context);
            _openRecordingSheet(category);
          },
        ),
      ),
    );
  }

  void _openRecordingSheet(Category? category) {
    final categoryBloc = context.read<CategoryBloc>();
    final noteBloc = context.read<NoteBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: categoryBloc),
          BlocProvider.value(value: noteBloc),
        ],
        child: _RecordingBottomSheet(
          selectedCategory: category,
          onNoteCreated: (savedCategory) {
            noteBloc.add(SelectCategory(savedCategory.id));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
              child: _buildHeader(),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSearchBar(),
            ),
            SizedBox(height: 16.h),
            _buildFilterChips(),
            SizedBox(height: 8.h),
            Expanded(child: _buildNotesList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRecordingSheet,
        child: const Icon(Icons.mic),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('SpeakingNotes', style: AppTypography.heading1),
        Row(
          children: [
            GestureDetector(
              onTap: _showCategorySheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.folder_outlined,
                    color: AppColors.primary, size: 20.r),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.person_outline,
                    color: AppColors.primary, size: 20.r),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchNotes,
          hintStyle: TextStyle(color: AppColors.iconSecondary, fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: AppColors.iconSecondary, size: 20.r),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close, color: AppColors.iconSecondary, size: 20.r),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded && state.deletedId != null) {
          final noteBloc = context.read<NoteBloc>();
          if (noteBloc.state.selectedCategoryId == state.deletedId) {
            noteBloc.add(SelectCategory(null));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.categoryDeleted)),
          );
        }
      },
      builder: (context, categoryState) {
        if (categoryState is CategoryError) {
          return SizedBox(
            height: 40.h,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.failedToLoadCategories,
                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
              ),
            ),
          );
        }
        final categories =
            categoryState is CategoryLoaded ? categoryState.categories : <Category>[];
        return BlocBuilder<NoteBloc, NoteState>(
          buildWhen: (prev, next) =>
              prev.selectedCategoryId != next.selectedCategoryId,
          builder: (context, noteState) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _FilterChip(
                    label: AppLocalizations.of(context)!.allNotes,
                    isSelected: noteState.selectedCategoryId == null,
                    onTap: () => context.read<NoteBloc>().add(SelectCategory(null)),
                  ),
                  ...categories.map((cat) => _FilterChip(
                        label: cat.name,
                        isSelected: noteState.selectedCategoryId == cat.id,
                        onTap: () =>
                            context.read<NoteBloc>().add(SelectCategory(cat.id)),
                        onLongPress: () => _showCategoryOptions(cat),
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryOptions(Category category) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(context);
                _showEditCategoryDialog(category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteCategoryDialog(category);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.categoryName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != category.name) {
                final updated = Category(
                  id: category.id,
                  name: name,
                  createdAt: category.createdAt,
                );
                context.read<CategoryBloc>().add(UpdateCategory(updated));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.categoryUpdated)),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(Category category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CategoryBloc>().add(DeleteCategory(category.id));
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        if (state.status == NoteStatus.loading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state.status == NoteStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                SizedBox(height: 12.h),
                Text(
                  AppLocalizations.of(context)!.somethingWentWrong,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15.sp),
                ),
              ],
            ),
          );
        }
        if (state.status == NoteStatus.loaded) {
          final notes = _searchQuery.isEmpty
              ? state.notes
              : state.notes
                  .where((n) => n.content
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();
          if (notes.isEmpty) {
            final isSearching = _searchQuery.isNotEmpty;
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSearching ? Icons.search_off : Icons.mic_none,
                    size: 72.r,
                    color: AppColors.disabled,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    isSearching ? l10n.noNotesFound : l10n.noNotesYet,
                    style: TextStyle(color: AppColors.disabled, fontSize: 15.sp),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
            itemCount: notes.length,
            itemBuilder: (ctx, i) {
              final note = notes[i];
              return Dismissible(
                key: ValueKey(note.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.w),
                  child: Icon(Icons.delete_outline, color: AppColors.white, size: 26.r),
                ),
                onDismissed: (_) {
                  context.read<NoteBloc>().add(
                        DeleteNote(note.id,
                            categoryId:
                                context.read<NoteBloc>().state.selectedCategoryId),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.noteDeleted)),
                  );
                },
                child: GestureDetector(
                  onTap: () =>
                      context.push('/note/${note.id}', extra: note),
                  child: _NoteCard(note: note),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  void _onLongPressStart(LongPressStartDetails _) {
    setState(() => _pressed = true);
    HapticFeedback.mediumImpact();
  }

  void _onLongPressEnd(LongPressEndDetails _) {
    setState(() => _pressed = false);
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasOptions = widget.onLongPress != null;

    return Tooltip(
      message: hasOptions ? AppLocalizations.of(context)!.holdToEditOrDelete : '',
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPressStart: hasOptions ? _onLongPressStart : null,
        onLongPressEnd: hasOptions ? _onLongPressEnd : null,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: _pressed
                  ? (widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.85)
                      : AppColors.background)
                  : (widget.isSelected ? AppColors.primary : AppColors.white),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                            alpha: _pressed ? 0.15 : 0.3),
                        blurRadius: _pressed ? 4 : 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.shadow.withValues(
                            alpha: _pressed ? 0.08 : 0.05),
                        blurRadius: _pressed ? 6 : 4,
                        spreadRadius: _pressed ? 1 : 0,
                      )
                    ],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;

  const _NoteCard({required this.note});

  String get _formattedDate {
    final d = note.createdAt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.description, color: AppColors.primary, size: 22.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content.length > 45
                      ? '${note.content.substring(0, 45)}...'
                      : note.content,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formattedDate,
                  style: TextStyle(color: AppColors.iconSecondary, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBottomSheet extends StatefulWidget {
  final Category? selectedCategory;
  final void Function(Category?) onSelect;

  const _CategoryBottomSheet({
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  State<_CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<_CategoryBottomSheet> {
  Category? _selected;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.newCategory),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.categoryName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                final category = Category(
                  id: const Uuid().v4(),
                  name: name,
                  createdAt: DateTime.now(),
                );
                context.read<CategoryBloc>().add(CreateCategory(category));
                _nameController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20.w, 24.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.disabled,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.selectCategory,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    ),
                  child: Icon(Icons.close, size: 16.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.allCategories,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              final categories =
                  state is CategoryLoaded ? state.categories : <Category>[];
              return Column(
                children: categories
                    .map((cat) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.folder,
                                color: AppColors.primary, size: 18.r),
                          ),
                          title: Text(cat.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          trailing: GestureDetector(
                            onTap: () => setState(() => _selected = cat),
                            child: Container(
                              width: 22.r,
                              height: 22.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selected == cat
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  width: 2,
                                ),
                              ),
                              child: _selected == cat
                                  ? Center(
                                      child: Container(
                                        width: 12.r,
                                        height: 12.r,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          onTap: () => setState(() => _selected = cat),
                        ))
                    .toList(),
              );
            },
          ),
          Divider(height: 24.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.add, color: AppColors.white, size: 20.r),
            ),
            title: Text(
              l10n.createNewCategory,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: _showCreateDialog,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => widget.onSelect(_selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.divider,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                l10n.select,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingBottomSheet extends StatefulWidget {
  final Category? selectedCategory;
  final void Function(Category) onNoteCreated;

  const _RecordingBottomSheet({
    required this.selectedCategory,
    required this.onNoteCreated,
  });

  @override
  State<_RecordingBottomSheet> createState() => _RecordingBottomSheetState();
}

class _RecordingBottomSheetState extends State<_RecordingBottomSheet> {
  final SpeechService _speechService = getIt<SpeechService>();
  Timer? _timer;
  Category? _targetCategory;
  late NoteBloc _noteBloc;

  @override
  void initState() {
    super.initState();
    _targetCategory = widget.selectedCategory;
    _noteBloc = context.read<NoteBloc>();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speechService.stopListening();
    if (_noteBloc.state.isRecording) {
      _noteBloc.add(StopRecording());
    }
    super.dispose();
  }

  String _timerDisplay(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleRecording(BuildContext context) {
    final noteBloc = context.read<NoteBloc>();
    if (noteBloc.state.isRecording) {
      _speechService.stopListening();
      _timer?.cancel();
      noteBloc.add(StopRecording());
    } else {
      noteBloc.add(StartRecording());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final current = context.read<NoteBloc>().state.recordingSeconds;
        context.read<NoteBloc>().add(UpdateRecordingTimer(current + 1));
      });

      if (kTestMode) {
        final navigator = Navigator.of(context);
        final targetCategory = _targetCategory!;
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          try {
            final text = _speechService.generateMockText();
            final note = Note(
              id: const Uuid().v4(),
              categoryId: targetCategory.id,
              content: text,
              createdAt: DateTime.now(),
            );
            noteBloc.add(CreateNote(note));
            _timer?.cancel();
            noteBloc.add(StopRecording());
            widget.onNoteCreated(targetCategory);
            navigator.pop();
          } catch (e) {
            _timer?.cancel();
            if (mounted) {
              noteBloc.add(StopRecording());
              ScaffoldMessenger.of(navigator.context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(navigator.context)!.failedToSaveNote)),
              );
            }
          }
        });
      } else {
        final targetCategory = _targetCategory!;
        _speechService.startListening(
          onResult: (text) {
            if (text.isEmpty) return;
            final note = Note(
              id: const Uuid().v4(),
              categoryId: targetCategory.id,
              content: text,
              createdAt: DateTime.now(),
            );
            context.read<NoteBloc>().add(CreateNote(note));
            _speechService.stopListening();
            _timer?.cancel();
            context.read<NoteBloc>().add(StopRecording());
            widget.onNoteCreated(targetCategory);
            Navigator.pop(context);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      buildWhen: (prev, next) =>
          prev.isRecording != next.isRecording ||
          prev.recordingSeconds != next.recordingSeconds,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              24.w, 24.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 40.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${AppLocalizations.of(context)!.recording} ',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.audio,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        ),
                      child: Icon(Icons.close, size: 16.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_outlined,
                      color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text(
                    _targetCategory?.name ?? '',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 36.h),
              _WaveformWidget(isAnimating: state.isRecording),
              SizedBox(height: 28.h),
              Text(
                _timerDisplay(state.recordingSeconds),
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 36.h),
              GestureDetector(
                onTap: () => _toggleRecording(context),
                child: Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    color: state.isRecording ? AppColors.error : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (state.isRecording ? AppColors.error : AppColors.primary)
                                .withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isRecording ? Icons.stop : Icons.mic,
                    color: AppColors.white,
                    size: 36.r,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaveformWidget extends StatefulWidget {
  final bool isAnimating;

  const _WaveformWidget({required this.isAnimating});

  @override
  State<_WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<_WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  List<double> _bars = List.filled(28, 0.1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(() {
        if (widget.isAnimating && mounted) {
          setState(() {
            _bars = List.generate(28, (_) => 0.1 + _random.nextDouble() * 0.9);
          });
        }
      });
    if (widget.isAnimating) _controller.repeat();
  }

  @override
  void didUpdateWidget(_WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _controller.repeat();
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      _controller.stop();
      setState(() => _bars = List.filled(28, 0.1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _bars
            .map((h) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 4.w,
                  height: (8 + h * 60).h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3 + h * 0.7),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
