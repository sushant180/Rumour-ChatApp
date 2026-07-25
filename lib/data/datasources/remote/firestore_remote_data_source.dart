import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/room_code_generator.dart';
import '../../models/chat_message_model.dart';
import '../../models/room_model.dart';

class FirestoreRemoteDataSource {
  FirestoreRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection(AppConstants.roomsCollection);

  CollectionReference<Map<String, dynamic>> _messages(String roomCode) =>
      _rooms.doc(roomCode).collection(AppConstants.messagesSubcollection);

  Future<RoomModel> createRoom({required String createdBy}) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = RoomCodeGenerator.generate();
      final doc = _rooms.doc(code);
      final existing = await doc.get();
      if (existing.exists) continue;

      final room = RoomModel(
        code: code,
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );
      await doc.set(room.toFirestore());
      return room;
    }
    throw const ServerFailure('Could not generate a unique room code.');
  }

  Future<RoomModel> joinRoom(String code) async {
    final doc = await _rooms.doc(code).get();
    if (!doc.exists) {
      throw const RoomNotFoundFailure();
    }
    return RoomModel.fromFirestore(doc);
  }

  Future<bool> roomExists(String code) async {
    final doc = await _rooms.doc(code).get();
    return doc.exists;
  }

  Stream<List<ChatMessageModel>> watchLatestMessages(String roomCode) {
    return _messages(roomCode)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.messagePageSize)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatMessageModel.fromFirestore(
                  roomCode: roomCode,
                  doc: doc,
                ),
              )
              .toList(),
        );
  }

  Future<List<ChatMessageModel>> loadOlderMessages({
    required String roomCode,
    required String beforeMessageId,
  }) async {
    final beforeDoc = await _messages(roomCode).doc(beforeMessageId).get();
    if (!beforeDoc.exists) return const [];

    final snapshot = await _messages(roomCode)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(beforeDoc)
        .limit(AppConstants.messagePageSize)
        .get();

    return snapshot.docs
        .map(
          (doc) => ChatMessageModel.fromFirestore(roomCode: roomCode, doc: doc),
        )
        .toList();
  }

  Future<void> sendMessage({
    required String roomCode,
    required String text,
    required String senderId,
    required String senderName,
    required String senderHandle,
    required String senderAvatar,
  }) async {
    await _messages(roomCode).add(
      ChatMessageModel.toFirestoreCreate(
        text: text,
        senderId: senderId,
        senderName: senderName,
        senderHandle: senderHandle,
        senderAvatar: senderAvatar,
      ),
    );
  }
}
