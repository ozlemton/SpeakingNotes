import '../../../../core/services/app_database.dart';
import '../../domain/models/note.dart' as domain;
import '../../domain/repositories/note_repository.dart';

class LocalNoteRepository implements NoteRepository {
  final AppDatabase db;

  LocalNoteRepository(this.db);

  @override
  Future<List<domain.Note>> getAllNotes() async {
    try {
      final rows = await db.select(db.notes).get();
      return rows
          .map((r) => domain.Note(
                id: r.id,
                categoryId: r.categoryId,
                content: r.content,
                createdAt: DateTime.parse(r.createdAt),
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes from local DB: $e');
    }
  }

  @override
  Future<List<domain.Note>> getNotesByCategory(String categoryId) async {
    try {
      final rows = await (db.select(db.notes)
            ..where((t) => t.categoryId.equals(categoryId)))
          .get();
      return rows
          .map((r) => domain.Note(
                id: r.id,
                categoryId: r.categoryId,
                content: r.content,
                createdAt: DateTime.parse(r.createdAt),
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes by category from local DB: $e');
    }
  }

  @override
  Future<void> createNote(domain.Note note) async {
    try {
      await db.into(db.notes).insert(NotesCompanion.insert(
            id: note.id,
            categoryId: note.categoryId,
            content: note.content,
            createdAt: note.createdAt.toIso8601String(),
          ));
    } catch (e) {
      throw Exception('Failed to save note to local DB: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await (db.delete(db.notes)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw Exception('Failed to delete note from local DB: $e');
    }
  }
}
