import '../models/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotesByCategory(String categoryId);
  Future<void> createNote(Note note);
  Future<void> deleteNote(String id);
}
