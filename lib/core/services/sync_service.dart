import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
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
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      return false;
    }
  }

  Future<void> syncAll() async {
    try {
      if (!await _isOnline()) return;
      await _syncCategories();
      await _syncNotes();
    } catch (e) {
      debugPrint('SyncService.syncAll failed: $e');
    }
  }

  Future<void> _syncCategories() async {
    try {
      final remote = await firebaseCategories.getAllCategories();
      final local = await localCategories.getAllCategories();

      final localIds = local.map((c) => c.id).toSet();
      final remoteIds = remote.map((c) => c.id).toSet();

      for (final category in remote) {
        if (!localIds.contains(category.id)) {
          try {
            await localCategories.createCategory(category);
          } catch (e) {
            debugPrint('Failed to sync remote category ${category.id} to local: $e');
          }
        }
      }

      for (final category in local) {
        if (!remoteIds.contains(category.id)) {
          try {
            await firebaseCategories.createCategory(category);
          } catch (e) {
            debugPrint('Failed to sync local category ${category.id} to Firebase: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('_syncCategories failed: $e');
    }
  }

  Future<void> _syncNotes() async {
    try {
      final remote = await firebaseNotes.getAllNotes();
      final local = await localNotes.getAllNotes();

      final localIds = local.map((n) => n.id).toSet();
      final remoteIds = remote.map((n) => n.id).toSet();

      for (final note in remote) {
        if (!localIds.contains(note.id)) {
          try {
            await localNotes.createNote(note);
          } catch (e) {
            debugPrint('Failed to sync remote note ${note.id} to local: $e');
          }
        }
      }

      for (final note in local) {
        if (!remoteIds.contains(note.id)) {
          try {
            await firebaseNotes.createNote(note);
          } catch (e) {
            debugPrint('Failed to sync local note ${note.id} to Firebase: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('_syncNotes failed: $e');
    }
  }
}
