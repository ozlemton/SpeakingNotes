import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/category_repository.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore;

  FirebaseCategoryRepository(this._firestore);

  CollectionReference get _collection => _firestore.collection('categories');

  @override
  Future<List<Category>> getAllCategories() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createCategory(Category category) async {
    await _collection.doc(category.id).set(category.toJson());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _collection.doc(id).delete();
  }
}
