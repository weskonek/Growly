import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growly_core/growly_core.dart';
import '../../launcher/providers/launcher_providers.dart';

/// Static subjects catalog (replace with courses table query when added)
final subjectsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return [
    {
      'id': 'math',
      'emoji': '🔢',
      'title': 'Matematika',
      'subtitle': 'Berhitung seru!',
      'color': 0xFF3498DB,
    },
    {
      'id': 'reading',
      'emoji': '📖',
      'title': 'Membaca',
      'subtitle': 'Baca cerita bersama',
      'color': 0xFF2ECC71,
    },
    {
      'id': 'science',
      'emoji': '🌍',
      'title': 'Sains',
      'subtitle': 'Kenali dunia sekitar',
      'color': 0xFF9B59B6,
    },
    {
      'id': 'creative',
      'emoji': '🎨',
      'title': 'Kreativitas',
      'subtitle': 'Gambar & mewarnai',
      'color': 0xFFF39C12,
    },
  ];
});

/// Learning progress for a subject
final subjectProgressProvider = FutureProvider.family<double, ({
  String childId,
  String subject
})>((ref, params) async {
  final repository = ref.watch(learningRepositoryProvider);
  final (progressList, _) = await repository.getProgress(params.childId);
  final subjectRecords =
      progressList?.where((p) => p.subject == params.subject) ?? [];
  final total = progressList?.where((p) => p.subject == params.subject) ?? [];
  if (total.isEmpty) return 0.0;
  return subjectRecords.length / total.length;
});

/// Learning session notifier (start/end sessions)
class LearningSessionNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> startSession(String subject) async {
    final child = ref.read(currentChildProvider).valueOrNull;
    if (child == null) return;

    final repository = ref.read(learningRepositoryProvider);
    final (session, _) = await repository.startSession(child.id, subject);
    state = AsyncData(session?.id);
  }

  Future<void> endSession({
    int durationMinutes = 0,
    List<String>? topicsCovered,
  }) async {
    final sessionId = state.value;
    if (sessionId == null) return;

    final repository = ref.read(learningRepositoryProvider);
    await repository.endSession(
      sessionId,
      durationMinutes: durationMinutes,
      topicsCovered: topicsCovered,
    );
    state = const AsyncData(null);
  }
}

final learningSessionProvider =
    AsyncNotifierProvider<LearningSessionNotifier, String?>(() {
  return LearningSessionNotifier();
});

/// Learning repository provider (child app)
final learningRepositoryProvider = Provider<ILearningRepository>((ref) {
  return LearningRepositoryImpl();
});