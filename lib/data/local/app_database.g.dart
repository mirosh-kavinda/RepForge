// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CatalogExercisesTable extends CatalogExercises
    with TableInfo<$CatalogExercisesTable, CatalogExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mechanicMeta = const VerificationMeta(
    'mechanic',
  );
  @override
  late final GeneratedColumn<String> mechanic = GeneratedColumn<String>(
    'mechanic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forceMeta = const VerificationMeta('force');
  @override
  late final GeneratedColumn<String> force = GeneratedColumn<String>(
    'force',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
    'images',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retiredAtMeta = const VerificationMeta(
    'retiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> retiredAt = GeneratedColumn<DateTime>(
    'retired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    equipment,
    category,
    level,
    mechanic,
    force,
    instructions,
    images,
    contentHash,
    retiredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('mechanic')) {
      context.handle(
        _mechanicMeta,
        mechanic.isAcceptableOrUnknown(data['mechanic']!, _mechanicMeta),
      );
    }
    if (data.containsKey('force')) {
      context.handle(
        _forceMeta,
        force.isAcceptableOrUnknown(data['force']!, _forceMeta),
      );
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionsMeta);
    }
    if (data.containsKey('images')) {
      context.handle(
        _imagesMeta,
        images.isAcceptableOrUnknown(data['images']!, _imagesMeta),
      );
    } else if (isInserting) {
      context.missing(_imagesMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('retired_at')) {
      context.handle(
        _retiredAtMeta,
        retiredAt.isAcceptableOrUnknown(data['retired_at']!, _retiredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      mechanic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mechanic'],
      ),
      force: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}force'],
      ),
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      )!,
      images: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      retiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_at'],
      ),
    );
  }

  @override
  $CatalogExercisesTable createAlias(String alias) {
    return $CatalogExercisesTable(attachedDatabase, alias);
  }
}

