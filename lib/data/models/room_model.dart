import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/room.dart';

class RoomModel extends Room {
  const RoomModel({
    required super.code,
    required super.createdAt,
    super.createdBy,
  });

  factory RoomModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RoomModel(
      code: (data['code'] as String?) ?? doc.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'code': code,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': createdBy,
      };
}
