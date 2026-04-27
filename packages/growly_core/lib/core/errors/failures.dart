sealed class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  String get userFriendlyMessage {
    if (this is NetworkFailure) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else if (this is DatabaseFailure) {
      return 'Terjadi kesalahan pada database.';
    } else if (this is AuthFailure) {
      return message;
    } else if (this is ServerFailure) {
      return message;
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  bool get isNetworkError => this is NetworkFailure;
  bool get isAuthError => this is AuthFailure;
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, int? code}) : super(message: message, code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({required String message, this.fieldErrors}) : super(message: message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message}) : super(message: message);
}

class UnknownFailure extends Failure {
  const UnknownFailure({required String message}) : super(message: message);
}