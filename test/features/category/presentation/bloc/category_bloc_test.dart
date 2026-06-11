import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speaking_notes/features/category/domain/models/category.dart';
import 'package:speaking_notes/features/category/domain/usecases/create_category_usecase.dart';
import 'package:speaking_notes/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:speaking_notes/features/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:speaking_notes/features/category/domain/usecases/update_category_usecase.dart';
import 'package:speaking_notes/features/category/presentation/bloc/category_bloc.dart';
import 'package:speaking_notes/features/category/presentation/bloc/category_event.dart';
import 'package:speaking_notes/features/category/presentation/bloc/category_state.dart';

import 'category_bloc_test.mocks.dart';

@GenerateMocks([
  GetAllCategoriesUseCase,
  CreateCategoryUseCase,
  UpdateCategoryUseCase,
  DeleteCategoryUseCase,
])
void main() {
  late MockGetAllCategoriesUseCase mockGetAll;
  late MockCreateCategoryUseCase mockCreate;
  late MockUpdateCategoryUseCase mockUpdate;
  late MockDeleteCategoryUseCase mockDelete;

  final categories = [
    Category(id: '1', name: 'Work', createdAt: DateTime(2024)),
    Category(id: '2', name: 'Personal', createdAt: DateTime(2024)),
  ];

  final newCategory = Category(id: '3', name: 'Health', createdAt: DateTime(2024));

  CategoryBloc buildBloc() => CategoryBloc(
        getAllCategories: mockGetAll,
        createCategory: mockCreate,
        updateCategory: mockUpdate,
        deleteCategory: mockDelete,
      );

  setUp(() {
    mockGetAll = MockGetAllCategoriesUseCase();
    mockCreate = MockCreateCategoryUseCase();
    mockUpdate = MockUpdateCategoryUseCase();
    mockDelete = MockDeleteCategoryUseCase();
  });

  group('LoadCategories', () {
    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryLoaded] on success',
      build: () {
        when(mockGetAll()).thenAnswer((_) async => categories);
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryLoaded>()
            .having((s) => s.categories, 'categories', categories),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryError] on failure',
      build: () {
        when(mockGetAll()).thenThrow(Exception('DB error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryError>(),
      ],
    );
  });

  group('CreateCategory', () {
    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoaded] with new category after creation',
      build: () {
        when(mockCreate(newCategory)).thenAnswer((_) async {});
        when(mockGetAll())
            .thenAnswer((_) async => [...categories, newCategory]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateCategory(newCategory)),
      expect: () => [
        isA<CategoryLoaded>().having(
          (s) => s.categories,
          'categories',
          containsAll([...categories, newCategory]),
        ),
      ],
    );
  });

  group('DeleteCategory', () {
    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoaded, CategoryLoading, CategoryLoaded] without deleted category',
      build: () {
        when(mockDelete('1')).thenAnswer((_) async {});
        when(mockGetAll()).thenAnswer(
          (_) async => categories.where((c) => c.id != '1').toList(),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteCategory('1')),
      expect: () => [
        isA<CategoryLoaded>()
            .having((s) => s.categories, 'categories',
                isNot(contains(categories.first)))
            .having((s) => s.deletedId, 'deletedId', '1'),
        isA<CategoryLoading>(),
        isA<CategoryLoaded>()
            .having((s) => s.categories, 'categories',
                isNot(contains(categories.first))),
      ],
    );

    test('calls onCategoryDeleted callback after successful delete', () async {
      when(mockDelete('1')).thenAnswer((_) async {});
      when(mockGetAll()).thenAnswer(
        (_) async => categories.where((c) => c.id != '1').toList(),
      );
      var callbackCalled = false;
      final bloc = CategoryBloc(
        getAllCategories: mockGetAll,
        createCategory: mockCreate,
        updateCategory: mockUpdate,
        deleteCategory: mockDelete,
        onCategoryDeleted: () => callbackCalled = true,
      );
      bloc.add(DeleteCategory('1'));
      await Future.delayed(Duration.zero);
      await bloc.close();
      expect(callbackCalled, isTrue);
    });
  });
}
