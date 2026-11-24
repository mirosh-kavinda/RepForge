// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateExercise {

// Distinct per row, so the same exercise can appear twice.
 String get id; String get exerciseId; int get sets; TargetKind get kind; int get repMin; int get repMax; int get seconds; double? get targetKg; int get restSec; String? get superset;
/// Create a copy of TemplateExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateExerciseCopyWith<TemplateExercise> get copyWith => _$TemplateExerciseCopyWithImpl<TemplateExercise>(this as TemplateExercise, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.repMin, repMin) || other.repMin == repMin)&&(identical(other.repMax, repMax) || other.repMax == repMax)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.targetKg, targetKg) || other.targetKg == targetKg)&&(identical(other.restSec, restSec) || other.restSec == restSec)&&(identical(other.superset, superset) || other.superset == superset));
}


@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,sets,kind,repMin,repMax,seconds,targetKg,restSec,superset);

@override
String toString() {
  return 'TemplateExercise(id: $id, exerciseId: $exerciseId, sets: $sets, kind: $kind, repMin: $repMin, repMax: $repMax, seconds: $seconds, targetKg: $targetKg, restSec: $restSec, superset: $superset)';
}


}

/// @nodoc
abstract mixin class $TemplateExerciseCopyWith<$Res>  {
  factory $TemplateExerciseCopyWith(TemplateExercise value, $Res Function(TemplateExercise) _then) = _$TemplateExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, int sets, TargetKind kind, int repMin, int repMax, int seconds, double? targetKg, int restSec, String? superset
});




}
/// @nodoc
class _$TemplateExerciseCopyWithImpl<$Res>
    implements $TemplateExerciseCopyWith<$Res> {
  _$TemplateExerciseCopyWithImpl(this._self, this._then);

  final TemplateExercise _self;
  final $Res Function(TemplateExercise) _then;

/// Create a copy of TemplateExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? sets = null,Object? kind = null,Object? repMin = null,Object? repMax = null,Object? seconds = null,Object? targetKg = freezed,Object? restSec = null,Object? superset = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TargetKind,repMin: null == repMin ? _self.repMin : repMin // ignore: cast_nullable_to_non_nullable
as int,repMax: null == repMax ? _self.repMax : repMax // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,targetKg: freezed == targetKg ? _self.targetKg : targetKg // ignore: cast_nullable_to_non_nullable
as double?,restSec: null == restSec ? _self.restSec : restSec // ignore: cast_nullable_to_non_nullable
as int,superset: freezed == superset ? _self.superset : superset // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateExercise].
extension TemplateExercisePatterns on TemplateExercise {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateExercise() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateExercise value)  $default,){
final _that = this;
switch (_that) {
case _TemplateExercise():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateExercise value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateExercise() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int sets,  TargetKind kind,  int repMin,  int repMax,  int seconds,  double? targetKg,  int restSec,  String? superset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.sets,_that.kind,_that.repMin,_that.repMax,_that.seconds,_that.targetKg,_that.restSec,_that.superset);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  int sets,  TargetKind kind,  int repMin,  int repMax,  int seconds,  double? targetKg,  int restSec,  String? superset)  $default,) {final _that = this;
switch (_that) {
case _TemplateExercise():
return $default(_that.id,_that.exerciseId,_that.sets,_that.kind,_that.repMin,_that.repMax,_that.seconds,_that.targetKg,_that.restSec,_that.superset);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  int sets,  TargetKind kind,  int repMin,  int repMax,  int seconds,  double? targetKg,  int restSec,  String? superset)?  $default,) {final _that = this;
switch (_that) {
case _TemplateExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.sets,_that.kind,_that.repMin,_that.repMax,_that.seconds,_that.targetKg,_that.restSec,_that.superset);case _:
  return null;

}
}

}

/// @nodoc


class _TemplateExercise implements TemplateExercise {
  const _TemplateExercise({required this.id, required this.exerciseId, this.sets = 3, this.kind = TargetKind.reps, this.repMin = 8, this.repMax = 12, this.seconds = 45, this.targetKg, this.restSec = 120, this.superset});
  

// Distinct per row, so the same exercise can appear twice.
@override final  String id;
@override final  String exerciseId;
@override@JsonKey() final  int sets;
@override@JsonKey() final  TargetKind kind;
@override@JsonKey() final  int repMin;
@override@JsonKey() final  int repMax;
@override@JsonKey() final  int seconds;
@override final  double? targetKg;
@override@JsonKey() final  int restSec;
@override final  String? superset;

/// Create a copy of TemplateExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateExerciseCopyWith<_TemplateExercise> get copyWith => __$TemplateExerciseCopyWithImpl<_TemplateExercise>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.repMin, repMin) || other.repMin == repMin)&&(identical(other.repMax, repMax) || other.repMax == repMax)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.targetKg, targetKg) || other.targetKg == targetKg)&&(identical(other.restSec, restSec) || other.restSec == restSec)&&(identical(other.superset, superset) || other.superset == superset));
}


