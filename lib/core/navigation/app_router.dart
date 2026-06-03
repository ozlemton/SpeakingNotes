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
import '../../features/splash/presentation/screens/splash_screen.dart';

abstract final class AppRouter {
  static GoRouter create({
    required AuthBloc authBloc,
    required bool firebaseFailed,
  }) {
    final notifier = _RouterNotifier(authBloc);
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: notifier,
      redirect: (context, state) {
        final authState = notifier.authState;
        final path = state.uri.path;

        // Splash owns its own navigation — never redirect away from it.
        if (path == '/splash') return null;

        final isAuthenticated = authState is AuthAuthenticated;
        final isPublic = path == '/login' || path == '/signup';

        if (!isAuthenticated && !isPublic) return '/login';
        if (isAuthenticated && isPublic) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
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

