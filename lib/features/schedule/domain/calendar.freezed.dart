// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalendarDay {

 DateTime get date; bool get inMonth; bool get isToday; CalendarKind get kind; DayStatus? get status;// The workout the date is about; null is rest (or unknown).
 String? get workoutId;// The cycle row's own workout when [workoutId] differs (a swap).
 String? get plannedWorkoutId;// The record shown, and every record on the date (edge: two cycles).
 DayRecord? get record; List<DayRecord> get records;
/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarDayCopyWith<CalendarDay> get copyWith => _$CalendarDayCopyWithImpl<CalendarDay>(this as CalendarDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarDay&&(identical(other.date, date) || other.date == date)&&(identical(other.inMonth, inMonth) || other.inMonth == inMonth)&&(identical(other.isToday, isToday) || other.isToday == isToday)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.plannedWorkoutId, plannedWorkoutId) || other.plannedWorkoutId == plannedWorkoutId)&&(identical(other.record, record) || other.record == record)&&const DeepCollectionEquality().equals(other.records, records));
}


@override
int get hashCode => Object.hash(runtimeType,date,inMonth,isToday,kind,status,workoutId,plannedWorkoutId,record,const DeepCollectionEquality().hash(records));

@override
String toString() {
  return 'CalendarDay(date: $date, inMonth: $inMonth, isToday: $isToday, kind: $kind, status: $status, workoutId: $workoutId, plannedWorkoutId: $plannedWorkoutId, record: $record, records: $records)';
}


}

/// @nodoc
abstract mixin class $CalendarDayCopyWith<$Res>  {
  factory $CalendarDayCopyWith(CalendarDay value, $Res Function(CalendarDay) _then) = _$CalendarDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, bool inMonth, bool isToday, CalendarKind kind, DayStatus? status, String? workoutId, String? plannedWorkoutId, DayRecord? record, List<DayRecord> records
});


$DayRecordCopyWith<$Res>? get record;

}
/// @nodoc
class _$CalendarDayCopyWithImpl<$Res>
    implements $CalendarDayCopyWith<$Res> {
  _$CalendarDayCopyWithImpl(this._self, this._then);

  final CalendarDay _self;
  final $Res Function(CalendarDay) _then;

/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? inMonth = null,Object? isToday = null,Object? kind = null,Object? status = freezed,Object? workoutId = freezed,Object? plannedWorkoutId = freezed,Object? record = freezed,Object? records = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,inMonth: null == inMonth ? _self.inMonth : inMonth // ignore: cast_nullable_to_non_nullable
as bool,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CalendarKind,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DayStatus?,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,plannedWorkoutId: freezed == plannedWorkoutId ? _self.plannedWorkoutId : plannedWorkoutId // ignore: cast_nullable_to_non_nullable
as String?,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as DayRecord?,records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as List<DayRecord>,
  ));
}
/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DayRecordCopyWith<$Res>? get record {
    if (_self.record == null) {
    return null;
  }

  return $DayRecordCopyWith<$Res>(_self.record!, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalendarDay].
extension CalendarDayPatterns on CalendarDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarDay value)  $default,){
final _that = this;
switch (_that) {
case _CalendarDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarDay value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  bool inMonth,  bool isToday,  CalendarKind kind,  DayStatus? status,  String? workoutId,  String? plannedWorkoutId,  DayRecord? record,  List<DayRecord> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarDay() when $default != null:
return $default(_that.date,_that.inMonth,_that.isToday,_that.kind,_that.status,_that.workoutId,_that.plannedWorkoutId,_that.record,_that.records);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  bool inMonth,  bool isToday,  CalendarKind kind,  DayStatus? status,  String? workoutId,  String? plannedWorkoutId,  DayRecord? record,  List<DayRecord> records)  $default,) {final _that = this;
switch (_that) {
case _CalendarDay():
return $default(_that.date,_that.inMonth,_that.isToday,_that.kind,_that.status,_that.workoutId,_that.plannedWorkoutId,_that.record,_that.records);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  bool inMonth,  bool isToday,  CalendarKind kind,  DayStatus? status,  String? workoutId,  String? plannedWorkoutId,  DayRecord? record,  List<DayRecord> records)?  $default,) {final _that = this;
switch (_that) {
case _CalendarDay() when $default != null:
return $default(_that.date,_that.inMonth,_that.isToday,_that.kind,_that.status,_that.workoutId,_that.plannedWorkoutId,_that.record,_that.records);case _:
  return null;

}
}

}

