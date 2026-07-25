import '../../core/error/failures.dart';
import '../../core/utils/room_code_generator.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

class JoinRoomUseCase {
  const JoinRoomUseCase(this._repository);

  final RoomRepository _repository;

  Future<Room> call(String rawCode) async {
    final code = RoomCodeGenerator.normalize(rawCode);
    if (!RoomCodeGenerator.isValid(code)) {
      throw const ValidationFailure('Enter a valid 6-character room code.');
    }
    return _repository.joinRoom(code);
  }
}
