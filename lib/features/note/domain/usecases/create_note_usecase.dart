import '../models/note.dart';
import '../repositories/note_repository.dart';

class CreateNoteUseCase {
  final NoteRepository repository;

  CreateNoteUseCase(this.repository);

  Future<void> call(Note note) => repository.createNote(note);
}
