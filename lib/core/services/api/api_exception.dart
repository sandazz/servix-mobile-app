/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;

  ApiException({required this.message, this.statusCode, this.error});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  bool get isNetworkError => statusCode == 0 || statusCode == 408;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isBadRequest => statusCode == 400;
  bool get isConflict => statusCode == 409;
}
