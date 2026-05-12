import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signUp(
      String username, String email, String password, String language);
  Future<UserModel> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}
