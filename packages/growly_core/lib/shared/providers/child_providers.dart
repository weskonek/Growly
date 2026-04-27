import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/remote/supabase_service.dart';
import '../../domain/models/child_profile.dart';

part 'child_providers.g.dart';

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
    final supabase = SupabaseService.client;
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('child_profiles')
        .select()
        .eq('parent_id', user.id)
        .order('created_at');

    return (response as List)
        .map((json) => ChildProfile.fromJson(json as Map<String, dynamic>))
        .toList();
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
    final supabase = SupabaseService.client;

    final progress = await supabase
        .from('learning_progress')
        .select()
        .eq('child_id', childId)
        .order('created_at', ascending: false)
        .limit(50);

    return {
      'records': progress,
      'totalActivities': (progress as List).length,
    };
  }
}