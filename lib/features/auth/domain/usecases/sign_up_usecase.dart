import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<UserModel> call(
          String username, String email, String password, String language) =>
      repository.signUp(username, email, password, language);
}
