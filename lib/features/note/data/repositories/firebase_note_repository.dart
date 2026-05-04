import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/note.dart';
import '../../domain/repositories/note_repository.dart';

class FirebaseNoteRepository implements NoteRepository {
  final FirebaseFirestore _firestore;

  FirebaseNoteRepository(this._firestore);

  CollectionReference get _collection => _firestore.collection('notes');

  @override
  Future<List<Note>> getNotesByCategory(String categoryId) async {
    final snapshot = await _collection
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs
        .map((doc) => Note.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createNote(Note note) async {
    await _collection.doc(note.id).set(note.toJson());
  }

  @override
  Future<void> deleteNote(String id) async {
    await _collection.doc(id).delete();
  }
}
