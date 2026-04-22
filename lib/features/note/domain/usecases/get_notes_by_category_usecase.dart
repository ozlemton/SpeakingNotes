import '../models/note.dart';
import '../repositories/note_repository.dart';

class GetNotesByCategoryUseCase {
  final NoteRepository repository;

  GetNotesByCategoryUseCase(this.repository);

  Future<List<Note>> call(String categoryId) => repository.getNotesByCategory(categoryId);
}
