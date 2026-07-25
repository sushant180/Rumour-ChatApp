import '../../domain/entities/anonymous_identity.dart';
import '../../domain/repositories/identity_repository.dart';
import '../datasources/local/identity_local_data_source.dart';
import '../datasources/remote/random_user_remote_data_source.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  IdentityRepositoryImpl({
    required this.local,
    required this.remote,
  });

  final IdentityLocalDataSource local;
  final RandomUserRemoteDataSource remote;

  @override
  Future<AnonymousIdentity> getOrCreateIdentity(String roomCode) async {
    final cached = await local.getIdentity(roomCode);
    if (cached != null) return cached;

    final fresh = await remote.fetchIdentity();
    await local.saveIdentity(roomCode, fresh);
    return fresh;
  }
}
