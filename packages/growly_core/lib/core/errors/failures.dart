import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.server({
    required String message,
    int? code,
  }) = ServerFailure;

  const factory Failure.network({
    required String message,
  }) = NetworkFailure;

  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  const factory Failure.auth({
    required String message,
  }) = AuthFailure;

  const factory Failure.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationFailure;

  const factory Failure.database({
    required String message,
  }) = DatabaseFailure;

  const factory Failure.unknown({
    required String message,
  }) = UnknownFailure;
}

extension FailureX on Failure {
  String get userFriendlyMessage {
    return when(
      server: (msg, _) => msg,
      network: (msg) => 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      cache: (msg) => 'Terjadi kesalahan pada sistem. Silakan coba lagi.',
      auth: (msg) => msg,
      validation: (msg, _) => msg,
      database: (msg) => 'Terjadi kesalahan pada database.',
      unknown: (msg) => 'Terjadi kesalahan yang tidak diketahui.',
    );
  }

  bool get isNetworkError => this is NetworkFailure;
  bool get isAuthError => this is AuthFailure;
}