import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GrowlyCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final EdgeInsets? padding;
  final double borderRadius;

  const GrowlyCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.elevation,
    this.padding,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      elevation: elevation ?? 2,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class LauncherCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const LauncherCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GrowlyCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  final double progress;
  final String centerText;
  final Color color;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.centerText,
    this.color = AppTheme.growlyGreen,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Center(
            child: Text(
              centerText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  final String emoji;
  final String name;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.emoji,
    required this.name,
    this.isUnlocked = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.amber[100] : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked ? Colors.amber : Colors.grey,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                isUnlocked ? emoji : '🔒',
                style: TextStyle(
                  fontSize: 28,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? Colors.black87 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ScreenTimeIndicator extends StatelessWidget {
  final int minutes;
  final int limitMinutes;
  final bool showStatus;

  const ScreenTimeIndicator({
    super.key,
    required this.minutes,
    required this.limitMinutes,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = minutes / limitMinutes;
    final isOk = percentage < 0.8;
    final isWarning = percentage >= 0.8 && percentage < 1.0;
    final isOver = percentage >= 1.0;

    Color statusColor;
    String statusText;
    if (isOk) {
      statusColor = Colors.green;
      statusText = 'OK';
    } else if (isWarning) {
      statusColor = Colors.orange;
      statusText = 'Hampir Habis';
    } else {
      statusColor = Colors.red;
      statusText = 'Habis';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 8),
              Text(
                '${minutes}m',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                ' / ${limitMinutes}m',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          if (showStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}