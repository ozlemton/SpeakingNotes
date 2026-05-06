import '../models/note.dart';
import '../repositories/note_repository.dart';

class GetAllNotesUseCase {
  final NoteRepository repository;

  GetAllNotesUseCase(this.repository);

  Future<List<Note>> call() => repository.getAllNotes();
}
