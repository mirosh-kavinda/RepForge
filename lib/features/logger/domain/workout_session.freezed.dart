// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionExercise {

 String get id; String get exerciseId; String get name; int get plannedSets; TargetKind get kind; int get repMin; int get repMax; int get seconds; double? get targetKg;// "Body only" equipment: 0 kg reads Bodyweight (edge).
 bool get bodyweight;
/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionExerciseCopyWith<SessionExercise> get copyWith => _$SessionExerciseCopyWithImpl<SessionExercise>(this as SessionExercise, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.plannedSets, plannedSets) || other.plannedSets == plannedSets)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.repMin, repMin) || other.repMin == repMin)&&(identical(other.repMax, repMax) || other.repMax == repMax)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.targetKg, targetKg) || other.targetKg == targetKg)&&(identical(other.bodyweight, bodyweight) || other.bodyweight == bodyweight));
}


@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,name,plannedSets,kind,repMin,repMax,seconds,targetKg,bodyweight);

@override
String toString() {
  return 'SessionExercise(id: $id, exerciseId: $exerciseId, name: $name, plannedSets: $plannedSets, kind: $kind, repMin: $repMin, repMax: $repMax, seconds: $seconds, targetKg: $targetKg, bodyweight: $bodyweight)';
}


}

/// @nodoc
abstract mixin class $SessionExerciseCopyWith<$Res>  {
  factory $SessionExerciseCopyWith(SessionExercise value, $Res Function(SessionExercise) _then) = _$SessionExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String exerciseId, String name, int plannedSets, TargetKind kind, int repMin, int repMax, int seconds, double? targetKg, bool bodyweight
});




}
/// @nodoc
class _$SessionExerciseCopyWithImpl<$Res>
    implements $SessionExerciseCopyWith<$Res> {
  _$SessionExerciseCopyWithImpl(this._self, this._then);

  final SessionExercise _self;
  final $Res Function(SessionExercise) _then;

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? exerciseId = null,Object? name = null,Object? plannedSets = null,Object? kind = null,Object? repMin = null,Object? repMax = null,Object? seconds = null,Object? targetKg = freezed,Object? bodyweight = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,plannedSets: null == plannedSets ? _self.plannedSets : plannedSets // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TargetKind,repMin: null == repMin ? _self.repMin : repMin // ignore: cast_nullable_to_non_nullable
as int,repMax: null == repMax ? _self.repMax : repMax // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,targetKg: freezed == targetKg ? _self.targetKg : targetKg // ignore: cast_nullable_to_non_nullable
as double?,bodyweight: null == bodyweight ? _self.bodyweight : bodyweight // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionExercise].
extension SessionExercisePatterns on SessionExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionExercise value)  $default,){
final _that = this;
switch (_that) {
case _SessionExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionExercise value)?  $default,){
final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String name,  int plannedSets,  TargetKind kind,  int repMin,  int repMax,  int seconds,  double? targetKg,  bool bodyweight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.name,_that.plannedSets,_that.kind,_that.repMin,_that.repMax,_that.seconds,_that.targetKg,_that.bodyweight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String exerciseId,  String name,  int plannedSets,  TargetKind kind,  int repMin,  int repMax,  int seconds,  double? targetKg,  bool bodyweight)  $default,) {final _that = this;
switch (_that) {
case _SessionExercise():
return $default(_that.id,_that.exerciseId,_that.name,_that.plannedSets,_that.kind,_that.repMin,_that.repMax,_that.seconds,_that.targetKg,_that.bodyweight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String exerciseId,  String name,  int plannedSets,  TargetKind kind,  int repMin,  int repMax,  int seconds,  double? targetKg,  bool bodyweight)?  $default,) {final _that = this;
switch (_that) {
case _SessionExercise() when $default != null:
return $default(_that.id,_that.exerciseId,_that.name,_that.plannedSets,_that.kind,_that.repMin,_that.repMax,_that.seconds,_that.targetKg,_that.bodyweight);case _:
  return null;

}
}

}

/// @nodoc


