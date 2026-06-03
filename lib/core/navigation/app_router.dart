import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/category/domain/models/category.dart';
import '../../features/category/presentation/screens/home_screen.dart';
import '../../features/note/presentation/screens/category_screen.dart';
import '../theme/app_colors.dart';

abstract final class AppRouter {
  static GoRouter create({
    required AuthBloc authBloc,
    required bool firebaseFailed,
  }) {
    final notifier = _RouterNotifier(authBloc);
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: notifier,
      redirect: (context, state) {
        final authState = notifier.authState;
        final path = state.uri.path;

        if (authState is AuthLoading || authState is AuthInitial) {
          return path == '/loading' ? null : '/loading';
        }

        final isAuthenticated = authState is AuthAuthenticated;
        final isPublic = path == '/login' || path == '/signup';

        if (!isAuthenticated && !isPublic) return '/login';
        if (isAuthenticated && (isPublic || path == '/loading')) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/loading',
          builder: (_, __) => const _LoadingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (_, __) => const SignupScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => HomeScreen(showFirebaseError: firebaseFailed),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/category/:id',
          builder: (_, state) {
            final category = state.extra! as Category;
            return CategoryScreen(category: category);
          },
        ),
      ],
    );
  }
}

class _RouterNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _subscription;
  AuthState _authState;

  _RouterNotifier(this._authBloc) : _authState = _authBloc.state {
    _subscription = _authBloc.stream.listen((state) {
      _authState = state;
      notifyListeners();
    });
  }

  AuthState get authState => _authState;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
