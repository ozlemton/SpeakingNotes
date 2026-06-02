import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speaking_notes/features/category/domain/models/category.dart';
import 'package:speaking_notes/features/category/domain/repositories/category_repository.dart';
import 'package:speaking_notes/features/category/domain/usecases/create_category_usecase.dart';

import 'create_category_usecase_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late MockCategoryRepository mockRepo;
  late CreateCategoryUseCase useCase;

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = CreateCategoryUseCase(mockRepo);
  });

  final category = Category(id: '1', name: 'Work', userId: 'u1', createdAt: DateTime(2024));

  test('delegates to repository', () async {
    when(mockRepo.createCategory(category)).thenAnswer((_) async {});

    await useCase(category);

    verify(mockRepo.createCategory(category)).called(1);
  });

  test('propagates exception from repository', () async {
    when(mockRepo.createCategory(any)).thenThrow(Exception('DB error'));

    expect(() => useCase(category), throwsException);
  });
}
