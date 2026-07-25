import '../entities/room.dart';

abstract class RoomRepository {
  Future<Room> createRoom({required String createdBy});

  Future<Room> joinRoom(String code);

  Future<bool> roomExists(String code);
}
