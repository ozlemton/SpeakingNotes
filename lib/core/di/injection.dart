import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/firebase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/update_language_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/category/data/repositories/firebase_category_repository.dart';
import '../../features/category/data/repositories/local_category_repository.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/create_category_usecase.dart';
import '../../features/category/domain/usecases/delete_category_usecase.dart';
import '../../features/category/domain/usecases/get_all_categories_usecase.dart';
import '../../features/category/domain/usecases/update_category_usecase.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/note/data/repositories/firebase_note_repository.dart';
import '../../features/note/data/repositories/local_note_repository.dart';
import '../../features/note/domain/repositories/note_repository.dart';
import '../../features/note/domain/usecases/create_note_usecase.dart';
import '../../features/note/domain/usecases/delete_note_usecase.dart';
import '../../features/note/domain/usecases/get_all_notes_usecase.dart';
import '../../features/note/domain/usecases/get_notes_by_category_usecase.dart';
import '../../features/note/presentation/bloc/note_bloc.dart';
import '../services/app_database.dart';
import '../services/repository_service.dart';
import '../services/speech_service.dart';
import '../services/sync_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  final speechService = SpeechService();
  try {
    await speechService.initialize();
  } catch (e) {
    debugPrint('SpeechService initialization failed: $e');
  }
  getIt.registerSingleton<SpeechService>(speechService);

  // Auth
  getIt.registerSingleton<AuthRepository>(
    FirebaseAuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance),
  );
  getIt.registerFactory<SignUpUseCase>(
      () => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<SignInUseCase>(
      () => SignInUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<SignOutUseCase>(
      () => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<UpdateLanguageUseCase>(
      () => UpdateLanguageUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      signUp: getIt<SignUpUseCase>(),
      signIn: getIt<SignInUseCase>(),
      signOut: getIt<SignOutUseCase>(),
      getCurrentUser: getIt<GetCurrentUserUseCase>(),
      updateLanguage: getIt<UpdateLanguageUseCase>(),
    ),
  );

  // Concrete repositories
  getIt.registerSingleton<LocalCategoryRepository>(
    LocalCategoryRepository(getIt<AppDatabase>()),
  );
  getIt.registerSingleton<FirebaseCategoryRepository>(
    FirebaseCategoryRepository(FirebaseFirestore.instance),
  );
  getIt.registerSingleton<LocalNoteRepository>(
    LocalNoteRepository(getIt<AppDatabase>()),
  );
  getIt.registerSingleton<FirebaseNoteRepository>(
    FirebaseNoteRepository(FirebaseFirestore.instance),
  );

  // Dual-write repository services
  getIt.registerSingleton<CategoryRepository>(
    RepositoryCategoryService(
      getIt<LocalCategoryRepository>(),
      getIt<FirebaseCategoryRepository>(),
    ),
  );
  getIt.registerSingleton<NoteRepository>(
    RepositoryNoteService(
      getIt<LocalNoteRepository>(),
      getIt<FirebaseNoteRepository>(),
    ),
  );

  // Sync service
  getIt.registerSingleton<SyncService>(
    SyncService(
      localCategories: getIt<LocalCategoryRepository>(),
      firebaseCategories: getIt<FirebaseCategoryRepository>(),
      localNotes: getIt<LocalNoteRepository>(),
      firebaseNotes: getIt<FirebaseNoteRepository>(),
    ),
  );

  getIt.registerFactory<GetAllCategoriesUseCase>(
    () => GetAllCategoriesUseCase(getIt<CategoryRepository>()),
  );
  getIt.registerFactory<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(getIt<CategoryRepository>()),
  );
  getIt.registerFactory<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(getIt<CategoryRepository>()),
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

  getIt.registerLazySingleton<CategoryBloc>(
    () => CategoryBloc(
      getAllCategories: getIt<GetAllCategoriesUseCase>(),
      createCategory: getIt<CreateCategoryUseCase>(),
      updateCategory: getIt<UpdateCategoryUseCase>(),
      deleteCategory: getIt<DeleteCategoryUseCase>(),
    ),
  );
  getIt.registerLazySingleton<NoteBloc>(
    () => NoteBloc(
      getAllNotes: getIt<GetAllNotesUseCase>(),
      getNotesByCategory: getIt<GetNotesByCategoryUseCase>(),
      createNote: getIt<CreateNoteUseCase>(),
      deleteNote: getIt<DeleteNoteUseCase>(),
    ),
  );
}

/// Call this after successful sign-in/sign-up to scope all repos to the user.
void setCurrentUserId(String userId) {
  getIt<LocalCategoryRepository>().setUserId(userId);
  getIt<FirebaseCategoryRepository>().setUserId(userId);
  getIt<LocalNoteRepository>().setUserId(userId);
  getIt<FirebaseNoteRepository>().setUserId(userId);
}

/// Wipes all local data — call on sign-out.
Future<void> clearLocalDatabase() async {
  final db = getIt<AppDatabase>();
  await db.delete(db.notes).go();
  await db.delete(db.categories).go();
}

/// Call this after sign-out to clear user scope.
void clearCurrentUserId() {
  getIt<LocalCategoryRepository>().setUserId(null);
  getIt<FirebaseCategoryRepository>().setUserId(null);
  getIt<LocalNoteRepository>().setUserId(null);
  getIt<FirebaseNoteRepository>().setUserId(null);
}
