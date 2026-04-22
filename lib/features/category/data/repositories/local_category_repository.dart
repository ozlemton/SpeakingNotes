import '../../../../core/services/app_database.dart';
import '../../domain/models/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';

class LocalCategoryRepository implements CategoryRepository {
  final AppDatabase db;

  LocalCategoryRepository(this.db);

  @override
  Future<List<domain.Category>> getAllCategories() async {
    final rows = await db.select(db.categories).get();
    return rows
        .map((r) => domain.Category(
              id: r.id,
              name: r.name,
              createdAt: DateTime.parse(r.createdAt),
            ))
        .toList();
  }

  @override
  Future<void> createCategory(domain.Category category) async {
    await db.into(db.categories).insert(CategoriesCompanion.insert(
          id: category.id,
          name: category.name,
          createdAt: category.createdAt.toIso8601String(),
        ));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
  }
}
