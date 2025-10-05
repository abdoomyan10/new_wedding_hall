class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class UnAuthenticatedException implements Exception {
  UnAuthenticatedException(this.message);
  final String message;
}

class OfflineException implements Exception {
  OfflineException({this.message = 'Check Your Internet Connection!'});
  final String message;
}
// core/error/exceptions.dart
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

