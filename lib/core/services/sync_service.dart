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
    try {
      final results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Future<void> syncAll() async {
    try {
      if (!await _isOnline()) return;
      await Future.wait([_syncCategories(), _syncNotes()]);
    } catch (_) {}
  }

  Future<void> _syncCategories() async {
    try {
      final remote = await firebaseCategories.getAllCategories();
      final local = await localCategories.getAllCategories();

      final localIds = local.map((c) => c.id).toSet();
      final remoteIds = remote.map((c) => c.id).toSet();

      for (final category in remote.where((c) => !localIds.contains(c.id))) {
        try {
          await localCategories.createCategory(category);
        } catch (_) {}
      }

      for (final category in local.where((c) => !remoteIds.contains(c.id))) {
        try {
          await firebaseCategories.createCategory(category);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _syncNotes() async {
    try {
      final remote = await firebaseNotes.getAllNotes();
      final local = await localNotes.getAllNotes();

      final localIds = local.map((n) => n.id).toSet();
      final remoteIds = remote.map((n) => n.id).toSet();

      for (final note in remote.where((n) => !localIds.contains(n.id))) {
        try {
          await localNotes.createNote(note);
        } catch (_) {}
      }

      for (final note in local.where((n) => !remoteIds.contains(n.id))) {
        try {
          await firebaseNotes.createNote(note);
        } catch (_) {}
      }
    } catch (_) {}
  }
}
