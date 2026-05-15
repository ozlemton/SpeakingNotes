import 'package:flutter/foundation.dart';

@immutable
sealed class AuthEvent {}

class CheckAuth extends AuthEvent {}

class SignUp extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String language;
  SignUp({
    required this.username,
    required this.email,
    required this.password,
    required this.language,
  });
}

class SignIn extends AuthEvent {
  final String email;
  final String password;
  SignIn({required this.email, required this.password});
}

class SignOut extends AuthEvent {}

class UpdateLanguage extends AuthEvent {
  final String language;
  UpdateLanguage(this.language);
}