class CatalogExercise extends DataClass implements Insertable<CatalogExercise> {
  final String id;
  final String name;
  final String equipment;
  final String category;
  final String level;
  final String? mechanic;
  final String? force;
  final String instructions;
  final String images;
  final String contentHash;
  final DateTime? retiredAt;
  const CatalogExercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.category,
    required this.level,
    this.mechanic,
    this.force,
    required this.instructions,
    required this.images,
    required this.contentHash,
    this.retiredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['equipment'] = Variable<String>(equipment);
    map['category'] = Variable<String>(category);
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] = Variable<String>(mechanic);
    }
    if (!nullToAbsent || force != null) {
      map['force'] = Variable<String>(force);
    }
    map['instructions'] = Variable<String>(instructions);
    map['images'] = Variable<String>(images);
    map['content_hash'] = Variable<String>(contentHash);
    if (!nullToAbsent || retiredAt != null) {
      map['retired_at'] = Variable<DateTime>(retiredAt);
    }
    return map;
  }

  CatalogExercisesCompanion toCompanion(bool nullToAbsent) {
    return CatalogExercisesCompanion(
      id: Value(id),
      name: Value(name),
      equipment: Value(equipment),
      category: Value(category),
      level: Value(level),
      mechanic: mechanic == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanic),
      force: force == null && nullToAbsent
          ? const Value.absent()
          : Value(force),
      instructions: Value(instructions),
      images: Value(images),
      contentHash: Value(contentHash),
      retiredAt: retiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredAt),
    );
  }

  factory CatalogExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogExercise(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      equipment: serializer.fromJson<String>(json['equipment']),
      category: serializer.fromJson<String>(json['category']),
      level: serializer.fromJson<String>(json['level']),
      mechanic: serializer.fromJson<String?>(json['mechanic']),
      force: serializer.fromJson<String?>(json['force']),
      instructions: serializer.fromJson<String>(json['instructions']),
      images: serializer.fromJson<String>(json['images']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      retiredAt: serializer.fromJson<DateTime?>(json['retiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'equipment': serializer.toJson<String>(equipment),
      'category': serializer.toJson<String>(category),
      'level': serializer.toJson<String>(level),
      'mechanic': serializer.toJson<String?>(mechanic),
      'force': serializer.toJson<String?>(force),
      'instructions': serializer.toJson<String>(instructions),
      'images': serializer.toJson<String>(images),
      'contentHash': serializer.toJson<String>(contentHash),
      'retiredAt': serializer.toJson<DateTime?>(retiredAt),
    };
  }

  CatalogExercise copyWith({
    String? id,
    String? name,
    String? equipment,
    String? category,
    String? level,
    Value<String?> mechanic = const Value.absent(),
    Value<String?> force = const Value.absent(),
    String? instructions,
    String? images,
    String? contentHash,
    Value<DateTime?> retiredAt = const Value.absent(),
  }) => CatalogExercise(
    id: id ?? this.id,
    name: name ?? this.name,
    equipment: equipment ?? this.equipment,
    category: category ?? this.category,
    level: level ?? this.level,
    mechanic: mechanic.present ? mechanic.value : this.mechanic,
    force: force.present ? force.value : this.force,
    instructions: instructions ?? this.instructions,
    images: images ?? this.images,
    contentHash: contentHash ?? this.contentHash,
    retiredAt: retiredAt.present ? retiredAt.value : this.retiredAt,
  );
  CatalogExercise copyWithCompanion(CatalogExercisesCompanion data) {
    return CatalogExercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      category: data.category.present ? data.category.value : this.category,
      level: data.level.present ? data.level.value : this.level,
      mechanic: data.mechanic.present ? data.mechanic.value : this.mechanic,
      force: data.force.present ? data.force.value : this.force,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      images: data.images.present ? data.images.value : this.images,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      retiredAt: data.retiredAt.present ? data.retiredAt.value : this.retiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogExercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('category: $category, ')
          ..write('level: $level, ')
          ..write('mechanic: $mechanic, ')
          ..write('force: $force, ')
          ..write('instructions: $instructions, ')
          ..write('images: $images, ')
          ..write('contentHash: $contentHash, ')
          ..write('retiredAt: $retiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    equipment,
    category,
    level,
    mechanic,
    force,
    instructions,
    images,
    contentHash,
    retiredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogExercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.equipment == this.equipment &&
          other.category == this.category &&
          other.level == this.level &&
          other.mechanic == this.mechanic &&
          other.force == this.force &&
          other.instructions == this.instructions &&
          other.images == this.images &&
          other.contentHash == this.contentHash &&
          other.retiredAt == this.retiredAt);
}

class CatalogExercisesCompanion extends UpdateCompanion<CatalogExercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> equipment;
  final Value<String> category;
  final Value<String> level;
  final Value<String?> mechanic;
  final Value<String?> force;
  final Value<String> instructions;
  final Value<String> images;
  final Value<String> contentHash;
  final Value<DateTime?> retiredAt;
  final Value<int> rowid;
  const CatalogExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.equipment = const Value.absent(),
    this.category = const Value.absent(),
    this.level = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.force = const Value.absent(),
    this.instructions = const Value.absent(),
    this.images = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogExercisesCompanion.insert({
    required String id,
    required String name,
    required String equipment,
    required String category,
    required String level,
    this.mechanic = const Value.absent(),
    this.force = const Value.absent(),
    required String instructions,
    required String images,
    required String contentHash,
    this.retiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       equipment = Value(equipment),
       category = Value(category),
       level = Value(level),
       instructions = Value(instructions),
       images = Value(images),
       contentHash = Value(contentHash);
  static Insertable<CatalogExercise> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? equipment,
    Expression<String>? category,
    Expression<String>? level,
    Expression<String>? mechanic,
    Expression<String>? force,
    Expression<String>? instructions,
    Expression<String>? images,
    Expression<String>? contentHash,
    Expression<DateTime>? retiredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (equipment != null) 'equipment': equipment,
      if (category != null) 'category': category,
      if (level != null) 'level': level,
      if (mechanic != null) 'mechanic': mechanic,
      if (force != null) 'force': force,
      if (instructions != null) 'instructions': instructions,
      if (images != null) 'images': images,
      if (contentHash != null) 'content_hash': contentHash,
      if (retiredAt != null) 'retired_at': retiredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? equipment,
    Value<String>? category,
    Value<String>? level,
    Value<String?>? mechanic,
    Value<String?>? force,
    Value<String>? instructions,
    Value<String>? images,
    Value<String>? contentHash,
    Value<DateTime?>? retiredAt,
    Value<int>? rowid,
  }) {
    return CatalogExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      equipment: equipment ?? this.equipment,
      category: category ?? this.category,
      level: level ?? this.level,
      mechanic: mechanic ?? this.mechanic,
      force: force ?? this.force,
      instructions: instructions ?? this.instructions,
      images: images ?? this.images,
      contentHash: contentHash ?? this.contentHash,
      retiredAt: retiredAt ?? this.retiredAt,
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
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (mechanic.present) {
      map['mechanic'] = Variable<String>(mechanic.value);
    }
    if (force.present) {
      map['force'] = Variable<String>(force.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (retiredAt.present) {
      map['retired_at'] = Variable<DateTime>(retiredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('category: $category, ')
          ..write('level: $level, ')
          ..write('mechanic: $mechanic, ')
          ..write('force: $force, ')
          ..write('instructions: $instructions, ')
          ..write('images: $images, ')
          ..write('contentHash: $contentHash, ')
          ..write('retiredAt: $retiredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMusclesTable extends ExerciseMuscles
    with TableInfo<$ExerciseMusclesTable, ExerciseMuscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_exercises (id)',
    ),
  );
  static const VerificationMeta _muscleMeta = const VerificationMeta('muscle');
  @override
  late final GeneratedColumn<String> muscle = GeneratedColumn<String>(
    'muscle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, muscle, isPrimary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_muscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMuscle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle')) {
      context.handle(
        _muscleMeta,
        muscle.isAcceptableOrUnknown(data['muscle']!, _muscleMeta),
      );
    } else if (isInserting) {
      context.missing(_muscleMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    } else if (isInserting) {
      context.missing(_isPrimaryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId, muscle};
  @override
  ExerciseMuscle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscle(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      muscle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $ExerciseMusclesTable createAlias(String alias) {
    return $ExerciseMusclesTable(attachedDatabase, alias);
  }
}

class ExerciseMuscle extends DataClass implements Insertable<ExerciseMuscle> {
  final String exerciseId;
  final String muscle;
  final bool isPrimary;
  const ExerciseMuscle({
    required this.exerciseId,
    required this.muscle,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['muscle'] = Variable<String>(muscle);
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  ExerciseMusclesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMusclesCompanion(
      exerciseId: Value(exerciseId),
      muscle: Value(muscle),
      isPrimary: Value(isPrimary),
    );
  }

  factory ExerciseMuscle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscle(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      muscle: serializer.fromJson<String>(json['muscle']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'muscle': serializer.toJson<String>(muscle),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  ExerciseMuscle copyWith({
    String? exerciseId,
    String? muscle,
    bool? isPrimary,
  }) => ExerciseMuscle(
    exerciseId: exerciseId ?? this.exerciseId,
    muscle: muscle ?? this.muscle,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  ExerciseMuscle copyWithCompanion(ExerciseMusclesCompanion data) {
    return ExerciseMuscle(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      muscle: data.muscle.present ? data.muscle.value : this.muscle,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscle(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscle: $muscle, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, muscle, isPrimary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMuscle &&
          other.exerciseId == this.exerciseId &&
          other.muscle == this.muscle &&
          other.isPrimary == this.isPrimary);
}

class ExerciseMusclesCompanion extends UpdateCompanion<ExerciseMuscle> {
  final Value<String> exerciseId;
  final Value<String> muscle;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const ExerciseMusclesCompanion({
    this.exerciseId = const Value.absent(),
    this.muscle = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMusclesCompanion.insert({
    required String exerciseId,
    required String muscle,
    required bool isPrimary,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       muscle = Value(muscle),
       isPrimary = Value(isPrimary);
  static Insertable<ExerciseMuscle> custom({
    Expression<String>? exerciseId,
    Expression<String>? muscle,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscle != null) 'muscle': muscle,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMusclesCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? muscle,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return ExerciseMusclesCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      muscle: muscle ?? this.muscle,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (muscle.present) {
      map['muscle'] = Variable<String>(muscle.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMusclesCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscle: $muscle, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxOp, String> op =
      GeneratedColumn<String>(
        'op',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OutboxOp>($OutboxTable.$converterop);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seq, entity, entityId, op, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: $OutboxTable.$converterop.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}op'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxOp, String, String> $converterop =
      const EnumNameConverter<OutboxOp>(OutboxOp.values);
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int seq;
  final String entity;
  final String entityId;
  final OutboxOp op;
  final DateTime createdAt;
  const OutboxData({
    required this.seq,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    {
      map['op'] = Variable<String>($OutboxTable.$converterop.toSql(op));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      seq: serializer.fromJson<int>(json['seq']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: $OutboxTable.$converterop.fromJson(
        serializer.fromJson<String>(json['op']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>($OutboxTable.$converterop.toJson(op)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxData copyWith({
    int? seq,
    String? entity,
    String? entityId,
    OutboxOp? op,
    DateTime? createdAt,
  }) => OutboxData(
    seq: seq ?? this.seq,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      seq: data.seq.present ? data.seq.value : this.seq,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seq, entity, entityId, op, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.seq == this.seq &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> seq;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<OutboxOp> op;
  final Value<DateTime> createdAt;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String entity,
    required String entityId,
    required OutboxOp op,
    required DateTime createdAt,
  }) : entity = Value(entity),
       entityId = Value(entityId),
       op = Value(op),
       createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<int>? seq,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? entity,
    Value<String>? entityId,
    Value<OutboxOp>? op,
    Value<DateTime>? createdAt,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>($OutboxTable.$converterop.toSql(op.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.pending.name),
      ).withConverter<SyncState>($UserProfilesTable.$convertersyncState);
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<String> units = GeneratedColumn<String>(
    'units',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    goal,
    level,
    units,
    sex,
    birthYear,
    heightCm,
    activityLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('units')) {
      context.handle(
        _unitsMeta,
        units.isAcceptableOrUnknown(data['units']!, _unitsMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: $UserProfilesTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      units: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}units'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncState syncState;
  final String? goal;
  final String? level;
  final String units;
  final String? sex;
  final int? birthYear;
  final double? heightCm;
  final String? activityLevel;
  const UserProfile({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    this.goal,
    this.level,
    required this.units,
    this.sex,
    this.birthYear,
    this.heightCm,
    this.activityLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_state'] = Variable<String>(
        $UserProfilesTable.$convertersyncState.toSql(syncState),
      );
    }
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<String>(goal);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    map['units'] = Variable<String>(units);
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      units: Value(units),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      birthYear: birthYear == null && nullToAbsent
          ? const Value.absent()
          : Value(birthYear),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: $UserProfilesTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      goal: serializer.fromJson<String?>(json['goal']),
      level: serializer.fromJson<String?>(json['level']),
      units: serializer.fromJson<String>(json['units']),
      sex: serializer.fromJson<String?>(json['sex']),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(
        $UserProfilesTable.$convertersyncState.toJson(syncState),
      ),
      'goal': serializer.toJson<String?>(goal),
      'level': serializer.toJson<String?>(level),
      'units': serializer.toJson<String>(units),
      'sex': serializer.toJson<String?>(sex),
      'birthYear': serializer.toJson<int?>(birthYear),
      'heightCm': serializer.toJson<double?>(heightCm),
      'activityLevel': serializer.toJson<String?>(activityLevel),
    };
  }

  UserProfile copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncState? syncState,
    Value<String?> goal = const Value.absent(),
    Value<String?> level = const Value.absent(),
    String? units,
    Value<String?> sex = const Value.absent(),
    Value<int?> birthYear = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<String?> activityLevel = const Value.absent(),
  }) => UserProfile(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    goal: goal.present ? goal.value : this.goal,
    level: level.present ? level.value : this.level,
    units: units ?? this.units,
    sex: sex.present ? sex.value : this.sex,
    birthYear: birthYear.present ? birthYear.value : this.birthYear,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      goal: data.goal.present ? data.goal.value : this.goal,
      level: data.level.present ? data.level.value : this.level,
      units: data.units.present ? data.units.value : this.units,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('goal: $goal, ')
          ..write('level: $level, ')
          ..write('units: $units, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    goal,
    level,
    units,
    sex,
    birthYear,
    heightCm,
    activityLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.goal == this.goal &&
          other.level == this.level &&
          other.units == this.units &&
          other.sex == this.sex &&
          other.birthYear == this.birthYear &&
          other.heightCm == this.heightCm &&
          other.activityLevel == this.activityLevel);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncState> syncState;
  final Value<String?> goal;
  final Value<String?> level;
  final Value<String> units;
  final Value<String?> sex;
  final Value<int?> birthYear;
  final Value<double?> heightCm;
  final Value<String?> activityLevel;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.goal = const Value.absent(),
    this.level = const Value.absent(),
    this.units = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.goal = const Value.absent(),
    this.level = const Value.absent(),
    required String units,
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       units = Value(units);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? goal,
    Expression<String>? level,
    Expression<String>? units,
    Expression<String>? sex,
    Expression<int>? birthYear,
    Expression<double>? heightCm,
    Expression<String>? activityLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (goal != null) 'goal': goal,
      if (level != null) 'level': level,
      if (units != null) 'units': units,
      if (sex != null) 'sex': sex,
      if (birthYear != null) 'birth_year': birthYear,
      if (heightCm != null) 'height_cm': heightCm,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncState>? syncState,
    Value<String?>? goal,
    Value<String?>? level,
    Value<String>? units,
    Value<String?>? sex,
    Value<int?>? birthYear,
    Value<double?>? heightCm,
    Value<String?>? activityLevel,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      units: units ?? this.units,
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $UserProfilesTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (units.present) {
      map['units'] = Variable<String>(units.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('goal: $goal, ')
          ..write('level: $level, ')
          ..write('units: $units, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodySnapshotsTable extends BodySnapshots
    with TableInfo<$BodySnapshotsTable, BodySnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodySnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.pending.name),
      ).withConverter<SyncState>($BodySnapshotsTable.$convertersyncState);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _neckCmMeta = const VerificationMeta('neckCm');
  @override
  late final GeneratedColumn<double> neckCm = GeneratedColumn<double>(
    'neck_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipCmMeta = const VerificationMeta('hipCm');
  @override
  late final GeneratedColumn<double> hipCm = GeneratedColumn<double>(
    'hip_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scaleBodyFatPctMeta = const VerificationMeta(
    'scaleBodyFatPct',
  );
  @override
  late final GeneratedColumn<double> scaleBodyFatPct = GeneratedColumn<double>(
    'scale_body_fat_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  @override
  late final GeneratedColumn<String> activity = GeneratedColumn<String>(
    'activity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resultsMeta = const VerificationMeta(
    'results',
  );
  @override
  late final GeneratedColumn<String> results = GeneratedColumn<String>(
    'results',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    date,
    weightKg,
    waistCm,
    neckCm,
    hipCm,
    scaleBodyFatPct,
    activity,
    results,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodySnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('neck_cm')) {
      context.handle(
        _neckCmMeta,
        neckCm.isAcceptableOrUnknown(data['neck_cm']!, _neckCmMeta),
      );
    }
    if (data.containsKey('hip_cm')) {
      context.handle(
        _hipCmMeta,
        hipCm.isAcceptableOrUnknown(data['hip_cm']!, _hipCmMeta),
      );
    }
    if (data.containsKey('scale_body_fat_pct')) {
      context.handle(
        _scaleBodyFatPctMeta,
        scaleBodyFatPct.isAcceptableOrUnknown(
          data['scale_body_fat_pct']!,
          _scaleBodyFatPctMeta,
        ),
      );
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    }
    if (data.containsKey('results')) {
      context.handle(
        _resultsMeta,
        results.isAcceptableOrUnknown(data['results']!, _resultsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodySnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodySnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: $BodySnapshotsTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      neckCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}neck_cm'],
      ),
      hipCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hip_cm'],
      ),
      scaleBodyFatPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scale_body_fat_pct'],
      ),
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity'],
      ),
      results: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}results'],
      ),
    );
  }

  @override
  $BodySnapshotsTable createAlias(String alias) {
    return $BodySnapshotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class BodySnapshotRow extends DataClass implements Insertable<BodySnapshotRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncState syncState;
  final DateTime date;
  final double? weightKg;
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;
  final double? scaleBodyFatPct;
  final String? activity;
  final String? results;
  const BodySnapshotRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.date,
    this.weightKg,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.scaleBodyFatPct,
    this.activity,
    this.results,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_state'] = Variable<String>(
        $BodySnapshotsTable.$convertersyncState.toSql(syncState),
      );
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || neckCm != null) {
      map['neck_cm'] = Variable<double>(neckCm);
    }
    if (!nullToAbsent || hipCm != null) {
      map['hip_cm'] = Variable<double>(hipCm);
    }
    if (!nullToAbsent || scaleBodyFatPct != null) {
      map['scale_body_fat_pct'] = Variable<double>(scaleBodyFatPct);
    }
    if (!nullToAbsent || activity != null) {
      map['activity'] = Variable<String>(activity);
    }
    if (!nullToAbsent || results != null) {
      map['results'] = Variable<String>(results);
    }
    return map;
  }

  BodySnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BodySnapshotsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      date: Value(date),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      neckCm: neckCm == null && nullToAbsent
          ? const Value.absent()
          : Value(neckCm),
      hipCm: hipCm == null && nullToAbsent
          ? const Value.absent()
          : Value(hipCm),
      scaleBodyFatPct: scaleBodyFatPct == null && nullToAbsent
          ? const Value.absent()
          : Value(scaleBodyFatPct),
      activity: activity == null && nullToAbsent
          ? const Value.absent()
          : Value(activity),
      results: results == null && nullToAbsent
          ? const Value.absent()
          : Value(results),
    );
  }

  factory BodySnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodySnapshotRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: $BodySnapshotsTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      neckCm: serializer.fromJson<double?>(json['neckCm']),
      hipCm: serializer.fromJson<double?>(json['hipCm']),
      scaleBodyFatPct: serializer.fromJson<double?>(json['scaleBodyFatPct']),
      activity: serializer.fromJson<String?>(json['activity']),
      results: serializer.fromJson<String?>(json['results']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(
        $BodySnapshotsTable.$convertersyncState.toJson(syncState),
      ),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double?>(weightKg),
      'waistCm': serializer.toJson<double?>(waistCm),
      'neckCm': serializer.toJson<double?>(neckCm),
      'hipCm': serializer.toJson<double?>(hipCm),
      'scaleBodyFatPct': serializer.toJson<double?>(scaleBodyFatPct),
      'activity': serializer.toJson<String?>(activity),
      'results': serializer.toJson<String?>(results),
    };
  }

  BodySnapshotRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncState? syncState,
    DateTime? date,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> waistCm = const Value.absent(),
    Value<double?> neckCm = const Value.absent(),
    Value<double?> hipCm = const Value.absent(),
    Value<double?> scaleBodyFatPct = const Value.absent(),
    Value<String?> activity = const Value.absent(),
    Value<String?> results = const Value.absent(),
  }) => BodySnapshotRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    date: date ?? this.date,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    neckCm: neckCm.present ? neckCm.value : this.neckCm,
    hipCm: hipCm.present ? hipCm.value : this.hipCm,
    scaleBodyFatPct: scaleBodyFatPct.present
        ? scaleBodyFatPct.value
        : this.scaleBodyFatPct,
    activity: activity.present ? activity.value : this.activity,
    results: results.present ? results.value : this.results,
  );
  BodySnapshotRow copyWithCompanion(BodySnapshotsCompanion data) {
    return BodySnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      neckCm: data.neckCm.present ? data.neckCm.value : this.neckCm,
      hipCm: data.hipCm.present ? data.hipCm.value : this.hipCm,
      scaleBodyFatPct: data.scaleBodyFatPct.present
          ? data.scaleBodyFatPct.value
          : this.scaleBodyFatPct,
      activity: data.activity.present ? data.activity.value : this.activity,
      results: data.results.present ? data.results.value : this.results,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodySnapshotRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('neckCm: $neckCm, ')
          ..write('hipCm: $hipCm, ')
          ..write('scaleBodyFatPct: $scaleBodyFatPct, ')
          ..write('activity: $activity, ')
          ..write('results: $results')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    date,
    weightKg,
    waistCm,
    neckCm,
    hipCm,
    scaleBodyFatPct,
    activity,
    results,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodySnapshotRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.waistCm == this.waistCm &&
          other.neckCm == this.neckCm &&
          other.hipCm == this.hipCm &&
          other.scaleBodyFatPct == this.scaleBodyFatPct &&
          other.activity == this.activity &&
          other.results == this.results);
}

class BodySnapshotsCompanion extends UpdateCompanion<BodySnapshotRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncState> syncState;
  final Value<DateTime> date;
  final Value<double?> weightKg;
  final Value<double?> waistCm;
  final Value<double?> neckCm;
  final Value<double?> hipCm;
  final Value<double?> scaleBodyFatPct;
  final Value<String?> activity;
  final Value<String?> results;
  final Value<int> rowid;
  const BodySnapshotsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.hipCm = const Value.absent(),
    this.scaleBodyFatPct = const Value.absent(),
    this.activity = const Value.absent(),
    this.results = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodySnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime date,
    this.weightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.hipCm = const Value.absent(),
    this.scaleBodyFatPct = const Value.absent(),
    this.activity = const Value.absent(),
    this.results = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       date = Value(date);
  static Insertable<BodySnapshotRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
    Expression<double>? waistCm,
    Expression<double>? neckCm,
    Expression<double>? hipCm,
    Expression<double>? scaleBodyFatPct,
    Expression<String>? activity,
    Expression<String>? results,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (waistCm != null) 'waist_cm': waistCm,
      if (neckCm != null) 'neck_cm': neckCm,
      if (hipCm != null) 'hip_cm': hipCm,
      if (scaleBodyFatPct != null) 'scale_body_fat_pct': scaleBodyFatPct,
      if (activity != null) 'activity': activity,
      if (results != null) 'results': results,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodySnapshotsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncState>? syncState,
    Value<DateTime>? date,
    Value<double?>? weightKg,
    Value<double?>? waistCm,
    Value<double?>? neckCm,
    Value<double?>? hipCm,
    Value<double?>? scaleBodyFatPct,
    Value<String?>? activity,
    Value<String?>? results,
    Value<int>? rowid,
  }) {
    return BodySnapshotsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      neckCm: neckCm ?? this.neckCm,
      hipCm: hipCm ?? this.hipCm,
      scaleBodyFatPct: scaleBodyFatPct ?? this.scaleBodyFatPct,
      activity: activity ?? this.activity,
      results: results ?? this.results,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $BodySnapshotsTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (neckCm.present) {
      map['neck_cm'] = Variable<double>(neckCm.value);
    }
    if (hipCm.present) {
      map['hip_cm'] = Variable<double>(hipCm.value);
    }
    if (scaleBodyFatPct.present) {
      map['scale_body_fat_pct'] = Variable<double>(scaleBodyFatPct.value);
    }
    if (activity.present) {
      map['activity'] = Variable<String>(activity.value);
    }
    if (results.present) {
      map['results'] = Variable<String>(results.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodySnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('neckCm: $neckCm, ')
          ..write('hipCm: $hipCm, ')
          ..write('scaleBodyFatPct: $scaleBodyFatPct, ')
          ..write('activity: $activity, ')
          ..write('results: $results, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTemplatesTable extends WorkoutTemplates
    with TableInfo<$WorkoutTemplatesTable, WorkoutTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.pending.name),
      ).withConverter<SyncState>($WorkoutTemplatesTable.$convertersyncState);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exercisesMeta = const VerificationMeta(
    'exercises',
  );
  @override
  late final GeneratedColumn<String> exercises = GeneratedColumn<String>(
    'exercises',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    name,
    exercises,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('exercises')) {
      context.handle(
        _exercisesMeta,
        exercises.isAcceptableOrUnknown(data['exercises']!, _exercisesMeta),
      );
    } else if (isInserting) {
      context.missing(_exercisesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: $WorkoutTemplatesTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      exercises: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercises'],
      )!,
    );
  }

  @override
  $WorkoutTemplatesTable createAlias(String alias) {
    return $WorkoutTemplatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class WorkoutTemplateRow extends DataClass
    implements Insertable<WorkoutTemplateRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncState syncState;
  final String name;
  final String exercises;
  const WorkoutTemplateRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.name,
    required this.exercises,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_state'] = Variable<String>(
        $WorkoutTemplatesTable.$convertersyncState.toSql(syncState),
      );
    }
    map['name'] = Variable<String>(name);
    map['exercises'] = Variable<String>(exercises);
    return map;
  }

  WorkoutTemplatesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTemplatesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      name: Value(name),
      exercises: Value(exercises),
    );
  }

  factory WorkoutTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: $WorkoutTemplatesTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      name: serializer.fromJson<String>(json['name']),
      exercises: serializer.fromJson<String>(json['exercises']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(
        $WorkoutTemplatesTable.$convertersyncState.toJson(syncState),
      ),
      'name': serializer.toJson<String>(name),
      'exercises': serializer.toJson<String>(exercises),
    };
  }

  WorkoutTemplateRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncState? syncState,
    String? name,
    String? exercises,
  }) => WorkoutTemplateRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    name: name ?? this.name,
    exercises: exercises ?? this.exercises,
  );
  WorkoutTemplateRow copyWithCompanion(WorkoutTemplatesCompanion data) {
    return WorkoutTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      name: data.name.present ? data.name.value : this.name,
      exercises: data.exercises.present ? data.exercises.value : this.exercises,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplateRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('exercises: $exercises')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deletedAt, syncState, name, exercises);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTemplateRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.name == this.name &&
          other.exercises == this.exercises);
}

class WorkoutTemplatesCompanion extends UpdateCompanion<WorkoutTemplateRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncState> syncState;
  final Value<String> name;
  final Value<String> exercises;
  final Value<int> rowid;
  const WorkoutTemplatesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.name = const Value.absent(),
    this.exercises = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String name,
    required String exercises,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       name = Value(name),
       exercises = Value(exercises);
  static Insertable<WorkoutTemplateRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? name,
    Expression<String>? exercises,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (name != null) 'name': name,
      if (exercises != null) 'exercises': exercises,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTemplatesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncState>? syncState,
    Value<String>? name,
    Value<String>? exercises,
    Value<int>? rowid,
  }) {
    return WorkoutTemplatesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $WorkoutTemplatesTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (exercises.present) {
      map['exercises'] = Variable<String>(exercises.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('exercises: $exercises, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CyclesTable extends Cycles with TableInfo<$CyclesTable, CycleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.pending.name),
      ).withConverter<SyncState>($CyclesTable.$convertersyncState);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<String> days = GeneratedColumn<String>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDayIndexMeta = const VerificationMeta(
    'startDayIndex',
  );
  @override
  late final GeneratedColumn<int> startDayIndex = GeneratedColumn<int>(
    'start_day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('rolling'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    name,
    days,
    isActive,
    startDate,
    startDayIndex,
    mode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CycleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('start_day_index')) {
      context.handle(
        _startDayIndexMeta,
        startDayIndex.isAcceptableOrUnknown(
          data['start_day_index']!,
          _startDayIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startDayIndexMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CycleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: $CyclesTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      startDayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_day_index'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
    );
  }

  @override
  $CyclesTable createAlias(String alias) {
    return $CyclesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class CycleRow extends DataClass implements Insertable<CycleRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncState syncState;
  final String name;
  final String days;
  final bool isActive;
  final DateTime startDate;
  final int startDayIndex;
  final String mode;
  const CycleRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.name,
    required this.days,
    required this.isActive,
    required this.startDate,
    required this.startDayIndex,
    required this.mode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_state'] = Variable<String>(
        $CyclesTable.$convertersyncState.toSql(syncState),
      );
    }
    map['name'] = Variable<String>(name);
    map['days'] = Variable<String>(days);
    map['is_active'] = Variable<bool>(isActive);
    map['start_date'] = Variable<DateTime>(startDate);
    map['start_day_index'] = Variable<int>(startDayIndex);
    map['mode'] = Variable<String>(mode);
    return map;
  }

  CyclesCompanion toCompanion(bool nullToAbsent) {
    return CyclesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      name: Value(name),
      days: Value(days),
      isActive: Value(isActive),
      startDate: Value(startDate),
      startDayIndex: Value(startDayIndex),
      mode: Value(mode),
    );
  }

  factory CycleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: $CyclesTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      name: serializer.fromJson<String>(json['name']),
      days: serializer.fromJson<String>(json['days']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      startDayIndex: serializer.fromJson<int>(json['startDayIndex']),
      mode: serializer.fromJson<String>(json['mode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(
        $CyclesTable.$convertersyncState.toJson(syncState),
      ),
      'name': serializer.toJson<String>(name),
      'days': serializer.toJson<String>(days),
      'isActive': serializer.toJson<bool>(isActive),
      'startDate': serializer.toJson<DateTime>(startDate),
      'startDayIndex': serializer.toJson<int>(startDayIndex),
      'mode': serializer.toJson<String>(mode),
    };
  }

  CycleRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncState? syncState,
    String? name,
    String? days,
    bool? isActive,
    DateTime? startDate,
    int? startDayIndex,
    String? mode,
  }) => CycleRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    name: name ?? this.name,
    days: days ?? this.days,
    isActive: isActive ?? this.isActive,
    startDate: startDate ?? this.startDate,
    startDayIndex: startDayIndex ?? this.startDayIndex,
    mode: mode ?? this.mode,
  );
  CycleRow copyWithCompanion(CyclesCompanion data) {
    return CycleRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      name: data.name.present ? data.name.value : this.name,
      days: data.days.present ? data.days.value : this.days,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      startDayIndex: data.startDayIndex.present
          ? data.startDayIndex.value
          : this.startDayIndex,
      mode: data.mode.present ? data.mode.value : this.mode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('days: $days, ')
          ..write('isActive: $isActive, ')
          ..write('startDate: $startDate, ')
          ..write('startDayIndex: $startDayIndex, ')
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    name,
    days,
    isActive,
    startDate,
    startDayIndex,
    mode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.name == this.name &&
          other.days == this.days &&
          other.isActive == this.isActive &&
          other.startDate == this.startDate &&
          other.startDayIndex == this.startDayIndex &&
          other.mode == this.mode);
}

