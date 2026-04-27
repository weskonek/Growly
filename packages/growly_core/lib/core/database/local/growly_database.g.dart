// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growly_database.dart';

// ignore_for_file: type=lint
class $ChildProfilesTable extends ChildProfiles
    with TableInfo<$ChildProfilesTable, ChildProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ageGroupMeta =
      const VerificationMeta('ageGroup');
  @override
  late final GeneratedColumn<int> ageGroup = GeneratedColumn<int>(
      'age_group', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pinMeta = const VerificationMeta('pin');
  @override
  late final GeneratedColumn<String> pin = GeneratedColumn<String>(
      'pin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _settingsMeta =
      const VerificationMeta('settings');
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
      'settings', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        birthDate,
        avatarUrl,
        ageGroup,
        parentId,
        pin,
        settings,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<ChildProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('age_group')) {
      context.handle(_ageGroupMeta,
          ageGroup.isAcceptableOrUnknown(data['age_group']!, _ageGroupMeta));
    } else if (isInserting) {
      context.missing(_ageGroupMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    } else if (isInserting) {
      context.missing(_parentIdMeta);
    }
    if (data.containsKey('pin')) {
      context.handle(
          _pinMeta, pin.isAcceptableOrUnknown(data['pin']!, _pinMeta));
    }
    if (data.containsKey('settings')) {
      context.handle(_settingsMeta,
          settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      ageGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age_group'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id'])!,
      pin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin']),
      settings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settings'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $ChildProfilesTable createAlias(String alias) {
    return $ChildProfilesTable(attachedDatabase, alias);
  }
}

