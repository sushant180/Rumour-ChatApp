import '../entities/anonymous_identity.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class WatchMessagesUseCase {
  const WatchMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Stream<List<ChatMessage>> call(String roomCode) =>
      _repository.watchLatestMessages(roomCode);
}

class LoadOlderMessagesUseCase {
  const LoadOlderMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Future<List<ChatMessage>> call({
    required String roomCode,
    required ChatMessage before,
  }) =>
      _repository.loadOlderMessages(roomCode: roomCode, before: before);
}

class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<void> call({
    required String roomCode,
    required String text,
    required AnonymousIdentity identity,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value();
    return _repository.sendMessage(
      roomCode: roomCode,
      text: trimmed,
      identity: identity,
    );
  }
}
