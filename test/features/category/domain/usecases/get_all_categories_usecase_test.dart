import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speaking_notes/features/category/domain/models/category.dart';
import 'package:speaking_notes/features/category/domain/repositories/category_repository.dart';
import 'package:speaking_notes/features/category/domain/usecases/get_all_categories_usecase.dart';

import 'get_all_categories_usecase_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late MockCategoryRepository mockRepo;
  late GetAllCategoriesUseCase useCase;

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = GetAllCategoriesUseCase(mockRepo);
  });

  final categories = [
    Category(id: '1', name: 'Work', createdAt: DateTime(2024)),
    Category(id: '2', name: 'Personal', createdAt: DateTime(2024)),
  ];

  test('returns list from repository', () async {
    when(mockRepo.getAllCategories()).thenAnswer((_) async => categories);

    final result = await useCase();

    expect(result, categories);
    verify(mockRepo.getAllCategories()).called(1);
  });

  test('propagates exception from repository', () async {
    when(mockRepo.getAllCategories()).thenThrow(Exception('DB error'));

    expect(() => useCase(), throwsException);
  });
}
