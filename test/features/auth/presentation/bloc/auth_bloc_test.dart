import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:speaking_notes/features/auth/domain/models/user_model.dart';
import 'package:speaking_notes/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:speaking_notes/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:speaking_notes/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:speaking_notes/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:speaking_notes/features/auth/domain/usecases/update_language_usecase.dart';
import 'package:speaking_notes/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:speaking_notes/features/auth/presentation/bloc/auth_event.dart';
import 'package:speaking_notes/features/auth/presentation/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  GetCurrentUserUseCase,
  SignInUseCase,
  SignOutUseCase,
  SignUpUseCase,
  UpdateLanguageUseCase,
])
void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockSignInUseCase mockSignIn;
  late MockSignOutUseCase mockSignOut;
  late MockSignUpUseCase mockSignUp;
  late MockUpdateLanguageUseCase mockUpdateLanguage;

  final user = UserModel(
    id: 'uid1',
    username: 'testuser',
    email: 'test@example.com',
    createdAt: DateTime(2024),
  );

  AuthBloc buildBloc() => AuthBloc(
        signUp: mockSignUp,
        signIn: mockSignIn,
        signOut: mockSignOut,
        getCurrentUser: mockGetCurrentUser,
        updateLanguage: mockUpdateLanguage,
      );

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockSignIn = MockSignInUseCase();
    mockSignOut = MockSignOutUseCase();
    mockSignUp = MockSignUpUseCase();
    mockUpdateLanguage = MockUpdateLanguageUseCase();
  });

  group('CheckAuth', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when user exists',
      build: () {
        when(mockGetCurrentUser()).thenAnswer((_) async => user);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuth()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.user, 'user', user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no user',
      build: () {
        when(mockGetCurrentUser()).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuth()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when getCurrentUser throws',
      build: () {
        when(mockGetCurrentUser()).thenThrow(Exception('network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CheckAuth()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });

  group('SignIn', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(mockSignIn('test@example.com', 'password123'))
            .thenAnswer((_) async => user);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        SignIn(email: 'test@example.com', password: 'password123'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.user.email, 'email',
            'test@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(mockSignIn(any, any))
            .thenThrow(Exception('Invalid credentials'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        SignIn(email: 'bad@example.com', password: 'wrong'),
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
            (s) => s.message, 'message', contains('Invalid credentials')),
      ],
    );
  });

  group('SignOut', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated]',
      build: () {
        when(mockSignOut()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(SignOut()),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] even when signOut throws',
      build: () {
        when(mockSignOut()).thenThrow(Exception('network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(SignOut()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}
