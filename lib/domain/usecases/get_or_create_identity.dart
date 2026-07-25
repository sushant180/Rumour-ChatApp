import '../entities/anonymous_identity.dart';
import '../repositories/identity_repository.dart';

class GetOrCreateIdentityUseCase {
  const GetOrCreateIdentityUseCase(this._repository);

  final IdentityRepository _repository;

  Future<AnonymousIdentity> call(String roomCode) =>
      _repository.getOrCreateIdentity(roomCode);
}
