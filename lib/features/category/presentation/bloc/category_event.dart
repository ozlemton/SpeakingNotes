import 'package:flutter/foundation.dart' hide Category;
import '../../domain/models/category.dart';

@immutable
sealed class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final Category category;
  CreateCategory(this.category);
}

class DeleteCategory extends CategoryEvent {
  final String id;
  DeleteCategory(this.id);
}
