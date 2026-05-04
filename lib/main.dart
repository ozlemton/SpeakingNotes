import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/di/injection.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/category/presentation/bloc/category_event.dart';
import 'features/category/presentation/screens/home_screen.dart';
import 'features/note/presentation/bloc/note_bloc.dart';
import 'features/note/presentation/screens/category_screen.dart';
import 'features/category/domain/models/category.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        home: const HomeScreen(),
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
