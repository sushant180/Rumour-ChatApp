import '../../domain/entities/anonymous_identity.dart';

class AnonymousIdentityModel extends AnonymousIdentity {
  const AnonymousIdentityModel({
    required super.id,
    required super.displayName,
    required super.handle,
    required super.avatarUrl,
  });

  factory AnonymousIdentityModel.fromJson(Map<String, dynamic> json) {
    return AnonymousIdentityModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      handle: (json['handle'] as String?) ??
          (json['displayName'] as String).replaceAll(' ', '').toLowerCase(),
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  factory AnonymousIdentityModel.fromRandomUser(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>;
    final user = results.first as Map<String, dynamic>;
    final name = user['name'] as Map<String, dynamic>;
    final picture = user['picture'] as Map<String, dynamic>;
    final login = user['login'] as Map<String, dynamic>;

    final first = (name['first'] as String?) ?? 'Anon';
    final last = (name['last'] as String?) ?? 'User';
    final username = (login['username'] as String?) ??
        '${first.toLowerCase()}${last.toLowerCase()}';

    return AnonymousIdentityModel(
      id: (login['uuid'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: '$first $last',
      handle: username,
      avatarUrl: (picture['medium'] as String?) ??
          (picture['thumbnail'] as String?) ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'handle': handle,
        'avatarUrl': avatarUrl,
      };
}
