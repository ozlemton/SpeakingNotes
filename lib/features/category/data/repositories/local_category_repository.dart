import 'package:drift/drift.dart' show Value;
import '../../../../core/services/app_database.dart';
import '../../domain/models/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';

class LocalCategoryRepository implements CategoryRepository {
  final AppDatabase db;
  String? _userId;

  LocalCategoryRepository(this.db);

  void setUserId(String? userId) => _userId = userId;

  @override
  Future<List<domain.Category>> getAllCategories() async {
    try {
      final query = db.select(db.categories);
      if (_userId != null) {
        query.where((t) => t.userId.equals(_userId!));
      }
      final rows = await query.get();
      return rows
          .map((r) => domain.Category(
                id: r.id,
                name: r.name,
                userId: r.userId,
                createdAt: DateTime.parse(r.createdAt),
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories from local DB: $e');
    }
  }

  @override
  Future<void> createCategory(domain.Category category) async {
    try {
      await db.into(db.categories).insert(CategoriesCompanion.insert(
            id: category.id,
            name: category.name,
            userId: Value(category.userId ?? _userId),
            createdAt: category.createdAt.toIso8601String(),
          ));
    } catch (e) {
      throw Exception('Failed to save category to local DB: $e');
    }
  }

  @override
  Future<void> updateCategory(domain.Category category) async {
    try {
      await (db.update(db.categories)..where((t) => t.id.equals(category.id)))
          .write(CategoriesCompanion(
        name: Value(category.name),
      ));
    } catch (e) {
      throw Exception('Failed to update category in local DB: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw Exception('Failed to delete category from local DB: $e');
    }
  }
}
