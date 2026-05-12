import '../../features/category/data/repositories/firebase_category_repository.dart';
import '../../features/category/data/repositories/local_category_repository.dart';
import '../../features/category/domain/models/category.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/note/data/repositories/firebase_note_repository.dart';
import '../../features/note/data/repositories/local_note_repository.dart';
import '../../features/note/domain/models/note.dart';
import '../../features/note/domain/repositories/note_repository.dart';

class RepositoryCategoryService implements CategoryRepository {
  final LocalCategoryRepository _local;
  final FirebaseCategoryRepository _firebase;

  RepositoryCategoryService(this._local, this._firebase);

  @override
  Future<List<Category>> getAllCategories() => _local.getAllCategories();

  @override
  Future<void> createCategory(Category category) async {
    await Future.wait([
      _local.createCategory(category),
      _firebase.createCategory(category),
    ]);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.wait([
      _local.deleteCategory(id),
      _firebase.deleteCategory(id),
    ]);
  }
}

class RepositoryNoteService implements NoteRepository {
  final LocalNoteRepository _local;
  final FirebaseNoteRepository _firebase;

  RepositoryNoteService(this._local, this._firebase);

  @override
  Future<List<Note>> getAllNotes() => _local.getAllNotes();

  @override
  Future<List<Note>> getNotesByCategory(String categoryId) =>
      _local.getNotesByCategory(categoryId);

  @override
  Future<void> createNote(Note note) async {
    await Future.wait([
      _local.createNote(note),
      _firebase.createNote(note),
    ]);
  }

  @override
  Future<void> deleteNote(String id) async {
    await Future.wait([
      _local.deleteNote(id),
      _firebase.deleteNote(id),
    ]);
  }
}
