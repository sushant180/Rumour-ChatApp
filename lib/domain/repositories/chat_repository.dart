import '../entities/anonymous_identity.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchLatestMessages(String roomCode);

  Future<List<ChatMessage>> loadOlderMessages({
    required String roomCode,
    required ChatMessage before,
  });

  Future<void> sendMessage({
    required String roomCode,
    required String text,
    required AnonymousIdentity identity,
  });
}
