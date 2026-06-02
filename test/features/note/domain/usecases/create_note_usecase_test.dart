import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speaking_notes/features/note/domain/models/note.dart';
import 'package:speaking_notes/features/note/domain/repositories/note_repository.dart';
import 'package:speaking_notes/features/note/domain/usecases/create_note_usecase.dart';

import 'create_note_usecase_test.mocks.dart';

@GenerateMocks([NoteRepository])
void main() {
  late MockNoteRepository mockRepo;
  late CreateNoteUseCase useCase;

  setUp(() {
    mockRepo = MockNoteRepository();
    useCase = CreateNoteUseCase(mockRepo);
  });

  final note = Note(
    id: 'n1',
    categoryId: 'cat-1',
    userId: 'user-1',
    content: 'Test note',
    createdAt: DateTime(2024),
  );

  test('delegates to repository', () async {
    when(mockRepo.createNote(note)).thenAnswer((_) async {});

    await useCase(note);

    verify(mockRepo.createNote(note)).called(1);
  });

  test('propagates exception from repository', () async {
    when(mockRepo.createNote(any)).thenThrow(Exception('DB error'));

    expect(() => useCase(note), throwsException);
  });
}
