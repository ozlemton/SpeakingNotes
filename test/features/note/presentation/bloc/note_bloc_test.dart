import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speaking_notes/features/note/domain/models/note.dart';
import 'package:speaking_notes/features/note/domain/usecases/create_note_usecase.dart';
import 'package:speaking_notes/features/note/domain/usecases/delete_note_usecase.dart';
import 'package:speaking_notes/features/note/domain/usecases/get_all_notes_usecase.dart';
import 'package:speaking_notes/features/note/domain/usecases/get_notes_by_category_usecase.dart';
import 'package:speaking_notes/features/note/presentation/bloc/note_bloc.dart';
import 'package:speaking_notes/features/note/presentation/bloc/note_event.dart';
import 'package:speaking_notes/features/note/presentation/bloc/note_state.dart';

import 'note_bloc_test.mocks.dart';

@GenerateMocks([
  GetAllNotesUseCase,
  GetNotesByCategoryUseCase,
  CreateNoteUseCase,
  DeleteNoteUseCase,
])
void main() {
  late MockGetAllNotesUseCase mockGetAll;
  late MockGetNotesByCategoryUseCase mockGetByCategory;
  late MockCreateNoteUseCase mockCreate;
  late MockDeleteNoteUseCase mockDelete;

  final notes = [
    Note(id: '1', categoryId: 'cat1', content: 'First note', createdAt: DateTime(2024)),
    Note(id: '2', categoryId: 'cat1', content: 'Second note', createdAt: DateTime(2024)),
  ];

  final newNote = Note(
    id: '3',
    categoryId: 'cat1',
    content: 'New note',
    createdAt: DateTime(2024),
  );

  NoteBloc buildBloc() => NoteBloc(
        getAllNotes: mockGetAll,
        getNotesByCategory: mockGetByCategory,
        createNote: mockCreate,
        deleteNote: mockDelete,
      );

  setUp(() {
    mockGetAll = MockGetAllNotesUseCase();
    mockGetByCategory = MockGetNotesByCategoryUseCase();
    mockCreate = MockCreateNoteUseCase();
    mockDelete = MockDeleteNoteUseCase();
  });

  group('LoadNotes', () {
    blocTest<NoteBloc, NoteState>(
      'emits [loading, loaded] on success',
      build: () {
        when(mockGetByCategory('cat1')).thenAnswer((_) async => notes);
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadNotes('cat1')),
      expect: () => [
        isA<NoteState>().having((s) => s.status, 'status', NoteStatus.loading),
        isA<NoteState>()
            .having((s) => s.status, 'status', NoteStatus.loaded)
            .having((s) => s.notes, 'notes', notes),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'emits [loading, error] on failure',
      build: () {
        when(mockGetByCategory('cat1')).thenThrow(Exception('DB error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadNotes('cat1')),
      expect: () => [
        isA<NoteState>().having((s) => s.status, 'status', NoteStatus.loading),
        isA<NoteState>().having((s) => s.status, 'status', NoteStatus.error),
      ],
    );
  });

  group('CreateNote', () {
    blocTest<NoteBloc, NoteState>(
      'emits [loading] then leaves notes unchanged (reloads via separate event)',
      build: () {
        when(mockCreate(newNote)).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateNote(newNote)),
      expect: () => [
        isA<NoteState>().having((s) => s.status, 'status', NoteStatus.loading),
      ],
      verify: (_) => verify(mockCreate(newNote)).called(1),
    );
  });

  group('DeleteNote', () {
    blocTest<NoteBloc, NoteState>(
      'emits [loaded] without deleted note when categoryId is provided',
      build: () {
        when(mockDelete('1')).thenAnswer((_) async {});
        when(mockGetByCategory('cat1')).thenAnswer(
          (_) async => notes.where((n) => n.id != '1').toList(),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteNote('1', categoryId: 'cat1')),
      expect: () => [
        isA<NoteState>()
            .having((s) => s.status, 'status', NoteStatus.loaded)
            .having((s) => s.notes, 'notes',
                isNot(contains(notes.first))),
      ],
    );

    blocTest<NoteBloc, NoteState>(
      'emits [loaded] without deleted note when no categoryId (loads all)',
      build: () {
        when(mockDelete('1')).thenAnswer((_) async {});
        when(mockGetAll()).thenAnswer(
          (_) async => notes.where((n) => n.id != '1').toList(),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteNote('1')),
      expect: () => [
        isA<NoteState>()
            .having((s) => s.status, 'status', NoteStatus.loaded)
            .having((s) => s.notes, 'notes',
                isNot(contains(notes.first))),
      ],
    );
  });
}
