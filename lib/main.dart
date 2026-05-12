import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'core/services/sync_service.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/category/presentation/bloc/category_event.dart';
import 'features/category/presentation/screens/home_screen.dart';
import 'features/note/presentation/bloc/note_bloc.dart';
import 'features/note/presentation/bloc/note_event.dart';
import 'features/note/presentation/screens/category_screen.dart';
import 'features/category/domain/models/category.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseFailed = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    firebaseFailed = true;
  }

  await setupDependencies();
  getIt<SyncService>().syncAll().then((_) {
    getIt<CategoryBloc>().add(LoadCategories());
    getIt<NoteBloc>().add(LoadAllNotes());
  });

  runApp(MyApp(firebaseFailed: firebaseFailed));
}

class MyApp extends StatelessWidget {
  final bool firebaseFailed;

  const MyApp({super.key, this.firebaseFailed = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>(
          create: (_) => getIt<CategoryBloc>()..add(LoadCategories()),
        ),
        BlocProvider<NoteBloc>(
          create: (_) => getIt<NoteBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Speaking Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: HomeScreen(showFirebaseError: firebaseFailed),
        onGenerateRoute: (settings) {
          if (settings.name == '/category') {
            final category = settings.arguments as Category;
            return MaterialPageRoute(
              builder: (_) => CategoryScreen(category: category),
            );
          }
          return null;
        },
      ),
    );
  }
}
