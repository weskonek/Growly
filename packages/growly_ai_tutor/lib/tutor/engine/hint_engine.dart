import '../../ai/models/tutor_context.dart';

class HintEngine {
  static const int maxHintLevels = 5;

  List<String> generateHints(String question, TutorContext context, int currentLevel) {
    final hints = <String>[];

    // Level 1: Identify the problem type
    hints.add('Coba pikirkan lagi - ini tentang apa?');
    hints.add('Apa yang kamu ketahui tentang topik ini?');

    // Level 2: Recall related concepts
    hints.add('Ingat kembali materi yang sudah dipelajari...');
    hints.add('Topik ini mirip dengan yang kamu sudah tahu...');

    // Level 3: Break down the problem
    hints.add('Coba pecah masalahnya jadi bagian kecil...');
    hints.add('Pertama, cari tahu bagian mana dulu yang mudah...');

    // Level 4: Guide to solution path
    hints.add('Hampir sampai! Coba gunakan cara yang berbeda...');
    hints.add('Kamu di jalur yang benar. Lanjutkan...');

    // Level 5: Explain concept
    hints.add('Konsep ini adalah tentang... (beri penjelasan konsep)');

    return hints.take(currentLevel).toList();
  }

  int calculateHintLevel(int wrongAttempts, int totalAttempts) {
    if (wrongAttempts == 0) return 0;
    if (wrongAttempts == 1) return 1;
    if (wrongAttempts == 2) return 2;
    if (wrongAttempts == 3) return 3;
    if (totalAttempts > 5) return 4;
    return 5;
  }

  bool shouldOfferHint(int wrongAttempts) {
    return wrongAttempts >= 2;
  }

  bool shouldGiveUp(String answer, String correctAnswer) {
    // Allow 3 wrong attempts before suggesting to move on
    return false; // Let the user decide
  }
}

class LearningPathEngine {
  Map<String, dynamic> getNextTopic(
    String currentTopic,
    int performanceScore,
    TutorContext context,
  ) {
    // Adaptive learning path based on performance
    // If score > 80%, move to harder topic
    // If score < 50%, review current topic

    if (performanceScore >= 80) {
      return {
        'action': 'advance',
        'topic': _getNextHarderTopic(currentTopic),
        'reason': 'Anak sudah menguasai topic ini!',
      };
    } else if (performanceScore >= 50) {
      return {
        'action': 'practice',
        'topic': currentTopic,
        'reason': 'Tetap latihan untuk lebih paham.',
      };
    } else {
      return {
        'action': 'review',
        'topic': _getPrerequisiteTopic(currentTopic),
        'reason': 'Perlu memahami dasar dulu.',
      };
    }
  }

  String _getNextHarderTopic(String current) {
    // Simplified - in production would use a proper topic tree
    final harderTopics = {
      'penjumlahan': 'pengurangan',
      'pengurangan': 'perkalian',
      'huruf': 'membaca',
      'membaca': 'menulis',
    };
    return harderTopics[current] ?? current;
  }

  String _getPrerequisiteTopic(String current) {
    final prerequisiteTopics = {
      'pengurangan': 'penjumlahan',
      'perkalian': 'pengurangan',
      'menulis': 'membaca',
    };
    return prerequisiteTopics[current] ?? current;
  }
}