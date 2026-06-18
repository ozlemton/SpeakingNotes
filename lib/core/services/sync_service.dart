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

  final _connectivity = Connectivity();
  bool _syncInProgress = false;

  SyncService({
    required this.localCategories,
    required this.firebaseCategories,
    required this.localNotes,
    required this.firebaseNotes,
  });

  Future<bool> _isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Future<void> syncAll() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    try {
      if (!await _isOnline()) return;
      await Future.wait([_syncCategories(), _syncNotes()]);
    } catch (_) {
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> _syncCategories() async {
    try {
      final results = await Future.wait([
        firebaseCategories.getAllCategories(),
        localCategories.getAllCategories(),
      ]);
      final remote = results[0];
      final local = results[1];

      final localIds = local.map((c) => c.id).toSet();
      final remoteIds = remote.map((c) => c.id).toSet();

      await Future.wait([
        for (final c in remote.where((c) => !localIds.contains(c.id)))
          localCategories.createCategory(c).catchError((_) {}),
        for (final c in local.where((c) => !remoteIds.contains(c.id)))
          firebaseCategories.createCategory(c).catchError((_) {}),
      ]);
    } catch (_) {}
  }

  Future<void> _syncNotes() async {
    try {
      final results = await Future.wait([
        firebaseNotes.getAllNotes(),
        localNotes.getAllNotes(),
      ]);
      final remote = results[0];
      final local = results[1];

      final localIds = local.map((n) => n.id).toSet();
      final remoteIds = remote.map((n) => n.id).toSet();

      await Future.wait([
        for (final n in remote.where((n) => !localIds.contains(n.id)))
          localNotes.createNote(n).catchError((_) {}),
        for (final n in local.where((n) => !remoteIds.contains(n.id)))
          firebaseNotes.createNote(n).catchError((_) {}),
      ]);
    } catch (_) {}
  }
}
