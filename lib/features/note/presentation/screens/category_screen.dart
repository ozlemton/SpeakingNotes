import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/utils/constants.dart';
import '../../../category/domain/models/category.dart';
import '../../domain/models/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';

const _primaryColor = Color(0xFF5B5FEF);
const _backgroundColor = Color(0xFFF5F5F5);

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(LoadNotes(widget.category.id));
  }

  void _showRecordingSheet() {
    final noteBloc = context.read<NoteBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: noteBloc,
        child: _RecordingBottomSheet(
          categoryId: widget.category.id,
          onNoteCreated: () => noteBloc.add(LoadNotes(widget.category.id)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.black87),
          ),
        ),
        title: Text(
          widget.category.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoading) {
            return const Center(
                child: CircularProgressIndicator(color: _primaryColor));
          }
          if (state is NoteError) {
            return Center(child: Text(state.message));
          }
          if (state is NoteLoaded) {
            if (state.notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_none, size: 72, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No notes yet. Tap the mic to record.',
                      style:
                          TextStyle(color: Colors.grey[400], fontSize: 15),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: state.notes.length,
              itemBuilder: (_, i) => _NoteCard(note: state.notes[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRecordingSheet,
        backgroundColor: _primaryColor,
        child: const Icon(Icons.mic, color: Colors.white),
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
            child:
                const Icon(Icons.description, color: _primaryColor, size: 22),
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

class _RecordingBottomSheet extends StatefulWidget {
  final String categoryId;
  final VoidCallback onNoteCreated;

  const _RecordingBottomSheet({
    required this.categoryId,
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
    final ms = 0;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}:${ms.toString().padLeft(2, '0')}';
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
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          final text = _speechService.generateMockText();
          final note = Note(
            id: const Uuid().v4(),
            categoryId: widget.categoryId,
            content: text,
            createdAt: DateTime.now(),
          );
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
        _speechService.startListening(
          onResult: (text) {
            if (text.isEmpty) return;
            final note = Note(
              id: const Uuid().v4(),
              categoryId: widget.categoryId,
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
          const SizedBox(height: 40),
          _WaveformWidget(isAnimating: _isRecording),
          const SizedBox(height: 32),
          Text(
            _timerDisplay,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
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
            _bars =
                List.generate(28, (_) => 0.1 + _random.nextDouble() * 0.9);
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
