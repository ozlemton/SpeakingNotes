import '../repositories/auth_repository.dart';

class UpdateLanguageUseCase {
  final AuthRepository _repository;
  UpdateLanguageUseCase(this._repository);

  Future<void> call(String userId, String language) =>
      _repository.updateLanguage(userId, language);
}
