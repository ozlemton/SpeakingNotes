import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/category/presentation/bloc/category_event.dart';
import 'features/note/presentation/bloc/note_bloc.dart';
import 'features/note/presentation/bloc/note_event.dart';
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

  final router = AppRouter.create(
    authBloc: getIt<AuthBloc>(),
    firebaseFailed: firebaseFailed,
  );

  runApp(MyApp(
    router: router,
    firebaseFailed: firebaseFailed,
    initialLanguage: savedLanguage,
  ));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  final bool firebaseFailed;
  final String initialLanguage;

  const MyApp({
    super.key,
    required this.router,
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
      child: BlocListener<AuthBloc, AuthState>(
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
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final language = authState is AuthAuthenticated
                ? authState.user.language
                : initialLanguage;
            return ScreenUtilInit(
              designSize: const Size(390, 844),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) => MaterialApp.router(
                title: 'Speaking Notes',
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale(language),
                theme: AppTheme.lightTheme,
                routerConfig: router,
              ),
            );
          },
        ),
      ),
    );
  }
}
