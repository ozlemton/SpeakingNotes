import 'package:drift/drift.dart' show Value;
import '../../../../core/services/app_database.dart';
import '../../domain/models/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';

class LocalCategoryRepository implements CategoryRepository {
  final AppDatabase db;

  LocalCategoryRepository(this.db);

  @override
  Future<List<domain.Category>> getAllCategories() async {
    try {
      final rows = await db.select(db.categories).get();
      return rows
          .map((r) => domain.Category(
                id: r.id,
                name: r.name,
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
