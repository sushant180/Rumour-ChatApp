import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.roomCode,
    required super.text,
    required super.senderId,
    required super.senderName,
    required super.senderHandle,
    required super.senderAvatar,
    super.createdAt,
  });

  factory ChatMessageModel.fromFirestore({
    required String roomCode,
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data() ?? {};
    final name = (data['senderName'] as String?) ?? 'Anonymous';
    final handle = (data['senderHandle'] as String?) ??
        name.replaceAll(' ', '').toLowerCase();
    return ChatMessageModel(
      id: doc.id,
      roomCode: roomCode,
      text: (data['text'] as String?) ?? '',
      senderId: (data['senderId'] as String?) ?? '',
      senderName: name,
      senderHandle: handle,
      senderAvatar: (data['senderAvatar'] as String?) ?? '',
      // Pending writes have null server timestamps; fall back to client time
      // so the bubble stays at the bottom until the server value arrives.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['clientCreatedAt'] as Timestamp?)?.toDate() ??
          (doc.metadata.hasPendingWrites ? DateTime.now() : null),
    );
  }

  static Map<String, dynamic> toFirestoreCreate({
    required String text,
    required String senderId,
    required String senderName,
    required String senderHandle,
    required String senderAvatar,
  }) {
    final now = Timestamp.now();
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderHandle': senderHandle,
      'senderAvatar': senderAvatar,
      'createdAt': FieldValue.serverTimestamp(),
      // Local clock for optimistic ordering while createdAt is still null.
      'clientCreatedAt': now,
    };
  }
}
