import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/remote/firestore_remote_data_source.dart';

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._remote);

  final FirestoreRemoteDataSource _remote;

  @override
  Future<Room> createRoom({required String createdBy}) =>
      _remote.createRoom(createdBy: createdBy);

  @override
  Future<Room> joinRoom(String code) => _remote.joinRoom(code);

  @override
  Future<bool> roomExists(String code) => _remote.roomExists(code);
}
