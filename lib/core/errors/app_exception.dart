enum AppFailureType { network, notFound, invalidData, storage, validation }

class AppException implements Exception {
  const AppException(this.message, {required this.type});

  final String message;
  final AppFailureType type;

  @override
  String toString() => message;
}
