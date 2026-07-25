import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Check your connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Please try again.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}

class RoomNotFoundFailure extends Failure {
  const RoomNotFoundFailure([super.message = 'Room not found. Check the code and try again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
