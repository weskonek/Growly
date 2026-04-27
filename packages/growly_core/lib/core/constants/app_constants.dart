class AppConstants {
  AppConstants._();

  static const String appName = 'Growly';
  static const String appVersion = '1.0.0';

  // Age groups for AI tutoring
  static const int earlyChildMinAge = 2;
  static const int earlyChildMaxAge = 5;
  static const int primaryMinAge = 6;
  static const int primaryMaxAge = 9;
  static const int upperPrimaryMinAge = 10;
  static const int upperPrimaryMaxAge = 12;
  static const int teenMinAge = 13;
  static const int teenMaxAge = 18;

  // Learning subjects
  static const List<String> learningSubjects = [
    'reading',
    'math',
    'science',
    'creative',
    'language',
  ];

  // Screen time limits (minutes)
  static const int defaultDailyScreenTimeLimit = 120;
  static const int maxDailyScreenTimeLimit = 240;

  // Cache TTL (hours)
  static const int aiResponseCacheTtlHours = 1;

  // Database
  static const String databaseName = 'growly_database.db';
  static const int databaseVersion = 1;

  // Hive boxes
  static const String authBoxName = 'auth_box';
  static const String settingsBoxName = 'settings_box';
  static const String aiCacheBoxName = 'ai_cache_box';
  static const String offlineBoxName = 'offline_box';

  // Platform channel
  static const String parentalControlChannel = 'com.growly/parental_control';
}