@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,sets,kind,repMin,repMax,seconds,targetKg,restSec,superset);

@override
String toString() {
  return 'TemplateExercise(id: $id, exerciseId: $exerciseId, sets: $sets, kind: $kind, repMin: $repMin, repMax: $repMax, seconds: $seconds, targetKg: $targetKg, restSec: $restSec, superset: $superset)';
}


}

/// @nodoc
abstract mixin class _$TemplateExerciseCopyWith<$Res> implements $TemplateExerciseCopyWith<$Res> {
  factory _$TemplateExerciseCopyWith(_TemplateExercise value, $Res Function(_TemplateExercise) _then) = __$TemplateExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, int sets, TargetKind kind, int repMin, int repMax, int seconds, double? targetKg, int restSec, String? superset
});




}
/// @nodoc
class __$TemplateExerciseCopyWithImpl<$Res>
    implements _$TemplateExerciseCopyWith<$Res> {
  __$TemplateExerciseCopyWithImpl(this._self, this._then);

  final _TemplateExercise _self;
  final $Res Function(_TemplateExercise) _then;

/// Create a copy of TemplateExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? sets = null,Object? kind = null,Object? repMin = null,Object? repMax = null,Object? seconds = null,Object? targetKg = freezed,Object? restSec = null,Object? superset = freezed,}) {
  return _then(_TemplateExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TargetKind,repMin: null == repMin ? _self.repMin : repMin // ignore: cast_nullable_to_non_nullable
as int,repMax: null == repMax ? _self.repMax : repMax // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,targetKg: freezed == targetKg ? _self.targetKg : targetKg // ignore: cast_nullable_to_non_nullable
as double?,restSec: null == restSec ? _self.restSec : restSec // ignore: cast_nullable_to_non_nullable
as int,superset: freezed == superset ? _self.superset : superset // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$WorkoutTemplate {

 String get id; String get name; List<TemplateExercise> get exercises;
/// Create a copy of WorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutTemplateCopyWith<WorkoutTemplate> get copyWith => _$WorkoutTemplateCopyWithImpl<WorkoutTemplate>(this as WorkoutTemplate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.exercises, exercises));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(exercises));

@override
String toString() {
  return 'WorkoutTemplate(id: $id, name: $name, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class $WorkoutTemplateCopyWith<$Res>  {
  factory $WorkoutTemplateCopyWith(WorkoutTemplate value, $Res Function(WorkoutTemplate) _then) = _$WorkoutTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<TemplateExercise> exercises
});




}
/// @nodoc
class _$WorkoutTemplateCopyWithImpl<$Res>
    implements $WorkoutTemplateCopyWith<$Res> {
  _$WorkoutTemplateCopyWithImpl(this._self, this._then);

  final WorkoutTemplate _self;
  final $Res Function(WorkoutTemplate) _then;

/// Create a copy of WorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? exercises = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<TemplateExercise>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutTemplate].
extension WorkoutTemplatePatterns on WorkoutTemplate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutTemplate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutTemplate value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutTemplate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutTemplate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<TemplateExercise> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutTemplate() when $default != null:
return $default(_that.id,_that.name,_that.exercises);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<TemplateExercise> exercises)  $default,) {final _that = this;
switch (_that) {
case _WorkoutTemplate():
return $default(_that.id,_that.name,_that.exercises);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<TemplateExercise> exercises)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutTemplate() when $default != null:
return $default(_that.id,_that.name,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutTemplate implements WorkoutTemplate {
  const _WorkoutTemplate({required this.id, required this.name, required final  List<TemplateExercise> exercises}): _exercises = exercises;
  

@override final  String id;
@override final  String name;
 final  List<TemplateExercise> _exercises;
@override List<TemplateExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


/// Create a copy of WorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutTemplateCopyWith<_WorkoutTemplate> get copyWith => __$WorkoutTemplateCopyWithImpl<_WorkoutTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._exercises, _exercises));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_exercises));

@override
String toString() {
  return 'WorkoutTemplate(id: $id, name: $name, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$WorkoutTemplateCopyWith<$Res> implements $WorkoutTemplateCopyWith<$Res> {
  factory _$WorkoutTemplateCopyWith(_WorkoutTemplate value, $Res Function(_WorkoutTemplate) _then) = __$WorkoutTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<TemplateExercise> exercises
});




}
/// @nodoc
class __$WorkoutTemplateCopyWithImpl<$Res>
    implements _$WorkoutTemplateCopyWith<$Res> {
  __$WorkoutTemplateCopyWithImpl(this._self, this._then);

  final _WorkoutTemplate _self;
  final $Res Function(_WorkoutTemplate) _then;

/// Create a copy of WorkoutTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? exercises = null,}) {
  return _then(_WorkoutTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<TemplateExercise>,
  ));
}


}

// dart format on
