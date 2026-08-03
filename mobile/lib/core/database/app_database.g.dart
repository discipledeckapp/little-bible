// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VersesTable extends Verses with TableInfo<$VersesTable, Verse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookMeta = const VerificationMeta('book');
  @override
  late final GeneratedColumn<String> book = GeneratedColumn<String>(
    'book',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant('web'),
  );
  static const VerificationMeta _isAdaptedMeta = const VerificationMeta(
    'isAdapted',
  );
  @override
  late final GeneratedColumn<bool> isAdapted = GeneratedColumn<bool>(
    'is_adapted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_adapted" IN (0, 1))',
    ),
    defaultValue: Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    book,
    chapter,
    verse,
    body,
    source,
    isAdapted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Verse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book')) {
      context.handle(
        _bookMeta,
        book.isAcceptableOrUnknown(data['book']!, _bookMeta),
      );
    } else if (isInserting) {
      context.missing(_bookMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('is_adapted')) {
      context.handle(
        _isAdaptedMeta,
        isAdapted.isAcceptableOrUnknown(data['is_adapted']!, _isAdaptedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Verse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Verse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      book: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      isAdapted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_adapted'],
      )!,
    );
  }

  @override
  $VersesTable createAlias(String alias) {
    return $VersesTable(attachedDatabase, alias);
  }
}

class Verse extends DataClass implements Insertable<Verse> {
  final int id;
  final String book;
  final int chapter;
  final int verse;
  final String body;
  final String source;
  final bool isAdapted;
  const Verse({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.body,
    required this.source,
    required this.isAdapted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book'] = Variable<String>(book);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['body'] = Variable<String>(body);
    map['source'] = Variable<String>(source);
    map['is_adapted'] = Variable<bool>(isAdapted);
    return map;
  }

  VersesCompanion toCompanion(bool nullToAbsent) {
    return VersesCompanion(
      id: Value(id),
      book: Value(book),
      chapter: Value(chapter),
      verse: Value(verse),
      body: Value(body),
      source: Value(source),
      isAdapted: Value(isAdapted),
    );
  }

  factory Verse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Verse(
      id: serializer.fromJson<int>(json['id']),
      book: serializer.fromJson<String>(json['book']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      body: serializer.fromJson<String>(json['body']),
      source: serializer.fromJson<String>(json['source']),
      isAdapted: serializer.fromJson<bool>(json['isAdapted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'book': serializer.toJson<String>(book),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'body': serializer.toJson<String>(body),
      'source': serializer.toJson<String>(source),
      'isAdapted': serializer.toJson<bool>(isAdapted),
    };
  }

  Verse copyWith({
    int? id,
    String? book,
    int? chapter,
    int? verse,
    String? body,
    String? source,
    bool? isAdapted,
  }) => Verse(
    id: id ?? this.id,
    book: book ?? this.book,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    body: body ?? this.body,
    source: source ?? this.source,
    isAdapted: isAdapted ?? this.isAdapted,
  );
  Verse copyWithCompanion(VersesCompanion data) {
    return Verse(
      id: data.id.present ? data.id.value : this.id,
      book: data.book.present ? data.book.value : this.book,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      body: data.body.present ? data.body.value : this.body,
      source: data.source.present ? data.source.value : this.source,
      isAdapted: data.isAdapted.present ? data.isAdapted.value : this.isAdapted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Verse(')
          ..write('id: $id, ')
          ..write('book: $book, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('body: $body, ')
          ..write('source: $source, ')
          ..write('isAdapted: $isAdapted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, book, chapter, verse, body, source, isAdapted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Verse &&
          other.id == this.id &&
          other.book == this.book &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.body == this.body &&
          other.source == this.source &&
          other.isAdapted == this.isAdapted);
}

class VersesCompanion extends UpdateCompanion<Verse> {
  final Value<int> id;
  final Value<String> book;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> body;
  final Value<String> source;
  final Value<bool> isAdapted;
  const VersesCompanion({
    this.id = const Value.absent(),
    this.book = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.body = const Value.absent(),
    this.source = const Value.absent(),
    this.isAdapted = const Value.absent(),
  });
  VersesCompanion.insert({
    this.id = const Value.absent(),
    required String book,
    required int chapter,
    required int verse,
    required String body,
    this.source = const Value.absent(),
    this.isAdapted = const Value.absent(),
  }) : book = Value(book),
       chapter = Value(chapter),
       verse = Value(verse),
       body = Value(body);
  static Insertable<Verse> custom({
    Expression<int>? id,
    Expression<String>? book,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? body,
    Expression<String>? source,
    Expression<bool>? isAdapted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (book != null) 'book': book,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (body != null) 'body': body,
      if (source != null) 'source': source,
      if (isAdapted != null) 'is_adapted': isAdapted,
    });
  }

  VersesCompanion copyWith({
    Value<int>? id,
    Value<String>? book,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? body,
    Value<String>? source,
    Value<bool>? isAdapted,
  }) {
    return VersesCompanion(
      id: id ?? this.id,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      body: body ?? this.body,
      source: source ?? this.source,
      isAdapted: isAdapted ?? this.isAdapted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (book.present) {
      map['book'] = Variable<String>(book.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isAdapted.present) {
      map['is_adapted'] = Variable<bool>(isAdapted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesCompanion(')
          ..write('id: $id, ')
          ..write('book: $book, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('body: $body, ')
          ..write('source: $source, ')
          ..write('isAdapted: $isAdapted')
          ..write(')'))
        .toString();
  }
}

class $ChildProfilesTable extends ChildProfiles
    with TableInfo<$ChildProfilesTable, ChildProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid(),
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageBandMeta = const VerificationMeta(
    'ageBand',
  );
  @override
  late final GeneratedColumn<String> ageBand = GeneratedColumn<String>(
    'age_band',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarIdMeta = const VerificationMeta(
    'avatarId',
  );
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
    'avatar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('lion'),
  );
  static const VerificationMeta _seedsMeta = const VerificationMeta('seeds');
  @override
  late final GeneratedColumn<int> seeds = GeneratedColumn<int>(
    'seeds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActiveDateMeta = const VerificationMeta(
    'lastActiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveDate =
      GeneratedColumn<DateTime>(
        'last_active_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isUnlockedMeta = const VerificationMeta(
    'isUnlocked',
  );
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
    'is_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasSeenIntroMeta = const VerificationMeta(
    'hasSeenIntro',
  );
  @override
  late final GeneratedColumn<bool> hasSeenIntro = GeneratedColumn<bool>(
    'has_seen_intro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_seen_intro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _badgesJsonMeta = const VerificationMeta(
    'badgesJson',
  );
  @override
  late final GeneratedColumn<String> badgesJson = GeneratedColumn<String>(
    'badges_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _autoplayEnabledMeta = const VerificationMeta(
    'autoplayEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoplayEnabled = GeneratedColumn<bool>(
    'autoplay_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("autoplay_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _quietStoryModeMeta = const VerificationMeta(
    'quietStoryMode',
  );
  @override
  late final GeneratedColumn<bool> quietStoryMode = GeneratedColumn<bool>(
    'quiet_story_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("quiet_story_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _musicEnabledMeta = const VerificationMeta(
    'musicEnabled',
  );
  @override
  late final GeneratedColumn<bool> musicEnabled = GeneratedColumn<bool>(
    'music_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("music_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _effectsEnabledMeta = const VerificationMeta(
    'effectsEnabled',
  );
  @override
  late final GeneratedColumn<bool> effectsEnabled = GeneratedColumn<bool>(
    'effects_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("effects_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reducedMotionMeta = const VerificationMeta(
    'reducedMotion',
  );
  @override
  late final GeneratedColumn<bool> reducedMotion = GeneratedColumn<bool>(
    'reduced_motion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reduced_motion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wifiOnlyDownloadsMeta = const VerificationMeta(
    'wifiOnlyDownloads',
  );
  @override
  late final GeneratedColumn<bool> wifiOnlyDownloads = GeneratedColumn<bool>(
    'wifi_only_downloads',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wifi_only_downloads" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _cloudSyncEnabledMeta = const VerificationMeta(
    'cloudSyncEnabled',
  );
  @override
  late final GeneratedColumn<bool> cloudSyncEnabled = GeneratedColumn<bool>(
    'cloud_sync_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cloud_sync_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    ageBand,
    avatarId,
    seeds,
    streakDays,
    lastActiveDate,
    isUnlocked,
    hasSeenIntro,
    badgesJson,
    isActive,
    autoplayEnabled,
    quietStoryMode,
    musicEnabled,
    effectsEnabled,
    notificationsEnabled,
    reducedMotion,
    wifiOnlyDownloads,
    cloudSyncEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'child_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChildProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('age_band')) {
      context.handle(
        _ageBandMeta,
        ageBand.isAcceptableOrUnknown(data['age_band']!, _ageBandMeta),
      );
    } else if (isInserting) {
      context.missing(_ageBandMeta);
    }
    if (data.containsKey('avatar_id')) {
      context.handle(
        _avatarIdMeta,
        avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta),
      );
    }
    if (data.containsKey('seeds')) {
      context.handle(
        _seedsMeta,
        seeds.isAcceptableOrUnknown(data['seeds']!, _seedsMeta),
      );
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    }
    if (data.containsKey('last_active_date')) {
      context.handle(
        _lastActiveDateMeta,
        lastActiveDate.isAcceptableOrUnknown(
          data['last_active_date']!,
          _lastActiveDateMeta,
        ),
      );
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
        _isUnlockedMeta,
        isUnlocked.isAcceptableOrUnknown(data['is_unlocked']!, _isUnlockedMeta),
      );
    }
    if (data.containsKey('has_seen_intro')) {
      context.handle(
        _hasSeenIntroMeta,
        hasSeenIntro.isAcceptableOrUnknown(
          data['has_seen_intro']!,
          _hasSeenIntroMeta,
        ),
      );
    }
    if (data.containsKey('badges_json')) {
      context.handle(
        _badgesJsonMeta,
        badgesJson.isAcceptableOrUnknown(data['badges_json']!, _badgesJsonMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('autoplay_enabled')) {
      context.handle(
        _autoplayEnabledMeta,
        autoplayEnabled.isAcceptableOrUnknown(
          data['autoplay_enabled']!,
          _autoplayEnabledMeta,
        ),
      );
    }
    if (data.containsKey('quiet_story_mode')) {
      context.handle(
        _quietStoryModeMeta,
        quietStoryMode.isAcceptableOrUnknown(
          data['quiet_story_mode']!,
          _quietStoryModeMeta,
        ),
      );
    }
    if (data.containsKey('music_enabled')) {
      context.handle(
        _musicEnabledMeta,
        musicEnabled.isAcceptableOrUnknown(
          data['music_enabled']!,
          _musicEnabledMeta,
        ),
      );
    }
    if (data.containsKey('effects_enabled')) {
      context.handle(
        _effectsEnabledMeta,
        effectsEnabled.isAcceptableOrUnknown(
          data['effects_enabled']!,
          _effectsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reduced_motion')) {
      context.handle(
        _reducedMotionMeta,
        reducedMotion.isAcceptableOrUnknown(
          data['reduced_motion']!,
          _reducedMotionMeta,
        ),
      );
    }
    if (data.containsKey('wifi_only_downloads')) {
      context.handle(
        _wifiOnlyDownloadsMeta,
        wifiOnlyDownloads.isAcceptableOrUnknown(
          data['wifi_only_downloads']!,
          _wifiOnlyDownloadsMeta,
        ),
      );
    }
    if (data.containsKey('cloud_sync_enabled')) {
      context.handle(
        _cloudSyncEnabledMeta,
        cloudSyncEnabled.isAcceptableOrUnknown(
          data['cloud_sync_enabled']!,
          _cloudSyncEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChildProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChildProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      ageBand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}age_band'],
      )!,
      avatarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_id'],
      )!,
      seeds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seeds'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
      lastActiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_date'],
      ),
      isUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unlocked'],
      )!,
      hasSeenIntro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_seen_intro'],
      )!,
      badgesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badges_json'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      autoplayEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}autoplay_enabled'],
      )!,
      quietStoryMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}quiet_story_mode'],
      )!,
      musicEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}music_enabled'],
      )!,
      effectsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}effects_enabled'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      reducedMotion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reduced_motion'],
      )!,
      wifiOnlyDownloads: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wifi_only_downloads'],
      )!,
      cloudSyncEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cloud_sync_enabled'],
      )!,
    );
  }

  @override
  $ChildProfilesTable createAlias(String alias) {
    return $ChildProfilesTable(attachedDatabase, alias);
  }
}

