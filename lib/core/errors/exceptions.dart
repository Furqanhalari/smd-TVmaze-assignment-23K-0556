/// Base error thrown by the network layer. Blocs catch this and
/// turn [message] into an error state.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// No internet connection or the request timed out.
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// The server answered with 404 (e.g. a page past the last one).
class NotFoundException extends ApiException {
  const NotFoundException() : super('Not found', statusCode: 404);
}

/// Turns any caught error into a message the UI can show.
/// Known [ApiException]s keep their message; anything else is generic.
String friendlyMessage(Object error) => error is ApiException
    ? error.message
    : 'Something went wrong. Please try again.';
