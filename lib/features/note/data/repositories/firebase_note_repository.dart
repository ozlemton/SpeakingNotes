import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/note.dart';
import '../../domain/repositories/note_repository.dart';

class FirebaseNoteRepository implements NoteRepository {
  final FirebaseFirestore _firestore;
  String? _userId;

  FirebaseNoteRepository(this._firestore);

  void setUserId(String? userId) => _userId = userId;

  CollectionReference get _collection => _firestore.collection('notes');

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      final query = _userId != null
          ? _collection.where('userId', isEqualTo: _userId)
          : _collection;
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Note.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes from Firebase: $e');
    }
  }

  @override
  Future<List<Note>> getNotesByCategory(String categoryId) async {
    try {
      Query query =
          _collection.where('categoryId', isEqualTo: categoryId);
      if (_userId != null) {
        query = query.where('userId', isEqualTo: _userId);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Note.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes by category from Firebase: $e');
    }
  }

  @override
  Future<void> createNote(Note note) async {
    try {
      final data = note.toJson();
      if (_userId != null) data['userId'] = _userId;
      await _collection.doc(note.id).set(data);
    } catch (e) {
      throw Exception('Failed to save note to Firebase: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete note from Firebase: $e');
    }
  }
}
