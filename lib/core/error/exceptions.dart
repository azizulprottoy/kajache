class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection.'});
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({this.message = 'Unauthorized.'});
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException({this.message = 'Not found.'});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  const ValidationException({required this.message, this.errors});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error.'});
}