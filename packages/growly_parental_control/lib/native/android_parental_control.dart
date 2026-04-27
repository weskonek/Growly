import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'android_parental_control.g.dart';

@riverpod
class AndroidParentalControl extends _$AndroidParentalControl {
  static const _channel = MethodChannel('com.growly/android_parental_control');

  @override
  bool build() => true;

  Future<bool> checkUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('checkUsageStatsPermission');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<void> requestUsageStatsPermission() async {
    await _channel.invokeMethod('requestUsageStatsPermission');
  }

  Future<bool> isDeviceAdmin() async {
    try {
      final result = await _channel.invokeMethod('isDeviceAdmin');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> requestDeviceAdmin() async {
    try {
      final result = await _channel.invokeMethod('requestDeviceAdmin');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<Map<String, int>> getScreenTimeByApp(DateTime start, DateTime end) async {
    try {
      final result = await _channel.invokeMethod('getScreenTimeByApp', {
        'start': start.millisecondsSinceEpoch,
        'end': end.millisecondsSinceEpoch,
      });
      return Map<String, int>.from(result as Map);
    } on PlatformException {
      return {};
    }
  }

  Future<int> getTotalScreenTime(DateTime start, DateTime end) async {
    try {
      final result = await _channel.invokeMethod('getTotalScreenTime', {
        'start': start.millisecondsSinceEpoch,
        'end': end.millisecondsSinceEpoch,
      });
      return result as int;
    } on PlatformException {
      return 0;
    }
  }

  Future<bool> startAppUsageMonitoring() async {
    try {
      final result = await _channel.invokeMethod('startAppUsageMonitoring');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> stopAppUsageMonitoring() async {
    try {
      final result = await _channel.invokeMethod('stopAppUsageMonitoring');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> lockApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod('lockApp', {'package': packageName});
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> unlockApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod('unlockApp', {'package': packageName});
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> enableKioskMode(String allowedPackage) async {
    try {
      final result = await _channel.invokeMethod('enableKioskMode', {'allowedPackage': allowedPackage});
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
      return (result as List).map((app) => Map<String, dynamic>.from(app)).toList();
    } on PlatformException {
      return [];
    }
  }
}