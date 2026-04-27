import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/remote/supabase_service.dart';

part 'auth_providers.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  User? build() {
    return SupabaseService.client.auth.currentUser;
  }

  Stream<User?> get authStateChanges {
    return SupabaseService.client.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    await SupabaseService.client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await SupabaseService.client.auth.resetPasswordForEmail(email);
  }
}

@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authNotifier = ref.watch(authNotifierProvider);
  return authNotifier != null;
}

@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  final authNotifier = ref.watch(authNotifierProvider);
  return authNotifier?.id;
}