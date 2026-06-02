import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speaking_notes/features/category/domain/repositories/category_repository.dart';
import 'package:speaking_notes/features/category/domain/usecases/delete_category_usecase.dart';

import 'delete_category_usecase_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late MockCategoryRepository mockRepo;
  late DeleteCategoryUseCase useCase;

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = DeleteCategoryUseCase(mockRepo);
  });

  test('delegates id to repository', () async {
    when(mockRepo.deleteCategory('cat-1')).thenAnswer((_) async {});

    await useCase('cat-1');

    verify(mockRepo.deleteCategory('cat-1')).called(1);
  });

  test('propagates exception from repository', () async {
    when(mockRepo.deleteCategory(any)).thenThrow(Exception('DB error'));

    expect(() => useCase('cat-1'), throwsException);
  });
}
