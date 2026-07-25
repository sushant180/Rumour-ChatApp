import '../entities/anonymous_identity.dart';

abstract class IdentityRepository {
  /// Returns cached identity for [roomCode], or creates one via RandomUser API.
  Future<AnonymousIdentity> getOrCreateIdentity(String roomCode);
}
