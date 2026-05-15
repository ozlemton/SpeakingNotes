import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/category/domain/models/category.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/category/presentation/bloc/category_event.dart';
import 'features/category/presentation/screens/home_screen.dart';
import 'features/note/presentation/bloc/note_bloc.dart';
import 'features/note/presentation/bloc/note_event.dart';
import 'features/note/presentation/screens/category_screen.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseFailed = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    firebaseFailed = true;
  }

  await setupDependencies();

  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('language') ?? 'en';

  runApp(MyApp(firebaseFailed: firebaseFailed, initialLanguage: savedLanguage));
}

class MyApp extends StatelessWidget {
  final bool firebaseFailed;
  final String initialLanguage;

  const MyApp({
    super.key,
    this.firebaseFailed = false,
    this.initialLanguage = 'en',
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(CheckAuth()),
        ),
        BlocProvider<CategoryBloc>(
          create: (_) => getIt<CategoryBloc>(),
        ),
        BlocProvider<NoteBloc>(
          create: (_) => getIt<NoteBloc>(),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final language = authState is AuthAuthenticated
              ? authState.user.language
              : initialLanguage;
          return MaterialApp(
            title: 'Speaking Notes',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(language),
            theme: AppTheme.lightTheme,
            home: _AppRouter(firebaseFailed: firebaseFailed),
            onGenerateRoute: (settings) {
              if (settings.name == '/category') {
                final category = settings.arguments as Category;
                return MaterialPageRoute(
                  builder: (_) => CategoryScreen(category: category),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  final bool firebaseFailed;

  const _AppRouter({required this.firebaseFailed});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setCurrentUserId(state.user.id);
          getIt<SyncService>().syncAll().then((_) {
            getIt<CategoryBloc>().add(LoadCategories());
            getIt<NoteBloc>().add(LoadAllNotes());
          });
        } else if (state is AuthUnauthenticated) {
          clearCurrentUserId();
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }
        if (state is AuthAuthenticated) {
          return HomeScreen(showFirebaseError: firebaseFailed);
        }
        return const LoginScreen();
      },
    );
  }
}
