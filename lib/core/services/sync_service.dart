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
      debugPrint('[Sync] syncAll() started');
      if (!await _isOnline()) {
        debugPrint('[Sync] offline — skipping sync');
        return;
      }
      debugPrint('[Sync] online — starting category and note sync');
      await _syncCategories();
      await _syncNotes();
      debugPrint('[Sync] syncAll() completed');
    } catch (e) {
      debugPrint('[Sync] syncAll() failed: $e');
    }
  }

  Future<void> _syncCategories() async {
    try {
      debugPrint('[Sync] _syncCategories: fetching from Firebase...');
      final remote = await firebaseCategories.getAllCategories();
      debugPrint('[Sync] _syncCategories: ${remote.length} categories from Firebase');

      debugPrint('[Sync] _syncCategories: fetching from local DB...');
      final local = await localCategories.getAllCategories();
      debugPrint('[Sync] _syncCategories: ${local.length} categories from local DB');

      final localIds = local.map((c) => c.id).toSet();
      final remoteIds = remote.map((c) => c.id).toSet();

      final toAddLocally = remote.where((c) => !localIds.contains(c.id)).toList();
      final toAddRemotely = local.where((c) => !remoteIds.contains(c.id)).toList();
      debugPrint('[Sync] _syncCategories: ${toAddLocally.length} to add locally, ${toAddRemotely.length} to push to Firebase');

      for (final category in toAddLocally) {
        try {
          await localCategories.createCategory(category);
          debugPrint('[Sync] _syncCategories: added "${category.name}" to local DB');
        } catch (e) {
          debugPrint('[Sync] _syncCategories: failed to add "${category.name}" locally: $e');
        }
      }

      for (final category in toAddRemotely) {
        try {
          await firebaseCategories.createCategory(category);
          debugPrint('[Sync] _syncCategories: pushed "${category.name}" to Firebase');
        } catch (e) {
          debugPrint('[Sync] _syncCategories: failed to push "${category.name}" to Firebase: $e');
        }
      }
    } catch (e) {
      debugPrint('[Sync] _syncCategories failed: $e');
    }
  }

  Future<void> _syncNotes() async {
    try {
      debugPrint('[Sync] _syncNotes: fetching from Firebase...');
      final remote = await firebaseNotes.getAllNotes();
      debugPrint('[Sync] _syncNotes: ${remote.length} notes from Firebase');

      debugPrint('[Sync] _syncNotes: fetching from local DB...');
      final local = await localNotes.getAllNotes();
      debugPrint('[Sync] _syncNotes: ${local.length} notes from local DB');

      final localIds = local.map((n) => n.id).toSet();
      final remoteIds = remote.map((n) => n.id).toSet();

      final toAddLocally = remote.where((n) => !localIds.contains(n.id)).toList();
      final toAddRemotely = local.where((n) => !remoteIds.contains(n.id)).toList();
      debugPrint('[Sync] _syncNotes: ${toAddLocally.length} to add locally, ${toAddRemotely.length} to push to Firebase');

      for (final note in toAddLocally) {
        try {
          await localNotes.createNote(note);
          debugPrint('[Sync] _syncNotes: added note ${note.id} to local DB');
        } catch (e) {
          debugPrint('[Sync] _syncNotes: failed to add note ${note.id} locally: $e');
        }
      }

      for (final note in toAddRemotely) {
        try {
          await firebaseNotes.createNote(note);
          debugPrint('[Sync] _syncNotes: pushed note ${note.id} to Firebase');
        } catch (e) {
          debugPrint('[Sync] _syncNotes: failed to push note ${note.id} to Firebase: $e');
        }
      }
    } catch (e) {
      debugPrint('[Sync] _syncNotes failed: $e');
    }
  }
}
