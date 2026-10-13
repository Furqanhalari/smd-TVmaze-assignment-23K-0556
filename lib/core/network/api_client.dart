import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// Thin wrapper around [http.Client].
/// Every request has a timeout and every failure becomes an [ApiException].
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Sends a GET request to [path] and returns the decoded JSON body.
  Future<dynamic> get(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(ApiConstants.timeout);
    } on TimeoutException {
      throw const NetworkException('Request timed out. Please try again.');
    } on http.ClientException {
      throw const NetworkException(
          'No internet connection. Check your network and retry.');
    }

    if (response.statusCode == 404) throw const NotFoundException();
    if (response.statusCode != 200) {
      throw ApiException('Server error (${response.statusCode})',
          statusCode: response.statusCode);
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('Invalid response from server.');
    }
  }
}
