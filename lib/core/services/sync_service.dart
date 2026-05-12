import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/category/data/repositories/firebase_category_repository.dart';
import '../../features/category/data/repositories/local_category_repository.dart';
import '../../features/note/data/repositories/firebase_note_repository.dart';
import '../../features/note/data/repositories/local_note_repository.dart';

class SyncService {
  final LocalCategoryRepository localCategories;
  final FirebaseCategoryRepository firebaseCategories;
  final LocalNoteRepository localNotes;
  final FirebaseNoteRepository firebaseNotes;

  SyncService({
    required this.localCategories,
    required this.firebaseCategories,
    required this.localNotes,
    required this.firebaseNotes,
  });

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> syncAll() async {
    if (!await _isOnline()) return;

    await _syncCategories();
    await _syncNotes();
  }

  Future<void> _syncCategories() async {
    final remote = await firebaseCategories.getAllCategories();
    final local = await localCategories.getAllCategories();

    final localIds = local.map((c) => c.id).toSet();
    final remoteIds = remote.map((c) => c.id).toSet();

    for (final category in remote) {
      if (!localIds.contains(category.id)) {
        await localCategories.createCategory(category);
      }
    }

    for (final category in local) {
      if (!remoteIds.contains(category.id)) {
        await firebaseCategories.createCategory(category);
      }
    }
  }

  Future<void> _syncNotes() async {
    final remote = await firebaseNotes.getAllNotes();
    final local = await localNotes.getAllNotes();

    final localIds = local.map((n) => n.id).toSet();
    final remoteIds = remote.map((n) => n.id).toSet();

    for (final note in remote) {
      if (!localIds.contains(note.id)) {
        await localNotes.createNote(note);
      }
    }

    for (final note in local) {
      if (!remoteIds.contains(note.id)) {
        await firebaseNotes.createNote(note);
      }
    }
  }
}
