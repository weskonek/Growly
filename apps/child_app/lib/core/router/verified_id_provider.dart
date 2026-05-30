import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the child has been verified via PIN gate.
/// This is used for redirection in the router and state management in the launcher.
final verifiedChildIdProvider = StateProvider<String?>((ref) => null);