/// @nodoc


class _CalendarDay implements CalendarDay {
  const _CalendarDay({required this.date, required this.inMonth, required this.isToday, required this.kind, this.status, this.workoutId, this.plannedWorkoutId, this.record, final  List<DayRecord> records = const <DayRecord>[]}): _records = records;
  

@override final  DateTime date;
@override final  bool inMonth;
@override final  bool isToday;
@override final  CalendarKind kind;
@override final  DayStatus? status;
// The workout the date is about; null is rest (or unknown).
@override final  String? workoutId;
// The cycle row's own workout when [workoutId] differs (a swap).
@override final  String? plannedWorkoutId;
// The record shown, and every record on the date (edge: two cycles).
@override final  DayRecord? record;
 final  List<DayRecord> _records;
@override@JsonKey() List<DayRecord> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}


/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarDayCopyWith<_CalendarDay> get copyWith => __$CalendarDayCopyWithImpl<_CalendarDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarDay&&(identical(other.date, date) || other.date == date)&&(identical(other.inMonth, inMonth) || other.inMonth == inMonth)&&(identical(other.isToday, isToday) || other.isToday == isToday)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.plannedWorkoutId, plannedWorkoutId) || other.plannedWorkoutId == plannedWorkoutId)&&(identical(other.record, record) || other.record == record)&&const DeepCollectionEquality().equals(other._records, _records));
}


@override
int get hashCode => Object.hash(runtimeType,date,inMonth,isToday,kind,status,workoutId,plannedWorkoutId,record,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'CalendarDay(date: $date, inMonth: $inMonth, isToday: $isToday, kind: $kind, status: $status, workoutId: $workoutId, plannedWorkoutId: $plannedWorkoutId, record: $record, records: $records)';
}


}

/// @nodoc
abstract mixin class _$CalendarDayCopyWith<$Res> implements $CalendarDayCopyWith<$Res> {
  factory _$CalendarDayCopyWith(_CalendarDay value, $Res Function(_CalendarDay) _then) = __$CalendarDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, bool inMonth, bool isToday, CalendarKind kind, DayStatus? status, String? workoutId, String? plannedWorkoutId, DayRecord? record, List<DayRecord> records
});


@override $DayRecordCopyWith<$Res>? get record;

}
/// @nodoc
class __$CalendarDayCopyWithImpl<$Res>
    implements _$CalendarDayCopyWith<$Res> {
  __$CalendarDayCopyWithImpl(this._self, this._then);

  final _CalendarDay _self;
  final $Res Function(_CalendarDay) _then;

/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? inMonth = null,Object? isToday = null,Object? kind = null,Object? status = freezed,Object? workoutId = freezed,Object? plannedWorkoutId = freezed,Object? record = freezed,Object? records = null,}) {
  return _then(_CalendarDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,inMonth: null == inMonth ? _self.inMonth : inMonth // ignore: cast_nullable_to_non_nullable
as bool,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CalendarKind,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DayStatus?,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,plannedWorkoutId: freezed == plannedWorkoutId ? _self.plannedWorkoutId : plannedWorkoutId // ignore: cast_nullable_to_non_nullable
as String?,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as DayRecord?,records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<DayRecord>,
  ));
}

/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DayRecordCopyWith<$Res>? get record {
    if (_self.record == null) {
    return null;
  }

  return $DayRecordCopyWith<$Res>(_self.record!, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}

// dart format on
