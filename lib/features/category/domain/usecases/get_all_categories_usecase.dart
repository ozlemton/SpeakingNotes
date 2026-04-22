import '../models/category.dart';
import '../repositories/category_repository.dart';

class GetAllCategoriesUseCase {
  final CategoryRepository repository;

  GetAllCategoriesUseCase(this.repository);

  Future<List<Category>> call() => repository.getAllCategories();
}