class _SessionExercise implements SessionExercise {
  const _SessionExercise({required this.id, required this.exerciseId, required this.name, this.plannedSets = 3, this.kind = TargetKind.reps, this.repMin = 8, this.repMax = 12, this.seconds = 45, this.targetKg, this.bodyweight = false});
  

@override final  String id;
@override final  String exerciseId;
@override final  String name;
@override@JsonKey() final  int plannedSets;
@override@JsonKey() final  TargetKind kind;
@override@JsonKey() final  int repMin;
@override@JsonKey() final  int repMax;
@override@JsonKey() final  int seconds;
@override final  double? targetKg;
// "Body only" equipment: 0 kg reads Bodyweight (edge).
@override@JsonKey() final  bool bodyweight;

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionExerciseCopyWith<_SessionExercise> get copyWith => __$SessionExerciseCopyWithImpl<_SessionExercise>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.name, name) || other.name == name)&&(identical(other.plannedSets, plannedSets) || other.plannedSets == plannedSets)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.repMin, repMin) || other.repMin == repMin)&&(identical(other.repMax, repMax) || other.repMax == repMax)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.targetKg, targetKg) || other.targetKg == targetKg)&&(identical(other.bodyweight, bodyweight) || other.bodyweight == bodyweight));
}


@override
int get hashCode => Object.hash(runtimeType,id,exerciseId,name,plannedSets,kind,repMin,repMax,seconds,targetKg,bodyweight);

@override
String toString() {
  return 'SessionExercise(id: $id, exerciseId: $exerciseId, name: $name, plannedSets: $plannedSets, kind: $kind, repMin: $repMin, repMax: $repMax, seconds: $seconds, targetKg: $targetKg, bodyweight: $bodyweight)';
}


}

/// @nodoc
abstract mixin class _$SessionExerciseCopyWith<$Res> implements $SessionExerciseCopyWith<$Res> {
  factory _$SessionExerciseCopyWith(_SessionExercise value, $Res Function(_SessionExercise) _then) = __$SessionExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String exerciseId, String name, int plannedSets, TargetKind kind, int repMin, int repMax, int seconds, double? targetKg, bool bodyweight
});




}
/// @nodoc
class __$SessionExerciseCopyWithImpl<$Res>
    implements _$SessionExerciseCopyWith<$Res> {
  __$SessionExerciseCopyWithImpl(this._self, this._then);

  final _SessionExercise _self;
  final $Res Function(_SessionExercise) _then;

/// Create a copy of SessionExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? exerciseId = null,Object? name = null,Object? plannedSets = null,Object? kind = null,Object? repMin = null,Object? repMax = null,Object? seconds = null,Object? targetKg = freezed,Object? bodyweight = null,}) {
  return _then(_SessionExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,plannedSets: null == plannedSets ? _self.plannedSets : plannedSets // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TargetKind,repMin: null == repMin ? _self.repMin : repMin // ignore: cast_nullable_to_non_nullable
as int,repMax: null == repMax ? _self.repMax : repMax // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,targetKg: freezed == targetKg ? _self.targetKg : targetKg // ignore: cast_nullable_to_non_nullable
as double?,bodyweight: null == bodyweight ? _self.bodyweight : bodyweight // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$LoggedSet {

 String get id;// The SessionExercise row it belongs to.
 String get rowId; String get exerciseId;// 1-based within its row.
 int get setNo; double get kg; int? get reps; int? get seconds;// LOG-02: stored at Finish; worked out on screen while in progress.
 bool get isPr;
/// Create a copy of LoggedSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoggedSetCopyWith<LoggedSet> get copyWith => _$LoggedSetCopyWithImpl<LoggedSet>(this as LoggedSet, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoggedSet&&(identical(other.id, id) || other.id == id)&&(identical(other.rowId, rowId) || other.rowId == rowId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.setNo, setNo) || other.setNo == setNo)&&(identical(other.kg, kg) || other.kg == kg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.isPr, isPr) || other.isPr == isPr));
}


@override
int get hashCode => Object.hash(runtimeType,id,rowId,exerciseId,setNo,kg,reps,seconds,isPr);

@override
String toString() {
  return 'LoggedSet(id: $id, rowId: $rowId, exerciseId: $exerciseId, setNo: $setNo, kg: $kg, reps: $reps, seconds: $seconds, isPr: $isPr)';
}


}

