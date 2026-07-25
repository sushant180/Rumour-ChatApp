import '../entities/room.dart';
import '../repositories/room_repository.dart';

class CreateRoomUseCase {
  const CreateRoomUseCase(this._repository);

  final RoomRepository _repository;

  Future<Room> call({required String createdBy}) =>
      _repository.createRoom(createdBy: createdBy);
}