class ChildProfile extends DataClass implements Insertable<ChildProfile> {
  final String id;
  final String nickname;
  final String ageBand;
  final String avatarId;
  final int seeds;
  final int streakDays;
  final DateTime? lastActiveDate;
  final bool isUnlocked;
  final bool hasSeenIntro;
  final String badgesJson;
  final bool isActive;
  final bool autoplayEnabled;
  final bool quietStoryMode;
  final bool musicEnabled;
  final bool effectsEnabled;
  final bool notificationsEnabled;
  final bool reducedMotion;
  final bool wifiOnlyDownloads;
  final bool cloudSyncEnabled;
  const ChildProfile({
    required this.id,
    required this.nickname,
    required this.ageBand,
    required this.avatarId,
    required this.seeds,
    required this.streakDays,
    this.lastActiveDate,
    required this.isUnlocked,
    required this.hasSeenIntro,
    required this.badgesJson,
    required this.isActive,
    required this.autoplayEnabled,
    required this.quietStoryMode,
    required this.musicEnabled,
    required this.effectsEnabled,
    required this.notificationsEnabled,
    required this.reducedMotion,
    required this.wifiOnlyDownloads,
    required this.cloudSyncEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nickname'] = Variable<String>(nickname);
    map['age_band'] = Variable<String>(ageBand);
    map['avatar_id'] = Variable<String>(avatarId);
    map['seeds'] = Variable<int>(seeds);
    map['streak_days'] = Variable<int>(streakDays);
    if (!nullToAbsent || lastActiveDate != null) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate);
    }
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    map['has_seen_intro'] = Variable<bool>(hasSeenIntro);
    map['badges_json'] = Variable<String>(badgesJson);
    map['is_active'] = Variable<bool>(isActive);
    map['autoplay_enabled'] = Variable<bool>(autoplayEnabled);
    map['quiet_story_mode'] = Variable<bool>(quietStoryMode);
    map['music_enabled'] = Variable<bool>(musicEnabled);
    map['effects_enabled'] = Variable<bool>(effectsEnabled);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['reduced_motion'] = Variable<bool>(reducedMotion);
    map['wifi_only_downloads'] = Variable<bool>(wifiOnlyDownloads);
    map['cloud_sync_enabled'] = Variable<bool>(cloudSyncEnabled);
    return map;
  }

  ChildProfilesCompanion toCompanion(bool nullToAbsent) {
    return ChildProfilesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      ageBand: Value(ageBand),
      avatarId: Value(avatarId),
      seeds: Value(seeds),
      streakDays: Value(streakDays),
      lastActiveDate: lastActiveDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDate),
      isUnlocked: Value(isUnlocked),
      hasSeenIntro: Value(hasSeenIntro),
      badgesJson: Value(badgesJson),
      isActive: Value(isActive),
      autoplayEnabled: Value(autoplayEnabled),
      quietStoryMode: Value(quietStoryMode),
      musicEnabled: Value(musicEnabled),
      effectsEnabled: Value(effectsEnabled),
      notificationsEnabled: Value(notificationsEnabled),
      reducedMotion: Value(reducedMotion),
      wifiOnlyDownloads: Value(wifiOnlyDownloads),
      cloudSyncEnabled: Value(cloudSyncEnabled),
    );
  }

  factory ChildProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChildProfile(
      id: serializer.fromJson<String>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      ageBand: serializer.fromJson<String>(json['ageBand']),
      avatarId: serializer.fromJson<String>(json['avatarId']),
      seeds: serializer.fromJson<int>(json['seeds']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
      lastActiveDate: serializer.fromJson<DateTime?>(json['lastActiveDate']),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      hasSeenIntro: serializer.fromJson<bool>(json['hasSeenIntro']),
      badgesJson: serializer.fromJson<String>(json['badgesJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      autoplayEnabled: serializer.fromJson<bool>(json['autoplayEnabled']),
      quietStoryMode: serializer.fromJson<bool>(json['quietStoryMode']),
      musicEnabled: serializer.fromJson<bool>(json['musicEnabled']),
      effectsEnabled: serializer.fromJson<bool>(json['effectsEnabled']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      reducedMotion: serializer.fromJson<bool>(json['reducedMotion']),
      wifiOnlyDownloads: serializer.fromJson<bool>(json['wifiOnlyDownloads']),
      cloudSyncEnabled: serializer.fromJson<bool>(json['cloudSyncEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nickname': serializer.toJson<String>(nickname),
      'ageBand': serializer.toJson<String>(ageBand),
      'avatarId': serializer.toJson<String>(avatarId),
      'seeds': serializer.toJson<int>(seeds),
      'streakDays': serializer.toJson<int>(streakDays),
      'lastActiveDate': serializer.toJson<DateTime?>(lastActiveDate),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'hasSeenIntro': serializer.toJson<bool>(hasSeenIntro),
      'badgesJson': serializer.toJson<String>(badgesJson),
      'isActive': serializer.toJson<bool>(isActive),
      'autoplayEnabled': serializer.toJson<bool>(autoplayEnabled),
      'quietStoryMode': serializer.toJson<bool>(quietStoryMode),
      'musicEnabled': serializer.toJson<bool>(musicEnabled),
      'effectsEnabled': serializer.toJson<bool>(effectsEnabled),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'reducedMotion': serializer.toJson<bool>(reducedMotion),
      'wifiOnlyDownloads': serializer.toJson<bool>(wifiOnlyDownloads),
      'cloudSyncEnabled': serializer.toJson<bool>(cloudSyncEnabled),
    };
  }

  ChildProfile copyWith({
    String? id,
    String? nickname,
    String? ageBand,
    String? avatarId,
    int? seeds,
    int? streakDays,
    Value<DateTime?> lastActiveDate = const Value.absent(),
    bool? isUnlocked,
    bool? hasSeenIntro,
    String? badgesJson,
    bool? isActive,
    bool? autoplayEnabled,
    bool? quietStoryMode,
    bool? musicEnabled,
    bool? effectsEnabled,
    bool? notificationsEnabled,
    bool? reducedMotion,
    bool? wifiOnlyDownloads,
    bool? cloudSyncEnabled,
  }) => ChildProfile(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    ageBand: ageBand ?? this.ageBand,
    avatarId: avatarId ?? this.avatarId,
    seeds: seeds ?? this.seeds,
    streakDays: streakDays ?? this.streakDays,
    lastActiveDate: lastActiveDate.present
        ? lastActiveDate.value
        : this.lastActiveDate,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    hasSeenIntro: hasSeenIntro ?? this.hasSeenIntro,
    badgesJson: badgesJson ?? this.badgesJson,
    isActive: isActive ?? this.isActive,
    autoplayEnabled: autoplayEnabled ?? this.autoplayEnabled,
    quietStoryMode: quietStoryMode ?? this.quietStoryMode,
    musicEnabled: musicEnabled ?? this.musicEnabled,
    effectsEnabled: effectsEnabled ?? this.effectsEnabled,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
    cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
  );
  ChildProfile copyWithCompanion(ChildProfilesCompanion data) {
    return ChildProfile(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      ageBand: data.ageBand.present ? data.ageBand.value : this.ageBand,
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      seeds: data.seeds.present ? data.seeds.value : this.seeds,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
      lastActiveDate: data.lastActiveDate.present
          ? data.lastActiveDate.value
          : this.lastActiveDate,
      isUnlocked: data.isUnlocked.present
          ? data.isUnlocked.value
          : this.isUnlocked,
      hasSeenIntro: data.hasSeenIntro.present
          ? data.hasSeenIntro.value
          : this.hasSeenIntro,
      badgesJson: data.badgesJson.present
          ? data.badgesJson.value
          : this.badgesJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      autoplayEnabled: data.autoplayEnabled.present
          ? data.autoplayEnabled.value
          : this.autoplayEnabled,
      quietStoryMode: data.quietStoryMode.present
          ? data.quietStoryMode.value
          : this.quietStoryMode,
      musicEnabled: data.musicEnabled.present
          ? data.musicEnabled.value
          : this.musicEnabled,
      effectsEnabled: data.effectsEnabled.present
          ? data.effectsEnabled.value
          : this.effectsEnabled,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      reducedMotion: data.reducedMotion.present
          ? data.reducedMotion.value
          : this.reducedMotion,
      wifiOnlyDownloads: data.wifiOnlyDownloads.present
          ? data.wifiOnlyDownloads.value
          : this.wifiOnlyDownloads,
      cloudSyncEnabled: data.cloudSyncEnabled.present
          ? data.cloudSyncEnabled.value
          : this.cloudSyncEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChildProfile(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('ageBand: $ageBand, ')
          ..write('avatarId: $avatarId, ')
          ..write('seeds: $seeds, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('hasSeenIntro: $hasSeenIntro, ')
          ..write('badgesJson: $badgesJson, ')
          ..write('isActive: $isActive, ')
          ..write('autoplayEnabled: $autoplayEnabled, ')
          ..write('quietStoryMode: $quietStoryMode, ')
          ..write('musicEnabled: $musicEnabled, ')
          ..write('effectsEnabled: $effectsEnabled, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('reducedMotion: $reducedMotion, ')
          ..write('wifiOnlyDownloads: $wifiOnlyDownloads, ')
          ..write('cloudSyncEnabled: $cloudSyncEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    ageBand,
    avatarId,
    seeds,
    streakDays,
    lastActiveDate,
    isUnlocked,
    hasSeenIntro,
    badgesJson,
    isActive,
    autoplayEnabled,
    quietStoryMode,
    musicEnabled,
    effectsEnabled,
    notificationsEnabled,
    reducedMotion,
    wifiOnlyDownloads,
    cloudSyncEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChildProfile &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.ageBand == this.ageBand &&
          other.avatarId == this.avatarId &&
          other.seeds == this.seeds &&
          other.streakDays == this.streakDays &&
          other.lastActiveDate == this.lastActiveDate &&
          other.isUnlocked == this.isUnlocked &&
          other.hasSeenIntro == this.hasSeenIntro &&
          other.badgesJson == this.badgesJson &&
          other.isActive == this.isActive &&
          other.autoplayEnabled == this.autoplayEnabled &&
          other.quietStoryMode == this.quietStoryMode &&
          other.musicEnabled == this.musicEnabled &&
          other.effectsEnabled == this.effectsEnabled &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.reducedMotion == this.reducedMotion &&
          other.wifiOnlyDownloads == this.wifiOnlyDownloads &&
          other.cloudSyncEnabled == this.cloudSyncEnabled);
}

class ChildProfilesCompanion extends UpdateCompanion<ChildProfile> {
  final Value<String> id;
  final Value<String> nickname;
  final Value<String> ageBand;
  final Value<String> avatarId;
  final Value<int> seeds;
  final Value<int> streakDays;
  final Value<DateTime?> lastActiveDate;
  final Value<bool> isUnlocked;
  final Value<bool> hasSeenIntro;
  final Value<String> badgesJson;
  final Value<bool> isActive;
  final Value<bool> autoplayEnabled;
  final Value<bool> quietStoryMode;
  final Value<bool> musicEnabled;
  final Value<bool> effectsEnabled;
  final Value<bool> notificationsEnabled;
  final Value<bool> reducedMotion;
  final Value<bool> wifiOnlyDownloads;
  final Value<bool> cloudSyncEnabled;
  final Value<int> rowid;
  const ChildProfilesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.ageBand = const Value.absent(),
    this.avatarId = const Value.absent(),
    this.seeds = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.hasSeenIntro = const Value.absent(),
    this.badgesJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.autoplayEnabled = const Value.absent(),
    this.quietStoryMode = const Value.absent(),
    this.musicEnabled = const Value.absent(),
    this.effectsEnabled = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.reducedMotion = const Value.absent(),
    this.wifiOnlyDownloads = const Value.absent(),
    this.cloudSyncEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String nickname,
    required String ageBand,
    this.avatarId = const Value.absent(),
    this.seeds = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.hasSeenIntro = const Value.absent(),
    this.badgesJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.autoplayEnabled = const Value.absent(),
    this.quietStoryMode = const Value.absent(),
    this.musicEnabled = const Value.absent(),
    this.effectsEnabled = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.reducedMotion = const Value.absent(),
    this.wifiOnlyDownloads = const Value.absent(),
    this.cloudSyncEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nickname = Value(nickname),
       ageBand = Value(ageBand);
  static Insertable<ChildProfile> custom({
    Expression<String>? id,
    Expression<String>? nickname,
    Expression<String>? ageBand,
    Expression<String>? avatarId,
    Expression<int>? seeds,
    Expression<int>? streakDays,
    Expression<DateTime>? lastActiveDate,
    Expression<bool>? isUnlocked,
    Expression<bool>? hasSeenIntro,
    Expression<String>? badgesJson,
    Expression<bool>? isActive,
    Expression<bool>? autoplayEnabled,
    Expression<bool>? quietStoryMode,
    Expression<bool>? musicEnabled,
    Expression<bool>? effectsEnabled,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? reducedMotion,
    Expression<bool>? wifiOnlyDownloads,
    Expression<bool>? cloudSyncEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (ageBand != null) 'age_band': ageBand,
      if (avatarId != null) 'avatar_id': avatarId,
      if (seeds != null) 'seeds': seeds,
      if (streakDays != null) 'streak_days': streakDays,
      if (lastActiveDate != null) 'last_active_date': lastActiveDate,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (hasSeenIntro != null) 'has_seen_intro': hasSeenIntro,
      if (badgesJson != null) 'badges_json': badgesJson,
      if (isActive != null) 'is_active': isActive,
      if (autoplayEnabled != null) 'autoplay_enabled': autoplayEnabled,
      if (quietStoryMode != null) 'quiet_story_mode': quietStoryMode,
      if (musicEnabled != null) 'music_enabled': musicEnabled,
      if (effectsEnabled != null) 'effects_enabled': effectsEnabled,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (reducedMotion != null) 'reduced_motion': reducedMotion,
      if (wifiOnlyDownloads != null) 'wifi_only_downloads': wifiOnlyDownloads,
      if (cloudSyncEnabled != null) 'cloud_sync_enabled': cloudSyncEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? nickname,
    Value<String>? ageBand,
    Value<String>? avatarId,
    Value<int>? seeds,
    Value<int>? streakDays,
    Value<DateTime?>? lastActiveDate,
    Value<bool>? isUnlocked,
    Value<bool>? hasSeenIntro,
    Value<String>? badgesJson,
    Value<bool>? isActive,
    Value<bool>? autoplayEnabled,
    Value<bool>? quietStoryMode,
    Value<bool>? musicEnabled,
    Value<bool>? effectsEnabled,
    Value<bool>? notificationsEnabled,
    Value<bool>? reducedMotion,
    Value<bool>? wifiOnlyDownloads,
    Value<bool>? cloudSyncEnabled,
    Value<int>? rowid,
  }) {
    return ChildProfilesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      ageBand: ageBand ?? this.ageBand,
      avatarId: avatarId ?? this.avatarId,
      seeds: seeds ?? this.seeds,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      hasSeenIntro: hasSeenIntro ?? this.hasSeenIntro,
      badgesJson: badgesJson ?? this.badgesJson,
      isActive: isActive ?? this.isActive,
      autoplayEnabled: autoplayEnabled ?? this.autoplayEnabled,
      quietStoryMode: quietStoryMode ?? this.quietStoryMode,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      effectsEnabled: effectsEnabled ?? this.effectsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (ageBand.present) {
      map['age_band'] = Variable<String>(ageBand.value);
    }
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (seeds.present) {
      map['seeds'] = Variable<int>(seeds.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (lastActiveDate.present) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate.value);
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (hasSeenIntro.present) {
      map['has_seen_intro'] = Variable<bool>(hasSeenIntro.value);
    }
    if (badgesJson.present) {
      map['badges_json'] = Variable<String>(badgesJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (autoplayEnabled.present) {
      map['autoplay_enabled'] = Variable<bool>(autoplayEnabled.value);
    }
    if (quietStoryMode.present) {
      map['quiet_story_mode'] = Variable<bool>(quietStoryMode.value);
    }
    if (musicEnabled.present) {
      map['music_enabled'] = Variable<bool>(musicEnabled.value);
    }
    if (effectsEnabled.present) {
      map['effects_enabled'] = Variable<bool>(effectsEnabled.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (reducedMotion.present) {
      map['reduced_motion'] = Variable<bool>(reducedMotion.value);
    }
    if (wifiOnlyDownloads.present) {
      map['wifi_only_downloads'] = Variable<bool>(wifiOnlyDownloads.value);
    }
    if (cloudSyncEnabled.present) {
      map['cloud_sync_enabled'] = Variable<bool>(cloudSyncEnabled.value);
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
          ..write('nickname: $nickname, ')
          ..write('ageBand: $ageBand, ')
          ..write('avatarId: $avatarId, ')
          ..write('seeds: $seeds, ')
          ..write('streakDays: $streakDays, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('hasSeenIntro: $hasSeenIntro, ')
          ..write('badgesJson: $badgesJson, ')
          ..write('isActive: $isActive, ')
          ..write('autoplayEnabled: $autoplayEnabled, ')
          ..write('quietStoryMode: $quietStoryMode, ')
          ..write('musicEnabled: $musicEnabled, ')
          ..write('effectsEnabled: $effectsEnabled, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('reducedMotion: $reducedMotion, ')
          ..write('wifiOnlyDownloads: $wifiOnlyDownloads, ')
          ..write('cloudSyncEnabled: $cloudSyncEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoryProgressTable extends StoryProgress
    with TableInfo<$StoryProgressTable, StoryProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoryProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storyIdMeta = const VerificationMeta(
    'storyId',
  );
  @override
  late final GeneratedColumn<String> storyId = GeneratedColumn<String>(
    'story_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSceneIndexMeta = const VerificationMeta(
    'lastSceneIndex',
  );
  @override
  late final GeneratedColumn<int> lastSceneIndex = GeneratedColumn<int>(
    'last_scene_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant('in_progress'),
  );
  static const VerificationMeta _gameScoreMeta = const VerificationMeta(
    'gameScore',
  );
  @override
  late final GeneratedColumn<int> gameScore = GeneratedColumn<int>(
    'game_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(0),
  );
  static const VerificationMeta _seedsEarnedMeta = const VerificationMeta(
    'seedsEarned',
  );
  @override
  late final GeneratedColumn<int> seedsEarned = GeneratedColumn<int>(
    'seeds_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    storyId,
    lastSceneIndex,
    status,
    gameScore,
    seedsEarned,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'story_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoryProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('story_id')) {
      context.handle(
        _storyIdMeta,
        storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storyIdMeta);
    }
    if (data.containsKey('last_scene_index')) {
      context.handle(
        _lastSceneIndexMeta,
        lastSceneIndex.isAcceptableOrUnknown(
          data['last_scene_index']!,
          _lastSceneIndexMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('game_score')) {
      context.handle(
        _gameScoreMeta,
        gameScore.isAcceptableOrUnknown(data['game_score']!, _gameScoreMeta),
      );
    }
    if (data.containsKey('seeds_earned')) {
      context.handle(
        _seedsEarnedMeta,
        seedsEarned.isAcceptableOrUnknown(
          data['seeds_earned']!,
          _seedsEarnedMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, storyId};
  @override
  StoryProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoryProgressData(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      storyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_id'],
      )!,
      lastSceneIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_scene_index'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      gameScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}game_score'],
      )!,
      seedsEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seeds_earned'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $StoryProgressTable createAlias(String alias) {
    return $StoryProgressTable(attachedDatabase, alias);
  }
}

class StoryProgressData extends DataClass
    implements Insertable<StoryProgressData> {
  final String profileId;
  final String storyId;
  final int lastSceneIndex;
  final String status;
  final int gameScore;
  final int seedsEarned;
  final DateTime startedAt;
  final DateTime? completedAt;
  const StoryProgressData({
    required this.profileId,
    required this.storyId,
    required this.lastSceneIndex,
    required this.status,
    required this.gameScore,
    required this.seedsEarned,
    required this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['story_id'] = Variable<String>(storyId);
    map['last_scene_index'] = Variable<int>(lastSceneIndex);
    map['status'] = Variable<String>(status);
    map['game_score'] = Variable<int>(gameScore);
    map['seeds_earned'] = Variable<int>(seedsEarned);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  StoryProgressCompanion toCompanion(bool nullToAbsent) {
    return StoryProgressCompanion(
      profileId: Value(profileId),
      storyId: Value(storyId),
      lastSceneIndex: Value(lastSceneIndex),
      status: Value(status),
      gameScore: Value(gameScore),
      seedsEarned: Value(seedsEarned),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory StoryProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoryProgressData(
      profileId: serializer.fromJson<String>(json['profileId']),
      storyId: serializer.fromJson<String>(json['storyId']),
      lastSceneIndex: serializer.fromJson<int>(json['lastSceneIndex']),
      status: serializer.fromJson<String>(json['status']),
      gameScore: serializer.fromJson<int>(json['gameScore']),
      seedsEarned: serializer.fromJson<int>(json['seedsEarned']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'storyId': serializer.toJson<String>(storyId),
      'lastSceneIndex': serializer.toJson<int>(lastSceneIndex),
      'status': serializer.toJson<String>(status),
      'gameScore': serializer.toJson<int>(gameScore),
      'seedsEarned': serializer.toJson<int>(seedsEarned),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  StoryProgressData copyWith({
    String? profileId,
    String? storyId,
    int? lastSceneIndex,
    String? status,
    int? gameScore,
    int? seedsEarned,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => StoryProgressData(
    profileId: profileId ?? this.profileId,
    storyId: storyId ?? this.storyId,
    lastSceneIndex: lastSceneIndex ?? this.lastSceneIndex,
    status: status ?? this.status,
    gameScore: gameScore ?? this.gameScore,
    seedsEarned: seedsEarned ?? this.seedsEarned,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  StoryProgressData copyWithCompanion(StoryProgressCompanion data) {
    return StoryProgressData(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      lastSceneIndex: data.lastSceneIndex.present
          ? data.lastSceneIndex.value
          : this.lastSceneIndex,
      status: data.status.present ? data.status.value : this.status,
      gameScore: data.gameScore.present ? data.gameScore.value : this.gameScore,
      seedsEarned: data.seedsEarned.present
          ? data.seedsEarned.value
          : this.seedsEarned,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoryProgressData(')
          ..write('profileId: $profileId, ')
          ..write('storyId: $storyId, ')
          ..write('lastSceneIndex: $lastSceneIndex, ')
          ..write('status: $status, ')
          ..write('gameScore: $gameScore, ')
          ..write('seedsEarned: $seedsEarned, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    storyId,
    lastSceneIndex,
    status,
    gameScore,
    seedsEarned,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoryProgressData &&
          other.profileId == this.profileId &&
          other.storyId == this.storyId &&
          other.lastSceneIndex == this.lastSceneIndex &&
          other.status == this.status &&
          other.gameScore == this.gameScore &&
          other.seedsEarned == this.seedsEarned &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class StoryProgressCompanion extends UpdateCompanion<StoryProgressData> {
  final Value<String> profileId;
  final Value<String> storyId;
  final Value<int> lastSceneIndex;
  final Value<String> status;
  final Value<int> gameScore;
  final Value<int> seedsEarned;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const StoryProgressCompanion({
    this.profileId = const Value.absent(),
    this.storyId = const Value.absent(),
    this.lastSceneIndex = const Value.absent(),
    this.status = const Value.absent(),
    this.gameScore = const Value.absent(),
    this.seedsEarned = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoryProgressCompanion.insert({
    required String profileId,
    required String storyId,
    this.lastSceneIndex = const Value.absent(),
    this.status = const Value.absent(),
    this.gameScore = const Value.absent(),
    this.seedsEarned = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       storyId = Value(storyId);
  static Insertable<StoryProgressData> custom({
    Expression<String>? profileId,
    Expression<String>? storyId,
    Expression<int>? lastSceneIndex,
    Expression<String>? status,
    Expression<int>? gameScore,
    Expression<int>? seedsEarned,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (storyId != null) 'story_id': storyId,
      if (lastSceneIndex != null) 'last_scene_index': lastSceneIndex,
      if (status != null) 'status': status,
      if (gameScore != null) 'game_score': gameScore,
      if (seedsEarned != null) 'seeds_earned': seedsEarned,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoryProgressCompanion copyWith({
    Value<String>? profileId,
    Value<String>? storyId,
    Value<int>? lastSceneIndex,
    Value<String>? status,
    Value<int>? gameScore,
    Value<int>? seedsEarned,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return StoryProgressCompanion(
      profileId: profileId ?? this.profileId,
      storyId: storyId ?? this.storyId,
      lastSceneIndex: lastSceneIndex ?? this.lastSceneIndex,
      status: status ?? this.status,
      gameScore: gameScore ?? this.gameScore,
      seedsEarned: seedsEarned ?? this.seedsEarned,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (storyId.present) {
      map['story_id'] = Variable<String>(storyId.value);
    }
    if (lastSceneIndex.present) {
      map['last_scene_index'] = Variable<int>(lastSceneIndex.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (gameScore.present) {
      map['game_score'] = Variable<int>(gameScore.value);
    }
    if (seedsEarned.present) {
      map['seeds_earned'] = Variable<int>(seedsEarned.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoryProgressCompanion(')
          ..write('profileId: $profileId, ')
          ..write('storyId: $storyId, ')
          ..write('lastSceneIndex: $lastSceneIndex, ')
          ..write('status: $status, ')
          ..write('gameScore: $gameScore, ')
          ..write('seedsEarned: $seedsEarned, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VerseMasteryTable extends VerseMastery
    with TableInfo<$VerseMasteryTable, VerseMasteryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseMasteryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseKeyMeta = const VerificationMeta(
    'verseKey',
  );
  @override
  late final GeneratedColumn<String> verseKey = GeneratedColumn<String>(
    'verse_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseRefMeta = const VerificationMeta(
    'verseRef',
  );
  @override
  late final GeneratedColumn<String> verseRef = GeneratedColumn<String>(
    'verse_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _storyIdMeta = const VerificationMeta(
    'storyId',
  );
  @override
  late final GeneratedColumn<String> storyId = GeneratedColumn<String>(
    'story_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('introduced'),
  );
  static const VerificationMeta _nextReviewDateMeta = const VerificationMeta(
    'nextReviewDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewDate =
      GeneratedColumn<DateTime>(
        'next_review_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _masteredAtMeta = const VerificationMeta(
    'masteredAt',
  );
  @override
  late final GeneratedColumn<DateTime> masteredAt = GeneratedColumn<DateTime>(
    'mastered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    verseKey,
    verseRef,
    storyId,
    stage,
    nextReviewDate,
    masteredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_mastery';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseMasteryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('verse_key')) {
      context.handle(
        _verseKeyMeta,
        verseKey.isAcceptableOrUnknown(data['verse_key']!, _verseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_verseKeyMeta);
    }
    if (data.containsKey('verse_ref')) {
      context.handle(
        _verseRefMeta,
        verseRef.isAcceptableOrUnknown(data['verse_ref']!, _verseRefMeta),
      );
    }
    if (data.containsKey('story_id')) {
      context.handle(
        _storyIdMeta,
        storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('next_review_date')) {
      context.handle(
        _nextReviewDateMeta,
        nextReviewDate.isAcceptableOrUnknown(
          data['next_review_date']!,
          _nextReviewDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewDateMeta);
    }
    if (data.containsKey('mastered_at')) {
      context.handle(
        _masteredAtMeta,
        masteredAt.isAcceptableOrUnknown(data['mastered_at']!, _masteredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VerseMasteryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseMasteryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      verseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_key'],
      )!,
      verseRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_ref'],
      )!,
      storyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_id'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      nextReviewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_date'],
      )!,
      masteredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}mastered_at'],
      ),
    );
  }

  @override
  $VerseMasteryTable createAlias(String alias) {
    return $VerseMasteryTable(attachedDatabase, alias);
  }
}

class VerseMasteryData extends DataClass
    implements Insertable<VerseMasteryData> {
  final int id;
  final String profileId;
  final String verseKey;
  final String verseRef;
  final String storyId;
  final String stage;
  final DateTime nextReviewDate;
  final DateTime? masteredAt;
  const VerseMasteryData({
    required this.id,
    required this.profileId,
    required this.verseKey,
    required this.verseRef,
    required this.storyId,
    required this.stage,
    required this.nextReviewDate,
    this.masteredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['verse_key'] = Variable<String>(verseKey);
    map['verse_ref'] = Variable<String>(verseRef);
    map['story_id'] = Variable<String>(storyId);
    map['stage'] = Variable<String>(stage);
    map['next_review_date'] = Variable<DateTime>(nextReviewDate);
    if (!nullToAbsent || masteredAt != null) {
      map['mastered_at'] = Variable<DateTime>(masteredAt);
    }
    return map;
  }

  VerseMasteryCompanion toCompanion(bool nullToAbsent) {
    return VerseMasteryCompanion(
      id: Value(id),
      profileId: Value(profileId),
      verseKey: Value(verseKey),
      verseRef: Value(verseRef),
      storyId: Value(storyId),
      stage: Value(stage),
      nextReviewDate: Value(nextReviewDate),
      masteredAt: masteredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(masteredAt),
    );
  }

  factory VerseMasteryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseMasteryData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      verseKey: serializer.fromJson<String>(json['verseKey']),
      verseRef: serializer.fromJson<String>(json['verseRef']),
      storyId: serializer.fromJson<String>(json['storyId']),
      stage: serializer.fromJson<String>(json['stage']),
      nextReviewDate: serializer.fromJson<DateTime>(json['nextReviewDate']),
      masteredAt: serializer.fromJson<DateTime?>(json['masteredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'verseKey': serializer.toJson<String>(verseKey),
      'verseRef': serializer.toJson<String>(verseRef),
      'storyId': serializer.toJson<String>(storyId),
      'stage': serializer.toJson<String>(stage),
      'nextReviewDate': serializer.toJson<DateTime>(nextReviewDate),
      'masteredAt': serializer.toJson<DateTime?>(masteredAt),
    };
  }

  VerseMasteryData copyWith({
    int? id,
    String? profileId,
    String? verseKey,
    String? verseRef,
    String? storyId,
    String? stage,
    DateTime? nextReviewDate,
    Value<DateTime?> masteredAt = const Value.absent(),
  }) => VerseMasteryData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    verseKey: verseKey ?? this.verseKey,
    verseRef: verseRef ?? this.verseRef,
    storyId: storyId ?? this.storyId,
    stage: stage ?? this.stage,
    nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    masteredAt: masteredAt.present ? masteredAt.value : this.masteredAt,
  );
  VerseMasteryData copyWithCompanion(VerseMasteryCompanion data) {
    return VerseMasteryData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      verseKey: data.verseKey.present ? data.verseKey.value : this.verseKey,
      verseRef: data.verseRef.present ? data.verseRef.value : this.verseRef,
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      stage: data.stage.present ? data.stage.value : this.stage,
      nextReviewDate: data.nextReviewDate.present
          ? data.nextReviewDate.value
          : this.nextReviewDate,
      masteredAt: data.masteredAt.present
          ? data.masteredAt.value
          : this.masteredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseMasteryData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('verseKey: $verseKey, ')
          ..write('verseRef: $verseRef, ')
          ..write('storyId: $storyId, ')
          ..write('stage: $stage, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('masteredAt: $masteredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    verseKey,
    verseRef,
    storyId,
    stage,
    nextReviewDate,
    masteredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseMasteryData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.verseKey == this.verseKey &&
          other.verseRef == this.verseRef &&
          other.storyId == this.storyId &&
          other.stage == this.stage &&
          other.nextReviewDate == this.nextReviewDate &&
          other.masteredAt == this.masteredAt);
}

class VerseMasteryCompanion extends UpdateCompanion<VerseMasteryData> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> verseKey;
  final Value<String> verseRef;
  final Value<String> storyId;
  final Value<String> stage;
  final Value<DateTime> nextReviewDate;
  final Value<DateTime?> masteredAt;
  const VerseMasteryCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.verseKey = const Value.absent(),
    this.verseRef = const Value.absent(),
    this.storyId = const Value.absent(),
    this.stage = const Value.absent(),
    this.nextReviewDate = const Value.absent(),
    this.masteredAt = const Value.absent(),
  });
  VerseMasteryCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String verseKey,
    this.verseRef = const Value.absent(),
    this.storyId = const Value.absent(),
    this.stage = const Value.absent(),
    required DateTime nextReviewDate,
    this.masteredAt = const Value.absent(),
  }) : profileId = Value(profileId),
       verseKey = Value(verseKey),
       nextReviewDate = Value(nextReviewDate);
  static Insertable<VerseMasteryData> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? verseKey,
    Expression<String>? verseRef,
    Expression<String>? storyId,
    Expression<String>? stage,
    Expression<DateTime>? nextReviewDate,
    Expression<DateTime>? masteredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (verseKey != null) 'verse_key': verseKey,
      if (verseRef != null) 'verse_ref': verseRef,
      if (storyId != null) 'story_id': storyId,
      if (stage != null) 'stage': stage,
      if (nextReviewDate != null) 'next_review_date': nextReviewDate,
      if (masteredAt != null) 'mastered_at': masteredAt,
    });
  }

  VerseMasteryCompanion copyWith({
    Value<int>? id,
    Value<String>? profileId,
    Value<String>? verseKey,
    Value<String>? verseRef,
    Value<String>? storyId,
    Value<String>? stage,
    Value<DateTime>? nextReviewDate,
    Value<DateTime?>? masteredAt,
  }) {
    return VerseMasteryCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      verseKey: verseKey ?? this.verseKey,
      verseRef: verseRef ?? this.verseRef,
      storyId: storyId ?? this.storyId,
      stage: stage ?? this.stage,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      masteredAt: masteredAt ?? this.masteredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (verseKey.present) {
      map['verse_key'] = Variable<String>(verseKey.value);
    }
    if (verseRef.present) {
      map['verse_ref'] = Variable<String>(verseRef.value);
    }
    if (storyId.present) {
      map['story_id'] = Variable<String>(storyId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (nextReviewDate.present) {
      map['next_review_date'] = Variable<DateTime>(nextReviewDate.value);
    }
    if (masteredAt.present) {
      map['mastered_at'] = Variable<DateTime>(masteredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseMasteryCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('verseKey: $verseKey, ')
          ..write('verseRef: $verseRef, ')
          ..write('storyId: $storyId, ')
          ..write('stage: $stage, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('masteredAt: $masteredAt')
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
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    operation,
    payload,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String profileId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const SyncQueueData({
    required this.id,
    required this.profileId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      profileId: Value(profileId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<String>(profileId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? profileId,
    String? operation,
    String? payload,
    DateTime? createdAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, operation, payload, createdAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> profileId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String profileId,
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  }) : profileId = Value(profileId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? profileId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? profileId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<DateTime?>? syncedAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
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
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
          ..write('profileId: $profileId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $ContentVersionsTable extends ContentVersions
    with TableInfo<$ContentVersionsTable, ContentVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [contentType, version, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contentType};
  @override
  ContentVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentVersion(
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ContentVersionsTable createAlias(String alias) {
    return $ContentVersionsTable(attachedDatabase, alias);
  }
}

class ContentVersion extends DataClass implements Insertable<ContentVersion> {
  final String contentType;
  final String version;
  final DateTime updatedAt;
  const ContentVersion({
    required this.contentType,
    required this.version,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['content_type'] = Variable<String>(contentType);
    map['version'] = Variable<String>(version);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ContentVersionsCompanion toCompanion(bool nullToAbsent) {
    return ContentVersionsCompanion(
      contentType: Value(contentType),
      version: Value(version),
      updatedAt: Value(updatedAt),
    );
  }

  factory ContentVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentVersion(
      contentType: serializer.fromJson<String>(json['contentType']),
      version: serializer.fromJson<String>(json['version']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contentType': serializer.toJson<String>(contentType),
      'version': serializer.toJson<String>(version),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ContentVersion copyWith({
    String? contentType,
    String? version,
    DateTime? updatedAt,
  }) => ContentVersion(
    contentType: contentType ?? this.contentType,
    version: version ?? this.version,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ContentVersion copyWithCompanion(ContentVersionsCompanion data) {
    return ContentVersion(
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentVersion(')
          ..write('contentType: $contentType, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(contentType, version, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentVersion &&
          other.contentType == this.contentType &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt);
}

class ContentVersionsCompanion extends UpdateCompanion<ContentVersion> {
  final Value<String> contentType;
  final Value<String> version;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ContentVersionsCompanion({
    this.contentType = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentVersionsCompanion.insert({
    required String contentType,
    required String version,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contentType = Value(contentType),
       version = Value(version);
  static Insertable<ContentVersion> custom({
    Expression<String>? contentType,
    Expression<String>? version,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contentType != null) 'content_type': contentType,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentVersionsCompanion copyWith({
    Value<String>? contentType,
    Value<String>? version,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ContentVersionsCompanion(
      contentType: contentType ?? this.contentType,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
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
    return (StringBuffer('ContentVersionsCompanion(')
          ..write('contentType: $contentType, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VersesTable verses = $VersesTable(this);
  late final $ChildProfilesTable childProfiles = $ChildProfilesTable(this);
  late final $StoryProgressTable storyProgress = $StoryProgressTable(this);
  late final $VerseMasteryTable verseMastery = $VerseMasteryTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $ContentVersionsTable contentVersions = $ContentVersionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    verses,
    childProfiles,
    storyProgress,
    verseMastery,
    syncQueue,
    contentVersions,
  ];
}

typedef $$VersesTableCreateCompanionBuilder =
    VersesCompanion Function({
      Value<int> id,
      required String book,
      required int chapter,
      required int verse,
      required String body,
      Value<String> source,
      Value<bool> isAdapted,
    });
typedef $$VersesTableUpdateCompanionBuilder =
    VersesCompanion Function({
      Value<int> id,
      Value<String> book,
      Value<int> chapter,
      Value<int> verse,
      Value<String> body,
      Value<String> source,
      Value<bool> isAdapted,
    });

class $$VersesTableFilterComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdapted => $composableBuilder(
    column: $table.isAdapted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VersesTableOrderingComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdapted => $composableBuilder(
    column: $table.isAdapted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get book =>
      $composableBuilder(column: $table.book, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isAdapted =>
      $composableBuilder(column: $table.isAdapted, builder: (column) => column);
}

class $$VersesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VersesTable,
          Verse,
          $$VersesTableFilterComposer,
          $$VersesTableOrderingComposer,
          $$VersesTableAnnotationComposer,
          $$VersesTableCreateCompanionBuilder,
          $$VersesTableUpdateCompanionBuilder,
          (Verse, BaseReferences<_$AppDatabase, $VersesTable, Verse>),
          Verse,
          PrefetchHooks Function()
        > {
  $$VersesTableTableManager(_$AppDatabase db, $VersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> book = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> isAdapted = const Value.absent(),
              }) => VersesCompanion(
                id: id,
                book: book,
                chapter: chapter,
                verse: verse,
                body: body,
                source: source,
                isAdapted: isAdapted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String book,
                required int chapter,
                required int verse,
                required String body,
                Value<String> source = const Value.absent(),
                Value<bool> isAdapted = const Value.absent(),
              }) => VersesCompanion.insert(
                id: id,
                book: book,
                chapter: chapter,
                verse: verse,
                body: body,
                source: source,
                isAdapted: isAdapted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VersesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VersesTable,
      Verse,
      $$VersesTableFilterComposer,
      $$VersesTableOrderingComposer,
      $$VersesTableAnnotationComposer,
      $$VersesTableCreateCompanionBuilder,
      $$VersesTableUpdateCompanionBuilder,
      (Verse, BaseReferences<_$AppDatabase, $VersesTable, Verse>),
      Verse,
      PrefetchHooks Function()
    >;
typedef $$ChildProfilesTableCreateCompanionBuilder =
    ChildProfilesCompanion Function({
      Value<String> id,
      required String nickname,
      required String ageBand,
      Value<String> avatarId,
      Value<int> seeds,
      Value<int> streakDays,
      Value<DateTime?> lastActiveDate,
      Value<bool> isUnlocked,
      Value<bool> hasSeenIntro,
      Value<String> badgesJson,
      Value<bool> isActive,
      Value<bool> autoplayEnabled,
      Value<bool> quietStoryMode,
      Value<bool> musicEnabled,
      Value<bool> effectsEnabled,
      Value<bool> notificationsEnabled,
      Value<bool> reducedMotion,
      Value<bool> wifiOnlyDownloads,
      Value<bool> cloudSyncEnabled,
      Value<int> rowid,
    });
typedef $$ChildProfilesTableUpdateCompanionBuilder =
    ChildProfilesCompanion Function({
      Value<String> id,
      Value<String> nickname,
      Value<String> ageBand,
      Value<String> avatarId,
      Value<int> seeds,
      Value<int> streakDays,
      Value<DateTime?> lastActiveDate,
      Value<bool> isUnlocked,
      Value<bool> hasSeenIntro,
      Value<String> badgesJson,
      Value<bool> isActive,
      Value<bool> autoplayEnabled,
      Value<bool> quietStoryMode,
      Value<bool> musicEnabled,
      Value<bool> effectsEnabled,
      Value<bool> notificationsEnabled,
      Value<bool> reducedMotion,
      Value<bool> wifiOnlyDownloads,
      Value<bool> cloudSyncEnabled,
      Value<int> rowid,
    });

class $$ChildProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ageBand => $composableBuilder(
    column: $table.ageBand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarId => $composableBuilder(
    column: $table.avatarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seeds => $composableBuilder(
    column: $table.seeds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasSeenIntro => $composableBuilder(
    column: $table.hasSeenIntro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get badgesJson => $composableBuilder(
    column: $table.badgesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoplayEnabled => $composableBuilder(
    column: $table.autoplayEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get quietStoryMode => $composableBuilder(
    column: $table.quietStoryMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get musicEnabled => $composableBuilder(
    column: $table.musicEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get effectsEnabled => $composableBuilder(
    column: $table.effectsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wifiOnlyDownloads => $composableBuilder(
    column: $table.wifiOnlyDownloads,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cloudSyncEnabled => $composableBuilder(
    column: $table.cloudSyncEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChildProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ageBand => $composableBuilder(
    column: $table.ageBand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarId => $composableBuilder(
    column: $table.avatarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seeds => $composableBuilder(
    column: $table.seeds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasSeenIntro => $composableBuilder(
    column: $table.hasSeenIntro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get badgesJson => $composableBuilder(
    column: $table.badgesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoplayEnabled => $composableBuilder(
    column: $table.autoplayEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get quietStoryMode => $composableBuilder(
    column: $table.quietStoryMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get musicEnabled => $composableBuilder(
    column: $table.musicEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get effectsEnabled => $composableBuilder(
    column: $table.effectsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wifiOnlyDownloads => $composableBuilder(
    column: $table.wifiOnlyDownloads,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cloudSyncEnabled => $composableBuilder(
    column: $table.cloudSyncEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildProfilesTable> {
  $$ChildProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get ageBand =>
      $composableBuilder(column: $table.ageBand, builder: (column) => column);

  GeneratedColumn<String> get avatarId =>
      $composableBuilder(column: $table.avatarId, builder: (column) => column);

  GeneratedColumn<int> get seeds =>
      $composableBuilder(column: $table.seeds, builder: (column) => column);

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasSeenIntro => $composableBuilder(
    column: $table.hasSeenIntro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get badgesJson => $composableBuilder(
    column: $table.badgesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get autoplayEnabled => $composableBuilder(
    column: $table.autoplayEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get quietStoryMode => $composableBuilder(
    column: $table.quietStoryMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get musicEnabled => $composableBuilder(
    column: $table.musicEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get effectsEnabled => $composableBuilder(
    column: $table.effectsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reducedMotion => $composableBuilder(
    column: $table.reducedMotion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wifiOnlyDownloads => $composableBuilder(
    column: $table.wifiOnlyDownloads,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cloudSyncEnabled => $composableBuilder(
    column: $table.cloudSyncEnabled,
    builder: (column) => column,
  );
}

class $$ChildProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChildProfilesTable,
          ChildProfile,
          $$ChildProfilesTableFilterComposer,
          $$ChildProfilesTableOrderingComposer,
          $$ChildProfilesTableAnnotationComposer,
          $$ChildProfilesTableCreateCompanionBuilder,
          $$ChildProfilesTableUpdateCompanionBuilder,
          (
            ChildProfile,
            BaseReferences<_$AppDatabase, $ChildProfilesTable, ChildProfile>,
          ),
          ChildProfile,
          PrefetchHooks Function()
        > {
  $$ChildProfilesTableTableManager(_$AppDatabase db, $ChildProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> ageBand = const Value.absent(),
                Value<String> avatarId = const Value.absent(),
                Value<int> seeds = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<bool> hasSeenIntro = const Value.absent(),
                Value<String> badgesJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> autoplayEnabled = const Value.absent(),
                Value<bool> quietStoryMode = const Value.absent(),
                Value<bool> musicEnabled = const Value.absent(),
                Value<bool> effectsEnabled = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> reducedMotion = const Value.absent(),
                Value<bool> wifiOnlyDownloads = const Value.absent(),
                Value<bool> cloudSyncEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChildProfilesCompanion(
                id: id,
                nickname: nickname,
                ageBand: ageBand,
                avatarId: avatarId,
                seeds: seeds,
                streakDays: streakDays,
                lastActiveDate: lastActiveDate,
                isUnlocked: isUnlocked,
                hasSeenIntro: hasSeenIntro,
                badgesJson: badgesJson,
                isActive: isActive,
                autoplayEnabled: autoplayEnabled,
                quietStoryMode: quietStoryMode,
                musicEnabled: musicEnabled,
                effectsEnabled: effectsEnabled,
                notificationsEnabled: notificationsEnabled,
                reducedMotion: reducedMotion,
                wifiOnlyDownloads: wifiOnlyDownloads,
                cloudSyncEnabled: cloudSyncEnabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String nickname,
                required String ageBand,
                Value<String> avatarId = const Value.absent(),
                Value<int> seeds = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<bool> hasSeenIntro = const Value.absent(),
                Value<String> badgesJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> autoplayEnabled = const Value.absent(),
                Value<bool> quietStoryMode = const Value.absent(),
                Value<bool> musicEnabled = const Value.absent(),
                Value<bool> effectsEnabled = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<bool> reducedMotion = const Value.absent(),
                Value<bool> wifiOnlyDownloads = const Value.absent(),
                Value<bool> cloudSyncEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChildProfilesCompanion.insert(
                id: id,
                nickname: nickname,
                ageBand: ageBand,
                avatarId: avatarId,
                seeds: seeds,
                streakDays: streakDays,
                lastActiveDate: lastActiveDate,
                isUnlocked: isUnlocked,
                hasSeenIntro: hasSeenIntro,
                badgesJson: badgesJson,
                isActive: isActive,
                autoplayEnabled: autoplayEnabled,
                quietStoryMode: quietStoryMode,
                musicEnabled: musicEnabled,
                effectsEnabled: effectsEnabled,
                notificationsEnabled: notificationsEnabled,
                reducedMotion: reducedMotion,
                wifiOnlyDownloads: wifiOnlyDownloads,
                cloudSyncEnabled: cloudSyncEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChildProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChildProfilesTable,
      ChildProfile,
      $$ChildProfilesTableFilterComposer,
      $$ChildProfilesTableOrderingComposer,
      $$ChildProfilesTableAnnotationComposer,
      $$ChildProfilesTableCreateCompanionBuilder,
      $$ChildProfilesTableUpdateCompanionBuilder,
      (
        ChildProfile,
        BaseReferences<_$AppDatabase, $ChildProfilesTable, ChildProfile>,
      ),
      ChildProfile,
      PrefetchHooks Function()
    >;
typedef $$StoryProgressTableCreateCompanionBuilder =
    StoryProgressCompanion Function({
      required String profileId,
      required String storyId,
      Value<int> lastSceneIndex,
      Value<String> status,
      Value<int> gameScore,
      Value<int> seedsEarned,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$StoryProgressTableUpdateCompanionBuilder =
    StoryProgressCompanion Function({
      Value<String> profileId,
      Value<String> storyId,
      Value<int> lastSceneIndex,
      Value<String> status,
      Value<int> gameScore,
      Value<int> seedsEarned,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$StoryProgressTableFilterComposer
    extends Composer<_$AppDatabase, $StoryProgressTable> {
  $$StoryProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSceneIndex => $composableBuilder(
    column: $table.lastSceneIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gameScore => $composableBuilder(
    column: $table.gameScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seedsEarned => $composableBuilder(
    column: $table.seedsEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoryProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $StoryProgressTable> {
  $$StoryProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSceneIndex => $composableBuilder(
    column: $table.lastSceneIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gameScore => $composableBuilder(
    column: $table.gameScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seedsEarned => $composableBuilder(
    column: $table.seedsEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoryProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoryProgressTable> {
  $$StoryProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get storyId =>
      $composableBuilder(column: $table.storyId, builder: (column) => column);

  GeneratedColumn<int> get lastSceneIndex => $composableBuilder(
    column: $table.lastSceneIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get gameScore =>
      $composableBuilder(column: $table.gameScore, builder: (column) => column);

  GeneratedColumn<int> get seedsEarned => $composableBuilder(
    column: $table.seedsEarned,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$StoryProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoryProgressTable,
          StoryProgressData,
          $$StoryProgressTableFilterComposer,
          $$StoryProgressTableOrderingComposer,
          $$StoryProgressTableAnnotationComposer,
          $$StoryProgressTableCreateCompanionBuilder,
          $$StoryProgressTableUpdateCompanionBuilder,
          (
            StoryProgressData,
            BaseReferences<
              _$AppDatabase,
              $StoryProgressTable,
              StoryProgressData
            >,
          ),
          StoryProgressData,
          PrefetchHooks Function()
        > {
  $$StoryProgressTableTableManager(_$AppDatabase db, $StoryProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoryProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoryProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoryProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> storyId = const Value.absent(),
                Value<int> lastSceneIndex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> gameScore = const Value.absent(),
                Value<int> seedsEarned = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoryProgressCompanion(
                profileId: profileId,
                storyId: storyId,
                lastSceneIndex: lastSceneIndex,
                status: status,
                gameScore: gameScore,
                seedsEarned: seedsEarned,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String storyId,
                Value<int> lastSceneIndex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> gameScore = const Value.absent(),
                Value<int> seedsEarned = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoryProgressCompanion.insert(
                profileId: profileId,
                storyId: storyId,
                lastSceneIndex: lastSceneIndex,
                status: status,
                gameScore: gameScore,
                seedsEarned: seedsEarned,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoryProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoryProgressTable,
      StoryProgressData,
      $$StoryProgressTableFilterComposer,
      $$StoryProgressTableOrderingComposer,
      $$StoryProgressTableAnnotationComposer,
      $$StoryProgressTableCreateCompanionBuilder,
      $$StoryProgressTableUpdateCompanionBuilder,
      (
        StoryProgressData,
        BaseReferences<_$AppDatabase, $StoryProgressTable, StoryProgressData>,
      ),
      StoryProgressData,
      PrefetchHooks Function()
    >;
typedef $$VerseMasteryTableCreateCompanionBuilder =
    VerseMasteryCompanion Function({
      Value<int> id,
      required String profileId,
      required String verseKey,
      Value<String> verseRef,
      Value<String> storyId,
      Value<String> stage,
      required DateTime nextReviewDate,
      Value<DateTime?> masteredAt,
    });
typedef $$VerseMasteryTableUpdateCompanionBuilder =
    VerseMasteryCompanion Function({
      Value<int> id,
      Value<String> profileId,
      Value<String> verseKey,
      Value<String> verseRef,
      Value<String> storyId,
      Value<String> stage,
      Value<DateTime> nextReviewDate,
      Value<DateTime?> masteredAt,
    });

class $$VerseMasteryTableFilterComposer
    extends Composer<_$AppDatabase, $VerseMasteryTable> {
  $$VerseMasteryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseRef => $composableBuilder(
    column: $table.verseRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VerseMasteryTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseMasteryTable> {
  $$VerseMasteryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseRef => $composableBuilder(
    column: $table.verseRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VerseMasteryTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseMasteryTable> {
  $$VerseMasteryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get verseKey =>
      $composableBuilder(column: $table.verseKey, builder: (column) => column);

  GeneratedColumn<String> get verseRef =>
      $composableBuilder(column: $table.verseRef, builder: (column) => column);

  GeneratedColumn<String> get storyId =>
      $composableBuilder(column: $table.storyId, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get masteredAt => $composableBuilder(
    column: $table.masteredAt,
    builder: (column) => column,
  );
}

class $$VerseMasteryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VerseMasteryTable,
          VerseMasteryData,
          $$VerseMasteryTableFilterComposer,
          $$VerseMasteryTableOrderingComposer,
          $$VerseMasteryTableAnnotationComposer,
          $$VerseMasteryTableCreateCompanionBuilder,
          $$VerseMasteryTableUpdateCompanionBuilder,
          (
            VerseMasteryData,
            BaseReferences<_$AppDatabase, $VerseMasteryTable, VerseMasteryData>,
          ),
          VerseMasteryData,
          PrefetchHooks Function()
        > {
  $$VerseMasteryTableTableManager(_$AppDatabase db, $VerseMasteryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerseMasteryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerseMasteryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerseMasteryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> verseKey = const Value.absent(),
                Value<String> verseRef = const Value.absent(),
                Value<String> storyId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<DateTime> nextReviewDate = const Value.absent(),
                Value<DateTime?> masteredAt = const Value.absent(),
              }) => VerseMasteryCompanion(
                id: id,
                profileId: profileId,
                verseKey: verseKey,
                verseRef: verseRef,
                storyId: storyId,
                stage: stage,
                nextReviewDate: nextReviewDate,
                masteredAt: masteredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileId,
                required String verseKey,
                Value<String> verseRef = const Value.absent(),
                Value<String> storyId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                required DateTime nextReviewDate,
                Value<DateTime?> masteredAt = const Value.absent(),
              }) => VerseMasteryCompanion.insert(
                id: id,
                profileId: profileId,
                verseKey: verseKey,
                verseRef: verseRef,
                storyId: storyId,
                stage: stage,
                nextReviewDate: nextReviewDate,
                masteredAt: masteredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VerseMasteryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VerseMasteryTable,
      VerseMasteryData,
      $$VerseMasteryTableFilterComposer,
      $$VerseMasteryTableOrderingComposer,
      $$VerseMasteryTableAnnotationComposer,
      $$VerseMasteryTableCreateCompanionBuilder,
      $$VerseMasteryTableUpdateCompanionBuilder,
      (
        VerseMasteryData,
        BaseReferences<_$AppDatabase, $VerseMasteryTable, VerseMasteryData>,
      ),
      VerseMasteryData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String profileId,
      required String operation,
      required String payload,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> profileId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                profileId: profileId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String profileId,
                required String operation,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                profileId: profileId,
                operation: operation,
                payload: payload,
                createdAt: createdAt,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$ContentVersionsTableCreateCompanionBuilder =
    ContentVersionsCompanion Function({
      required String contentType,
      required String version,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ContentVersionsTableUpdateCompanionBuilder =
    ContentVersionsCompanion Function({
      Value<String> contentType,
      Value<String> version,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ContentVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentVersionsTable> {
  $$ContentVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentVersionsTable> {
  $$ContentVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentVersionsTable> {
  $$ContentVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ContentVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentVersionsTable,
          ContentVersion,
          $$ContentVersionsTableFilterComposer,
          $$ContentVersionsTableOrderingComposer,
          $$ContentVersionsTableAnnotationComposer,
          $$ContentVersionsTableCreateCompanionBuilder,
          $$ContentVersionsTableUpdateCompanionBuilder,
          (
            ContentVersion,
            BaseReferences<
              _$AppDatabase,
              $ContentVersionsTable,
              ContentVersion
            >,
          ),
          ContentVersion,
          PrefetchHooks Function()
        > {
  $$ContentVersionsTableTableManager(
    _$AppDatabase db,
    $ContentVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> contentType = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentVersionsCompanion(
                contentType: contentType,
                version: version,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String contentType,
                required String version,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentVersionsCompanion.insert(
                contentType: contentType,
                version: version,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentVersionsTable,
      ContentVersion,
      $$ContentVersionsTableFilterComposer,
      $$ContentVersionsTableOrderingComposer,
      $$ContentVersionsTableAnnotationComposer,
      $$ContentVersionsTableCreateCompanionBuilder,
      $$ContentVersionsTableUpdateCompanionBuilder,
      (
        ContentVersion,
        BaseReferences<_$AppDatabase, $ContentVersionsTable, ContentVersion>,
      ),
      ContentVersion,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db, _db.verses);
  $$ChildProfilesTableTableManager get childProfiles =>
      $$ChildProfilesTableTableManager(_db, _db.childProfiles);
  $$StoryProgressTableTableManager get storyProgress =>
      $$StoryProgressTableTableManager(_db, _db.storyProgress);
  $$VerseMasteryTableTableManager get verseMastery =>
      $$VerseMasteryTableTableManager(_db, _db.verseMastery);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$ContentVersionsTableTableManager get contentVersions =>
      $$ContentVersionsTableTableManager(_db, _db.contentVersions);
}