class ChildProfile extends DataClass implements Insertable<ChildProfile> {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? avatarUrl;
  final int ageGroup;
  final String parentId;
  final String? pin;
  final String settings;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const ChildProfile(
      {required this.id,
      required this.name,
      required this.birthDate,
      this.avatarUrl,
      required this.ageGroup,
      required this.parentId,
      this.pin,
      required this.settings,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['birth_date'] = Variable<DateTime>(birthDate);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['age_group'] = Variable<int>(ageGroup);
    map['parent_id'] = Variable<String>(parentId);
    if (!nullToAbsent || pin != null) {
      map['pin'] = Variable<String>(pin);
    }
    map['settings'] = Variable<String>(settings);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ChildProfilesCompanion toCompanion(bool nullToAbsent) {
    return ChildProfilesCompanion(
      id: Value(id),
      name: Value(name),
      birthDate: Value(birthDate),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      ageGroup: Value(ageGroup),
      parentId: Value(parentId),
      pin: pin == null && nullToAbsent ? const Value.absent() : Value(pin),
      settings: Value(settings),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      ageGroup: serializer.fromJson<int>(json['ageGroup']),
      parentId: serializer.fromJson<String>(json['parentId']),
      pin: serializer.fromJson<String?>(json['pin']),
      settings: serializer.fromJson<String>(json['settings']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'ageGroup': serializer.toJson<int>(ageGroup),
      'parentId': serializer.toJson<String>(parentId),
      'pin': serializer.toJson<String?>(pin),
      'settings': serializer.toJson<String>(settings),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ChildProfile copyWith(
          {String? id,
          String? name,
          DateTime? birthDate,
          Value<String?> avatarUrl = const Value.absent(),
          int? ageGroup,
          String? parentId,
          Value<String?> pin = const Value.absent(),
          String? settings,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      ChildProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        birthDate: birthDate ?? this.birthDate,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        ageGroup: ageGroup ?? this.ageGroup,
        parentId: parentId ?? this.parentId,
        pin: pin.present ? pin.value : this.pin,
        settings: settings ?? this.settings,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  ChildProfile copyWithCompanion(ChildProfilesCompanion data) {
    return ChildProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      ageGroup: data.ageGroup.present ? data.ageGroup.value : this.ageGroup,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      pin: data.pin.present ? data.pin.value : this.pin,
      settings: data.settings.present ? data.settings.value : this.settings,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('ageGroup: $ageGroup, ')
          ..write('parentId: $parentId, ')
          ..write('pin: $pin, ')
          ..write('settings: $settings, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, birthDate, avatarUrl, ageGroup,
      parentId, pin, settings, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthDate == this.birthDate &&
          other.avatarUrl == this.avatarUrl &&
          other.ageGroup == this.ageGroup &&
          other.parentId == this.parentId &&
          other.pin == this.pin &&
          other.settings == this.settings &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChildProfilesCompanion extends UpdateCompanion<ChildProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> birthDate;
  final Value<String?> avatarUrl;
  final Value<int> ageGroup;
  final Value<String> parentId;
  final Value<String?> pin;
  final Value<String> settings;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ChildProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.ageGroup = const Value.absent(),
    this.parentId = const Value.absent(),
    this.pin = const Value.absent(),
    this.settings = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildProfilesCompanion.insert({
    required String id,
    required String name,
    required DateTime birthDate,
    this.avatarUrl = const Value.absent(),
    required int ageGroup,
    required String parentId,
    this.pin = const Value.absent(),
    this.settings = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        birthDate = Value(birthDate),
        ageGroup = Value(ageGroup),
        parentId = Value(parentId),
        createdAt = Value(createdAt);
  static Insertable<ChildProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<String>? avatarUrl,
    Expression<int>? ageGroup,
    Expression<String>? parentId,
    Expression<String>? pin,
    Expression<String>? settings,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (ageGroup != null) 'age_group': ageGroup,
      if (parentId != null) 'parent_id': parentId,
      if (pin != null) 'pin': pin,
      if (settings != null) 'settings': settings,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? birthDate,
      Value<String?>? avatarUrl,
      Value<int>? ageGroup,
      Value<String>? parentId,
      Value<String?>? pin,
      Value<String>? settings,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return ChildProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ageGroup: ageGroup ?? this.ageGroup,
      parentId: parentId ?? this.parentId,
      pin: pin ?? this.pin,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (ageGroup.present) {
      map['age_group'] = Variable<int>(ageGroup.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (pin.present) {
      map['pin'] = Variable<String>(pin.value);
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('ageGroup: $ageGroup, ')
          ..write('parentId: $parentId, ')
          ..write('pin: $pin, ')
          ..write('settings: $settings, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningProgressTableTable extends LearningProgressTable
    with TableInfo<$LearningProgressTableTable, LearningProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES child_profiles (id)'));
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childId,
        subject,
        topic,
        score,
        completed,
        completedAt,
        createdAt,
        updatedAt,
        sessionId,
        metadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_progress_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<LearningProgressTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearningProgressTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningProgressTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
    );
  }

  @override
  $LearningProgressTableTable createAlias(String alias) {
    return $LearningProgressTableTable(attachedDatabase, alias);
  }
}

class LearningProgressTableData extends DataClass
    implements Insertable<LearningProgressTableData> {
  final String id;
  final String childId;
  final String subject;
  final String topic;
  final int score;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? sessionId;
  final String metadata;
  const LearningProgressTableData(
      {required this.id,
      required this.childId,
      required this.subject,
      required this.topic,
      required this.score,
      required this.completed,
      this.completedAt,
      required this.createdAt,
      this.updatedAt,
      this.sessionId,
      required this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['subject'] = Variable<String>(subject);
    map['topic'] = Variable<String>(topic);
    map['score'] = Variable<int>(score);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['metadata'] = Variable<String>(metadata);
    return map;
  }

  LearningProgressTableCompanion toCompanion(bool nullToAbsent) {
    return LearningProgressTableCompanion(
      id: Value(id),
      childId: Value(childId),
      subject: Value(subject),
      topic: Value(topic),
      score: Value(score),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      metadata: Value(metadata),
    );
  }

  factory LearningProgressTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningProgressTableData(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      subject: serializer.fromJson<String>(json['subject']),
      topic: serializer.fromJson<String>(json['topic']),
      score: serializer.fromJson<int>(json['score']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      metadata: serializer.fromJson<String>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'subject': serializer.toJson<String>(subject),
      'topic': serializer.toJson<String>(topic),
      'score': serializer.toJson<int>(score),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'sessionId': serializer.toJson<String?>(sessionId),
      'metadata': serializer.toJson<String>(metadata),
    };
  }

  LearningProgressTableData copyWith(
          {String? id,
          String? childId,
          String? subject,
          String? topic,
          int? score,
          bool? completed,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent(),
          Value<String?> sessionId = const Value.absent(),
          String? metadata}) =>
      LearningProgressTableData(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        subject: subject ?? this.subject,
        topic: topic ?? this.topic,
        score: score ?? this.score,
        completed: completed ?? this.completed,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        metadata: metadata ?? this.metadata,
      );
  LearningProgressTableData copyWithCompanion(
      LearningProgressTableCompanion data) {
    return LearningProgressTableData(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      subject: data.subject.present ? data.subject.value : this.subject,
      topic: data.topic.present ? data.topic.value : this.topic,
      score: data.score.present ? data.score.value : this.score,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningProgressTableData(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('score: $score, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, subject, topic, score, completed,
      completedAt, createdAt, updatedAt, sessionId, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningProgressTableData &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.subject == this.subject &&
          other.topic == this.topic &&
          other.score == this.score &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sessionId == this.sessionId &&
          other.metadata == this.metadata);
}

class LearningProgressTableCompanion
    extends UpdateCompanion<LearningProgressTableData> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> subject;
  final Value<String> topic;
  final Value<int> score;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<String?> sessionId;
  final Value<String> metadata;
  final Value<int> rowid;
  const LearningProgressTableCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.subject = const Value.absent(),
    this.topic = const Value.absent(),
    this.score = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearningProgressTableCompanion.insert({
    required String id,
    required String childId,
    required String subject,
    required String topic,
    this.score = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        subject = Value(subject),
        topic = Value(topic),
        createdAt = Value(createdAt);
  static Insertable<LearningProgressTableData> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? subject,
    Expression<String>? topic,
    Expression<int>? score,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? sessionId,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (subject != null) 'subject': subject,
      if (topic != null) 'topic': topic,
      if (score != null) 'score': score,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearningProgressTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<String>? subject,
      Value<String>? topic,
      Value<int>? score,
      Value<bool>? completed,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<String?>? sessionId,
      Value<String>? metadata,
      Value<int>? rowid}) {
    return LearningProgressTableCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      score: score ?? this.score,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionId: sessionId ?? this.sessionId,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningProgressTableCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('subject: $subject, ')
          ..write('topic: $topic, ')
          ..write('score: $score, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreenTimeRecordsTable extends ScreenTimeRecords
    with TableInfo<$ScreenTimeRecordsTable, ScreenTimeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreenTimeRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES child_profiles (id)'));
  static const VerificationMeta _appPackageMeta =
      const VerificationMeta('appPackage');
  @override
  late final GeneratedColumn<String> appPackage = GeneratedColumn<String>(
      'app_package', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appNameMeta =
      const VerificationMeta('appName');
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
      'app_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, childId, appPackage, appName, durationMinutes, date, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screen_time_records';
  @override
  VerificationContext validateIntegrity(Insertable<ScreenTimeRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('app_package')) {
      context.handle(
          _appPackageMeta,
          appPackage.isAcceptableOrUnknown(
              data['app_package']!, _appPackageMeta));
    } else if (isInserting) {
      context.missing(_appPackageMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(_appNameMeta,
          appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScreenTimeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreenTimeRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      appPackage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_package'])!,
      appName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_name']),
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ScreenTimeRecordsTable createAlias(String alias) {
    return $ScreenTimeRecordsTable(attachedDatabase, alias);
  }
}

class ScreenTimeRecord extends DataClass
    implements Insertable<ScreenTimeRecord> {
  final String id;
  final String childId;
  final String appPackage;
  final String? appName;
  final int durationMinutes;
  final DateTime date;
  final DateTime createdAt;
  const ScreenTimeRecord(
      {required this.id,
      required this.childId,
      required this.appPackage,
      this.appName,
      required this.durationMinutes,
      required this.date,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['app_package'] = Variable<String>(appPackage);
    if (!nullToAbsent || appName != null) {
      map['app_name'] = Variable<String>(appName);
    }
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScreenTimeRecordsCompanion toCompanion(bool nullToAbsent) {
    return ScreenTimeRecordsCompanion(
      id: Value(id),
      childId: Value(childId),
      appPackage: Value(appPackage),
      appName: appName == null && nullToAbsent
          ? const Value.absent()
          : Value(appName),
      durationMinutes: Value(durationMinutes),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory ScreenTimeRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreenTimeRecord(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      appPackage: serializer.fromJson<String>(json['appPackage']),
      appName: serializer.fromJson<String?>(json['appName']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'appPackage': serializer.toJson<String>(appPackage),
      'appName': serializer.toJson<String?>(appName),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScreenTimeRecord copyWith(
          {String? id,
          String? childId,
          String? appPackage,
          Value<String?> appName = const Value.absent(),
          int? durationMinutes,
          DateTime? date,
          DateTime? createdAt}) =>
      ScreenTimeRecord(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        appPackage: appPackage ?? this.appPackage,
        appName: appName.present ? appName.value : this.appName,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
      );
  ScreenTimeRecord copyWithCompanion(ScreenTimeRecordsCompanion data) {
    return ScreenTimeRecord(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      appPackage:
          data.appPackage.present ? data.appPackage.value : this.appPackage,
      appName: data.appName.present ? data.appName.value : this.appName,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeRecord(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('appPackage: $appPackage, ')
          ..write('appName: $appName, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, childId, appPackage, appName, durationMinutes, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreenTimeRecord &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.appPackage == this.appPackage &&
          other.appName == this.appName &&
          other.durationMinutes == this.durationMinutes &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class ScreenTimeRecordsCompanion extends UpdateCompanion<ScreenTimeRecord> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> appPackage;
  final Value<String?> appName;
  final Value<int> durationMinutes;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ScreenTimeRecordsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.appPackage = const Value.absent(),
    this.appName = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreenTimeRecordsCompanion.insert({
    required String id,
    required String childId,
    required String appPackage,
    this.appName = const Value.absent(),
    required int durationMinutes,
    required DateTime date,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        appPackage = Value(appPackage),
        durationMinutes = Value(durationMinutes),
        date = Value(date),
        createdAt = Value(createdAt);
  static Insertable<ScreenTimeRecord> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? appPackage,
    Expression<String>? appName,
    Expression<int>? durationMinutes,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (appPackage != null) 'app_package': appPackage,
      if (appName != null) 'app_name': appName,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreenTimeRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<String>? appPackage,
      Value<String?>? appName,
      Value<int>? durationMinutes,
      Value<DateTime>? date,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ScreenTimeRecordsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      appPackage: appPackage ?? this.appPackage,
      appName: appName ?? this.appName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (appPackage.present) {
      map['app_package'] = Variable<String>(appPackage.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreenTimeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('appPackage: $appPackage, ')
          ..write('appName: $appName, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppRestrictionsTable extends AppRestrictions
    with TableInfo<$AppRestrictionsTable, AppRestriction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppRestrictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES child_profiles (id)'));
  static const VerificationMeta _appPackageMeta =
      const VerificationMeta('appPackage');
  @override
  late final GeneratedColumn<String> appPackage = GeneratedColumn<String>(
      'app_package', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appNameMeta =
      const VerificationMeta('appName');
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
      'app_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _appIconMeta =
      const VerificationMeta('appIcon');
  @override
  late final GeneratedColumn<String> appIcon = GeneratedColumn<String>(
      'app_icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAllowedMeta =
      const VerificationMeta('isAllowed');
  @override
  late final GeneratedColumn<bool> isAllowed = GeneratedColumn<bool>(
      'is_allowed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_allowed" IN (0, 1))'));
  static const VerificationMeta _timeLimitMinutesMeta =
      const VerificationMeta('timeLimitMinutes');
  @override
  late final GeneratedColumn<int> timeLimitMinutes = GeneratedColumn<int>(
      'time_limit_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _scheduleLimitsMeta =
      const VerificationMeta('scheduleLimits');
  @override
  late final GeneratedColumn<String> scheduleLimits = GeneratedColumn<String>(
      'schedule_limits', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childId,
        appPackage,
        appName,
        appIcon,
        isAllowed,
        timeLimitMinutes,
        scheduleLimits,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_restrictions';
  @override
  VerificationContext validateIntegrity(Insertable<AppRestriction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('app_package')) {
      context.handle(
          _appPackageMeta,
          appPackage.isAcceptableOrUnknown(
              data['app_package']!, _appPackageMeta));
    } else if (isInserting) {
      context.missing(_appPackageMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(_appNameMeta,
          appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta));
    }
    if (data.containsKey('app_icon')) {
      context.handle(_appIconMeta,
          appIcon.isAcceptableOrUnknown(data['app_icon']!, _appIconMeta));
    }
    if (data.containsKey('is_allowed')) {
      context.handle(_isAllowedMeta,
          isAllowed.isAcceptableOrUnknown(data['is_allowed']!, _isAllowedMeta));
    } else if (isInserting) {
      context.missing(_isAllowedMeta);
    }
    if (data.containsKey('time_limit_minutes')) {
      context.handle(
          _timeLimitMinutesMeta,
          timeLimitMinutes.isAcceptableOrUnknown(
              data['time_limit_minutes']!, _timeLimitMinutesMeta));
    }
    if (data.containsKey('schedule_limits')) {
      context.handle(
          _scheduleLimitsMeta,
          scheduleLimits.isAcceptableOrUnknown(
              data['schedule_limits']!, _scheduleLimitsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppRestriction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppRestriction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      appPackage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_package'])!,
      appName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_name']),
      appIcon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_icon']),
      isAllowed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_allowed'])!,
      timeLimitMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_limit_minutes']),
      scheduleLimits: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}schedule_limits'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $AppRestrictionsTable createAlias(String alias) {
    return $AppRestrictionsTable(attachedDatabase, alias);
  }
}

class AppRestriction extends DataClass implements Insertable<AppRestriction> {
  final String id;
  final String childId;
  final String appPackage;
  final String? appName;
  final String? appIcon;
  final bool isAllowed;
  final int? timeLimitMinutes;
  final String scheduleLimits;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const AppRestriction(
      {required this.id,
      required this.childId,
      required this.appPackage,
      this.appName,
      this.appIcon,
      required this.isAllowed,
      this.timeLimitMinutes,
      required this.scheduleLimits,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['app_package'] = Variable<String>(appPackage);
    if (!nullToAbsent || appName != null) {
      map['app_name'] = Variable<String>(appName);
    }
    if (!nullToAbsent || appIcon != null) {
      map['app_icon'] = Variable<String>(appIcon);
    }
    map['is_allowed'] = Variable<bool>(isAllowed);
    if (!nullToAbsent || timeLimitMinutes != null) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes);
    }
    map['schedule_limits'] = Variable<String>(scheduleLimits);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AppRestrictionsCompanion toCompanion(bool nullToAbsent) {
    return AppRestrictionsCompanion(
      id: Value(id),
      childId: Value(childId),
      appPackage: Value(appPackage),
      appName: appName == null && nullToAbsent
          ? const Value.absent()
          : Value(appName),
      appIcon: appIcon == null && nullToAbsent
          ? const Value.absent()
          : Value(appIcon),
      isAllowed: Value(isAllowed),
      timeLimitMinutes: timeLimitMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeLimitMinutes),
      scheduleLimits: Value(scheduleLimits),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AppRestriction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppRestriction(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      appPackage: serializer.fromJson<String>(json['appPackage']),
      appName: serializer.fromJson<String?>(json['appName']),
      appIcon: serializer.fromJson<String?>(json['appIcon']),
      isAllowed: serializer.fromJson<bool>(json['isAllowed']),
      timeLimitMinutes: serializer.fromJson<int?>(json['timeLimitMinutes']),
      scheduleLimits: serializer.fromJson<String>(json['scheduleLimits']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'appPackage': serializer.toJson<String>(appPackage),
      'appName': serializer.toJson<String?>(appName),
      'appIcon': serializer.toJson<String?>(appIcon),
      'isAllowed': serializer.toJson<bool>(isAllowed),
      'timeLimitMinutes': serializer.toJson<int?>(timeLimitMinutes),
      'scheduleLimits': serializer.toJson<String>(scheduleLimits),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  AppRestriction copyWith(
          {String? id,
          String? childId,
          String? appPackage,
          Value<String?> appName = const Value.absent(),
          Value<String?> appIcon = const Value.absent(),
          bool? isAllowed,
          Value<int?> timeLimitMinutes = const Value.absent(),
          String? scheduleLimits,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      AppRestriction(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        appPackage: appPackage ?? this.appPackage,
        appName: appName.present ? appName.value : this.appName,
        appIcon: appIcon.present ? appIcon.value : this.appIcon,
        isAllowed: isAllowed ?? this.isAllowed,
        timeLimitMinutes: timeLimitMinutes.present
            ? timeLimitMinutes.value
            : this.timeLimitMinutes,
        scheduleLimits: scheduleLimits ?? this.scheduleLimits,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  AppRestriction copyWithCompanion(AppRestrictionsCompanion data) {
    return AppRestriction(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      appPackage:
          data.appPackage.present ? data.appPackage.value : this.appPackage,
      appName: data.appName.present ? data.appName.value : this.appName,
      appIcon: data.appIcon.present ? data.appIcon.value : this.appIcon,
      isAllowed: data.isAllowed.present ? data.isAllowed.value : this.isAllowed,
      timeLimitMinutes: data.timeLimitMinutes.present
          ? data.timeLimitMinutes.value
          : this.timeLimitMinutes,
      scheduleLimits: data.scheduleLimits.present
          ? data.scheduleLimits.value
          : this.scheduleLimits,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppRestriction(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('appPackage: $appPackage, ')
          ..write('appName: $appName, ')
          ..write('appIcon: $appIcon, ')
          ..write('isAllowed: $isAllowed, ')
          ..write('timeLimitMinutes: $timeLimitMinutes, ')
          ..write('scheduleLimits: $scheduleLimits, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, appPackage, appName, appIcon,
      isAllowed, timeLimitMinutes, scheduleLimits, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppRestriction &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.appPackage == this.appPackage &&
          other.appName == this.appName &&
          other.appIcon == this.appIcon &&
          other.isAllowed == this.isAllowed &&
          other.timeLimitMinutes == this.timeLimitMinutes &&
          other.scheduleLimits == this.scheduleLimits &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppRestrictionsCompanion extends UpdateCompanion<AppRestriction> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> appPackage;
  final Value<String?> appName;
  final Value<String?> appIcon;
  final Value<bool> isAllowed;
  final Value<int?> timeLimitMinutes;
  final Value<String> scheduleLimits;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const AppRestrictionsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.appPackage = const Value.absent(),
    this.appName = const Value.absent(),
    this.appIcon = const Value.absent(),
    this.isAllowed = const Value.absent(),
    this.timeLimitMinutes = const Value.absent(),
    this.scheduleLimits = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppRestrictionsCompanion.insert({
    required String id,
    required String childId,
    required String appPackage,
    this.appName = const Value.absent(),
    this.appIcon = const Value.absent(),
    required bool isAllowed,
    this.timeLimitMinutes = const Value.absent(),
    this.scheduleLimits = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        appPackage = Value(appPackage),
        isAllowed = Value(isAllowed),
        createdAt = Value(createdAt);
  static Insertable<AppRestriction> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? appPackage,
    Expression<String>? appName,
    Expression<String>? appIcon,
    Expression<bool>? isAllowed,
    Expression<int>? timeLimitMinutes,
    Expression<String>? scheduleLimits,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (appPackage != null) 'app_package': appPackage,
      if (appName != null) 'app_name': appName,
      if (appIcon != null) 'app_icon': appIcon,
      if (isAllowed != null) 'is_allowed': isAllowed,
      if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
      if (scheduleLimits != null) 'schedule_limits': scheduleLimits,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppRestrictionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<String>? appPackage,
      Value<String?>? appName,
      Value<String?>? appIcon,
      Value<bool>? isAllowed,
      Value<int?>? timeLimitMinutes,
      Value<String>? scheduleLimits,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return AppRestrictionsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      appPackage: appPackage ?? this.appPackage,
      appName: appName ?? this.appName,
      appIcon: appIcon ?? this.appIcon,
      isAllowed: isAllowed ?? this.isAllowed,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      scheduleLimits: scheduleLimits ?? this.scheduleLimits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (appPackage.present) {
      map['app_package'] = Variable<String>(appPackage.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (appIcon.present) {
      map['app_icon'] = Variable<String>(appIcon.value);
    }
    if (isAllowed.present) {
      map['is_allowed'] = Variable<bool>(isAllowed.value);
    }
    if (timeLimitMinutes.present) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes.value);
    }
    if (scheduleLimits.present) {
      map['schedule_limits'] = Variable<String>(scheduleLimits.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppRestrictionsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('appPackage: $appPackage, ')
          ..write('appName: $appName, ')
          ..write('appIcon: $appIcon, ')
          ..write('isAllowed: $isAllowed, ')
          ..write('timeLimitMinutes: $timeLimitMinutes, ')
          ..write('scheduleLimits: $scheduleLimits, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES child_profiles (id)'));
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childId,
        dayOfWeek,
        startTime,
        endTime,
        mode,
        isEnabled,
        label,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(Insertable<Schedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final String id;
  final String childId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String mode;
  final bool isEnabled;
  final String? label;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Schedule(
      {required this.id,
      required this.childId,
      required this.dayOfWeek,
      required this.startTime,
      required this.endTime,
      required this.mode,
      required this.isEnabled,
      this.label,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['mode'] = Variable<String>(mode);
    map['is_enabled'] = Variable<bool>(isEnabled);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      childId: Value(childId),
      dayOfWeek: Value(dayOfWeek),
      startTime: Value(startTime),
      endTime: Value(endTime),
      mode: Value(mode),
      isEnabled: Value(isEnabled),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      mode: serializer.fromJson<String>(json['mode']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'mode': serializer.toJson<String>(mode),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Schedule copyWith(
          {String? id,
          String? childId,
          int? dayOfWeek,
          String? startTime,
          String? endTime,
          String? mode,
          bool? isEnabled,
          Value<String?> label = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Schedule(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        mode: mode ?? this.mode,
        isEnabled: isEnabled ?? this.isEnabled,
        label: label.present ? label.value : this.label,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      mode: data.mode.present ? data.mode.value : this.mode,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('mode: $mode, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, dayOfWeek, startTime, endTime,
      mode, isEnabled, label, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.mode == this.mode &&
          other.isEnabled == this.isEnabled &&
          other.label == this.label &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<String> id;
  final Value<String> childId;
  final Value<int> dayOfWeek;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> mode;
  final Value<bool> isEnabled;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.mode = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchedulesCompanion.insert({
    required String id,
    required String childId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String mode,
    this.isEnabled = const Value.absent(),
    this.label = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        dayOfWeek = Value(dayOfWeek),
        startTime = Value(startTime),
        endTime = Value(endTime),
        mode = Value(mode),
        createdAt = Value(createdAt);
  static Insertable<Schedule> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<int>? dayOfWeek,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? mode,
    Expression<bool>? isEnabled,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (mode != null) 'mode': mode,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchedulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<int>? dayOfWeek,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<String>? mode,
      Value<bool>? isEnabled,
      Value<String?>? label,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return SchedulesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      mode: mode ?? this.mode,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('mode: $mode, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadgesTable extends Badges with TableInfo<$BadgesTable, Badge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES child_profiles (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _earnedAtMeta =
      const VerificationMeta('earnedAt');
  @override
  late final GeneratedColumn<DateTime> earnedAt = GeneratedColumn<DateTime>(
      'earned_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, childId, type, name, description, emoji, earnedAt, metadata];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badges';
  @override
  VerificationContext validateIntegrity(Insertable<Badge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(_earnedAtMeta,
          earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta));
    } else if (isInserting) {
      context.missing(_earnedAtMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Badge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Badge(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      earnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}earned_at'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
    );
  }

  @override
  $BadgesTable createAlias(String alias) {
    return $BadgesTable(attachedDatabase, alias);
  }
}

class Badge extends DataClass implements Insertable<Badge> {
  final String id;
  final String childId;
  final int type;
  final String name;
  final String description;
  final String emoji;
  final DateTime earnedAt;
  final String metadata;
  const Badge(
      {required this.id,
      required this.childId,
      required this.type,
      required this.name,
      required this.description,
      required this.emoji,
      required this.earnedAt,
      required this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['type'] = Variable<int>(type);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['emoji'] = Variable<String>(emoji);
    map['earned_at'] = Variable<DateTime>(earnedAt);
    map['metadata'] = Variable<String>(metadata);
    return map;
  }

  BadgesCompanion toCompanion(bool nullToAbsent) {
    return BadgesCompanion(
      id: Value(id),
      childId: Value(childId),
      type: Value(type),
      name: Value(name),
      description: Value(description),
      emoji: Value(emoji),
      earnedAt: Value(earnedAt),
      metadata: Value(metadata),
    );
  }

  factory Badge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Badge(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      type: serializer.fromJson<int>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      emoji: serializer.fromJson<String>(json['emoji']),
      earnedAt: serializer.fromJson<DateTime>(json['earnedAt']),
      metadata: serializer.fromJson<String>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'type': serializer.toJson<int>(type),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'emoji': serializer.toJson<String>(emoji),
      'earnedAt': serializer.toJson<DateTime>(earnedAt),
      'metadata': serializer.toJson<String>(metadata),
    };
  }

  Badge copyWith(
          {String? id,
          String? childId,
          int? type,
          String? name,
          String? description,
          String? emoji,
          DateTime? earnedAt,
          String? metadata}) =>
      Badge(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description ?? this.description,
        emoji: emoji ?? this.emoji,
        earnedAt: earnedAt ?? this.earnedAt,
        metadata: metadata ?? this.metadata,
      );
  Badge copyWithCompanion(BadgesCompanion data) {
    return Badge(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Badge(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('emoji: $emoji, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, childId, type, name, description, emoji, earnedAt, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Badge &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.type == this.type &&
          other.name == this.name &&
          other.description == this.description &&
          other.emoji == this.emoji &&
          other.earnedAt == this.earnedAt &&
          other.metadata == this.metadata);
}

class BadgesCompanion extends UpdateCompanion<Badge> {
  final Value<String> id;
  final Value<String> childId;
  final Value<int> type;
  final Value<String> name;
  final Value<String> description;
  final Value<String> emoji;
  final Value<DateTime> earnedAt;
  final Value<String> metadata;
  final Value<int> rowid;
  const BadgesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.emoji = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgesCompanion.insert({
    required String id,
    required String childId,
    required int type,
    required String name,
    required String description,
    required String emoji,
    required DateTime earnedAt,
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        type = Value(type),
        name = Value(name),
        description = Value(description),
        emoji = Value(emoji),
        earnedAt = Value(earnedAt);
  static Insertable<Badge> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<int>? type,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? emoji,
    Expression<DateTime>? earnedAt,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (emoji != null) 'emoji': emoji,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgesCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<int>? type,
      Value<String>? name,
      Value<String>? description,
      Value<String>? emoji,
      Value<DateTime>? earnedAt,
      Value<String>? metadata,
      Value<int>? rowid}) {
    return BadgesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      earnedAt: earnedAt ?? this.earnedAt,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<DateTime>(earnedAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('emoji: $emoji, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tableNameMeta =
      const VerificationMeta('tableName');
  @override
  late final GeneratedColumn<String> tableName = GeneratedColumn<String>(
      'table_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordIdMeta =
      const VerificationMeta('recordId');
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
      'record_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tableName, recordId, operation, data, createdAt, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_name')) {
      context.handle(_tableNameMeta,
          tableName.isAcceptableOrUnknown(data['table_name']!, _tableNameMeta));
    } else if (isInserting) {
      context.missing(_tableNameMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(_recordIdMeta,
          recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta));
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tableName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}table_name'])!,
      recordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String tableName;
  final String recordId;
  final String operation;
  final String data;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const SyncQueueData(
      {required this.id,
      required this.tableName,
      required this.recordId,
      required this.operation,
      required this.data,
      required this.createdAt,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['table_name'] = Variable<String>(tableName);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['data'] = Variable<String>(data);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      tableName: Value(tableName),
      recordId: Value(recordId),
      operation: Value(operation),
      data: Value(data),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      tableName: serializer.fromJson<String>(json['tableName']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      data: serializer.fromJson<String>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tableName': serializer.toJson<String>(tableName),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'data': serializer.toJson<String>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? tableName,
          String? recordId,
          String? operation,
          String? data,
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      SyncQueueData(
        id: id ?? this.id,
        tableName: tableName ?? this.tableName,
        recordId: recordId ?? this.recordId,
        operation: operation ?? this.operation,
        data: data ?? this.data,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      tableName: data.tableName.present ? data.tableName.value : this.tableName,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('tableName: $tableName, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, tableName, recordId, operation, data, createdAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.tableName == this.tableName &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> tableName;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<String> data;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.tableName = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String tableName,
    required String recordId,
    required String operation,
    required String data,
    required DateTime createdAt,
    this.syncedAt = const Value.absent(),
  })  : tableName = Value(tableName),
        recordId = Value(recordId),
        operation = Value(operation),
        data = Value(data),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? tableName,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableName != null) 'table_name': tableName,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? tableName,
      Value<String>? recordId,
      Value<String>? operation,
      Value<String>? data,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tableName.present) {
      map['table_name'] = Variable<String>(tableName.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('tableName: $tableName, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $RewardSystemsTable extends RewardSystems
    with TableInfo<$RewardSystemsTable, RewardSystem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardSystemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
      'child_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'UNIQUE REFERENCES child_profiles (id)'));
  static const VerificationMeta _currentStreakMeta =
      const VerificationMeta('currentStreak');
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
      'current_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _longestStreakMeta =
      const VerificationMeta('longestStreak');
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
      'longest_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalStarsMeta =
      const VerificationMeta('totalStars');
  @override
  late final GeneratedColumn<int> totalStars = GeneratedColumn<int>(
      'total_stars', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unlockedBadgesMeta =
      const VerificationMeta('unlockedBadges');
  @override
  late final GeneratedColumn<String> unlockedBadges = GeneratedColumn<String>(
      'unlocked_badges', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _lastActivityAtMeta =
      const VerificationMeta('lastActivityAt');
  @override
  late final GeneratedColumn<DateTime> lastActivityAt =
      GeneratedColumn<DateTime>('last_activity_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        childId,
        currentStreak,
        longestStreak,
        totalStars,
        unlockedBadges,
        lastActivityAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reward_systems';
  @override
  VerificationContext validateIntegrity(Insertable<RewardSystem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('current_streak')) {
      context.handle(
          _currentStreakMeta,
          currentStreak.isAcceptableOrUnknown(
              data['current_streak']!, _currentStreakMeta));
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
          _longestStreakMeta,
          longestStreak.isAcceptableOrUnknown(
              data['longest_streak']!, _longestStreakMeta));
    }
    if (data.containsKey('total_stars')) {
      context.handle(
          _totalStarsMeta,
          totalStars.isAcceptableOrUnknown(
              data['total_stars']!, _totalStarsMeta));
    }
    if (data.containsKey('unlocked_badges')) {
      context.handle(
          _unlockedBadgesMeta,
          unlockedBadges.isAcceptableOrUnknown(
              data['unlocked_badges']!, _unlockedBadgesMeta));
    }
    if (data.containsKey('last_activity_at')) {
      context.handle(
          _lastActivityAtMeta,
          lastActivityAt.isAcceptableOrUnknown(
              data['last_activity_at']!, _lastActivityAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RewardSystem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RewardSystem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_id'])!,
      currentStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_streak'])!,
      longestStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}longest_streak'])!,
      totalStars: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_stars'])!,
      unlockedBadges: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}unlocked_badges'])!,
      lastActivityAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_activity_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $RewardSystemsTable createAlias(String alias) {
    return $RewardSystemsTable(attachedDatabase, alias);
  }
}

class RewardSystem extends DataClass implements Insertable<RewardSystem> {
  final String id;
  final String childId;
  final int currentStreak;
  final int longestStreak;
  final int totalStars;
  final String unlockedBadges;
  final DateTime? lastActivityAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const RewardSystem(
      {required this.id,
      required this.childId,
      required this.currentStreak,
      required this.longestStreak,
      required this.totalStars,
      required this.unlockedBadges,
      this.lastActivityAt,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    map['total_stars'] = Variable<int>(totalStars);
    map['unlocked_badges'] = Variable<String>(unlockedBadges);
    if (!nullToAbsent || lastActivityAt != null) {
      map['last_activity_at'] = Variable<DateTime>(lastActivityAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  RewardSystemsCompanion toCompanion(bool nullToAbsent) {
    return RewardSystemsCompanion(
      id: Value(id),
      childId: Value(childId),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      totalStars: Value(totalStars),
      unlockedBadges: Value(unlockedBadges),
      lastActivityAt: lastActivityAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivityAt),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory RewardSystem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RewardSystem(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      totalStars: serializer.fromJson<int>(json['totalStars']),
      unlockedBadges: serializer.fromJson<String>(json['unlockedBadges']),
      lastActivityAt: serializer.fromJson<DateTime?>(json['lastActivityAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'totalStars': serializer.toJson<int>(totalStars),
      'unlockedBadges': serializer.toJson<String>(unlockedBadges),
      'lastActivityAt': serializer.toJson<DateTime?>(lastActivityAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  RewardSystem copyWith(
          {String? id,
          String? childId,
          int? currentStreak,
          int? longestStreak,
          int? totalStars,
          String? unlockedBadges,
          Value<DateTime?> lastActivityAt = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      RewardSystem(
        id: id ?? this.id,
        childId: childId ?? this.childId,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        totalStars: totalStars ?? this.totalStars,
        unlockedBadges: unlockedBadges ?? this.unlockedBadges,
        lastActivityAt:
            lastActivityAt.present ? lastActivityAt.value : this.lastActivityAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  RewardSystem copyWithCompanion(RewardSystemsCompanion data) {
    return RewardSystem(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      totalStars:
          data.totalStars.present ? data.totalStars.value : this.totalStars,
      unlockedBadges: data.unlockedBadges.present
          ? data.unlockedBadges.value
          : this.unlockedBadges,
      lastActivityAt: data.lastActivityAt.present
          ? data.lastActivityAt.value
          : this.lastActivityAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RewardSystem(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('totalStars: $totalStars, ')
          ..write('unlockedBadges: $unlockedBadges, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, currentStreak, longestStreak,
      totalStars, unlockedBadges, lastActivityAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardSystem &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.totalStars == this.totalStars &&
          other.unlockedBadges == this.unlockedBadges &&
          other.lastActivityAt == this.lastActivityAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RewardSystemsCompanion extends UpdateCompanion<RewardSystem> {
  final Value<String> id;
  final Value<String> childId;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<int> totalStars;
  final Value<String> unlockedBadges;
  final Value<DateTime?> lastActivityAt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const RewardSystemsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.totalStars = const Value.absent(),
    this.unlockedBadges = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RewardSystemsCompanion.insert({
    required String id,
    required String childId,
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.totalStars = const Value.absent(),
    this.unlockedBadges = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        childId = Value(childId),
        createdAt = Value(createdAt);
  static Insertable<RewardSystem> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<int>? totalStars,
    Expression<String>? unlockedBadges,
    Expression<DateTime>? lastActivityAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (totalStars != null) 'total_stars': totalStars,
      if (unlockedBadges != null) 'unlocked_badges': unlockedBadges,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RewardSystemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? childId,
      Value<int>? currentStreak,
      Value<int>? longestStreak,
      Value<int>? totalStars,
      Value<String>? unlockedBadges,
      Value<DateTime?>? lastActivityAt,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return RewardSystemsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalStars: totalStars ?? this.totalStars,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (totalStars.present) {
      map['total_stars'] = Variable<int>(totalStars.value);
    }
    if (unlockedBadges.present) {
      map['unlocked_badges'] = Variable<String>(unlockedBadges.value);
    }
    if (lastActivityAt.present) {
      map['last_activity_at'] = Variable<DateTime>(lastActivityAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardSystemsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('totalStars: $totalStars, ')
          ..write('unlockedBadges: $unlockedBadges, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$GrowlyDatabase extends GeneratedDatabase {
  _$GrowlyDatabase(QueryExecutor e) : super(e);
  $GrowlyDatabaseManager get managers => $GrowlyDatabaseManager(this);
  late final $ChildProfilesTable childProfiles = $ChildProfilesTable(this);
  late final $LearningProgressTableTable learningProgressTable =
      $LearningProgressTableTable(this);
  late final $ScreenTimeRecordsTable screenTimeRecords =
      $ScreenTimeRecordsTable(this);
  late final $AppRestrictionsTable appRestrictions =
      $AppRestrictionsTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $BadgesTable badges = $BadgesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $RewardSystemsTable rewardSystems = $RewardSystemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        childProfiles,
        learningProgressTable,
        screenTimeRecords,
        appRestrictions,
        schedules,
        badges,
        syncQueue,
        rewardSystems
      ];
}

typedef $$ChildProfilesTableCreateCompanionBuilder = ChildProfilesCompanion
    Function({
  required String id,
  required String name,
  required DateTime birthDate,
  Value<String?> avatarUrl,
  required int ageGroup,
  required String parentId,
  Value<String?> pin,
  Value<String> settings,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$ChildProfilesTableUpdateCompanionBuilder = ChildProfilesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> birthDate,
  Value<String?> avatarUrl,
  Value<int> ageGroup,
  Value<String> parentId,
  Value<String?> pin,
  Value<String> settings,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

final class $$ChildProfilesTableReferences extends BaseReferences<
    _$GrowlyDatabase, $ChildProfilesTable, ChildProfile> {
  $$ChildProfilesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LearningProgressTableTable,
      List<LearningProgressTableData>> _learningProgressTableRefsTable(
          _$GrowlyDatabase db) =>
      MultiTypedResultKey.fromTable(db.learningProgressTable,
          aliasName: $_aliasNameGenerator(
              db.childProfiles.id, db.learningProgressTable.childId));

  $$LearningProgressTableTableProcessedTableManager
      get learningProgressTableRefs {
    final manager = $$LearningProgressTableTableTableManager(
            $_db, $_db.learningProgressTable)
        .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_learningProgressTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ScreenTimeRecordsTable, List<ScreenTimeRecord>>
      _screenTimeRecordsRefsTable(_$GrowlyDatabase db) =>
          MultiTypedResultKey.fromTable(db.screenTimeRecords,
              aliasName: $_aliasNameGenerator(
                  db.childProfiles.id, db.screenTimeRecords.childId));

  $$ScreenTimeRecordsTableProcessedTableManager get screenTimeRecordsRefs {
    final manager =
        $$ScreenTimeRecordsTableTableManager($_db, $_db.screenTimeRecords)
            .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_screenTimeRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AppRestrictionsTable, List<AppRestriction>>
      _appRestrictionsRefsTable(_$GrowlyDatabase db) =>
          MultiTypedResultKey.fromTable(db.appRestrictions,
              aliasName: $_aliasNameGenerator(
                  db.childProfiles.id, db.appRestrictions.childId));

  $$AppRestrictionsTableProcessedTableManager get appRestrictionsRefs {
    final manager =
        $$AppRestrictionsTableTableManager($_db, $_db.appRestrictions)
            .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_appRestrictionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SchedulesTable, List<Schedule>>
      _schedulesRefsTable(_$GrowlyDatabase db) => MultiTypedResultKey.fromTable(
          db.schedules,
          aliasName:
              $_aliasNameGenerator(db.childProfiles.id, db.schedules.childId));

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BadgesTable, List<Badge>> _badgesRefsTable(
          _$GrowlyDatabase db) =>
      MultiTypedResultKey.fromTable(db.badges,
          aliasName:
              $_aliasNameGenerator(db.childProfiles.id, db.badges.childId));

  $$BadgesTableProcessedTableManager get badgesRefs {
    final manager = $$BadgesTableTableManager($_db, $_db.badges)
        .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_badgesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RewardSystemsTable, List<RewardSystem>>
      _rewardSystemsRefsTable(_$GrowlyDatabase db) =>
          MultiTypedResultKey.fromTable(db.rewardSystems,
              aliasName: $_aliasNameGenerator(
                  db.childProfiles.id, db.rewardSystems.childId));

  $$RewardSystemsTableProcessedTableManager get rewardSystemsRefs {
    final manager = $$RewardSystemsTableTableManager($_db, $_db.rewardSystems)
        .filter((f) => f.childId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_rewardSystemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ChildProfilesTableFilterComposer
    extends Composer<_$GrowlyDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ageGroup => $composableBuilder(
      column: $table.ageGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pin => $composableBuilder(
      column: $table.pin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settings => $composableBuilder(
      column: $table.settings, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> learningProgressTableRefs(
      Expression<bool> Function($$LearningProgressTableTableFilterComposer f)
          f) {
    final $$LearningProgressTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.learningProgressTable,
            getReferencedColumn: (t) => t.childId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LearningProgressTableTableFilterComposer(
                  $db: $db,
                  $table: $db.learningProgressTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> screenTimeRecordsRefs(
      Expression<bool> Function($$ScreenTimeRecordsTableFilterComposer f) f) {
    final $$ScreenTimeRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.screenTimeRecords,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScreenTimeRecordsTableFilterComposer(
              $db: $db,
              $table: $db.screenTimeRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> appRestrictionsRefs(
      Expression<bool> Function($$AppRestrictionsTableFilterComposer f) f) {
    final $$AppRestrictionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appRestrictions,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppRestrictionsTableFilterComposer(
              $db: $db,
              $table: $db.appRestrictions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> schedulesRefs(
      Expression<bool> Function($$SchedulesTableFilterComposer f) f) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> badgesRefs(
      Expression<bool> Function($$BadgesTableFilterComposer f) f) {
    final $$BadgesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.badges,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BadgesTableFilterComposer(
              $db: $db,
              $table: $db.badges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> rewardSystemsRefs(
      Expression<bool> Function($$RewardSystemsTableFilterComposer f) f) {
    final $$RewardSystemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rewardSystems,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RewardSystemsTableFilterComposer(
              $db: $db,
              $table: $db.rewardSystems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChildProfilesTableOrderingComposer
    extends Composer<_$GrowlyDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ageGroup => $composableBuilder(
      column: $table.ageGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pin => $composableBuilder(
      column: $table.pin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settings => $composableBuilder(
      column: $table.settings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChildProfilesTableAnnotationComposer
    extends Composer<_$GrowlyDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get ageGroup =>
      $composableBuilder(column: $table.ageGroup, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get pin =>
      $composableBuilder(column: $table.pin, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> learningProgressTableRefs<T extends Object>(
      Expression<T> Function($$LearningProgressTableTableAnnotationComposer a)
          f) {
    final $$LearningProgressTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.learningProgressTable,
            getReferencedColumn: (t) => t.childId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$LearningProgressTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.learningProgressTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> screenTimeRecordsRefs<T extends Object>(
      Expression<T> Function($$ScreenTimeRecordsTableAnnotationComposer a) f) {
    final $$ScreenTimeRecordsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.screenTimeRecords,
            getReferencedColumn: (t) => t.childId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScreenTimeRecordsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.screenTimeRecords,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> appRestrictionsRefs<T extends Object>(
      Expression<T> Function($$AppRestrictionsTableAnnotationComposer a) f) {
    final $$AppRestrictionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appRestrictions,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppRestrictionsTableAnnotationComposer(
              $db: $db,
              $table: $db.appRestrictions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> schedulesRefs<T extends Object>(
      Expression<T> Function($$SchedulesTableAnnotationComposer a) f) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> badgesRefs<T extends Object>(
      Expression<T> Function($$BadgesTableAnnotationComposer a) f) {
    final $$BadgesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.badges,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BadgesTableAnnotationComposer(
              $db: $db,
              $table: $db.badges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> rewardSystemsRefs<T extends Object>(
      Expression<T> Function($$RewardSystemsTableAnnotationComposer a) f) {
    final $$RewardSystemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rewardSystems,
        getReferencedColumn: (t) => t.childId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RewardSystemsTableAnnotationComposer(
              $db: $db,
              $table: $db.rewardSystems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChildProfilesTableTableManager extends RootTableManager<
    _$GrowlyDatabase,
    $ChildProfilesTable,
    ChildProfile,
    $$ChildProfilesTableFilterComposer,
    $$ChildProfilesTableOrderingComposer,
    $$ChildProfilesTableAnnotationComposer,
    $$ChildProfilesTableCreateCompanionBuilder,
    $$ChildProfilesTableUpdateCompanionBuilder,
    (ChildProfile, $$ChildProfilesTableReferences),
    ChildProfile,
    PrefetchHooks Function(
        {bool learningProgressTableRefs,
        bool screenTimeRecordsRefs,
        bool appRestrictionsRefs,
        bool schedulesRefs,
        bool badgesRefs,
        bool rewardSystemsRefs})> {
  $$ChildProfilesTableTableManager(
      _$GrowlyDatabase db, $ChildProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> birthDate = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<int> ageGroup = const Value.absent(),
            Value<String> parentId = const Value.absent(),
            Value<String?> pin = const Value.absent(),
            Value<String> settings = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChildProfilesCompanion(
            id: id,
            name: name,
            birthDate: birthDate,
            avatarUrl: avatarUrl,
            ageGroup: ageGroup,
            parentId: parentId,
            pin: pin,
            settings: settings,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime birthDate,
            Value<String?> avatarUrl = const Value.absent(),
            required int ageGroup,
            required String parentId,
            Value<String?> pin = const Value.absent(),
            Value<String> settings = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChildProfilesCompanion.insert(
            id: id,
            name: name,
            birthDate: birthDate,
            avatarUrl: avatarUrl,
            ageGroup: ageGroup,
            parentId: parentId,
            pin: pin,
            settings: settings,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ChildProfilesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {learningProgressTableRefs = false,
              screenTimeRecordsRefs = false,
              appRestrictionsRefs = false,
              schedulesRefs = false,
              badgesRefs = false,
              rewardSystemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (learningProgressTableRefs) db.learningProgressTable,
                if (screenTimeRecordsRefs) db.screenTimeRecords,
                if (appRestrictionsRefs) db.appRestrictions,
                if (schedulesRefs) db.schedules,
                if (badgesRefs) db.badges,
                if (rewardSystemsRefs) db.rewardSystems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (learningProgressTableRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable,
                            LearningProgressTableData>(
                        currentTable: table,
                        referencedTable: $$ChildProfilesTableReferences
                            ._learningProgressTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .learningProgressTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (screenTimeRecordsRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable,
                            ScreenTimeRecord>(
                        currentTable: table,
                        referencedTable: $$ChildProfilesTableReferences
                            ._screenTimeRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .screenTimeRecordsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (appRestrictionsRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable, AppRestriction>(
                        currentTable: table,
                        referencedTable: $$ChildProfilesTableReferences
                            ._appRestrictionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .appRestrictionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (schedulesRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable,
                            Schedule>(
                        currentTable: table,
                        referencedTable: $$ChildProfilesTableReferences
                            ._schedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .schedulesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (badgesRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable,
                            Badge>(
                        currentTable: table,
                        referencedTable:
                            $$ChildProfilesTableReferences._badgesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .badgesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (rewardSystemsRefs)
                    await $_getPrefetchedData<ChildProfile, $ChildProfilesTable,
                            RewardSystem>(
                        currentTable: table,
                        referencedTable: $$ChildProfilesTableReferences
                            ._rewardSystemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChildProfilesTableReferences(db, table, p0)
                                .rewardSystemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ChildProfilesTableProcessedTableManager = ProcessedTableManager<
    _$GrowlyDatabase,
    $ChildProfilesTable,
    ChildProfile,
    $$ChildProfilesTableFilterComposer,
    $$ChildProfilesTableOrderingComposer,
    $$ChildProfilesTableAnnotationComposer,
    $$ChildProfilesTableCreateCompanionBuilder,
    $$ChildProfilesTableUpdateCompanionBuilder,
    (ChildProfile, $$ChildProfilesTableReferences),
    ChildProfile,
    PrefetchHooks Function(
        {bool learningProgressTableRefs,
        bool screenTimeRecordsRefs,
        bool appRestrictionsRefs,
        bool schedulesRefs,
        bool badgesRefs,
        bool rewardSystemsRefs})>;
typedef $$LearningProgressTableTableCreateCompanionBuilder
    = LearningProgressTableCompanion Function({
  required String id,
  required String childId,
  required String subject,
  required String topic,
  Value<int> score,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> sessionId,
  Value<String> metadata,
  Value<int> rowid,
});
typedef $$LearningProgressTableTableUpdateCompanionBuilder
    = LearningProgressTableCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<String> subject,
  Value<String> topic,
  Value<int> score,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<String?> sessionId,
  Value<String> metadata,
  Value<int> rowid,
});

final class $$LearningProgressTableTableReferences extends BaseReferences<
    _$GrowlyDatabase, $LearningProgressTableTable, LearningProgressTableData> {
  $$LearningProgressTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$GrowlyDatabase db) =>
      db.childProfiles.createAlias($_aliasNameGenerator(
          db.learningProgressTable.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LearningProgressTableTableFilterComposer
    extends Composer<_$GrowlyDatabase, $LearningProgressTableTable> {
  $$LearningProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  $$ChildProfilesTableFilterComposer get childId {
    final $$ChildProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableFilterComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LearningProgressTableTableOrderingComposer
    extends Composer<_$GrowlyDatabase, $LearningProgressTableTable> {
  $$LearningProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  $$ChildProfilesTableOrderingComposer get childId {
    final $$ChildProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LearningProgressTableTableAnnotationComposer
    extends Composer<_$GrowlyDatabase, $LearningProgressTableTable> {
  $$LearningProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$ChildProfilesTableAnnotationComposer get childId {
    final $$ChildProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LearningProgressTableTableTableManager extends RootTableManager<
    _$GrowlyDatabase,
    $LearningProgressTableTable,
    LearningProgressTableData,
    $$LearningProgressTableTableFilterComposer,
    $$LearningProgressTableTableOrderingComposer,
    $$LearningProgressTableTableAnnotationComposer,
    $$LearningProgressTableTableCreateCompanionBuilder,
    $$LearningProgressTableTableUpdateCompanionBuilder,
    (LearningProgressTableData, $$LearningProgressTableTableReferences),
    LearningProgressTableData,
    PrefetchHooks Function({bool childId})> {
  $$LearningProgressTableTableTableManager(
      _$GrowlyDatabase db, $LearningProgressTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningProgressTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LearningProgressTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearningProgressTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> topic = const Value.absent(),
            Value<int> score = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningProgressTableCompanion(
            id: id,
            childId: childId,
            subject: subject,
            topic: topic,
            score: score,
            completed: completed,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            sessionId: sessionId,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required String subject,
            required String topic,
            Value<int> score = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningProgressTableCompanion.insert(
            id: id,
            childId: childId,
            subject: subject,
            topic: topic,
            score: score,
            completed: completed,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            sessionId: sessionId,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LearningProgressTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable: $$LearningProgressTableTableReferences
                        ._childIdTable(db),
                    referencedColumn: $$LearningProgressTableTableReferences
                        ._childIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LearningProgressTableTableProcessedTableManager
    = ProcessedTableManager<
        _$GrowlyDatabase,
        $LearningProgressTableTable,
        LearningProgressTableData,
        $$LearningProgressTableTableFilterComposer,
        $$LearningProgressTableTableOrderingComposer,
        $$LearningProgressTableTableAnnotationComposer,
        $$LearningProgressTableTableCreateCompanionBuilder,
        $$LearningProgressTableTableUpdateCompanionBuilder,
        (LearningProgressTableData, $$LearningProgressTableTableReferences),
        LearningProgressTableData,
        PrefetchHooks Function({bool childId})>;
typedef $$ScreenTimeRecordsTableCreateCompanionBuilder
    = ScreenTimeRecordsCompanion Function({
  required String id,
  required String childId,
  required String appPackage,
  Value<String?> appName,
  required int durationMinutes,
  required DateTime date,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ScreenTimeRecordsTableUpdateCompanionBuilder
    = ScreenTimeRecordsCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<String> appPackage,
  Value<String?> appName,
  Value<int> durationMinutes,
  Value<DateTime> date,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$ScreenTimeRecordsTableReferences extends BaseReferences<
    _$GrowlyDatabase, $ScreenTimeRecordsTable, ScreenTimeRecord> {
  $$ScreenTimeRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$GrowlyDatabase db) =>
      db.childProfiles.createAlias($_aliasNameGenerator(
          db.screenTimeRecords.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ScreenTimeRecordsTableFilterComposer
    extends Composer<_$GrowlyDatabase, $ScreenTimeRecordsTable> {
  $$ScreenTimeRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appPackage => $composableBuilder(
      column: $table.appPackage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ChildProfilesTableFilterComposer get childId {
    final $$ChildProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableFilterComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScreenTimeRecordsTableOrderingComposer
    extends Composer<_$GrowlyDatabase, $ScreenTimeRecordsTable> {
  $$ScreenTimeRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appPackage => $composableBuilder(
      column: $table.appPackage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ChildProfilesTableOrderingComposer get childId {
    final $$ChildProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScreenTimeRecordsTableAnnotationComposer
    extends Composer<_$GrowlyDatabase, $ScreenTimeRecordsTable> {
  $$ScreenTimeRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get appPackage => $composableBuilder(
      column: $table.appPackage, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChildProfilesTableAnnotationComposer get childId {
    final $$ChildProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScreenTimeRecordsTableTableManager extends RootTableManager<
    _$GrowlyDatabase,
    $ScreenTimeRecordsTable,
    ScreenTimeRecord,
    $$ScreenTimeRecordsTableFilterComposer,
    $$ScreenTimeRecordsTableOrderingComposer,
    $$ScreenTimeRecordsTableAnnotationComposer,
    $$ScreenTimeRecordsTableCreateCompanionBuilder,
    $$ScreenTimeRecordsTableUpdateCompanionBuilder,
    (ScreenTimeRecord, $$ScreenTimeRecordsTableReferences),
    ScreenTimeRecord,
    PrefetchHooks Function({bool childId})> {
  $$ScreenTimeRecordsTableTableManager(
      _$GrowlyDatabase db, $ScreenTimeRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScreenTimeRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScreenTimeRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScreenTimeRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<String> appPackage = const Value.absent(),
            Value<String?> appName = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScreenTimeRecordsCompanion(
            id: id,
            childId: childId,
            appPackage: appPackage,
            appName: appName,
            durationMinutes: durationMinutes,
            date: date,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required String appPackage,
            Value<String?> appName = const Value.absent(),
            required int durationMinutes,
            required DateTime date,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScreenTimeRecordsCompanion.insert(
            id: id,
            childId: childId,
            appPackage: appPackage,
            appName: appName,
            durationMinutes: durationMinutes,
            date: date,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ScreenTimeRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable:
                        $$ScreenTimeRecordsTableReferences._childIdTable(db),
                    referencedColumn:
                        $$ScreenTimeRecordsTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ScreenTimeRecordsTableProcessedTableManager = ProcessedTableManager<
    _$GrowlyDatabase,
    $ScreenTimeRecordsTable,
    ScreenTimeRecord,
    $$ScreenTimeRecordsTableFilterComposer,
    $$ScreenTimeRecordsTableOrderingComposer,
    $$ScreenTimeRecordsTableAnnotationComposer,
    $$ScreenTimeRecordsTableCreateCompanionBuilder,
    $$ScreenTimeRecordsTableUpdateCompanionBuilder,
    (ScreenTimeRecord, $$ScreenTimeRecordsTableReferences),
    ScreenTimeRecord,
    PrefetchHooks Function({bool childId})>;
typedef $$AppRestrictionsTableCreateCompanionBuilder = AppRestrictionsCompanion
    Function({
  required String id,
  required String childId,
  required String appPackage,
  Value<String?> appName,
  Value<String?> appIcon,
  required bool isAllowed,
  Value<int?> timeLimitMinutes,
  Value<String> scheduleLimits,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$AppRestrictionsTableUpdateCompanionBuilder = AppRestrictionsCompanion
    Function({
  Value<String> id,
  Value<String> childId,
  Value<String> appPackage,
  Value<String?> appName,
  Value<String?> appIcon,
  Value<bool> isAllowed,
  Value<int?> timeLimitMinutes,
  Value<String> scheduleLimits,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

final class $$AppRestrictionsTableReferences extends BaseReferences<
    _$GrowlyDatabase, $AppRestrictionsTable, AppRestriction> {
  $$AppRestrictionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$GrowlyDatabase db) =>
      db.childProfiles.createAlias($_aliasNameGenerator(
          db.appRestrictions.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AppRestrictionsTableFilterComposer
    extends Composer<_$GrowlyDatabase, $AppRestrictionsTable> {
  $$AppRestrictionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appPackage => $composableBuilder(
      column: $table.appPackage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appIcon => $composableBuilder(
      column: $table.appIcon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAllowed => $composableBuilder(
      column: $table.isAllowed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeLimitMinutes => $composableBuilder(
      column: $table.timeLimitMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduleLimits => $composableBuilder(
      column: $table.scheduleLimits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ChildProfilesTableFilterComposer get childId {
    final $$ChildProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableFilterComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppRestrictionsTableOrderingComposer
    extends Composer<_$GrowlyDatabase, $AppRestrictionsTable> {
  $$AppRestrictionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appPackage => $composableBuilder(
      column: $table.appPackage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appIcon => $composableBuilder(
      column: $table.appIcon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAllowed => $composableBuilder(
      column: $table.isAllowed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeLimitMinutes => $composableBuilder(
      column: $table.timeLimitMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduleLimits => $composableBuilder(
      column: $table.scheduleLimits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ChildProfilesTableOrderingComposer get childId {
    final $$ChildProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppRestrictionsTableAnnotationComposer
    extends Composer<_$GrowlyDatabase, $AppRestrictionsTable> {
  $$AppRestrictionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get appPackage => $composableBuilder(
      column: $table.appPackage, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get appIcon =>
      $composableBuilder(column: $table.appIcon, builder: (column) => column);

  GeneratedColumn<bool> get isAllowed =>
      $composableBuilder(column: $table.isAllowed, builder: (column) => column);

  GeneratedColumn<int> get timeLimitMinutes => $composableBuilder(
      column: $table.timeLimitMinutes, builder: (column) => column);

  GeneratedColumn<String> get scheduleLimits => $composableBuilder(
      column: $table.scheduleLimits, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChildProfilesTableAnnotationComposer get childId {
    final $$ChildProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppRestrictionsTableTableManager extends RootTableManager<
    _$GrowlyDatabase,
    $AppRestrictionsTable,
    AppRestriction,
    $$AppRestrictionsTableFilterComposer,
    $$AppRestrictionsTableOrderingComposer,
    $$AppRestrictionsTableAnnotationComposer,
    $$AppRestrictionsTableCreateCompanionBuilder,
    $$AppRestrictionsTableUpdateCompanionBuilder,
    (AppRestriction, $$AppRestrictionsTableReferences),
    AppRestriction,
    PrefetchHooks Function({bool childId})> {
  $$AppRestrictionsTableTableManager(
      _$GrowlyDatabase db, $AppRestrictionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppRestrictionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppRestrictionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppRestrictionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<String> appPackage = const Value.absent(),
            Value<String?> appName = const Value.absent(),
            Value<String?> appIcon = const Value.absent(),
            Value<bool> isAllowed = const Value.absent(),
            Value<int?> timeLimitMinutes = const Value.absent(),
            Value<String> scheduleLimits = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppRestrictionsCompanion(
            id: id,
            childId: childId,
            appPackage: appPackage,
            appName: appName,
            appIcon: appIcon,
            isAllowed: isAllowed,
            timeLimitMinutes: timeLimitMinutes,
            scheduleLimits: scheduleLimits,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required String appPackage,
            Value<String?> appName = const Value.absent(),
            Value<String?> appIcon = const Value.absent(),
            required bool isAllowed,
            Value<int?> timeLimitMinutes = const Value.absent(),
            Value<String> scheduleLimits = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppRestrictionsCompanion.insert(
            id: id,
            childId: childId,
            appPackage: appPackage,
            appName: appName,
            appIcon: appIcon,
            isAllowed: isAllowed,
            timeLimitMinutes: timeLimitMinutes,
            scheduleLimits: scheduleLimits,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AppRestrictionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable:
                        $$AppRestrictionsTableReferences._childIdTable(db),
                    referencedColumn:
                        $$AppRestrictionsTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AppRestrictionsTableProcessedTableManager = ProcessedTableManager<
    _$GrowlyDatabase,
    $AppRestrictionsTable,
    AppRestriction,
    $$AppRestrictionsTableFilterComposer,
    $$AppRestrictionsTableOrderingComposer,
    $$AppRestrictionsTableAnnotationComposer,
    $$AppRestrictionsTableCreateCompanionBuilder,
    $$AppRestrictionsTableUpdateCompanionBuilder,
    (AppRestriction, $$AppRestrictionsTableReferences),
    AppRestriction,
    PrefetchHooks Function({bool childId})>;
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  required String id,
  required String childId,
  required int dayOfWeek,
  required String startTime,
  required String endTime,
  required String mode,
  Value<bool> isEnabled,
  Value<String?> label,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<int> dayOfWeek,
  Value<String> startTime,
  Value<String> endTime,
  Value<String> mode,
  Value<bool> isEnabled,
  Value<String?> label,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

final class $$SchedulesTableReferences
    extends BaseReferences<_$GrowlyDatabase, $SchedulesTable, Schedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$GrowlyDatabase db) =>
      db.childProfiles.createAlias(
          $_aliasNameGenerator(db.schedules.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$GrowlyDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ChildProfilesTableFilterComposer get childId {
    final $$ChildProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableFilterComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$GrowlyDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ChildProfilesTableOrderingComposer get childId {
    final $$ChildProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$GrowlyDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChildProfilesTableAnnotationComposer get childId {
    final $$ChildProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesTableTableManager extends RootTableManager<
    _$GrowlyDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, $$SchedulesTableReferences),
    Schedule,
    PrefetchHooks Function({bool childId})> {
  $$SchedulesTableTableManager(_$GrowlyDatabase db, $SchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SchedulesCompanion(
            id: id,
            childId: childId,
            dayOfWeek: dayOfWeek,
            startTime: startTime,
            endTime: endTime,
            mode: mode,
            isEnabled: isEnabled,
            label: label,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required int dayOfWeek,
            required String startTime,
            required String endTime,
            required String mode,
            Value<bool> isEnabled = const Value.absent(),
            Value<String?> label = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SchedulesCompanion.insert(
            id: id,
            childId: childId,
            dayOfWeek: dayOfWeek,
            startTime: startTime,
            endTime: endTime,
            mode: mode,
            isEnabled: isEnabled,
            label: label,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable:
                        $$SchedulesTableReferences._childIdTable(db),
                    referencedColumn:
                        $$SchedulesTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SchedulesTableProcessedTableManager = ProcessedTableManager<
    _$GrowlyDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (Schedule, $$SchedulesTableReferences),
    Schedule,
    PrefetchHooks Function({bool childId})>;
typedef $$BadgesTableCreateCompanionBuilder = BadgesCompanion Function({
  required String id,
  required String childId,
  required int type,
  required String name,
  required String description,
  required String emoji,
  required DateTime earnedAt,
  Value<String> metadata,
  Value<int> rowid,
});
typedef $$BadgesTableUpdateCompanionBuilder = BadgesCompanion Function({
  Value<String> id,
  Value<String> childId,
  Value<int> type,
  Value<String> name,
  Value<String> description,
  Value<String> emoji,
  Value<DateTime> earnedAt,
  Value<String> metadata,
  Value<int> rowid,
});

final class $$BadgesTableReferences
    extends BaseReferences<_$GrowlyDatabase, $BadgesTable, Badge> {
  $$BadgesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$GrowlyDatabase db) =>
      db.childProfiles.createAlias(
          $_aliasNameGenerator(db.badges.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BadgesTableFilterComposer
    extends Composer<_$GrowlyDatabase, $BadgesTable> {
  $$BadgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  $$ChildProfilesTableFilterComposer get childId {
    final $$ChildProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableFilterComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BadgesTableOrderingComposer
    extends Composer<_$GrowlyDatabase, $BadgesTable> {
  $$BadgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  $$ChildProfilesTableOrderingComposer get childId {
    final $$ChildProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BadgesTableAnnotationComposer
    extends Composer<_$GrowlyDatabase, $BadgesTable> {
  $$BadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<DateTime> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  $$ChildProfilesTableAnnotationComposer get childId {
    final $$ChildProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BadgesTableTableManager extends RootTableManager<
    _$GrowlyDatabase,
    $BadgesTable,
    Badge,
    $$BadgesTableFilterComposer,
    $$BadgesTableOrderingComposer,
    $$BadgesTableAnnotationComposer,
    $$BadgesTableCreateCompanionBuilder,
    $$BadgesTableUpdateCompanionBuilder,
    (Badge, $$BadgesTableReferences),
    Badge,
    PrefetchHooks Function({bool childId})> {
  $$BadgesTableTableManager(_$GrowlyDatabase db, $BadgesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<DateTime> earnedAt = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BadgesCompanion(
            id: id,
            childId: childId,
            type: type,
            name: name,
            description: description,
            emoji: emoji,
            earnedAt: earnedAt,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            required int type,
            required String name,
            required String description,
            required String emoji,
            required DateTime earnedAt,
            Value<String> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BadgesCompanion.insert(
            id: id,
            childId: childId,
            type: type,
            name: name,
            description: description,
            emoji: emoji,
            earnedAt: earnedAt,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BadgesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable: $$BadgesTableReferences._childIdTable(db),
                    referencedColumn:
                        $$BadgesTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BadgesTableProcessedTableManager = ProcessedTableManager<
    _$GrowlyDatabase,
    $BadgesTable,
    Badge,
    $$BadgesTableFilterComposer,
    $$BadgesTableOrderingComposer,
    $$BadgesTableAnnotationComposer,
    $$BadgesTableCreateCompanionBuilder,
    $$BadgesTableUpdateCompanionBuilder,
    (Badge, $$BadgesTableReferences),
    Badge,
    PrefetchHooks Function({bool childId})>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String tableName,
  required String recordId,
  required String operation,
  required String data,
  required DateTime createdAt,
  Value<DateTime?> syncedAt,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> tableName,
  Value<String> recordId,
  Value<String> operation,
  Value<String> data,
  Value<DateTime> createdAt,
  Value<DateTime?> syncedAt,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$GrowlyDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tableName => $composableBuilder(
      column: $table.tableName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$GrowlyDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tableName => $composableBuilder(
      column: $table.tableName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordId => $composableBuilder(
      column: $table.recordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$GrowlyDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tableName =>
      $composableBuilder(column: $table.tableName, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$GrowlyDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$GrowlyDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$GrowlyDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> tableName = const Value.absent(),
            Value<String> recordId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            tableName: tableName,
            recordId: recordId,
            operation: operation,
            data: data,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String tableName,
            required String recordId,
            required String operation,
            required String data,
            required DateTime createdAt,
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            tableName: tableName,
            recordId: recordId,
            operation: operation,
            data: data,
            createdAt: createdAt,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$GrowlyDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$GrowlyDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$RewardSystemsTableCreateCompanionBuilder = RewardSystemsCompanion
    Function({
  required String id,
  required String childId,
  Value<int> currentStreak,
  Value<int> longestStreak,
  Value<int> totalStars,
  Value<String> unlockedBadges,
  Value<DateTime?> lastActivityAt,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$RewardSystemsTableUpdateCompanionBuilder = RewardSystemsCompanion
    Function({
  Value<String> id,
  Value<String> childId,
  Value<int> currentStreak,
  Value<int> longestStreak,
  Value<int> totalStars,
  Value<String> unlockedBadges,
  Value<DateTime?> lastActivityAt,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

final class $$RewardSystemsTableReferences extends BaseReferences<
    _$GrowlyDatabase, $RewardSystemsTable, RewardSystem> {
  $$RewardSystemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ChildProfilesTable _childIdTable(_$GrowlyDatabase db) =>
      db.childProfiles.createAlias(
          $_aliasNameGenerator(db.rewardSystems.childId, db.childProfiles.id));

  $$ChildProfilesTableProcessedTableManager get childId {
    final $_column = $_itemColumn<String>('child_id')!;

    final manager = $$ChildProfilesTableTableManager($_db, $_db.childProfiles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RewardSystemsTableFilterComposer
    extends Composer<_$GrowlyDatabase, $RewardSystemsTable> {
  $$RewardSystemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalStars => $composableBuilder(
      column: $table.totalStars, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unlockedBadges => $composableBuilder(
      column: $table.unlockedBadges,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastActivityAt => $composableBuilder(
      column: $table.lastActivityAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ChildProfilesTableFilterComposer get childId {
    final $$ChildProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableFilterComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RewardSystemsTableOrderingComposer
    extends Composer<_$GrowlyDatabase, $RewardSystemsTable> {
  $$RewardSystemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalStars => $composableBuilder(
      column: $table.totalStars, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unlockedBadges => $composableBuilder(
      column: $table.unlockedBadges,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastActivityAt => $composableBuilder(
      column: $table.lastActivityAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ChildProfilesTableOrderingComposer get childId {
    final $$ChildProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RewardSystemsTableAnnotationComposer
    extends Composer<_$GrowlyDatabase, $RewardSystemsTable> {
  $$RewardSystemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak, builder: (column) => column);

  GeneratedColumn<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak, builder: (column) => column);

  GeneratedColumn<int> get totalStars => $composableBuilder(
      column: $table.totalStars, builder: (column) => column);

  GeneratedColumn<String> get unlockedBadges => $composableBuilder(
      column: $table.unlockedBadges, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActivityAt => $composableBuilder(
      column: $table.lastActivityAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ChildProfilesTableAnnotationComposer get childId {
    final $$ChildProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.childProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChildProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.childProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RewardSystemsTableTableManager extends RootTableManager<
    _$GrowlyDatabase,
    $RewardSystemsTable,
    RewardSystem,
    $$RewardSystemsTableFilterComposer,
    $$RewardSystemsTableOrderingComposer,
    $$RewardSystemsTableAnnotationComposer,
    $$RewardSystemsTableCreateCompanionBuilder,
    $$RewardSystemsTableUpdateCompanionBuilder,
    (RewardSystem, $$RewardSystemsTableReferences),
    RewardSystem,
    PrefetchHooks Function({bool childId})> {
  $$RewardSystemsTableTableManager(
      _$GrowlyDatabase db, $RewardSystemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardSystemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardSystemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardSystemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> childId = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<int> longestStreak = const Value.absent(),
            Value<int> totalStars = const Value.absent(),
            Value<String> unlockedBadges = const Value.absent(),
            Value<DateTime?> lastActivityAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RewardSystemsCompanion(
            id: id,
            childId: childId,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalStars: totalStars,
            unlockedBadges: unlockedBadges,
            lastActivityAt: lastActivityAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String childId,
            Value<int> currentStreak = const Value.absent(),
            Value<int> longestStreak = const Value.absent(),
            Value<int> totalStars = const Value.absent(),
            Value<String> unlockedBadges = const Value.absent(),
            Value<DateTime?> lastActivityAt = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RewardSystemsCompanion.insert(
            id: id,
            childId: childId,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalStars: totalStars,
            unlockedBadges: unlockedBadges,
            lastActivityAt: lastActivityAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RewardSystemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable:
                        $$RewardSystemsTableReferences._childIdTable(db),
                    referencedColumn:
                        $$RewardSystemsTableReferences._childIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RewardSystemsTableProcessedTableManager = ProcessedTableManager<
    _$GrowlyDatabase,
    $RewardSystemsTable,
    RewardSystem,
    $$RewardSystemsTableFilterComposer,
    $$RewardSystemsTableOrderingComposer,
    $$RewardSystemsTableAnnotationComposer,
    $$RewardSystemsTableCreateCompanionBuilder,
    $$RewardSystemsTableUpdateCompanionBuilder,
    (RewardSystem, $$RewardSystemsTableReferences),
    RewardSystem,
    PrefetchHooks Function({bool childId})>;

class $GrowlyDatabaseManager {
  final _$GrowlyDatabase _db;
  $GrowlyDatabaseManager(this._db);
  $$ChildProfilesTableTableManager get childProfiles =>
      $$ChildProfilesTableTableManager(_db, _db.childProfiles);
  $$LearningProgressTableTableTableManager get learningProgressTable =>
      $$LearningProgressTableTableTableManager(_db, _db.learningProgressTable);
  $$ScreenTimeRecordsTableTableManager get screenTimeRecords =>
      $$ScreenTimeRecordsTableTableManager(_db, _db.screenTimeRecords);
  $$AppRestrictionsTableTableManager get appRestrictions =>
      $$AppRestrictionsTableTableManager(_db, _db.appRestrictions);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$BadgesTableTableManager get badges =>
      $$BadgesTableTableManager(_db, _db.badges);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$RewardSystemsTableTableManager get rewardSystems =>
      $$RewardSystemsTableTableManager(_db, _db.rewardSystems);
}
