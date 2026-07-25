import 'package:equatable/equatable.dart';

class Room extends Equatable {
  const Room({
    required this.code,
    required this.createdAt,
    this.createdBy,
  });

  final String code;
  final DateTime createdAt;
  final String? createdBy;

  @override
  List<Object?> get props => [code, createdAt, createdBy];
}
