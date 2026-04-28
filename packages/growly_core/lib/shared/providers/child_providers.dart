import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/remote/supabase_service.dart';
import '../../../data/repositories/child_repository_impl.dart';
import '../../../data/repositories/learning_repository_impl.dart';
import '../../domain/models/child_profile.dart';
import '../../domain/repositories/child_repository.dart';
import '../../domain/repositories/learning_repository.dart';

/// Provider for child repository
final childRepositoryProvider = Provider<IChildRepository>((ref) {
  final client = SupabaseService.client;
  return ChildRepositoryImpl(client);
});

/// Provider for learning repository
final learningRepositoryProvider = Provider<ILearningRepository>((ref) {
  final client = SupabaseService.client;
  return LearningRepositoryImpl(client);
});

/// Provider for current selected child
class CurrentChildNotifier extends StateNotifier<ChildProfile?> {
  CurrentChildNotifier() : super(null);

  void setChild(ChildProfile child) {
    state = child;
  }

  void clear() {
    state = null;
  }
}

final currentChildProvider = StateNotifierProvider<CurrentChildNotifier, ChildProfile?>((ref) {
  return CurrentChildNotifier();
});

/// Provider for list of children
class ChildrenListNotifier extends AsyncNotifier<List<ChildProfile>> {
  @override
  Future<List<ChildProfile>> build() async {
    final repository = ref.watch(childRepositoryProvider);
    final supabase = SupabaseService.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Sesi habis. Silakan login ulang.');
    }

    final (children, failure) = await repository.getChildren(user.id);
    if (failure != null) {
      throw Exception(failure.message);
    }
    return children ?? [];
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final childrenListProvider = AsyncNotifierProvider<ChildrenListNotifier, List<ChildProfile>>(() {
  return ChildrenListNotifier();
});

/// Provider for selected child ID
class SelectedChildIdNotifier extends StateNotifier<String?> {
  SelectedChildIdNotifier() : super(null);

  void select(String childId) {
    state = childId;
  }
}

final selectedChildIdProvider = StateNotifierProvider<SelectedChildIdNotifier, String?>((ref) {
  return SelectedChildIdNotifier();
});

/// Provider for child progress/stats
final childProgressProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, childId) async {
  final repository = ref.watch(learningRepositoryProvider);
  final (stats, failure) = await repository.getStats(childId);
  if (failure != null) {
    throw Exception(failure.message);
  }
  return stats ?? {};
});