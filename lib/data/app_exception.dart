enum AppErrorKind { network, timeout, server, unknown }

class AppException implements Exception {
  final String message;
  final AppErrorKind kind;

  const AppException(this.message, this.kind);

  @override
  String toString() => 'AppException($kind): $message';
}
