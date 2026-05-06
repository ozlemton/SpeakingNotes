import 'package:get_it/get_it.dart';
import '../services/app_database.dart';
import '../../features/category/data/repositories/local_category_repository.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/get_all_categories_usecase.dart';
import '../../features/category/domain/usecases/create_category_usecase.dart';
import '../../features/category/domain/usecases/delete_category_usecase.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/note/data/repositories/local_note_repository.dart';
import '../../features/note/domain/repositories/note_repository.dart';
import '../../features/note/domain/usecases/get_all_notes_usecase.dart';
import '../../features/note/domain/usecases/get_notes_by_category_usecase.dart';
import '../../features/note/domain/usecases/create_note_usecase.dart';
import '../../features/note/domain/usecases/delete_note_usecase.dart';
import '../../features/note/presentation/bloc/note_bloc.dart';
import '../services/speech_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  final speechService = SpeechService();
  await speechService.initialize();
  getIt.registerSingleton<SpeechService>(speechService);

  getIt.registerSingleton<CategoryRepository>(
    LocalCategoryRepository(getIt<AppDatabase>()),
  );

  getIt.registerSingleton<NoteRepository>(
    LocalNoteRepository(getIt<AppDatabase>()),
  );

  getIt.registerFactory<GetAllCategoriesUseCase>(
    () => GetAllCategoriesUseCase(getIt<CategoryRepository>()),
  );

  getIt.registerFactory<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(getIt<CategoryRepository>()),
  );

  getIt.registerFactory<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(getIt<CategoryRepository>()),
  );

  getIt.registerFactory<GetAllNotesUseCase>(
    () => GetAllNotesUseCase(getIt<NoteRepository>()),
  );

  getIt.registerFactory<GetNotesByCategoryUseCase>(
    () => GetNotesByCategoryUseCase(getIt<NoteRepository>()),
  );

  getIt.registerFactory<CreateNoteUseCase>(
    () => CreateNoteUseCase(getIt<NoteRepository>()),
  );

  getIt.registerFactory<DeleteNoteUseCase>(
    () => DeleteNoteUseCase(getIt<NoteRepository>()),
  );

  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      getAllCategories: getIt<GetAllCategoriesUseCase>(),
      createCategory: getIt<CreateCategoryUseCase>(),
      deleteCategory: getIt<DeleteCategoryUseCase>(),
    ),
  );

  getIt.registerFactory<NoteBloc>(
    () => NoteBloc(
      getAllNotes: getIt<GetAllNotesUseCase>(),
      getNotesByCategory: getIt<GetNotesByCategoryUseCase>(),
      createNote: getIt<CreateNoteUseCase>(),
      deleteNote: getIt<DeleteNoteUseCase>(),
    ),
  );
}
