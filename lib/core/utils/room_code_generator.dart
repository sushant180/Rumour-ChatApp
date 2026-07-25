import 'dart:math';

import '../constants/app_constants.dart';

class RoomCodeGenerator {
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String generate({int length = AppConstants.roomCodeLength}) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => _alphabet[random.nextInt(_alphabet.length)],
    ).join();
  }

  static String normalize(String code) =>
      code.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static bool isValid(String code) {
    final normalized = normalize(code);
    return normalized.length == AppConstants.roomCodeLength &&
        RegExp(r'^[A-Z0-9]+$').hasMatch(normalized);
  }
}
