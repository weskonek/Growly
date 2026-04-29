import 'package:flutter/material.dart';

enum RiskLevel { low, medium, high }

class RiskIndicator {
  final String childName;
  final String childId;
  final String message;
  final RiskLevel level;

  const RiskIndicator({
    required this.childName,
    required this.childId,
    required this.message,
    required this.level,
  });

  Color get color {
    switch (level) {
      case RiskLevel.high:
        return const Color(0xFFE74C3C);
      case RiskLevel.medium:
        return const Color(0xFFF39C12);
      case RiskLevel.low:
        return const Color(0xFF3498DB);
    }
  }

  IconData get icon {
    switch (level) {
      case RiskLevel.high:
        return Icons.error;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.low:
        return Icons.info_outline;
    }
  }
}
