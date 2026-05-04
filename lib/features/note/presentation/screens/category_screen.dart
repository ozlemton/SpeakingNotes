import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/speech_service.dart';
import '../../../category/domain/models/category.dart';
import '../../domain/models/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';

class CategoryScreen extends StatefulWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final SpeechService _speechService = getIt<SpeechService>();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(LoadNotes(widget.category.id));
  }

  @override
  void dispose() {
    _speechService.stopListening();
    super.dispose();
  }

  void _toggleRecording(BuildContext context) {
    if (_isListening) {
      _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      _speechService.startListening(
        onResult: (text) {
          if (text.isEmpty) return;
          final note = Note(
            id: const Uuid().v4(),
            categoryId: widget.category.id,
            content: text,
            createdAt: DateTime.now(),
          );
          context.read<NoteBloc>().add(CreateNote(note));
          _speechService.stopListening();
          setState(() => _isListening = false);
        },
      );
      setState(() => _isListening = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          if (_isListening)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.mic, color: Colors.red),
            ),
        ],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NoteError) {
            return Center(child: Text(state.message));
          }
          if (state is NoteLoaded) {
            if (state.notes.isEmpty) {
              return const Center(child: Text('No notes yet. Tap mic to record.'));
            }
            return ListView.builder(
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return ListTile(
                  title: Text(note.content),
                  subtitle: Text(
                    '${note.createdAt.year}-${note.createdAt.month.toString().padLeft(2, '0')}-${note.createdAt.day.toString().padLeft(2, '0')} '
                    '${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}',
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toggleRecording(context),
        child: Icon(_isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
