import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParentalControlChannel {
  static const _channel = MethodChannel('com.growly/parental_control');

  Future<Map<String, dynamic>> getScreenTimeData(String childId) async {
    try {
      final result = await _channel.invokeMethod('getScreenTime', {'childId': childId});
      return Map<String, dynamic>.from(result);
    } on PlatformException {
      return {'error': 'Platform not supported'};
    }
  }

  Future<bool> setAppRestriction({
    required String appPackage,
    required bool isAllowed,
    int? timeLimit,
  }) async {
    try {
      final result = await _channel.invokeMethod('setAppRestriction', {
        'appPackage': appPackage,
        'isAllowed': isAllowed,
        'timeLimit': timeLimit,
      });
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> enableKioskMode(String childId) async {
    try {
      final result = await _channel.invokeMethod('enableKioskMode', {'childId': childId});
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> disableKioskMode() async {
    try {
      final result = await _channel.invokeMethod('disableKioskMode');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      return (result as List).cast<Map<String, dynamic>>();
    } on PlatformException {
      return [];
    }
  }

  Future<Map<String, dynamic>> getAppUsageStats(String packageName, DateTime start, DateTime end) async {
    try {
      final result = await _channel.invokeMethod('getAppUsageStats', {
        'package': packageName,
        'start': start.millisecondsSinceEpoch,
        'end': end.millisecondsSinceEpoch,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException {
      return {'error': 'Platform not supported'};
    }
  }

  Future<void> requestUsageStatsPermission() async {
    await _channel.invokeMethod('requestUsageStatsPermission');
  }
}

final parentalControlChannelProvider = Provider<ParentalControlChannel>((ref) {
  return ParentalControlChannel();
});