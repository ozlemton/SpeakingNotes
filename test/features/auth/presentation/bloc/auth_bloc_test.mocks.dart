// Mocks generated manually (build_runner unavailable).
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:speaking_notes/features/auth/domain/models/user_model.dart'
    as _i5;
import 'package:speaking_notes/features/auth/domain/repositories/auth_repository.dart'
    as _i2;
import 'package:speaking_notes/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i3;
import 'package:speaking_notes/features/auth/domain/usecases/sign_in_usecase.dart'
    as _i6;
import 'package:speaking_notes/features/auth/domain/usecases/sign_out_usecase.dart'
    as _i7;
import 'package:speaking_notes/features/auth/domain/usecases/sign_up_usecase.dart'
    as _i8;
import 'package:speaking_notes/features/auth/domain/usecases/update_language_usecase.dart'
    as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeAuthRepository_0 extends _i1.SmartFake
    implements _i2.AuthRepository {
  _FakeAuthRepository_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [GetCurrentUserUseCase].
class MockGetCurrentUserUseCase extends _i1.Mock
    implements _i3.GetCurrentUserUseCase {
  MockGetCurrentUserUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AuthRepository get repository =>
      (super.noSuchMethod(
            Invocation.getter(#repository),
            returnValue: _FakeAuthRepository_0(
              this,
              Invocation.getter(#repository),
            ),
          )
          as _i2.AuthRepository);

  @override
  _i4.Future<_i5.UserModel?> call() =>
      (super.noSuchMethod(
            Invocation.method(#call, []),
            returnValue: _i4.Future<_i5.UserModel?>.value(null),
          )
          as _i4.Future<_i5.UserModel?>);
}

/// A class which mocks [SignInUseCase].
class MockSignInUseCase extends _i1.Mock implements _i6.SignInUseCase {
  MockSignInUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AuthRepository get repository =>
      (super.noSuchMethod(
            Invocation.getter(#repository),
            returnValue: _FakeAuthRepository_0(
              this,
              Invocation.getter(#repository),
            ),
          )
          as _i2.AuthRepository);

  @override
  _i4.Future<_i5.UserModel> call(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#call, [email, password]),
            returnValue: _i4.Future<_i5.UserModel>.value(
              _i5.UserModel(
                id: '',
                username: '',
                email: '',
                createdAt: DateTime(2024),
              ),
            ),
          )
          as _i4.Future<_i5.UserModel>);
}

/// A class which mocks [SignOutUseCase].
class MockSignOutUseCase extends _i1.Mock implements _i7.SignOutUseCase {
  MockSignOutUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AuthRepository get repository =>
      (super.noSuchMethod(
            Invocation.getter(#repository),
            returnValue: _FakeAuthRepository_0(
              this,
              Invocation.getter(#repository),
            ),
          )
          as _i2.AuthRepository);

  @override
  _i4.Future<void> call() =>
      (super.noSuchMethod(
            Invocation.method(#call, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}

/// A class which mocks [SignUpUseCase].
class MockSignUpUseCase extends _i1.Mock implements _i8.SignUpUseCase {
  MockSignUpUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AuthRepository get repository =>
      (super.noSuchMethod(
            Invocation.getter(#repository),
            returnValue: _FakeAuthRepository_0(
              this,
              Invocation.getter(#repository),
            ),
          )
          as _i2.AuthRepository);

  @override
  _i4.Future<_i5.UserModel> call(
    String? username,
    String? email,
    String? password,
    String? language,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#call, [username, email, password, language]),
            returnValue: _i4.Future<_i5.UserModel>.value(
              _i5.UserModel(
                id: '',
                username: '',
                email: '',
                createdAt: DateTime(2024),
              ),
            ),
          )
          as _i4.Future<_i5.UserModel>);
}

/// A class which mocks [UpdateLanguageUseCase].
class MockUpdateLanguageUseCase extends _i1.Mock
    implements _i9.UpdateLanguageUseCase {
  MockUpdateLanguageUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> call(
    String? userId,
    String? language,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#call, [userId, language]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}
