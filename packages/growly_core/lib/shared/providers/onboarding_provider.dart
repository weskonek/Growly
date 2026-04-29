import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Whether the current parent has completed onboarding
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return true; // no user → skip onboarding

  final resp = await Supabase.instance.client
      .from('parent_profiles')
      .select('onboarding_completed')
      .eq('id', userId)
      .maybeSingle();

  if (resp == null) return true;
  return (resp['onboarding_completed'] as bool? ) ?? false;
});

/// Provider to mark onboarding as complete after step 6
Future<void> completeOnboarding(WidgetRef ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  await Supabase.instance.client
      .from('parent_profiles')
      .update({'onboarding_completed': true})
      .eq('id', userId);

  ref.invalidate(onboardingCompletedProvider);
}

/// Advance onboarding step N for current parent (upsert)
Future<void> markStepComplete(WidgetRef ref, int stepNumber) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  await Supabase.instance.client.from('onboarding_steps').upsert({
    'parent_id': userId,
    'step_number': stepNumber,
    'completed': true,
    'completed_at': DateTime.now().toIso8601String(),
  }, onConflict: 'parent_id,step_number');
}