import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/remote/supabase_service.dart';
import '../../../data/repositories/child_repository_impl.dart';
import '../../../data/repositories/learning_repository_impl.dart';
import '../../domain/models/child_profile.dart';
import '../../domain/repositories/child_repository.dart';
import '../../domain/repositories/learning_repository.dart';

part 'child_providers.g.dart';

final childRepositoryProvider = Provider<IChildRepository>((ref) {
  final client = SupabaseService.client;
  return ChildRepositoryImpl(client);
});

final learningRepositoryProvider = Provider<ILearningRepository>((ref) {
  final client = SupabaseService.client;
  return LearningRepositoryImpl(client);
});

@riverpod
class CurrentChild extends _$CurrentChild {
  @override
  ChildProfile? build() => null;

  void setChild(ChildProfile child) {
    state = child;
  }

  void clear() {
    state = null;
  }
}

@riverpod
class ChildrenList extends _$ChildrenList {
  @override
  Future<List<ChildProfile>> build() async {
    final repository = ref.watch(childRepositoryProvider);
    final supabase = SupabaseService.client;
    final user = supabase.auth.currentUser;
    if (user == null) return [];

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

@riverpod
class SelectedChildId extends _$SelectedChildId {
  @override
  String? build() => null;

  void select(String childId) {
    state = childId;
  }
}

@riverpod
class ChildProgress extends _$ChildProgress {
  @override
  Future<Map<String, dynamic>> build(String childId) async {
    final repository = ref.watch(learningRepositoryProvider);
    final (stats, failure) = await repository.getStats(childId);
    if (failure != null) {
      throw Exception(failure.message);
    }
    return stats ?? {};
  }
}