/// @nodoc
abstract mixin class $LoggedSetCopyWith<$Res>  {
  factory $LoggedSetCopyWith(LoggedSet value, $Res Function(LoggedSet) _then) = _$LoggedSetCopyWithImpl;
@useResult
$Res call({
 String id, String rowId, String exerciseId, int setNo, double kg, int? reps, int? seconds, bool isPr
});




}
/// @nodoc
class _$LoggedSetCopyWithImpl<$Res>
    implements $LoggedSetCopyWith<$Res> {
  _$LoggedSetCopyWithImpl(this._self, this._then);

  final LoggedSet _self;
  final $Res Function(LoggedSet) _then;

/// Create a copy of LoggedSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rowId = null,Object? exerciseId = null,Object? setNo = null,Object? kg = null,Object? reps = freezed,Object? seconds = freezed,Object? isPr = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rowId: null == rowId ? _self.rowId : rowId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,setNo: null == setNo ? _self.setNo : setNo // ignore: cast_nullable_to_non_nullable
as int,kg: null == kg ? _self.kg : kg // ignore: cast_nullable_to_non_nullable
as double,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,seconds: freezed == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int?,isPr: null == isPr ? _self.isPr : isPr // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LoggedSet].
extension LoggedSetPatterns on LoggedSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoggedSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoggedSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoggedSet value)  $default,){
final _that = this;
switch (_that) {
case _LoggedSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoggedSet value)?  $default,){
final _that = this;
switch (_that) {
case _LoggedSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rowId,  String exerciseId,  int setNo,  double kg,  int? reps,  int? seconds,  bool isPr)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoggedSet() when $default != null:
return $default(_that.id,_that.rowId,_that.exerciseId,_that.setNo,_that.kg,_that.reps,_that.seconds,_that.isPr);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rowId,  String exerciseId,  int setNo,  double kg,  int? reps,  int? seconds,  bool isPr)  $default,) {final _that = this;
switch (_that) {
case _LoggedSet():
return $default(_that.id,_that.rowId,_that.exerciseId,_that.setNo,_that.kg,_that.reps,_that.seconds,_that.isPr);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rowId,  String exerciseId,  int setNo,  double kg,  int? reps,  int? seconds,  bool isPr)?  $default,) {final _that = this;
switch (_that) {
case _LoggedSet() when $default != null:
return $default(_that.id,_that.rowId,_that.exerciseId,_that.setNo,_that.kg,_that.reps,_that.seconds,_that.isPr);case _:
  return null;

}
}

}

/// @nodoc


class _LoggedSet implements LoggedSet {
  const _LoggedSet({required this.id, required this.rowId, required this.exerciseId, required this.setNo, required this.kg, this.reps, this.seconds, this.isPr = false});
  

@override final  String id;
// The SessionExercise row it belongs to.
@override final  String rowId;
@override final  String exerciseId;
// 1-based within its row.
@override final  int setNo;
@override final  double kg;
@override final  int? reps;
@override final  int? seconds;
// LOG-02: stored at Finish; worked out on screen while in progress.
@override@JsonKey() final  bool isPr;

/// Create a copy of LoggedSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoggedSetCopyWith<_LoggedSet> get copyWith => __$LoggedSetCopyWithImpl<_LoggedSet>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoggedSet&&(identical(other.id, id) || other.id == id)&&(identical(other.rowId, rowId) || other.rowId == rowId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.setNo, setNo) || other.setNo == setNo)&&(identical(other.kg, kg) || other.kg == kg)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.isPr, isPr) || other.isPr == isPr));
}


@override
int get hashCode => Object.hash(runtimeType,id,rowId,exerciseId,setNo,kg,reps,seconds,isPr);

