import 'package:flutter/foundation.dart' hide Category;
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
    await _local.createCategory(category);
    try {
      await _firebase.createCategory(category);
    } catch (e) {
      debugPrint('Firebase createCategory failed (saved locally): $e');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _local.updateCategory(category);
    try {
      await _firebase.updateCategory(category);
    } catch (e) {
      debugPrint('Firebase updateCategory failed (updated locally): $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _local.deleteCategory(id);
    try {
      await _firebase.deleteCategory(id);
    } catch (e) {
      debugPrint('Firebase deleteCategory failed (deleted locally): $e');
    }
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
    await _local.createNote(note);
    try {
      await _firebase.createNote(note);
    } catch (e) {
      debugPrint('Firebase createNote failed (saved locally): $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    await _local.deleteNote(id);
    try {
      await _firebase.deleteNote(id);
    } catch (e) {
      debugPrint('Firebase deleteNote failed (deleted locally): $e');
    }
  }
}
