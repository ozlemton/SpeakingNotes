import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<UserModel> call(String email, String password) =>
      repository.signIn(email, password);
}