@override
String toString() {
  return 'LoggedSet(id: $id, rowId: $rowId, exerciseId: $exerciseId, setNo: $setNo, kg: $kg, reps: $reps, seconds: $seconds, isPr: $isPr)';
}


}

/// @nodoc
abstract mixin class _$LoggedSetCopyWith<$Res> implements $LoggedSetCopyWith<$Res> {
  factory _$LoggedSetCopyWith(_LoggedSet value, $Res Function(_LoggedSet) _then) = __$LoggedSetCopyWithImpl;
@override @useResult
$Res call({
 String id, String rowId, String exerciseId, int setNo, double kg, int? reps, int? seconds, bool isPr
});




}
/// @nodoc
class __$LoggedSetCopyWithImpl<$Res>
    implements _$LoggedSetCopyWith<$Res> {
  __$LoggedSetCopyWithImpl(this._self, this._then);

  final _LoggedSet _self;
  final $Res Function(_LoggedSet) _then;

/// Create a copy of LoggedSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rowId = null,Object? exerciseId = null,Object? setNo = null,Object? kg = null,Object? reps = freezed,Object? seconds = freezed,Object? isPr = null,}) {
  return _then(_LoggedSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rowId: null == rowId ? _self.rowId : rowId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,setNo: null == setNo ? _self.setNo : setNo // ignore: cast_nullable_to_non_nullable
as int,kg: null == kg ? _self.kg : kg // ignore: cast_nullable_to_non_nullable
as double,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,seconds: freezed == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int?,isPr: null == isPr ? _self.isPr : isPr // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$WorkoutSession {

 String get id; String get name; List<SessionExercise> get exercises; DateTime get date; DateTime get startedAt; List<LoggedSet> get sets; String? get templateId;// The cycle day it was started for; Finish marks it done (AC9).
 String? get cycleId; String? get dayId; int? get dayIndex; DateTime? get endedAt;
/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSessionCopyWith<WorkoutSession> get copyWith => _$WorkoutSessionCopyWithImpl<WorkoutSession>(this as WorkoutSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSession&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.date, date) || other.date == date)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other.sets, sets)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.dayId, dayId) || other.dayId == dayId)&&(identical(other.dayIndex, dayIndex) || other.dayIndex == dayIndex)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(exercises),date,startedAt,const DeepCollectionEquality().hash(sets),templateId,cycleId,dayId,dayIndex,endedAt);

