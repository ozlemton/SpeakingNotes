import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/note.dart';
import '../../domain/repositories/note_repository.dart';

class FirebaseNoteRepository implements NoteRepository {
  final FirebaseFirestore _firestore;

  FirebaseNoteRepository(this._firestore);

  CollectionReference get _collection => _firestore.collection('notes');

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      final snapshot = await _collection.get();
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
      final snapshot = await _collection
          .where('categoryId', isEqualTo: categoryId)
          .get();
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
      await _collection.doc(note.id).set(note.toJson());
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
