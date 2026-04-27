import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await _registerAdapters();
    await _openBoxes();
  }

  static Future<void> _registerAdapters() async {
    // Register custom adapters if needed
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox(AppConstants.authBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
    await Hive.openBox(AppConstants.aiCacheBoxName);
    await Hive.openBox(AppConstants.offlineBoxName);
  }

  // Auth box operations
  static Box get authBox => Hive.box(AppConstants.authBoxName);

  static Future<void> saveAuthToken(String token) async {
    await authBox.put('auth_token', token);
  }

  static String? getAuthToken() {
    return authBox.get('auth_token');
  }

  static Future<void> clearAuth() async {
    await authBox.clear();
  }

  // Settings box operations
  static Box get settingsBox => Hive.box(AppConstants.settingsBoxName);

  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static dynamic getSetting(String key) {
    return settingsBox.get(key);
  }

  static Future<void> saveSelectedChildId(String childId) async {
    await settingsBox.put('selected_child_id', childId);
  }

  static String? getSelectedChildId() {
    return settingsBox.get('selected_child_id');
  }

  // AI cache operations
  static Box get aiCacheBox => Hive.box(AppConstants.aiCacheBoxName);

  static Future<void> cacheAiResponse(String key, Map<String, dynamic> response) async {
    final cacheData = {
      'response': response,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await aiCacheBox.put(key, jsonEncode(cacheData));
  }

  static Map<String, dynamic>? getCachedAiResponse(String key) {
    final data = aiCacheBox.get(key);
    if (data == null) return null;

    final cacheData = jsonDecode(data) as Map<String, dynamic>;
    final timestamp = DateTime.parse(cacheData['timestamp'] as String);
    final ttlHours = AppConstants.aiResponseCacheTtlHours;

    if (DateTime.now().difference(timestamp).inHours > ttlHours) {
      aiCacheBox.delete(key);
      return null;
    }

    return cacheData['response'] as Map<String, dynamic>;
  }

  static Future<void> clearAiCache() async {
    await aiCacheBox.clear();
  }

  // Offline queue operations
  static Box get offlineBox => Hive.box(AppConstants.offlineBoxName);

  static Future<void> addToOfflineQueue(String operation, Map<String, dynamic> data) async {
    final queue = List<String>.from(offlineBox.get('queue') ?? []);
    queue.add(jsonEncode({
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    }));
    await offlineBox.put('queue', queue);
  }

  static List<Map<String, dynamic>> getOfflineQueue() {
    final queue = List<String>.from(offlineBox.get('queue') ?? []);
    return queue.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  static Future<void> clearOfflineQueue() async {
    await offlineBox.put('queue', <String>[]);
  }

  static Future<void> removeFromOfflineQueue(int index) async {
    final queue = List<String>.from(offlineBox.get('queue') ?? []);
    if (index >= 0 && index < queue.length) {
      queue.removeAt(index);
      await offlineBox.put('queue', queue);
    }
  }
}