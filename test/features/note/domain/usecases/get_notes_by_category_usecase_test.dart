import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speaking_notes/features/note/domain/models/note.dart';
import 'package:speaking_notes/features/note/domain/repositories/note_repository.dart';
import 'package:speaking_notes/features/note/domain/usecases/get_notes_by_category_usecase.dart';

import 'get_notes_by_category_usecase_test.mocks.dart';

@GenerateMocks([NoteRepository])
void main() {
  late MockNoteRepository mockRepo;
  late GetNotesByCategoryUseCase useCase;

  setUp(() {
    mockRepo = MockNoteRepository();
    useCase = GetNotesByCategoryUseCase(mockRepo);
  });

  final notes = [
    Note(id: 'n1', categoryId: 'cat-1', content: 'Note 1', createdAt: DateTime(2024)),
    Note(id: 'n2', categoryId: 'cat-1', content: 'Note 2', createdAt: DateTime(2024)),
  ];

  test('returns notes for given categoryId', () async {
    when(mockRepo.getNotesByCategory('cat-1')).thenAnswer((_) async => notes);

    final result = await useCase('cat-1');

    expect(result, notes);
    verify(mockRepo.getNotesByCategory('cat-1')).called(1);
  });

  test('propagates exception from repository', () async {
    when(mockRepo.getNotesByCategory(any)).thenThrow(Exception('DB error'));

    expect(() => useCase('cat-1'), throwsException);
  });
}
