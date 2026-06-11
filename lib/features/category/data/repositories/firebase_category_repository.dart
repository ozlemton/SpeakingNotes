import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/category_repository.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore;
  String? _userId;

  FirebaseCategoryRepository(this._firestore);

  void setUserId(String? userId) => _userId = userId;

  CollectionReference get _collection => _firestore.collection('categories');
  CollectionReference get _notes => _firestore.collection('notes');

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final query = _userId != null
          ? _collection.where('userId', isEqualTo: _userId)
          : _collection;
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories from Firebase: $e');
    }
  }

  @override
  Future<void> createCategory(Category category) async {
    try {
      final data = category.toJson();
      if (_userId != null) data['userId'] = _userId;
      await _collection.doc(category.id).set(data);
    } catch (e) {
      throw Exception('Failed to save category to Firebase: $e');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      await _collection.doc(category.id).update(category.toJson());
    } catch (e) {
      throw Exception('Failed to update category in Firebase: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final notesSnapshot = await _notes.where('categoryId', isEqualTo: id).get();
      final batch = _firestore.batch();
      for (final doc in notesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_collection.doc(id));
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete category from Firebase: $e');
    }
  }
}
