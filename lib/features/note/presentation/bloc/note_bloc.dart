import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/get_all_notes_usecase.dart';
import '../../domain/usecases/get_notes_by_category_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetAllNotesUseCase getAllNotes;
  final GetNotesByCategoryUseCase getNotesByCategory;
  final CreateNoteUseCase createNote;
  final UpdateNoteUseCase updateNote;
  final DeleteNoteUseCase deleteNote;

  NoteBloc({
    required this.getAllNotes,
    required this.getNotesByCategory,
    required this.createNote,
    required this.updateNote,
    required this.deleteNote,
  }) : super(const NoteState()) {
    on<LoadAllNotes>(_onLoadAllNotes);
    on<LoadNotes>(_onLoadNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<SelectCategory>(_onSelectCategory);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<UpdateRecordingTimer>(_onUpdateRecordingTimer);
  }

  Future<void> _onLoadAllNotes(
    LoadAllNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.loading));
    try {
      final notes = await getAllNotes();
      emit(state.copyWith(status: NoteStatus.loaded, notes: notes));
    } catch (e) {
      emit(state.copyWith(status: NoteStatus.error, error: e.toString()));
    }
  }

  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.loading));
    try {
      final notes = await getNotesByCategory(event.categoryId);
      emit(state.copyWith(status: NoteStatus.loaded, notes: notes));
    } catch (e) {
      emit(state.copyWith(status: NoteStatus.error, error: e.toString()));
    }
  }

  Future<void> _onCreateNote(
    CreateNote event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.loading));
    try {
      await createNote(event.note);
    } catch (e) {
      emit(state.copyWith(status: NoteStatus.error, error: e.toString()));
    }
  }

  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await updateNote(event.note);
      final notes = await getNotesByCategory(event.note.categoryId);
      emit(state.copyWith(status: NoteStatus.loaded, notes: notes));
    } catch (e) {
      emit(state.copyWith(status: NoteStatus.error, error: e.toString()));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await deleteNote(event.id);
      if (event.categoryId != null) {
        final notes = await getNotesByCategory(event.categoryId!);
        emit(state.copyWith(status: NoteStatus.loaded, notes: notes));
      } else {
        final notes = await getAllNotes();
        emit(state.copyWith(status: NoteStatus.loaded, notes: notes));
      }
    } catch (e) {
      emit(state.copyWith(status: NoteStatus.error, error: e.toString()));
    }
  }

  Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<NoteState> emit,
  ) async {
    final categoryId = event.categoryId;
    if (categoryId != null) {
      emit(state.copyWith(
        selectedCategoryId: categoryId,
        status: NoteStatus.loading,
      ));
      try {
        final notes = await getNotesByCategory(categoryId);
        emit(state.copyWith(status: NoteStatus.loaded, notes: notes));
      } catch (e) {
        emit(state.copyWith(status: NoteStatus.error, error: e.toString()));
      }
    } else {
      emit(state.copyWith(
        clearSelectedCategoryId: true,
        status: NoteStatus.loading,
      ));
      try {
        final notes = await getAllNotes();
        emit(state.copyWith(status: NoteStatus.loaded, notes: notes));
      } catch (e) {
        emit(state.copyWith(status: NoteStatus.error, error: e.toString()));
      }
    }
  }

  void _onStartRecording(StartRecording event, Emitter<NoteState> emit) {
    emit(state.copyWith(isRecording: true, recordingSeconds: 0));
  }

  void _onStopRecording(StopRecording event, Emitter<NoteState> emit) {
    emit(state.copyWith(isRecording: false, recordingSeconds: 0));
  }

  void _onUpdateRecordingTimer(
    UpdateRecordingTimer event,
    Emitter<NoteState> emit,
  ) {
    emit(state.copyWith(recordingSeconds: event.seconds));
  }
}
