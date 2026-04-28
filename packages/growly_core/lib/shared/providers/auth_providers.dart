import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/remote/supabase_service.dart';

/// Auth state notifier for managing authentication.
/// CRITICAL: listens to onAuthStateChange so router guard always sees current state.
class AuthNotifier extends StateNotifier<User?> {
  StreamSubscription<AuthState>? _subscription;

  AuthNotifier() : super(null) {
    _subscription = SupabaseService.client.auth.onAuthStateChange.listen((event) {
      state = event.session?.user;
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await SupabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // State will update via onAuthStateChange listener above
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

/// Stream of auth state changes — use this in router for redirects
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});

/// Check if user is authenticated — watched by router guard
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull?.session?.user != null;
});

/// Get current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull?.session?.user.id;
});
