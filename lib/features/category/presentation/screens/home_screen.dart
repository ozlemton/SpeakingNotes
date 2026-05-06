import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/models/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../../../note/domain/models/note.dart';
import '../../../note/presentation/bloc/note_bloc.dart';
import '../../../note/presentation/bloc/note_event.dart';
import '../../../note/presentation/bloc/note_state.dart';

const _primaryColor = Color(0xFF5B5FEF);
const _backgroundColor = Color(0xFFF5F5F5);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Category? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<NoteBloc>().add(LoadAllNotes());
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
          selectedCategory: _selectedCategory,
          onNoteCreated: () {
            if (_selectedCategory == null) {
              noteBloc.add(LoadAllNotes());
            } else {
              noteBloc.add(LoadNotes(_selectedCategory!.id));
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
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
        backgroundColor: _primaryColor,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'SpeakingNotes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: _showCategorySheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.folder_outlined, color: _primaryColor, size: 18),
                SizedBox(width: 6),
                Text(
                  'Category',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
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
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: const InputDecoration(
          hintText: 'Search notes...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: Icon(Icons.tune, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
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
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesList() {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        print('[UI] NoteBloc state changed: $state');
        if (state is NoteLoading) {
          return const Center(
              child: CircularProgressIndicator(color: _primaryColor));
        }
        if (state is NoteError) {
          return Center(child: Text(state.message));
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_none, size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet. Tap the mic to record.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: notes.length,
            itemBuilder: (_, i) => _NoteCard(note: notes[i]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  )
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
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
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description, color: _primaryColor, size: 22),
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
          Icon(Icons.more_vert, color: Colors.grey[400]),
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
                              color: _primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.folder,
                                color: _primaryColor, size: 18),
                          ),
                          title: Text(cat.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500)),
                          trailing: Radio<Category?>(
                            value: cat,
                            groupValue: _selected,
                            activeColor: _primaryColor,
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
                color: _primaryColor,
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
                backgroundColor: _primaryColor,
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
  final VoidCallback onNoteCreated;

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
      if (_targetCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category first')),
        );
        return;
      }
      _timer = Timer.periodic(
          const Duration(seconds: 1), (_) => setState(() => _seconds++));
      setState(() => _isRecording = true);

      if (kTestMode) {
        final noteBloc = context.read<NoteBloc>();
        final navigator = Navigator.of(context);
        final targetCategory = _targetCategory!;
        print('[TEST] Selected category: id=${targetCategory.id}, name=${targetCategory.name}');
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          final text = _speechService.generateMockText();
          print('[TEST] Mock text generated: $text');
          final note = Note(
            id: const Uuid().v4(),
            categoryId: targetCategory.id,
            content: text,
            createdAt: DateTime.now(),
          );
          print('[TEST] Dispatching CreateNote: categoryId=${note.categoryId}, categoryName=${targetCategory.name}');
          noteBloc.add(CreateNote(note));
          _timer?.cancel();
          setState(() {
            _isRecording = false;
            _seconds = 0;
          });
          widget.onNoteCreated();
          navigator.pop();
        });
      } else {
        final targetCategory = _targetCategory!;
        print('[SPEECH] Selected category: id=${targetCategory.id}, name=${targetCategory.name}');
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
            widget.onNoteCreated();
            Navigator.pop(context);
          },
        );
      }
    }
  }

  void _showCategorySheet(BuildContext context) {
    final categoryBloc = context.read<CategoryBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: categoryBloc,
        child: _CategoryBottomSheet(
          selectedCategory: _targetCategory,
          onSelect: (category) {
            Navigator.pop(context);
            setState(() => _targetCategory = category);
          },
        ),
      ),
    );
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
                        color: _primaryColor,
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
          GestureDetector(
            onTap: () => _showCategorySheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_outlined,
                      color: _primaryColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _targetCategory?.name ?? 'Select Category',
                    style: const TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      color: _primaryColor, size: 16),
                ],
              ),
            ),
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
                color: _isRecording ? Colors.red : _primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : _primaryColor)
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
                    color: _primaryColor.withValues(alpha: 0.3 + h * 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
