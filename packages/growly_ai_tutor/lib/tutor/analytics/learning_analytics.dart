import '../../ai/models/ai_response.dart';

class LearningAnalytics {
  int calculateEngagementScore(List<AiMessage> conversation) {
    if (conversation.isEmpty) return 0;

    int score = 0;

    // Base score for conversation length
    score += (conversation.length * 5).clamp(0, 30);

    // Check for follow-up questions (engagement indicator)
    final hasFollowUps = conversation.any(
      (msg) => msg.role == 'user' && msg.content.length > 20,
    );
    if (hasFollowUps) score += 20;

    // Check for positive indicators
    final positiveWords = ['terima kasih', 'aku tahu', 'aku paham', 'iya', 'benar'];
    final hasPositive = conversation.any((msg) => msg.role == 'user' &&
        positiveWords.any((word) => msg.content.toLowerCase().contains(word)));
    if (hasPositive) score += 10;

    // Check for completion (story ended, problem solved)
    final lastMessage = conversation.last;
    if (lastMessage.role == 'assistant' &&
        (lastMessage.content.contains('selesai') ||
         lastMessage.content.contains('jawaban'))) {
      score += 20;
    }

    return score.clamp(0, 100);
  }

  Map<String, dynamic> generateInsights(
    String childId,
    List<AiSession> sessions,
  ) {
    final totalSessions = sessions.length;
    final totalTime = sessions.fold<int>(
      0,
      (sum, session) => sum + _calculateSessionDuration(session),
    );
    final modesUsed = sessions.map((s) => s.mode).toSet();

    return {
      'childId': childId,
      'totalSessions': totalSessions,
      'totalMinutes': totalTime,
      'modesUsed': modesUsed.toList(),
      'favoriteMode': _getMostUsedMode(sessions),
      'averageSessionLength': totalSessions > 0 ? totalTime ~/ totalSessions : 0,
      'engagementTrend': _calculateEngagementTrend(sessions),
    };
  }

  int _calculateSessionDuration(AiSession session) {
    if (session.endedAt == null) return 0;
    return session.endedAt!.difference(session.startedAt).inMinutes;
  }

  String _getMostUsedMode(List<AiSession> sessions) {
    final modeCount = <String, int>{};
    for (final session in sessions) {
      modeCount[session.mode] = (modeCount[session.mode] ?? 0) + 1;
    }
    return modeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  List<int> _calculateEngagementTrend(List<AiSession> sessions) {
    // Simple trend - in production would use proper time series analysis
    final recentSessions = sessions.take(5).toList();
    return recentSessions.map((s) => s.messages.length).toList();
  }

  String generateWeeklyReport(Map<String, dynamic> insights) {
    final buffer = StringBuffer();
    buffer.writeln('📊 Laporan Mingguan Growly');
    buffer.writeln('');
    buffer.writeln('Total sesi belajar: ${insights['totalSessions']}');
    buffer.writeln('Total waktu: ${insights['totalMinutes']} menit');
    buffer.writeln('Mode favorit: ${insights['favoriteMode']}');
    buffer.writeln('');
    buffer.writeln('💡 Insight:');
    buffer.writeln(_generateInsightText(insights));
    return buffer.toString();
  }

  String _generateInsightText(Map<String, dynamic> insights) {
    final totalMinutes = insights['totalMinutes'] as int;
    if (totalMinutes < 30) {
      return 'Anak baru mulai belajar dengan Growly. Ayo semangat!';
    } else if (totalMinutes < 60) {
      return 'Anak sudah mulai terbiasa. Terus semangat!';
    } else if (totalMinutes < 120) {
      return 'Anak sudah belajar aktif. Bagus sekali!';
    } else {
      return 'Anak sangat aktif belajar! Pertahankan! 🎉';
    }
  }
}