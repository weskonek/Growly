import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'growly_database.g.dart';

class ChildProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get avatarUrl => text().nullable()();
  IntColumn get ageGroup => integer()();
  TextColumn get parentId => text()();
  TextColumn get pin => text().nullable()();
  TextColumn get settings => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LearningProgressTable extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(ChildProfiles, #id)();
  TextColumn get subject => text()();
  TextColumn get topic => text()();
  IntColumn get score => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class ScreenTimeRecords extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(ChildProfiles, #id)();
  TextColumn get appPackage => text()();
  TextColumn get appName => text().nullable()();
  IntColumn get durationMinutes => integer()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppRestrictions extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(ChildProfiles, #id)();
  TextColumn get appPackage => text()();
  TextColumn get appName => text().nullable()();
  TextColumn get appIcon => text().nullable()();
  BoolColumn get isAllowed => boolean()();
  IntColumn get timeLimitMinutes => integer().nullable()();
  TextColumn get scheduleLimits => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Schedules extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(ChildProfiles, #id)();
  IntColumn get dayOfWeek => integer()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get mode => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Badges extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(ChildProfiles, #id)();
  IntColumn get type => integer()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get emoji => text()();
  DateTimeColumn get earnedAt => dateTime()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()();
  TextColumn get data => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

class RewardSystems extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text().references(ChildProfiles, #id).unique()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  IntColumn get totalStars => integer().withDefault(const Constant(0))();
  TextColumn get unlockedBadges => text().withDefault(const Constant('[]'))();
  DateTimeColumn get lastActivityAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  ChildProfiles,
  LearningProgressTable,
  ScreenTimeRecords,
  AppRestrictions,
  Schedules,
  Badges,
  SyncQueue,
  RewardSystems,
])
class GrowlyDatabase extends _$GrowlyDatabase {
  GrowlyDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'growly_database.db');
  }

  // Child profiles queries
  Future<List<ChildProfile>> getChildProfiles(String parentId) {
    return (select(childProfiles)..where((t) => t.parentId.equals(parentId))).get();
  }

  Future<ChildProfile?> getChildProfile(String id) {
    return (select(childProfiles)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertChildProfile(ChildProfilesCompanion profile) {
    return into(childProfiles).insert(profile);
  }

  Future<void> updateChildProfile(ChildProfilesCompanion profile) {
    return (update(childProfiles)..where((t) => t.id.equals(profile.id.value)))
        .write(profile);
  }

  // Learning progress queries
  Future<List<LearningProgressTableData>> getLearningProgress(String childId) {
    return (select(learningProgressTable)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> insertLearningProgress(LearningProgressTableCompanion progress) {
    return into(learningProgressTable).insert(progress);
  }

  // Screen time queries
  Future<List<ScreenTimeRecord>> getScreenTimeRecords(String childId, DateTime date) {
    return (select(screenTimeRecords)
          ..where((t) => t.childId.equals(childId) & t.date.equals(date)))
        .get();
  }

  Future<void> insertScreenTimeRecord(ScreenTimeRecordsCompanion record) {
    return into(screenTimeRecords).insert(record);
  }

  // Schedule queries
  Future<List<Schedule>> getSchedules(String childId) {
    return (select(schedules)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.asc(t.dayOfWeek)]))
        .get();
  }

  Future<void> insertSchedule(SchedulesCompanion schedule) {
    return into(schedules).insert(schedule);
  }

  // Badge queries
  Future<List<Badge>> getBadges(String childId) {
    return (select(badges)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.earnedAt)]))
        .get();
  }

  Future<void> insertBadge(BadgesCompanion badge) {
    return into(badges).insert(badge);
  }
}