import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ios_parental_control.g.dart';

@riverpod
class IosParentalControl extends _$IosParentalControl {
  static const _channel = MethodChannel('com.growly/ios_parental_control');

  @override
  bool build() => true;

  Future<bool> requestScreenTimePermission() async {
    try {
      final result = await _channel.invokeMethod('requestScreenTimePermission');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> checkScreenTimeAuthorization() async {
    try {
      final result = await _channel.invokeMethod('checkScreenTimeAuthorization');
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<Map<String, int>> getScreenTimeByCategory(DateTime start, DateTime end) async {
    try {
      final result = await _channel.invokeMethod('getScreenTimeByCategory', {
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

  Future<bool> setAppLimit(String bundleId, int minutes) async {
    try {
      final result = await _channel.invokeMethod('setAppLimit', {
        'bundleId': bundleId,
        'minutes': minutes,
      });
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> removeAppLimit(String bundleId) async {
    try {
      final result = await _channel.invokeMethod('removeAppLimit', {'bundleId': bundleId});
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> setDowTimeRestriction(int startHour, int startMinute, int endHour, int endMinute) async {
    try {
      final result = await _channel.invokeMethod('setDndTimeRestriction', {
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
      });
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> enableContentRestriction(String category) async {
    try {
      final result = await _channel.invokeMethod('enableContentRestriction', {'category': category});
      return result as bool;
    } on PlatformException {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAppUsageDetails(DateTime start, DateTime end) async {
    try {
      final result = await _channel.invokeMethod('getAppUsageDetails', {
        'start': start.millisecondsSinceEpoch,
        'end': end.millisecondsSinceEpoch,
      });
      return (result as List).map((app) => Map<String, dynamic>.from(app)).toList();
    } on PlatformException {
      return [];
    }
  }
}