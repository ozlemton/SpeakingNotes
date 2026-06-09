import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _timerDone = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      _timerDone = true;
      _tryNavigate(context.read<AuthBloc>().state);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tryNavigate(AuthState state) {
    if (!_timerDone) return;
    if (!mounted) return;
    if (state is AuthAuthenticated) {
      context.go('/home');
    } else if (state is AuthUnauthenticated || state is AuthError) {
      context.go('/login');
    }
    // AuthLoading / AuthInitial → wait for next state change via BlocListener
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _tryNavigate(state),
      child: Scaffold(
        backgroundColor: const Color(0xFFD8DAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/app_icon.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),
              Text(
                'Speaking Notes',
                style: AppTypography.heading1.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
