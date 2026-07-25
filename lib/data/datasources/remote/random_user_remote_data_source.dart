import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/error/failures.dart';
import '../../models/anonymous_identity_model.dart';

class RandomUserRemoteDataSource {
  RandomUserRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<AnonymousIdentityModel> fetchIdentity() async {
    try {
      final response = await _client.get(Uri.parse(AppConstants.randomUserApi));
      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to fetch anonymous identity.');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AnonymousIdentityModel.fromRandomUser(json);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure('Could not reach RandomUser API.');
    }
  }
}
