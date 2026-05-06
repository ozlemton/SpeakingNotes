import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_notes_usecase.dart';
import '../../domain/usecases/get_notes_by_category_usecase.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetAllNotesUseCase getAllNotes;
  final GetNotesByCategoryUseCase getNotesByCategory;
  final CreateNoteUseCase createNote;
  final DeleteNoteUseCase deleteNote;

  NoteBloc({
    required this.getAllNotes,
    required this.getNotesByCategory,
    required this.createNote,
    required this.deleteNote,
  }) : super(NoteInitial()) {
    on<LoadAllNotes>(_onLoadAllNotes);
    on<LoadNotes>(_onLoadNotes);
    on<CreateNote>(_onCreateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadAllNotes(
    LoadAllNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoading());
    try {
      final notes = await getAllNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoading());
    try {
      final notes = await getNotesByCategory(event.categoryId);
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onCreateNote(
    CreateNote event,
    Emitter<NoteState> emit,
  ) async {
    print('[BLOC] CreateNote received, content: ${event.note.content}');
    try {
      await createNote(event.note);
      print('[BLOC] Note saved to repository');
      final currentState = state;
      print('[BLOC] Current state after save: $currentState');
      if (currentState is NoteLoaded && currentState.notes.isNotEmpty) {
        final notes = await getNotesByCategory(currentState.notes.first.categoryId);
        print('[BLOC] Emitting NoteLoaded with ${notes.length} notes');
        emit(NoteLoaded(notes));
      } else {
        print('[BLOC] State is not NoteLoaded or notes is empty — reloading by note categoryId');
        final notes = await getNotesByCategory(event.note.categoryId);
        print('[BLOC] Emitting NoteLoaded with ${notes.length} notes');
        emit(NoteLoaded(notes));
      }
    } catch (e) {
      print('[BLOC] Error in CreateNote: $e');
      emit(NoteError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await deleteNote(event.id);
      final currentState = state;
      if (currentState is NoteLoaded && currentState.notes.isNotEmpty) {
        final notes = await getNotesByCategory(currentState.notes.first.categoryId);
        emit(NoteLoaded(notes));
      }
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }
}
