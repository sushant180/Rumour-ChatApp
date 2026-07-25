import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.roomCode,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderHandle,
    required this.senderAvatar,
    this.createdAt,
  });

  final String id;
  final String roomCode;
  final String text;
  final String senderId;
  final String senderName;
  final String senderHandle;
  final String senderAvatar;
  final DateTime? createdAt;

  String get atHandle =>
      senderHandle.startsWith('@') ? senderHandle : '@$senderHandle';

  @override
  List<Object?> get props => [
        id,
        roomCode,
        text,
        senderId,
        senderName,
        senderHandle,
        senderAvatar,
        createdAt,
      ];
}
