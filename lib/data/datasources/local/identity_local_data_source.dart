import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/anonymous_identity_model.dart';

class IdentityLocalDataSource {
  IdentityLocalDataSource({this._prefs});

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _storage async =>
      _prefs ??= await SharedPreferences.getInstance();

  String _key(String roomCode) =>
      '${AppConstants.identityPrefsPrefix}$roomCode';

  Future<AnonymousIdentityModel?> getIdentity(String roomCode) async {
    final prefs = await _storage;
    final raw = prefs.getString(_key(roomCode));
    if (raw == null) return null;
    return AnonymousIdentityModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveIdentity(
    String roomCode,
    AnonymousIdentityModel identity,
  ) async {
    final prefs = await _storage;
    await prefs.setString(_key(roomCode), jsonEncode(identity.toJson()));
  }
}