@override
String toString() {
  return 'WorkoutSession(id: $id, name: $name, exercises: $exercises, date: $date, startedAt: $startedAt, sets: $sets, templateId: $templateId, cycleId: $cycleId, dayId: $dayId, dayIndex: $dayIndex, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class $WorkoutSessionCopyWith<$Res>  {
  factory $WorkoutSessionCopyWith(WorkoutSession value, $Res Function(WorkoutSession) _then) = _$WorkoutSessionCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<SessionExercise> exercises, DateTime date, DateTime startedAt, List<LoggedSet> sets, String? templateId, String? cycleId, String? dayId, int? dayIndex, DateTime? endedAt
});




}
/// @nodoc
class _$WorkoutSessionCopyWithImpl<$Res>
    implements $WorkoutSessionCopyWith<$Res> {
  _$WorkoutSessionCopyWithImpl(this._self, this._then);

  final WorkoutSession _self;
  final $Res Function(WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? exercises = null,Object? date = null,Object? startedAt = null,Object? sets = null,Object? templateId = freezed,Object? cycleId = freezed,Object? dayId = freezed,Object? dayIndex = freezed,Object? endedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<LoggedSet>,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,cycleId: freezed == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String?,dayId: freezed == dayId ? _self.dayId : dayId // ignore: cast_nullable_to_non_nullable
as String?,dayIndex: freezed == dayIndex ? _self.dayIndex : dayIndex // ignore: cast_nullable_to_non_nullable
as int?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSession].
extension WorkoutSessionPatterns on WorkoutSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSession value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSession value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<SessionExercise> exercises,  DateTime date,  DateTime startedAt,  List<LoggedSet> sets,  String? templateId,  String? cycleId,  String? dayId,  int? dayIndex,  DateTime? endedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.name,_that.exercises,_that.date,_that.startedAt,_that.sets,_that.templateId,_that.cycleId,_that.dayId,_that.dayIndex,_that.endedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<SessionExercise> exercises,  DateTime date,  DateTime startedAt,  List<LoggedSet> sets,  String? templateId,  String? cycleId,  String? dayId,  int? dayIndex,  DateTime? endedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession():
return $default(_that.id,_that.name,_that.exercises,_that.date,_that.startedAt,_that.sets,_that.templateId,_that.cycleId,_that.dayId,_that.dayIndex,_that.endedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<SessionExercise> exercises,  DateTime date,  DateTime startedAt,  List<LoggedSet> sets,  String? templateId,  String? cycleId,  String? dayId,  int? dayIndex,  DateTime? endedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSession() when $default != null:
return $default(_that.id,_that.name,_that.exercises,_that.date,_that.startedAt,_that.sets,_that.templateId,_that.cycleId,_that.dayId,_that.dayIndex,_that.endedAt);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutSession extends WorkoutSession {
  const _WorkoutSession({required this.id, required this.name, required final  List<SessionExercise> exercises, required this.date, required this.startedAt, final  List<LoggedSet> sets = const <LoggedSet>[], this.templateId, this.cycleId, this.dayId, this.dayIndex, this.endedAt}): _exercises = exercises,_sets = sets,super._();
  

@override final  String id;
@override final  String name;
 final  List<SessionExercise> _exercises;
@override List<SessionExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override final  DateTime date;
@override final  DateTime startedAt;
 final  List<LoggedSet> _sets;
@override@JsonKey() List<LoggedSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}

@override final  String? templateId;
// The cycle day it was started for; Finish marks it done (AC9).
@override final  String? cycleId;
@override final  String? dayId;
@override final  int? dayIndex;
@override final  DateTime? endedAt;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSessionCopyWith<_WorkoutSession> get copyWith => __$WorkoutSessionCopyWithImpl<_WorkoutSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSession&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.date, date) || other.date == date)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other._sets, _sets)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.dayId, dayId) || other.dayId == dayId)&&(identical(other.dayIndex, dayIndex) || other.dayIndex == dayIndex)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_exercises),date,startedAt,const DeepCollectionEquality().hash(_sets),templateId,cycleId,dayId,dayIndex,endedAt);

@override
String toString() {
  return 'WorkoutSession(id: $id, name: $name, exercises: $exercises, date: $date, startedAt: $startedAt, sets: $sets, templateId: $templateId, cycleId: $cycleId, dayId: $dayId, dayIndex: $dayIndex, endedAt: $endedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSessionCopyWith<$Res> implements $WorkoutSessionCopyWith<$Res> {
  factory _$WorkoutSessionCopyWith(_WorkoutSession value, $Res Function(_WorkoutSession) _then) = __$WorkoutSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<SessionExercise> exercises, DateTime date, DateTime startedAt, List<LoggedSet> sets, String? templateId, String? cycleId, String? dayId, int? dayIndex, DateTime? endedAt
});




}
/// @nodoc
class __$WorkoutSessionCopyWithImpl<$Res>
    implements _$WorkoutSessionCopyWith<$Res> {
  __$WorkoutSessionCopyWithImpl(this._self, this._then);

  final _WorkoutSession _self;
  final $Res Function(_WorkoutSession) _then;

/// Create a copy of WorkoutSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? exercises = null,Object? date = null,Object? startedAt = null,Object? sets = null,Object? templateId = freezed,Object? cycleId = freezed,Object? dayId = freezed,Object? dayIndex = freezed,Object? endedAt = freezed,}) {
  return _then(_WorkoutSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SessionExercise>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<LoggedSet>,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,cycleId: freezed == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String?,dayId: freezed == dayId ? _self.dayId : dayId // ignore: cast_nullable_to_non_nullable
as String?,dayIndex: freezed == dayIndex ? _self.dayIndex : dayIndex // ignore: cast_nullable_to_non_nullable
as int?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
