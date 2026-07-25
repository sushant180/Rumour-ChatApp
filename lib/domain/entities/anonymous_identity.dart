import 'package:equatable/equatable.dart';

class AnonymousIdentity extends Equatable {
  const AnonymousIdentity({
    required this.id,
    required this.displayName,
    required this.handle,
    required this.avatarUrl,
  });

  final String id;

  /// Human-readable name shown on the identity screen (e.g. "Jane Doe").
  final String displayName;

  /// Chat handle without @ (e.g. "janedoe92") — rendered as @handle.
  final String handle;

  final String avatarUrl;

  String get atHandle => handle.startsWith('@') ? handle : '@$handle';

  @override
  List<Object?> get props => [id, displayName, handle, avatarUrl];
}
