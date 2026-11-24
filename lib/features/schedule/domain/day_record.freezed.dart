// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayRecord {

 String get id; String get cycleId;// UTC midnight of the phone's calendar day, as Cycle.startDate.
 DateTime get date;// The cycle row the date was on; survives reorders (AC12).
 String get dayId; int get dayIndex; DayStatus get status;// The workout for this date when it is not the row's own.
 String? get workoutId;// moved: where it went; a moved-in planned record: where it came from.
 DateTime? get linkedDate;
/// Create a copy of DayRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayRecordCopyWith<DayRecord> get copyWith => _$DayRecordCopyWithImpl<DayRecord>(this as DayRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.date, date) || other.date == date)&&(identical(other.dayId, dayId) || other.dayId == dayId)&&(identical(other.dayIndex, dayIndex) || other.dayIndex == dayIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.linkedDate, linkedDate) || other.linkedDate == linkedDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,cycleId,date,dayId,dayIndex,status,workoutId,linkedDate);

@override
String toString() {
  return 'DayRecord(id: $id, cycleId: $cycleId, date: $date, dayId: $dayId, dayIndex: $dayIndex, status: $status, workoutId: $workoutId, linkedDate: $linkedDate)';
}


}

/// @nodoc
abstract mixin class $DayRecordCopyWith<$Res>  {
  factory $DayRecordCopyWith(DayRecord value, $Res Function(DayRecord) _then) = _$DayRecordCopyWithImpl;
@useResult
$Res call({
 String id, String cycleId, DateTime date, String dayId, int dayIndex, DayStatus status, String? workoutId, DateTime? linkedDate
});




}
/// @nodoc
class _$DayRecordCopyWithImpl<$Res>
    implements $DayRecordCopyWith<$Res> {
  _$DayRecordCopyWithImpl(this._self, this._then);

  final DayRecord _self;
  final $Res Function(DayRecord) _then;

/// Create a copy of DayRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cycleId = null,Object? date = null,Object? dayId = null,Object? dayIndex = null,Object? status = null,Object? workoutId = freezed,Object? linkedDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dayId: null == dayId ? _self.dayId : dayId // ignore: cast_nullable_to_non_nullable
as String,dayIndex: null == dayIndex ? _self.dayIndex : dayIndex // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DayStatus,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,linkedDate: freezed == linkedDate ? _self.linkedDate : linkedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DayRecord].
extension DayRecordPatterns on DayRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayRecord value)  $default,){
final _that = this;
switch (_that) {
case _DayRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayRecord value)?  $default,){
final _that = this;
switch (_that) {
case _DayRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String cycleId,  DateTime date,  String dayId,  int dayIndex,  DayStatus status,  String? workoutId,  DateTime? linkedDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayRecord() when $default != null:
return $default(_that.id,_that.cycleId,_that.date,_that.dayId,_that.dayIndex,_that.status,_that.workoutId,_that.linkedDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String cycleId,  DateTime date,  String dayId,  int dayIndex,  DayStatus status,  String? workoutId,  DateTime? linkedDate)  $default,) {final _that = this;
switch (_that) {
case _DayRecord():
return $default(_that.id,_that.cycleId,_that.date,_that.dayId,_that.dayIndex,_that.status,_that.workoutId,_that.linkedDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String cycleId,  DateTime date,  String dayId,  int dayIndex,  DayStatus status,  String? workoutId,  DateTime? linkedDate)?  $default,) {final _that = this;
switch (_that) {
case _DayRecord() when $default != null:
return $default(_that.id,_that.cycleId,_that.date,_that.dayId,_that.dayIndex,_that.status,_that.workoutId,_that.linkedDate);case _:
  return null;

}
}

}

/// @nodoc


class _DayRecord implements DayRecord {
  const _DayRecord({required this.id, required this.cycleId, required this.date, required this.dayId, required this.dayIndex, required this.status, this.workoutId, this.linkedDate});
  

@override final  String id;
@override final  String cycleId;
// UTC midnight of the phone's calendar day, as Cycle.startDate.
@override final  DateTime date;
// The cycle row the date was on; survives reorders (AC12).
@override final  String dayId;
@override final  int dayIndex;
@override final  DayStatus status;
// The workout for this date when it is not the row's own.
@override final  String? workoutId;
// moved: where it went; a moved-in planned record: where it came from.
@override final  DateTime? linkedDate;

/// Create a copy of DayRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayRecordCopyWith<_DayRecord> get copyWith => __$DayRecordCopyWithImpl<_DayRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&(identical(other.date, date) || other.date == date)&&(identical(other.dayId, dayId) || other.dayId == dayId)&&(identical(other.dayIndex, dayIndex) || other.dayIndex == dayIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.linkedDate, linkedDate) || other.linkedDate == linkedDate));
}


@override
int get hashCode => Object.hash(runtimeType,id,cycleId,date,dayId,dayIndex,status,workoutId,linkedDate);

@override
String toString() {
  return 'DayRecord(id: $id, cycleId: $cycleId, date: $date, dayId: $dayId, dayIndex: $dayIndex, status: $status, workoutId: $workoutId, linkedDate: $linkedDate)';
}


}

/// @nodoc
abstract mixin class _$DayRecordCopyWith<$Res> implements $DayRecordCopyWith<$Res> {
  factory _$DayRecordCopyWith(_DayRecord value, $Res Function(_DayRecord) _then) = __$DayRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String cycleId, DateTime date, String dayId, int dayIndex, DayStatus status, String? workoutId, DateTime? linkedDate
});




}
/// @nodoc
class __$DayRecordCopyWithImpl<$Res>
    implements _$DayRecordCopyWith<$Res> {
  __$DayRecordCopyWithImpl(this._self, this._then);

  final _DayRecord _self;
  final $Res Function(_DayRecord) _then;

/// Create a copy of DayRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cycleId = null,Object? date = null,Object? dayId = null,Object? dayIndex = null,Object? status = null,Object? workoutId = freezed,Object? linkedDate = freezed,}) {
  return _then(_DayRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dayId: null == dayId ? _self.dayId : dayId // ignore: cast_nullable_to_non_nullable
as String,dayIndex: null == dayIndex ? _self.dayIndex : dayIndex // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DayStatus,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,linkedDate: freezed == linkedDate ? _self.linkedDate : linkedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
