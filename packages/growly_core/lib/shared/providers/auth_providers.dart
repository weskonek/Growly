import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/remote/supabase_service.dart';

/// Auth state notifier for managing authentication
class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(SupabaseService.client.auth.currentUser);

  Stream<User?> get authStateChanges =>
      SupabaseService.client.auth.onAuthStateChange.map((event) => event.session?.user);

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

/// Provider for auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

/// Stream of auth state changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull?.session?.user != null;
});

/// Get current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull?.session?.user.id;
});