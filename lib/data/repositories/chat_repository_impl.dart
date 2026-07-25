import '../../domain/entities/anonymous_identity.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/firestore_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote);

  final FirestoreRemoteDataSource _remote;

  @override
  Stream<List<ChatMessage>> watchLatestMessages(String roomCode) =>
      _remote.watchLatestMessages(roomCode);

  @override
  Future<List<ChatMessage>> loadOlderMessages({
    required String roomCode,
    required ChatMessage before,
  }) =>
      _remote.loadOlderMessages(
        roomCode: roomCode,
        beforeMessageId: before.id,
      );

  @override
  Future<void> sendMessage({
    required String roomCode,
    required String text,
    required AnonymousIdentity identity,
  }) =>
      _remote.sendMessage(
        roomCode: roomCode,
        text: text,
        senderId: identity.id,
        senderName: identity.displayName,
        senderHandle: identity.handle,
        senderAvatar: identity.avatarUrl,
      );
}