class CyclesCompanion extends UpdateCompanion<CycleRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncState> syncState;
  final Value<String> name;
  final Value<String> days;
  final Value<bool> isActive;
  final Value<DateTime> startDate;
  final Value<int> startDayIndex;
  final Value<String> mode;
  final Value<int> rowid;
  const CyclesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.name = const Value.absent(),
    this.days = const Value.absent(),
    this.isActive = const Value.absent(),
    this.startDate = const Value.absent(),
    this.startDayIndex = const Value.absent(),
    this.mode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CyclesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String name,
    required String days,
    required bool isActive,
    required DateTime startDate,
    required int startDayIndex,
    this.mode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       name = Value(name),
       days = Value(days),
       isActive = Value(isActive),
       startDate = Value(startDate),
       startDayIndex = Value(startDayIndex);
  static Insertable<CycleRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? name,
    Expression<String>? days,
    Expression<bool>? isActive,
    Expression<DateTime>? startDate,
    Expression<int>? startDayIndex,
    Expression<String>? mode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (name != null) 'name': name,
      if (days != null) 'days': days,
      if (isActive != null) 'is_active': isActive,
      if (startDate != null) 'start_date': startDate,
      if (startDayIndex != null) 'start_day_index': startDayIndex,
      if (mode != null) 'mode': mode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CyclesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncState>? syncState,
    Value<String>? name,
    Value<String>? days,
    Value<bool>? isActive,
    Value<DateTime>? startDate,
    Value<int>? startDayIndex,
    Value<String>? mode,
    Value<int>? rowid,
  }) {
    return CyclesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      name: name ?? this.name,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      startDayIndex: startDayIndex ?? this.startDayIndex,
      mode: mode ?? this.mode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $CyclesTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (days.present) {
      map['days'] = Variable<String>(days.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (startDayIndex.present) {
      map['start_day_index'] = Variable<int>(startDayIndex.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('days: $days, ')
          ..write('isActive: $isActive, ')
          ..write('startDate: $startDate, ')
          ..write('startDayIndex: $startDayIndex, ')
          ..write('mode: $mode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleDaysTable extends ScheduleDays
    with TableInfo<$ScheduleDaysTable, ScheduleDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.pending.name),
      ).withConverter<SyncState>($ScheduleDaysTable.$convertersyncState);
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedDateMeta = const VerificationMeta(
    'linkedDate',
  );
  @override
  late final GeneratedColumn<DateTime> linkedDate = GeneratedColumn<DateTime>(
    'linked_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    cycleId,
    date,
    dayId,
    dayIndex,
    status,
    workoutId,
    linkedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    }
    if (data.containsKey('linked_date')) {
      context.handle(
        _linkedDateMeta,
        linkedDate.isAcceptableOrUnknown(data['linked_date']!, _linkedDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cycleId, date},
  ];
  @override
  ScheduleDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleDayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: $ScheduleDaysTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      ),
      linkedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}linked_date'],
      ),
    );
  }

  @override
  $ScheduleDaysTable createAlias(String alias) {
    return $ScheduleDaysTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class ScheduleDayRow extends DataClass implements Insertable<ScheduleDayRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncState syncState;
  final String cycleId;
  final DateTime date;
  final String dayId;
  final int dayIndex;
  final String status;
  final String? workoutId;
  final DateTime? linkedDate;
  const ScheduleDayRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.cycleId,
    required this.date,
    required this.dayId,
    required this.dayIndex,
    required this.status,
    this.workoutId,
    this.linkedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_state'] = Variable<String>(
        $ScheduleDaysTable.$convertersyncState.toSql(syncState),
      );
    }
    map['cycle_id'] = Variable<String>(cycleId);
    map['date'] = Variable<DateTime>(date);
    map['day_id'] = Variable<String>(dayId);
    map['day_index'] = Variable<int>(dayIndex);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || workoutId != null) {
      map['workout_id'] = Variable<String>(workoutId);
    }
    if (!nullToAbsent || linkedDate != null) {
      map['linked_date'] = Variable<DateTime>(linkedDate);
    }
    return map;
  }

  ScheduleDaysCompanion toCompanion(bool nullToAbsent) {
    return ScheduleDaysCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      cycleId: Value(cycleId),
      date: Value(date),
      dayId: Value(dayId),
      dayIndex: Value(dayIndex),
      status: Value(status),
      workoutId: workoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutId),
      linkedDate: linkedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedDate),
    );
  }

  factory ScheduleDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleDayRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: $ScheduleDaysTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      date: serializer.fromJson<DateTime>(json['date']),
      dayId: serializer.fromJson<String>(json['dayId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      status: serializer.fromJson<String>(json['status']),
      workoutId: serializer.fromJson<String?>(json['workoutId']),
      linkedDate: serializer.fromJson<DateTime?>(json['linkedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(
        $ScheduleDaysTable.$convertersyncState.toJson(syncState),
      ),
      'cycleId': serializer.toJson<String>(cycleId),
      'date': serializer.toJson<DateTime>(date),
      'dayId': serializer.toJson<String>(dayId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'status': serializer.toJson<String>(status),
      'workoutId': serializer.toJson<String?>(workoutId),
      'linkedDate': serializer.toJson<DateTime?>(linkedDate),
    };
  }

  ScheduleDayRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncState? syncState,
    String? cycleId,
    DateTime? date,
    String? dayId,
    int? dayIndex,
    String? status,
    Value<String?> workoutId = const Value.absent(),
    Value<DateTime?> linkedDate = const Value.absent(),
  }) => ScheduleDayRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    cycleId: cycleId ?? this.cycleId,
    date: date ?? this.date,
    dayId: dayId ?? this.dayId,
    dayIndex: dayIndex ?? this.dayIndex,
    status: status ?? this.status,
    workoutId: workoutId.present ? workoutId.value : this.workoutId,
    linkedDate: linkedDate.present ? linkedDate.value : this.linkedDate,
  );
  ScheduleDayRow copyWithCompanion(ScheduleDaysCompanion data) {
    return ScheduleDayRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      date: data.date.present ? data.date.value : this.date,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      status: data.status.present ? data.status.value : this.status,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      linkedDate: data.linkedDate.present
          ? data.linkedDate.value
          : this.linkedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleDayRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('cycleId: $cycleId, ')
          ..write('date: $date, ')
          ..write('dayId: $dayId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('status: $status, ')
          ..write('workoutId: $workoutId, ')
          ..write('linkedDate: $linkedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    cycleId,
    date,
    dayId,
    dayIndex,
    status,
    workoutId,
    linkedDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleDayRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.cycleId == this.cycleId &&
          other.date == this.date &&
          other.dayId == this.dayId &&
          other.dayIndex == this.dayIndex &&
          other.status == this.status &&
          other.workoutId == this.workoutId &&
          other.linkedDate == this.linkedDate);
}

class ScheduleDaysCompanion extends UpdateCompanion<ScheduleDayRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncState> syncState;
  final Value<String> cycleId;
  final Value<DateTime> date;
  final Value<String> dayId;
  final Value<int> dayIndex;
  final Value<String> status;
  final Value<String?> workoutId;
  final Value<DateTime?> linkedDate;
  final Value<int> rowid;
  const ScheduleDaysCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.date = const Value.absent(),
    this.dayId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.status = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.linkedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleDaysCompanion.insert({
    this.id = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String cycleId,
    required DateTime date,
    required String dayId,
    required int dayIndex,
    required String status,
    this.workoutId = const Value.absent(),
    this.linkedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       cycleId = Value(cycleId),
       date = Value(date),
       dayId = Value(dayId),
       dayIndex = Value(dayIndex),
       status = Value(status);
  static Insertable<ScheduleDayRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? cycleId,
    Expression<DateTime>? date,
    Expression<String>? dayId,
    Expression<int>? dayIndex,
    Expression<String>? status,
    Expression<String>? workoutId,
    Expression<DateTime>? linkedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (cycleId != null) 'cycle_id': cycleId,
      if (date != null) 'date': date,
      if (dayId != null) 'day_id': dayId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (status != null) 'status': status,
      if (workoutId != null) 'workout_id': workoutId,
      if (linkedDate != null) 'linked_date': linkedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleDaysCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncState>? syncState,
    Value<String>? cycleId,
    Value<DateTime>? date,
    Value<String>? dayId,
    Value<int>? dayIndex,
    Value<String>? status,
    Value<String?>? workoutId,
    Value<DateTime?>? linkedDate,
    Value<int>? rowid,
  }) {
    return ScheduleDaysCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      cycleId: cycleId ?? this.cycleId,
      date: date ?? this.date,
      dayId: dayId ?? this.dayId,
      dayIndex: dayIndex ?? this.dayIndex,
      status: status ?? this.status,
      workoutId: workoutId ?? this.workoutId,
      linkedDate: linkedDate ?? this.linkedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $ScheduleDaysTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (linkedDate.present) {
      map['linked_date'] = Variable<DateTime>(linkedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleDaysCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('cycleId: $cycleId, ')
          ..write('date: $date, ')
          ..write('dayId: $dayId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('status: $status, ')
          ..write('workoutId: $workoutId, ')
          ..write('linkedDate: $linkedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.pending.name),
      ).withConverter<SyncState>($WorkoutSessionsTable.$convertersyncState);
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exercisesMeta = const VerificationMeta(
    'exercises',
  );
  @override
  late final GeneratedColumn<String> exercises = GeneratedColumn<String>(
    'exercises',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restMeta = const VerificationMeta('rest');
  @override
  late final GeneratedColumn<String> rest = GeneratedColumn<String>(
    'rest',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    templateId,
    name,
    exercises,
    cycleId,
    dayId,
    dayIndex,
    date,
    startedAt,
    endedAt,
    rest,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('exercises')) {
      context.handle(
        _exercisesMeta,
        exercises.isAcceptableOrUnknown(data['exercises']!, _exercisesMeta),
      );
    } else if (isInserting) {
      context.missing(_exercisesMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('rest')) {
      context.handle(
        _restMeta,
        rest.isAcceptableOrUnknown(data['rest']!, _restMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: $WorkoutSessionsTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      exercises: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercises'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      ),
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      ),
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      rest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rest'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncState syncState;
  final String? templateId;
  final String name;
  final String exercises;
  final String? cycleId;
  final String? dayId;
  final int? dayIndex;
  final DateTime date;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? rest;
  final String? note;
  const SessionRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    this.templateId,
    required this.name,
    required this.exercises,
    this.cycleId,
    this.dayId,
    this.dayIndex,
    required this.date,
    required this.startedAt,
    this.endedAt,
    this.rest,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_state'] = Variable<String>(
        $WorkoutSessionsTable.$convertersyncState.toSql(syncState),
      );
    }
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    map['name'] = Variable<String>(name);
    map['exercises'] = Variable<String>(exercises);
    if (!nullToAbsent || cycleId != null) {
      map['cycle_id'] = Variable<String>(cycleId);
    }
    if (!nullToAbsent || dayId != null) {
      map['day_id'] = Variable<String>(dayId);
    }
    if (!nullToAbsent || dayIndex != null) {
      map['day_index'] = Variable<int>(dayIndex);
    }
    map['date'] = Variable<DateTime>(date);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || rest != null) {
      map['rest'] = Variable<String>(rest);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      name: Value(name),
      exercises: Value(exercises),
      cycleId: cycleId == null && nullToAbsent
          ? const Value.absent()
          : Value(cycleId),
      dayId: dayId == null && nullToAbsent
          ? const Value.absent()
          : Value(dayId),
      dayIndex: dayIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(dayIndex),
      date: Value(date),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      rest: rest == null && nullToAbsent ? const Value.absent() : Value(rest),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: $WorkoutSessionsTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      templateId: serializer.fromJson<String?>(json['templateId']),
      name: serializer.fromJson<String>(json['name']),
      exercises: serializer.fromJson<String>(json['exercises']),
      cycleId: serializer.fromJson<String?>(json['cycleId']),
      dayId: serializer.fromJson<String?>(json['dayId']),
      dayIndex: serializer.fromJson<int?>(json['dayIndex']),
      date: serializer.fromJson<DateTime>(json['date']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      rest: serializer.fromJson<String?>(json['rest']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(
        $WorkoutSessionsTable.$convertersyncState.toJson(syncState),
      ),
      'templateId': serializer.toJson<String?>(templateId),
      'name': serializer.toJson<String>(name),
      'exercises': serializer.toJson<String>(exercises),
      'cycleId': serializer.toJson<String?>(cycleId),
      'dayId': serializer.toJson<String?>(dayId),
      'dayIndex': serializer.toJson<int?>(dayIndex),
      'date': serializer.toJson<DateTime>(date),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'rest': serializer.toJson<String?>(rest),
      'note': serializer.toJson<String?>(note),
    };
  }

  SessionRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncState? syncState,
    Value<String?> templateId = const Value.absent(),
    String? name,
    String? exercises,
    Value<String?> cycleId = const Value.absent(),
    Value<String?> dayId = const Value.absent(),
    Value<int?> dayIndex = const Value.absent(),
    DateTime? date,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> rest = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => SessionRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    templateId: templateId.present ? templateId.value : this.templateId,
    name: name ?? this.name,
    exercises: exercises ?? this.exercises,
    cycleId: cycleId.present ? cycleId.value : this.cycleId,
    dayId: dayId.present ? dayId.value : this.dayId,
    dayIndex: dayIndex.present ? dayIndex.value : this.dayIndex,
    date: date ?? this.date,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    rest: rest.present ? rest.value : this.rest,
    note: note.present ? note.value : this.note,
  );
  SessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      name: data.name.present ? data.name.value : this.name,
      exercises: data.exercises.present ? data.exercises.value : this.exercises,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      date: data.date.present ? data.date.value : this.date,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      rest: data.rest.present ? data.rest.value : this.rest,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('exercises: $exercises, ')
          ..write('cycleId: $cycleId, ')
          ..write('dayId: $dayId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('date: $date, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rest: $rest, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    templateId,
    name,
    exercises,
    cycleId,
    dayId,
    dayIndex,
    date,
    startedAt,
    endedAt,
    rest,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.templateId == this.templateId &&
          other.name == this.name &&
          other.exercises == this.exercises &&
          other.cycleId == this.cycleId &&
          other.dayId == this.dayId &&
          other.dayIndex == this.dayIndex &&
          other.date == this.date &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.rest == this.rest &&
          other.note == this.note);
}

class WorkoutSessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncState> syncState;
  final Value<String?> templateId;
  final Value<String> name;
  final Value<String> exercises;
  final Value<String?> cycleId;
  final Value<String?> dayId;
  final Value<int?> dayIndex;
  final Value<DateTime> date;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> rest;
  final Value<String?> note;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.templateId = const Value.absent(),
    this.name = const Value.absent(),
    this.exercises = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.dayId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.date = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rest = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.templateId = const Value.absent(),
    required String name,
    required String exercises,
    this.cycleId = const Value.absent(),
    this.dayId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    required DateTime date,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.rest = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       name = Value(name),
       exercises = Value(exercises),
       date = Value(date),
       startedAt = Value(startedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? templateId,
    Expression<String>? name,
    Expression<String>? exercises,
    Expression<String>? cycleId,
    Expression<String>? dayId,
    Expression<int>? dayIndex,
    Expression<DateTime>? date,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? rest,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (templateId != null) 'template_id': templateId,
      if (name != null) 'name': name,
      if (exercises != null) 'exercises': exercises,
      if (cycleId != null) 'cycle_id': cycleId,
      if (dayId != null) 'day_id': dayId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (date != null) 'date': date,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rest != null) 'rest': rest,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncState>? syncState,
    Value<String?>? templateId,
    Value<String>? name,
    Value<String>? exercises,
    Value<String?>? cycleId,
    Value<String?>? dayId,
    Value<int?>? dayIndex,
    Value<DateTime>? date,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? rest,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      cycleId: cycleId ?? this.cycleId,
      dayId: dayId ?? this.dayId,
      dayIndex: dayIndex ?? this.dayIndex,
      date: date ?? this.date,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rest: rest ?? this.rest,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $WorkoutSessionsTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (exercises.present) {
      map['exercises'] = Variable<String>(exercises.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rest.present) {
      map['rest'] = Variable<String>(rest.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('exercises: $exercises, ')
          ..write('cycleId: $cycleId, ')
          ..write('dayId: $dayId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('date: $date, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rest: $rest, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionSetsTable extends SessionSets
    with TableInfo<$SessionSetsTable, SessionSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNoMeta = const VerificationMeta('setNo');
  @override
  late final GeneratedColumn<int> setNo = GeneratedColumn<int>(
    'set_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
    'kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta(
    'seconds',
  );
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrMeta = const VerificationMeta('isPr');
  @override
  late final GeneratedColumn<bool> isPr = GeneratedColumn<bool>(
    'is_pr',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pr" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    rowId,
    exerciseId,
    setNo,
    kg,
    reps,
    seconds,
    isPr,
    loggedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('set_no')) {
      context.handle(
        _setNoMeta,
        setNo.isAcceptableOrUnknown(data['set_no']!, _setNoMeta),
      );
    } else if (isInserting) {
      context.missing(_setNoMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('seconds')) {
      context.handle(
        _secondsMeta,
        seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta),
      );
    }
    if (data.containsKey('is_pr')) {
      context.handle(
        _isPrMeta,
        isPr.isAcceptableOrUnknown(data['is_pr']!, _isPrMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      setNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_no'],
      )!,
      kg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kg'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      ),
      isPr: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pr'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionSetsTable createAlias(String alias) {
    return $SessionSetsTable(attachedDatabase, alias);
  }
}

class SessionSetRow extends DataClass implements Insertable<SessionSetRow> {
  final String id;
  final String sessionId;
  final String rowId;
  final String exerciseId;
  final int setNo;
  final double kg;
  final int? reps;
  final int? seconds;
  final bool isPr;
  final DateTime loggedAt;
  final DateTime updatedAt;
  const SessionSetRow({
    required this.id,
    required this.sessionId,
    required this.rowId,
    required this.exerciseId,
    required this.setNo,
    required this.kg,
    this.reps,
    this.seconds,
    required this.isPr,
    required this.loggedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['row_id'] = Variable<String>(rowId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['set_no'] = Variable<int>(setNo);
    map['kg'] = Variable<double>(kg);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || seconds != null) {
      map['seconds'] = Variable<int>(seconds);
    }
    map['is_pr'] = Variable<bool>(isPr);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionSetsCompanion toCompanion(bool nullToAbsent) {
    return SessionSetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      rowId: Value(rowId),
      exerciseId: Value(exerciseId),
      setNo: Value(setNo),
      kg: Value(kg),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      seconds: seconds == null && nullToAbsent
          ? const Value.absent()
          : Value(seconds),
      isPr: Value(isPr),
      loggedAt: Value(loggedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionSetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSetRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      rowId: serializer.fromJson<String>(json['rowId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      setNo: serializer.fromJson<int>(json['setNo']),
      kg: serializer.fromJson<double>(json['kg']),
      reps: serializer.fromJson<int?>(json['reps']),
      seconds: serializer.fromJson<int?>(json['seconds']),
      isPr: serializer.fromJson<bool>(json['isPr']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'rowId': serializer.toJson<String>(rowId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'setNo': serializer.toJson<int>(setNo),
      'kg': serializer.toJson<double>(kg),
      'reps': serializer.toJson<int?>(reps),
      'seconds': serializer.toJson<int?>(seconds),
      'isPr': serializer.toJson<bool>(isPr),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionSetRow copyWith({
    String? id,
    String? sessionId,
    String? rowId,
    String? exerciseId,
    int? setNo,
    double? kg,
    Value<int?> reps = const Value.absent(),
    Value<int?> seconds = const Value.absent(),
    bool? isPr,
    DateTime? loggedAt,
    DateTime? updatedAt,
  }) => SessionSetRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    rowId: rowId ?? this.rowId,
    exerciseId: exerciseId ?? this.exerciseId,
    setNo: setNo ?? this.setNo,
    kg: kg ?? this.kg,
    reps: reps.present ? reps.value : this.reps,
    seconds: seconds.present ? seconds.value : this.seconds,
    isPr: isPr ?? this.isPr,
    loggedAt: loggedAt ?? this.loggedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionSetRow copyWithCompanion(SessionSetsCompanion data) {
    return SessionSetRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      setNo: data.setNo.present ? data.setNo.value : this.setNo,
      kg: data.kg.present ? data.kg.value : this.kg,
      reps: data.reps.present ? data.reps.value : this.reps,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
      isPr: data.isPr.present ? data.isPr.value : this.isPr,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSetRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('rowId: $rowId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setNo: $setNo, ')
          ..write('kg: $kg, ')
          ..write('reps: $reps, ')
          ..write('seconds: $seconds, ')
          ..write('isPr: $isPr, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    rowId,
    exerciseId,
    setNo,
    kg,
    reps,
    seconds,
    isPr,
    loggedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSetRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.rowId == this.rowId &&
          other.exerciseId == this.exerciseId &&
          other.setNo == this.setNo &&
          other.kg == this.kg &&
          other.reps == this.reps &&
          other.seconds == this.seconds &&
          other.isPr == this.isPr &&
          other.loggedAt == this.loggedAt &&
          other.updatedAt == this.updatedAt);
}

class SessionSetsCompanion extends UpdateCompanion<SessionSetRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> rowId;
  final Value<String> exerciseId;
  final Value<int> setNo;
  final Value<double> kg;
  final Value<int?> reps;
  final Value<int?> seconds;
  final Value<bool> isPr;
  final Value<DateTime> loggedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionSetsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.rowId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.setNo = const Value.absent(),
    this.kg = const Value.absent(),
    this.reps = const Value.absent(),
    this.seconds = const Value.absent(),
    this.isPr = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionSetsCompanion.insert({
    required String id,
    required String sessionId,
    required String rowId,
    required String exerciseId,
    required int setNo,
    required double kg,
    this.reps = const Value.absent(),
    this.seconds = const Value.absent(),
    this.isPr = const Value.absent(),
    required DateTime loggedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       rowId = Value(rowId),
       exerciseId = Value(exerciseId),
       setNo = Value(setNo),
       kg = Value(kg),
       loggedAt = Value(loggedAt),
       updatedAt = Value(updatedAt);
  static Insertable<SessionSetRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? rowId,
    Expression<String>? exerciseId,
    Expression<int>? setNo,
    Expression<double>? kg,
    Expression<int>? reps,
    Expression<int>? seconds,
    Expression<bool>? isPr,
    Expression<DateTime>? loggedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (rowId != null) 'row_id': rowId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (setNo != null) 'set_no': setNo,
      if (kg != null) 'kg': kg,
      if (reps != null) 'reps': reps,
      if (seconds != null) 'seconds': seconds,
      if (isPr != null) 'is_pr': isPr,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? rowId,
    Value<String>? exerciseId,
    Value<int>? setNo,
    Value<double>? kg,
    Value<int?>? reps,
    Value<int?>? seconds,
    Value<bool>? isPr,
    Value<DateTime>? loggedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionSetsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      rowId: rowId ?? this.rowId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNo: setNo ?? this.setNo,
      kg: kg ?? this.kg,
      reps: reps ?? this.reps,
      seconds: seconds ?? this.seconds,
      isPr: isPr ?? this.isPr,
      loggedAt: loggedAt ?? this.loggedAt,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (setNo.present) {
      map['set_no'] = Variable<int>(setNo.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (isPr.present) {
      map['is_pr'] = Variable<bool>(isPr.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
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
    return (StringBuffer('SessionSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('rowId: $rowId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setNo: $setNo, ')
          ..write('kg: $kg, ')
          ..write('reps: $reps, ')
          ..write('seconds: $seconds, ')
          ..write('isPr: $isPr, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomExercisesTable extends CustomExercises
    with TableInfo<$CustomExercisesTable, CustomExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: newId,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> syncState =
      GeneratedColumn<String>(
        'sync_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.pending.name),
      ).withConverter<SyncState>($CustomExercisesTable.$convertersyncState);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryMusclesMeta = const VerificationMeta(
    'primaryMuscles',
  );
  @override
  late final GeneratedColumn<String> primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryMusclesMeta = const VerificationMeta(
    'secondaryMuscles',
  );
  @override
  late final GeneratedColumn<String> secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    syncState,
    name,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('primary_muscles')) {
      context.handle(
        _primaryMusclesMeta,
        primaryMuscles.isAcceptableOrUnknown(
          data['primary_muscles']!,
          _primaryMusclesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryMusclesMeta);
    }
    if (data.containsKey('secondary_muscles')) {
      context.handle(
        _secondaryMusclesMeta,
        secondaryMuscles.isAcceptableOrUnknown(
          data['secondary_muscles']!,
          _secondaryMusclesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondaryMusclesMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: $CustomExercisesTable.$convertersyncState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_state'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      primaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscles'],
      )!,
      secondaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_muscles'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CustomExercisesTable createAlias(String alias) {
    return $CustomExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncState, String, String> $convertersyncState =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class CustomExerciseRow extends DataClass
    implements Insertable<CustomExerciseRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncState syncState;
  final String name;
  final String equipment;
  final String primaryMuscles;
  final String secondaryMuscles;
  final String? notes;
  const CustomExerciseRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.name,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_state'] = Variable<String>(
        $CustomExercisesTable.$convertersyncState.toSql(syncState),
      );
    }
    map['name'] = Variable<String>(name);
    map['equipment'] = Variable<String>(equipment);
    map['primary_muscles'] = Variable<String>(primaryMuscles);
    map['secondary_muscles'] = Variable<String>(secondaryMuscles);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CustomExercisesCompanion toCompanion(bool nullToAbsent) {
    return CustomExercisesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      name: Value(name),
      equipment: Value(equipment),
      primaryMuscles: Value(primaryMuscles),
      secondaryMuscles: Value(secondaryMuscles),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CustomExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: $CustomExercisesTable.$convertersyncState.fromJson(
        serializer.fromJson<String>(json['syncState']),
      ),
      name: serializer.fromJson<String>(json['name']),
      equipment: serializer.fromJson<String>(json['equipment']),
      primaryMuscles: serializer.fromJson<String>(json['primaryMuscles']),
      secondaryMuscles: serializer.fromJson<String>(json['secondaryMuscles']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<String>(
        $CustomExercisesTable.$convertersyncState.toJson(syncState),
      ),
      'name': serializer.toJson<String>(name),
      'equipment': serializer.toJson<String>(equipment),
      'primaryMuscles': serializer.toJson<String>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<String>(secondaryMuscles),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CustomExerciseRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncState? syncState,
    String? name,
    String? equipment,
    String? primaryMuscles,
    String? secondaryMuscles,
    Value<String?> notes = const Value.absent(),
  }) => CustomExerciseRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    name: name ?? this.name,
    equipment: equipment ?? this.equipment,
    primaryMuscles: primaryMuscles ?? this.primaryMuscles,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    notes: notes.present ? notes.value : this.notes,
  );
  CustomExerciseRow copyWithCompanion(CustomExercisesCompanion data) {
    return CustomExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      name: data.name.present ? data.name.value : this.name,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      primaryMuscles: data.primaryMuscles.present
          ? data.primaryMuscles.value
          : this.primaryMuscles,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomExerciseRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    syncState,
    name,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExerciseRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.name == this.name &&
          other.equipment == this.equipment &&
          other.primaryMuscles == this.primaryMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.notes == this.notes);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExerciseRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncState> syncState;
  final Value<String> name;
  final Value<String> equipment;
  final Value<String> primaryMuscles;
  final Value<String> secondaryMuscles;
  final Value<String?> notes;
  final Value<int> rowid;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.name = const Value.absent(),
    this.equipment = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String name,
    required String equipment,
    required String primaryMuscles,
    required String secondaryMuscles,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       name = Value(name),
       equipment = Value(equipment),
       primaryMuscles = Value(primaryMuscles),
       secondaryMuscles = Value(secondaryMuscles);
  static Insertable<CustomExerciseRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncState,
    Expression<String>? name,
    Expression<String>? equipment,
    Expression<String>? primaryMuscles,
    Expression<String>? secondaryMuscles,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (name != null) 'name': name,
      if (equipment != null) 'equipment': equipment,
      if (primaryMuscles != null) 'primary_muscles': primaryMuscles,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomExercisesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncState>? syncState,
    Value<String>? name,
    Value<String>? equipment,
    Value<String>? primaryMuscles,
    Value<String>? secondaryMuscles,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      name: name ?? this.name,
      equipment: equipment ?? this.equipment,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(
        $CustomExercisesTable.$convertersyncState.toSql(syncState.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(primaryMuscles.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercisesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CatalogExercisesTable catalogExercises = $CatalogExercisesTable(
    this,
  );
  late final $ExerciseMusclesTable exerciseMuscles = $ExerciseMusclesTable(
    this,
  );
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $BodySnapshotsTable bodySnapshots = $BodySnapshotsTable(this);
  late final $WorkoutTemplatesTable workoutTemplates = $WorkoutTemplatesTable(
    this,
  );
  late final $CyclesTable cycles = $CyclesTable(this);
  late final $ScheduleDaysTable scheduleDays = $ScheduleDaysTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $SessionSetsTable sessionSets = $SessionSetsTable(this);
  late final $CustomExercisesTable customExercises = $CustomExercisesTable(
    this,
  );
  late final Index exerciseMusclesMuscle = Index(
    'exercise_muscles_muscle',
    'CREATE INDEX exercise_muscles_muscle ON exercise_muscles (muscle)',
  );
  late final Index scheduleDaysDate = Index(
    'schedule_days_date',
    'CREATE INDEX schedule_days_date ON schedule_days (date)',
  );
  late final Index workoutSessionsTemplateEnded = Index(
    'workout_sessions_template_ended',
    'CREATE INDEX workout_sessions_template_ended ON workout_sessions (template_id, ended_at)',
  );
  late final Index sessionSetsSession = Index(
    'session_sets_session',
    'CREATE INDEX session_sets_session ON session_sets (session_id)',
  );
  late final Index sessionSetsExercise = Index(
    'session_sets_exercise',
    'CREATE INDEX session_sets_exercise ON session_sets (exercise_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    catalogExercises,
    exerciseMuscles,
    appMeta,
    outbox,
    userProfiles,
    bodySnapshots,
    workoutTemplates,
    cycles,
    scheduleDays,
    workoutSessions,
    sessionSets,
    customExercises,
    exerciseMusclesMuscle,
    scheduleDaysDate,
    workoutSessionsTemplateEnded,
    sessionSetsSession,
    sessionSetsExercise,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CatalogExercisesTableCreateCompanionBuilder =
    CatalogExercisesCompanion Function({
      required String id,
      required String name,
      required String equipment,
      required String category,
      required String level,
      Value<String?> mechanic,
      Value<String?> force,
      required String instructions,
      required String images,
      required String contentHash,
      Value<DateTime?> retiredAt,
      Value<int> rowid,
    });
typedef $$CatalogExercisesTableUpdateCompanionBuilder =
    CatalogExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> equipment,
      Value<String> category,
      Value<String> level,
      Value<String?> mechanic,
      Value<String?> force,
      Value<String> instructions,
      Value<String> images,
      Value<String> contentHash,
      Value<DateTime?> retiredAt,
      Value<int> rowid,
    });

final class $$CatalogExercisesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CatalogExercisesTable, CatalogExercise> {
  $$CatalogExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExerciseMusclesTable, List<ExerciseMuscle>>
  _exerciseMusclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscles,
    aliasName: $_aliasNameGenerator(
      db.catalogExercises.id,
      db.exerciseMuscles.exerciseId,
    ),
  );

  $$ExerciseMusclesTableProcessedTableManager get exerciseMusclesRefs {
    final manager = $$ExerciseMusclesTableTableManager(
      $_db,
      $_db.exerciseMuscles,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMusclesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatalogExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogExercisesTable> {
  $$CatalogExercisesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiredAt => $composableBuilder(
    column: $table.retiredAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMusclesRefs(
    Expression<bool> Function($$ExerciseMusclesTableFilterComposer f) f,
  ) {
    final $$ExerciseMusclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogExercisesTable> {
  $$CatalogExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiredAt => $composableBuilder(
    column: $table.retiredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogExercisesTable> {
  $$CatalogExercisesTableAnnotationComposer({
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

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get mechanic =>
      $composableBuilder(column: $table.mechanic, builder: (column) => column);

  GeneratedColumn<String> get force =>
      $composableBuilder(column: $table.force, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get retiredAt =>
      $composableBuilder(column: $table.retiredAt, builder: (column) => column);

  Expression<T> exerciseMusclesRefs<T extends Object>(
    Expression<T> Function($$ExerciseMusclesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMusclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscles,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMusclesTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogExercisesTable,
          CatalogExercise,
          $$CatalogExercisesTableFilterComposer,
          $$CatalogExercisesTableOrderingComposer,
          $$CatalogExercisesTableAnnotationComposer,
          $$CatalogExercisesTableCreateCompanionBuilder,
          $$CatalogExercisesTableUpdateCompanionBuilder,
          (CatalogExercise, $$CatalogExercisesTableReferences),
          CatalogExercise,
          PrefetchHooks Function({bool exerciseMusclesRefs})
        > {
  $$CatalogExercisesTableTableManager(
    _$AppDatabase db,
    $CatalogExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<String> instructions = const Value.absent(),
                Value<String> images = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<DateTime?> retiredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogExercisesCompanion(
                id: id,
                name: name,
                equipment: equipment,
                category: category,
                level: level,
                mechanic: mechanic,
                force: force,
                instructions: instructions,
                images: images,
                contentHash: contentHash,
                retiredAt: retiredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String equipment,
                required String category,
                required String level,
                Value<String?> mechanic = const Value.absent(),
                Value<String?> force = const Value.absent(),
                required String instructions,
                required String images,
                required String contentHash,
                Value<DateTime?> retiredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogExercisesCompanion.insert(
                id: id,
                name: name,
                equipment: equipment,
                category: category,
                level: level,
                mechanic: mechanic,
                force: force,
                instructions: instructions,
                images: images,
                contentHash: contentHash,
                retiredAt: retiredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CatalogExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseMusclesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseMusclesRefs) db.exerciseMuscles,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseMusclesRefs)
                    await $_getPrefetchedData<
                      CatalogExercise,
                      $CatalogExercisesTable,
                      ExerciseMuscle
                    >(
                      currentTable: table,
                      referencedTable: $$CatalogExercisesTableReferences
                          ._exerciseMusclesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CatalogExercisesTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseMusclesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.exerciseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CatalogExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogExercisesTable,
      CatalogExercise,
      $$CatalogExercisesTableFilterComposer,
      $$CatalogExercisesTableOrderingComposer,
      $$CatalogExercisesTableAnnotationComposer,
      $$CatalogExercisesTableCreateCompanionBuilder,
      $$CatalogExercisesTableUpdateCompanionBuilder,
      (CatalogExercise, $$CatalogExercisesTableReferences),
      CatalogExercise,
      PrefetchHooks Function({bool exerciseMusclesRefs})
    >;
typedef $$ExerciseMusclesTableCreateCompanionBuilder =
    ExerciseMusclesCompanion Function({
      required String exerciseId,
      required String muscle,
      required bool isPrimary,
      Value<int> rowid,
    });
typedef $$ExerciseMusclesTableUpdateCompanionBuilder =
    ExerciseMusclesCompanion Function({
      Value<String> exerciseId,
      Value<String> muscle,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

final class $$ExerciseMusclesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExerciseMusclesTable, ExerciseMuscle> {
  $$ExerciseMusclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CatalogExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.catalogExercises.createAlias(
        $_aliasNameGenerator(
          db.exerciseMuscles.exerciseId,
          db.catalogExercises.id,
        ),
      );

  $$CatalogExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$CatalogExercisesTableTableManager(
      $_db,
      $_db.catalogExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseMusclesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get muscle => $composableBuilder(
    column: $table.muscle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  $$CatalogExercisesTableFilterComposer get exerciseId {
    final $$CatalogExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.catalogExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogExercisesTableFilterComposer(
            $db: $db,
            $table: $db.catalogExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get muscle => $composableBuilder(
    column: $table.muscle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatalogExercisesTableOrderingComposer get exerciseId {
    final $$CatalogExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.catalogExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.catalogExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseMusclesTable> {
  $$ExerciseMusclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get muscle =>
      $composableBuilder(column: $table.muscle, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  $$CatalogExercisesTableAnnotationComposer get exerciseId {
    final $$CatalogExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.catalogExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMusclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseMusclesTable,
          ExerciseMuscle,
          $$ExerciseMusclesTableFilterComposer,
          $$ExerciseMusclesTableOrderingComposer,
          $$ExerciseMusclesTableAnnotationComposer,
          $$ExerciseMusclesTableCreateCompanionBuilder,
          $$ExerciseMusclesTableUpdateCompanionBuilder,
          (ExerciseMuscle, $$ExerciseMusclesTableReferences),
          ExerciseMuscle,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseMusclesTableTableManager(
    _$AppDatabase db,
    $ExerciseMusclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMusclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMusclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseMusclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> muscle = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion(
                exerciseId: exerciseId,
                muscle: muscle,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String muscle,
                required bool isPrimary,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMusclesCompanion.insert(
                exerciseId: exerciseId,
                muscle: muscle,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseMusclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$ExerciseMusclesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$ExerciseMusclesTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseMusclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseMusclesTable,
      ExerciseMuscle,
      $$ExerciseMusclesTableFilterComposer,
      $$ExerciseMusclesTableOrderingComposer,
      $$ExerciseMusclesTableAnnotationComposer,
      $$ExerciseMusclesTableCreateCompanionBuilder,
      $$ExerciseMusclesTableUpdateCompanionBuilder,
      (ExerciseMuscle, $$ExerciseMusclesTableReferences),
      ExerciseMuscle,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      required String entity,
      required String entityId,
      required OutboxOp op,
      required DateTime createdAt,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      Value<String> entity,
      Value<String> entityId,
      Value<OutboxOp> op,
      Value<DateTime> createdAt,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxOp, OutboxOp, String> get op =>
      $composableBuilder(
        column: $table.op,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxOp, String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<OutboxOp> op = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                entity: entity,
                entityId: entityId,
                op: op,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String entity,
                required String entityId,
                required OutboxOp op,
                required DateTime createdAt,
              }) => OutboxCompanion.insert(
                seq: seq,
                entity: entity,
                entityId: entityId,
                op: op,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<String?> goal,
      Value<String?> level,
      required String units,
      Value<String?> sex,
      Value<int?> birthYear,
      Value<double?> heightCm,
      Value<String?> activityLevel,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<String?> goal,
      Value<String?> level,
      Value<String> units,
      Value<String?> sex,
      Value<int?> birthYear,
      Value<double?> heightCm,
      Value<String?> activityLevel,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String> units = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                goal: goal,
                level: level,
                units: units,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                activityLevel: activityLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<String?> level = const Value.absent(),
                required String units,
                Value<String?> sex = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                goal: goal,
                level: level,
                units: units,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                activityLevel: activityLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$BodySnapshotsTableCreateCompanionBuilder =
    BodySnapshotsCompanion Function({
      Value<String> id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      required DateTime date,
      Value<double?> weightKg,
      Value<double?> waistCm,
      Value<double?> neckCm,
      Value<double?> hipCm,
      Value<double?> scaleBodyFatPct,
      Value<String?> activity,
      Value<String?> results,
      Value<int> rowid,
    });
typedef $$BodySnapshotsTableUpdateCompanionBuilder =
    BodySnapshotsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<DateTime> date,
      Value<double?> weightKg,
      Value<double?> waistCm,
      Value<double?> neckCm,
      Value<double?> hipCm,
      Value<double?> scaleBodyFatPct,
      Value<String?> activity,
      Value<String?> results,
      Value<int> rowid,
    });

class $$BodySnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $BodySnapshotsTable> {
  $$BodySnapshotsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipCm => $composableBuilder(
    column: $table.hipCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scaleBodyFatPct => $composableBuilder(
    column: $table.scaleBodyFatPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get results => $composableBuilder(
    column: $table.results,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodySnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodySnapshotsTable> {
  $$BodySnapshotsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipCm => $composableBuilder(
    column: $table.hipCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scaleBodyFatPct => $composableBuilder(
    column: $table.scaleBodyFatPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get results => $composableBuilder(
    column: $table.results,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodySnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodySnapshotsTable> {
  $$BodySnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get neckCm =>
      $composableBuilder(column: $table.neckCm, builder: (column) => column);

  GeneratedColumn<double> get hipCm =>
      $composableBuilder(column: $table.hipCm, builder: (column) => column);

  GeneratedColumn<double> get scaleBodyFatPct => $composableBuilder(
    column: $table.scaleBodyFatPct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<String> get results =>
      $composableBuilder(column: $table.results, builder: (column) => column);
}

class $$BodySnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodySnapshotsTable,
          BodySnapshotRow,
          $$BodySnapshotsTableFilterComposer,
          $$BodySnapshotsTableOrderingComposer,
          $$BodySnapshotsTableAnnotationComposer,
          $$BodySnapshotsTableCreateCompanionBuilder,
          $$BodySnapshotsTableUpdateCompanionBuilder,
          (
            BodySnapshotRow,
            BaseReferences<_$AppDatabase, $BodySnapshotsTable, BodySnapshotRow>,
          ),
          BodySnapshotRow,
          PrefetchHooks Function()
        > {
  $$BodySnapshotsTableTableManager(_$AppDatabase db, $BodySnapshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodySnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodySnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodySnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<double?> hipCm = const Value.absent(),
                Value<double?> scaleBodyFatPct = const Value.absent(),
                Value<String?> activity = const Value.absent(),
                Value<String?> results = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodySnapshotsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                date: date,
                weightKg: weightKg,
                waistCm: waistCm,
                neckCm: neckCm,
                hipCm: hipCm,
                scaleBodyFatPct: scaleBodyFatPct,
                activity: activity,
                results: results,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required DateTime date,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<double?> hipCm = const Value.absent(),
                Value<double?> scaleBodyFatPct = const Value.absent(),
                Value<String?> activity = const Value.absent(),
                Value<String?> results = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodySnapshotsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                date: date,
                weightKg: weightKg,
                waistCm: waistCm,
                neckCm: neckCm,
                hipCm: hipCm,
                scaleBodyFatPct: scaleBodyFatPct,
                activity: activity,
                results: results,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodySnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodySnapshotsTable,
      BodySnapshotRow,
      $$BodySnapshotsTableFilterComposer,
      $$BodySnapshotsTableOrderingComposer,
      $$BodySnapshotsTableAnnotationComposer,
      $$BodySnapshotsTableCreateCompanionBuilder,
      $$BodySnapshotsTableUpdateCompanionBuilder,
      (
        BodySnapshotRow,
        BaseReferences<_$AppDatabase, $BodySnapshotsTable, BodySnapshotRow>,
      ),
      BodySnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutTemplatesTableCreateCompanionBuilder =
    WorkoutTemplatesCompanion Function({
      Value<String> id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      required String name,
      required String exercises,
      Value<int> rowid,
    });
typedef $$WorkoutTemplatesTableUpdateCompanionBuilder =
    WorkoutTemplatesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<String> name,
      Value<String> exercises,
      Value<int> rowid,
    });

class $$WorkoutTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exercises => $composableBuilder(
    column: $table.exercises,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercises => $composableBuilder(
    column: $table.exercises,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get exercises =>
      $composableBuilder(column: $table.exercises, builder: (column) => column);
}

class $$WorkoutTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTemplatesTable,
          WorkoutTemplateRow,
          $$WorkoutTemplatesTableFilterComposer,
          $$WorkoutTemplatesTableOrderingComposer,
          $$WorkoutTemplatesTableAnnotationComposer,
          $$WorkoutTemplatesTableCreateCompanionBuilder,
          $$WorkoutTemplatesTableUpdateCompanionBuilder,
          (
            WorkoutTemplateRow,
            BaseReferences<
              _$AppDatabase,
              $WorkoutTemplatesTable,
              WorkoutTemplateRow
            >,
          ),
          WorkoutTemplateRow,
          PrefetchHooks Function()
        > {
  $$WorkoutTemplatesTableTableManager(
    _$AppDatabase db,
    $WorkoutTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> exercises = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplatesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                exercises: exercises,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required String name,
                required String exercises,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplatesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                exercises: exercises,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTemplatesTable,
      WorkoutTemplateRow,
      $$WorkoutTemplatesTableFilterComposer,
      $$WorkoutTemplatesTableOrderingComposer,
      $$WorkoutTemplatesTableAnnotationComposer,
      $$WorkoutTemplatesTableCreateCompanionBuilder,
      $$WorkoutTemplatesTableUpdateCompanionBuilder,
      (
        WorkoutTemplateRow,
        BaseReferences<
          _$AppDatabase,
          $WorkoutTemplatesTable,
          WorkoutTemplateRow
        >,
      ),
      WorkoutTemplateRow,
      PrefetchHooks Function()
    >;
typedef $$CyclesTableCreateCompanionBuilder =
    CyclesCompanion Function({
      Value<String> id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      required String name,
      required String days,
      required bool isActive,
      required DateTime startDate,
      required int startDayIndex,
      Value<String> mode,
      Value<int> rowid,
    });
typedef $$CyclesTableUpdateCompanionBuilder =
    CyclesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<String> name,
      Value<String> days,
      Value<bool> isActive,
      Value<DateTime> startDate,
      Value<int> startDayIndex,
      Value<String> mode,
      Value<int> rowid,
    });

class $$CyclesTableFilterComposer
    extends Composer<_$AppDatabase, $CyclesTable> {
  $$CyclesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDayIndex => $composableBuilder(
    column: $table.startDayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $CyclesTable> {
  $$CyclesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDayIndex => $composableBuilder(
    column: $table.startDayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CyclesTable> {
  $$CyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get startDayIndex => $composableBuilder(
    column: $table.startDayIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);
}

class $$CyclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CyclesTable,
          CycleRow,
          $$CyclesTableFilterComposer,
          $$CyclesTableOrderingComposer,
          $$CyclesTableAnnotationComposer,
          $$CyclesTableCreateCompanionBuilder,
          $$CyclesTableUpdateCompanionBuilder,
          (CycleRow, BaseReferences<_$AppDatabase, $CyclesTable, CycleRow>),
          CycleRow,
          PrefetchHooks Function()
        > {
  $$CyclesTableTableManager(_$AppDatabase db, $CyclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> days = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<int> startDayIndex = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CyclesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                days: days,
                isActive: isActive,
                startDate: startDate,
                startDayIndex: startDayIndex,
                mode: mode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required String name,
                required String days,
                required bool isActive,
                required DateTime startDate,
                required int startDayIndex,
                Value<String> mode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CyclesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                days: days,
                isActive: isActive,
                startDate: startDate,
                startDayIndex: startDayIndex,
                mode: mode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CyclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CyclesTable,
      CycleRow,
      $$CyclesTableFilterComposer,
      $$CyclesTableOrderingComposer,
      $$CyclesTableAnnotationComposer,
      $$CyclesTableCreateCompanionBuilder,
      $$CyclesTableUpdateCompanionBuilder,
      (CycleRow, BaseReferences<_$AppDatabase, $CyclesTable, CycleRow>),
      CycleRow,
      PrefetchHooks Function()
    >;
typedef $$ScheduleDaysTableCreateCompanionBuilder =
    ScheduleDaysCompanion Function({
      Value<String> id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      required String cycleId,
      required DateTime date,
      required String dayId,
      required int dayIndex,
      required String status,
      Value<String?> workoutId,
      Value<DateTime?> linkedDate,
      Value<int> rowid,
    });
typedef $$ScheduleDaysTableUpdateCompanionBuilder =
    ScheduleDaysCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<String> cycleId,
      Value<DateTime> date,
      Value<String> dayId,
      Value<int> dayIndex,
      Value<String> status,
      Value<String?> workoutId,
      Value<DateTime?> linkedDate,
      Value<int> rowid,
    });

class $$ScheduleDaysTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleDaysTable> {
  $$ScheduleDaysTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get linkedDate => $composableBuilder(
    column: $table.linkedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleDaysTable> {
  $$ScheduleDaysTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get linkedDate => $composableBuilder(
    column: $table.linkedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleDaysTable> {
  $$ScheduleDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get workoutId =>
      $composableBuilder(column: $table.workoutId, builder: (column) => column);

  GeneratedColumn<DateTime> get linkedDate => $composableBuilder(
    column: $table.linkedDate,
    builder: (column) => column,
  );
}

class $$ScheduleDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleDaysTable,
          ScheduleDayRow,
          $$ScheduleDaysTableFilterComposer,
          $$ScheduleDaysTableOrderingComposer,
          $$ScheduleDaysTableAnnotationComposer,
          $$ScheduleDaysTableCreateCompanionBuilder,
          $$ScheduleDaysTableUpdateCompanionBuilder,
          (
            ScheduleDayRow,
            BaseReferences<_$AppDatabase, $ScheduleDaysTable, ScheduleDayRow>,
          ),
          ScheduleDayRow,
          PrefetchHooks Function()
        > {
  $$ScheduleDaysTableTableManager(_$AppDatabase db, $ScheduleDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<String> cycleId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> dayId = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> workoutId = const Value.absent(),
                Value<DateTime?> linkedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleDaysCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                cycleId: cycleId,
                date: date,
                dayId: dayId,
                dayIndex: dayIndex,
                status: status,
                workoutId: workoutId,
                linkedDate: linkedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required String cycleId,
                required DateTime date,
                required String dayId,
                required int dayIndex,
                required String status,
                Value<String?> workoutId = const Value.absent(),
                Value<DateTime?> linkedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleDaysCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                cycleId: cycleId,
                date: date,
                dayId: dayId,
                dayIndex: dayIndex,
                status: status,
                workoutId: workoutId,
                linkedDate: linkedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleDaysTable,
      ScheduleDayRow,
      $$ScheduleDaysTableFilterComposer,
      $$ScheduleDaysTableOrderingComposer,
      $$ScheduleDaysTableAnnotationComposer,
      $$ScheduleDaysTableCreateCompanionBuilder,
      $$ScheduleDaysTableUpdateCompanionBuilder,
      (
        ScheduleDayRow,
        BaseReferences<_$AppDatabase, $ScheduleDaysTable, ScheduleDayRow>,
      ),
      ScheduleDayRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<String?> templateId,
      required String name,
      required String exercises,
      Value<String?> cycleId,
      Value<String?> dayId,
      Value<int?> dayIndex,
      required DateTime date,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String?> rest,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<String?> templateId,
      Value<String> name,
      Value<String> exercises,
      Value<String?> cycleId,
      Value<String?> dayId,
      Value<int?> dayIndex,
      Value<DateTime> date,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> rest,
      Value<String?> note,
      Value<int> rowid,
    });

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exercises => $composableBuilder(
    column: $table.exercises,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rest => $composableBuilder(
    column: $table.rest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercises => $composableBuilder(
    column: $table.exercises,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rest => $composableBuilder(
    column: $table.rest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get exercises =>
      $composableBuilder(column: $table.exercises, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<String> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get rest =>
      $composableBuilder(column: $table.rest, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          SessionRow,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (
            SessionRow,
            BaseReferences<_$AppDatabase, $WorkoutSessionsTable, SessionRow>,
          ),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> exercises = const Value.absent(),
                Value<String?> cycleId = const Value.absent(),
                Value<String?> dayId = const Value.absent(),
                Value<int?> dayIndex = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> rest = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                templateId: templateId,
                name: name,
                exercises: exercises,
                cycleId: cycleId,
                dayId: dayId,
                dayIndex: dayIndex,
                date: date,
                startedAt: startedAt,
                endedAt: endedAt,
                rest: rest,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                required String name,
                required String exercises,
                Value<String?> cycleId = const Value.absent(),
                Value<String?> dayId = const Value.absent(),
                Value<int?> dayIndex = const Value.absent(),
                required DateTime date,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> rest = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                templateId: templateId,
                name: name,
                exercises: exercises,
                cycleId: cycleId,
                dayId: dayId,
                dayIndex: dayIndex,
                date: date,
                startedAt: startedAt,
                endedAt: endedAt,
                rest: rest,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      SessionRow,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (
        SessionRow,
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, SessionRow>,
      ),
      SessionRow,
      PrefetchHooks Function()
    >;
typedef $$SessionSetsTableCreateCompanionBuilder =
    SessionSetsCompanion Function({
      required String id,
      required String sessionId,
      required String rowId,
      required String exerciseId,
      required int setNo,
      required double kg,
      Value<int?> reps,
      Value<int?> seconds,
      Value<bool> isPr,
      required DateTime loggedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SessionSetsTableUpdateCompanionBuilder =
    SessionSetsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> rowId,
      Value<String> exerciseId,
      Value<int> setNo,
      Value<double> kg,
      Value<int?> reps,
      Value<int?> seconds,
      Value<bool> isPr,
      Value<DateTime> loggedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionSetsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNo => $composableBuilder(
    column: $table.setNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPr => $composableBuilder(
    column: $table.isPr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNo => $composableBuilder(
    column: $table.setNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPr => $composableBuilder(
    column: $table.isPr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionSetsTable> {
  $$SessionSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setNo =>
      $composableBuilder(column: $table.setNo, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);

  GeneratedColumn<bool> get isPr =>
      $composableBuilder(column: $table.isPr, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionSetsTable,
          SessionSetRow,
          $$SessionSetsTableFilterComposer,
          $$SessionSetsTableOrderingComposer,
          $$SessionSetsTableAnnotationComposer,
          $$SessionSetsTableCreateCompanionBuilder,
          $$SessionSetsTableUpdateCompanionBuilder,
          (
            SessionSetRow,
            BaseReferences<_$AppDatabase, $SessionSetsTable, SessionSetRow>,
          ),
          SessionSetRow,
          PrefetchHooks Function()
        > {
  $$SessionSetsTableTableManager(_$AppDatabase db, $SessionSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> setNo = const Value.absent(),
                Value<double> kg = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> seconds = const Value.absent(),
                Value<bool> isPr = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSetsCompanion(
                id: id,
                sessionId: sessionId,
                rowId: rowId,
                exerciseId: exerciseId,
                setNo: setNo,
                kg: kg,
                reps: reps,
                seconds: seconds,
                isPr: isPr,
                loggedAt: loggedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String rowId,
                required String exerciseId,
                required int setNo,
                required double kg,
                Value<int?> reps = const Value.absent(),
                Value<int?> seconds = const Value.absent(),
                Value<bool> isPr = const Value.absent(),
                required DateTime loggedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionSetsCompanion.insert(
                id: id,
                sessionId: sessionId,
                rowId: rowId,
                exerciseId: exerciseId,
                setNo: setNo,
                kg: kg,
                reps: reps,
                seconds: seconds,
                isPr: isPr,
                loggedAt: loggedAt,
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

typedef $$SessionSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionSetsTable,
      SessionSetRow,
      $$SessionSetsTableFilterComposer,
      $$SessionSetsTableOrderingComposer,
      $$SessionSetsTableAnnotationComposer,
      $$SessionSetsTableCreateCompanionBuilder,
      $$SessionSetsTableUpdateCompanionBuilder,
      (
        SessionSetRow,
        BaseReferences<_$AppDatabase, $SessionSetsTable, SessionSetRow>,
      ),
      SessionSetRow,
      PrefetchHooks Function()
    >;
typedef $$CustomExercisesTableCreateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<String> id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      required String name,
      required String equipment,
      required String primaryMuscles,
      required String secondaryMuscles,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$CustomExercisesTableUpdateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncState> syncState,
      Value<String> name,
      Value<String> equipment,
      Value<String> primaryMuscles,
      Value<String> secondaryMuscles,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$CustomExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get syncState =>
      $composableBuilder(
        column: $table.syncState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$CustomExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomExercisesTable,
          CustomExerciseRow,
          $$CustomExercisesTableFilterComposer,
          $$CustomExercisesTableOrderingComposer,
          $$CustomExercisesTableAnnotationComposer,
          $$CustomExercisesTableCreateCompanionBuilder,
          $$CustomExercisesTableUpdateCompanionBuilder,
          (
            CustomExerciseRow,
            BaseReferences<
              _$AppDatabase,
              $CustomExercisesTable,
              CustomExerciseRow
            >,
          ),
          CustomExerciseRow,
          PrefetchHooks Function()
        > {
  $$CustomExercisesTableTableManager(
    _$AppDatabase db,
    $CustomExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> primaryMuscles = const Value.absent(),
                Value<String> secondaryMuscles = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                equipment: equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncState> syncState = const Value.absent(),
                required String name,
                required String equipment,
                required String primaryMuscles,
                required String secondaryMuscles,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                equipment: equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomExercisesTable,
      CustomExerciseRow,
      $$CustomExercisesTableFilterComposer,
      $$CustomExercisesTableOrderingComposer,
      $$CustomExercisesTableAnnotationComposer,
      $$CustomExercisesTableCreateCompanionBuilder,
      $$CustomExercisesTableUpdateCompanionBuilder,
      (
        CustomExerciseRow,
        BaseReferences<_$AppDatabase, $CustomExercisesTable, CustomExerciseRow>,
      ),
      CustomExerciseRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CatalogExercisesTableTableManager get catalogExercises =>
      $$CatalogExercisesTableTableManager(_db, _db.catalogExercises);
  $$ExerciseMusclesTableTableManager get exerciseMuscles =>
      $$ExerciseMusclesTableTableManager(_db, _db.exerciseMuscles);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$BodySnapshotsTableTableManager get bodySnapshots =>
      $$BodySnapshotsTableTableManager(_db, _db.bodySnapshots);
  $$WorkoutTemplatesTableTableManager get workoutTemplates =>
      $$WorkoutTemplatesTableTableManager(_db, _db.workoutTemplates);
  $$CyclesTableTableManager get cycles =>
      $$CyclesTableTableManager(_db, _db.cycles);
  $$ScheduleDaysTableTableManager get scheduleDays =>
      $$ScheduleDaysTableTableManager(_db, _db.scheduleDays);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$SessionSetsTableTableManager get sessionSets =>
      $$SessionSetsTableTableManager(_db, _db.sessionSets);
  $$CustomExercisesTableTableManager get customExercises =>
      $$CustomExercisesTableTableManager(_db, _db.customExercises);
}
