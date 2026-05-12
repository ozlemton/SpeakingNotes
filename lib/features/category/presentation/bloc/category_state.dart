import 'package:flutter/foundation.dart' hide Category;
import '../../domain/models/category.dart';

@immutable
sealed class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final String? deletedId;
  CategoryLoaded(this.categories, {this.deletedId});
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
