import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/models/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../../../note/domain/models/note.dart';
import '../../../note/presentation/bloc/note_bloc.dart';
import '../../../note/presentation/bloc/note_event.dart';
import '../../../note/presentation/bloc/note_state.dart';
import '../../../auth/presentation/screens/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  final bool showFirebaseError;

  const HomeScreen({super.key, this.showFirebaseError = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Category? _selectedCategory;
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sync Unavailable'),
        content: const Text(
            'Cloud sync is unavailable. Your notes will be saved locally only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectCategory(Category? category) {
    setState(() => _selectedCategory = category);
    if (category == null) {
      context.read<NoteBloc>().add(LoadAllNotes());
    } else {
      context.read<NoteBloc>().add(LoadNotes(category.id));
    }
  }

  void _showCategorySheet() {
    final categoryBloc = context.read<CategoryBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: categoryBloc,
        child: _CategoryBottomSheet(
          selectedCategory: _selectedCategory,
          onSelect: (category) {
            Navigator.pop(context);
            _selectCategory(category);
          },
        ),
      ),
    );
  }

  void _showRecordingSheet() {
    if (_selectedCategory == null) {
      _showCategoryPickerThenRecording();
    } else {
      _openRecordingSheet(_selectedCategory);
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
            setState(() => _selectedCategory = savedCategory);
            noteBloc.add(LoadNotes(savedCategory.id));
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _buildHeader(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 8),
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
        const Text('SpeakingNotes', style: AppTypography.heading1),
        Row(
          children: [
            GestureDetector(
              onTap: _showCategorySheet,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.folder_outlined, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Category',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline,
                    color: AppColors.primary, size: 20),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search notes...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryLoaded && state.deletedId != null) {
          if (_selectedCategory?.id == state.deletedId) {
            _selectCategory(null);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted')),
          );
        }
      },
      builder: (context, state) {
        if (state is CategoryError) {
          return SizedBox(
            height: 40,
            child: Center(
              child: Text(
                'Failed to load categories',
                style: TextStyle(color: Colors.red[400], fontSize: 12),
              ),
            ),
          );
        }
        final categories =
            state is CategoryLoaded ? state.categories : <Category>[];
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _FilterChip(
                label: 'All Notes',
                isSelected: _selectedCategory == null,
                onTap: () => _selectCategory(null),
              ),
              ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: cat.name,
                      isSelected: _selectedCategory?.id == cat.id,
                      onTap: () => _selectCategory(cat),
                      onLongPress: () => _showCategoryOptions(cat),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryOptions(Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditCategoryDialog(category);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[400]),
              title: Text('Delete', style: TextStyle(color: Colors.red[400])),
              onTap: () {
                Navigator.pop(context);
                _showDeleteCategoryDialog(category);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
                if (_selectedCategory?.id == category.id) {
                  setState(() => _selectedCategory = updated);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category updated')),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Delete "${category.name}"? Notes in this category will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CategoryBloc>().add(DeleteCategory(category.id));
            },
            child: Text('Delete', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is NoteError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 12),
                const Text(
                  'Something went wrong. Please try again.',
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ],
            ),
          );
        }
        if (state is NoteLoaded) {
          final notes = _searchQuery.isEmpty
              ? state.notes
              : state.notes
                  .where((n) => n.content
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();
          if (notes.isEmpty) {
            final isSearching = _searchQuery.isNotEmpty;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSearching ? Icons.search_off : Icons.mic_none,
                    size: 72,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSearching
                        ? 'No notes found for your search.'
                        : 'No notes yet. Tap the mic to record.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: notes.length,
            itemBuilder: (ctx, i) {
              final note = notes[i];
              return Dismissible(
                key: ValueKey(note.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 26),
                ),
                onDismissed: (_) {
                  context.read<NoteBloc>().add(
                        DeleteNote(note.id,
                            categoryId: _selectedCategory?.id),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted')),
                  );
                },
                child: _NoteCard(note: note),
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
      message: hasOptions ? 'Hold to edit or delete' : '',
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: _pressed
                  ? (widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.85)
                      : Colors.grey[100])
                  : (widget.isSelected ? AppColors.primary : Colors.white),
              borderRadius: BorderRadius.circular(20),
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
                        color: Colors.black.withValues(
                            alpha: _pressed ? 0.08 : 0.05),
                        blurRadius: _pressed ? 6 : 4,
                        spreadRadius: _pressed ? 1 : 0,
                      )
                    ],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected ? Colors.white : Colors.grey[600],
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content.length > 45
                      ? '${note.content.substring(0, 45)}...'
                      : note.content,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formattedDate,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Select Category',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'All Categories',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              final categories =
                  state is CategoryLoaded ? state.categories : <Category>[];
              return Column(
                children: categories
                    .map((cat) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.folder,
                                color: AppColors.primary, size: 18),
                          ),
                          title: Text(cat.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          trailing: Radio<Category?>(
                            value: cat,
                            groupValue: _selected,
                            activeColor: AppColors.primary,
                            onChanged: (v) => setState(() => _selected = v),
                          ),
                          onTap: () => setState(() => _selected = cat),
                        ))
                    .toList(),
              );
            },
          ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            title: const Text(
              'Create New Category',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: _showCreateDialog,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => widget.onSelect(_selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Select',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  Category? _targetCategory;

  @override
  void initState() {
    super.initState();
    _targetCategory = widget.selectedCategory;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speechService.stopListening();
    super.dispose();
  }

  String get _timerDisplay {
    final h = _seconds ~/ 3600;
    final m = (_seconds % 3600) ~/ 60;
    final s = _seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleRecording(BuildContext context) {
    if (_isRecording) {
      _speechService.stopListening();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        _seconds = 0;
      });
    } else {
      _timer = Timer.periodic(
          const Duration(seconds: 1), (_) => setState(() => _seconds++));
      setState(() => _isRecording = true);

      if (kTestMode) {
        final noteBloc = context.read<NoteBloc>();
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
            setState(() {
              _isRecording = false;
              _seconds = 0;
            });
            widget.onNoteCreated(targetCategory);
            navigator.pop();
          } catch (e) {
            _timer?.cancel();
            if (mounted) {
              setState(() {
                _isRecording = false;
                _seconds = 0;
              });
              ScaffoldMessenger.of(navigator.context).showSnackBar(
                const SnackBar(content: Text('Failed to save note. Please try again.')),
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
            setState(() {
              _isRecording = false;
              _seconds = 0;
            });
            widget.onNoteCreated(targetCategory);
            Navigator.pop(context);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Recording ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'Audio',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_outlined, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                _targetCategory?.name ?? '',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          _WaveformWidget(isAnimating: _isRecording),
          const SizedBox(height: 28),
          Text(
            _timerDisplay,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              letterSpacing: 6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 36),
          GestureDetector(
            onTap: () => _toggleRecording(context),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : AppColors.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ],
      ),
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
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _bars
            .map((h) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 4,
                  height: 8 + h * 60,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3 + h * 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
