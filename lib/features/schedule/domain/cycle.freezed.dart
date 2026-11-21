// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CycleDay {

 String get id; String? get workoutId;
/// Create a copy of CycleDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleDayCopyWith<CycleDay> get copyWith => _$CycleDayCopyWithImpl<CycleDay>(this as CycleDay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleDay&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId));
}


@override
int get hashCode => Object.hash(runtimeType,id,workoutId);

@override
String toString() {
  return 'CycleDay(id: $id, workoutId: $workoutId)';
}


}

/// @nodoc
abstract mixin class $CycleDayCopyWith<$Res>  {
  factory $CycleDayCopyWith(CycleDay value, $Res Function(CycleDay) _then) = _$CycleDayCopyWithImpl;
@useResult
$Res call({
 String id, String? workoutId
});




}
/// @nodoc
class _$CycleDayCopyWithImpl<$Res>
    implements $CycleDayCopyWith<$Res> {
  _$CycleDayCopyWithImpl(this._self, this._then);

  final CycleDay _self;
  final $Res Function(CycleDay) _then;

/// Create a copy of CycleDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CycleDay].
extension CycleDayPatterns on CycleDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleDay value)  $default,){
final _that = this;
switch (_that) {
case _CycleDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleDay value)?  $default,){
final _that = this;
switch (_that) {
case _CycleDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? workoutId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleDay() when $default != null:
return $default(_that.id,_that.workoutId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? workoutId)  $default,) {final _that = this;
switch (_that) {
case _CycleDay():
return $default(_that.id,_that.workoutId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? workoutId)?  $default,) {final _that = this;
switch (_that) {
case _CycleDay() when $default != null:
return $default(_that.id,_that.workoutId);case _:
  return null;

}
}

}

/// @nodoc


class _CycleDay extends CycleDay {
  const _CycleDay({required this.id, this.workoutId}): super._();
  

@override final  String id;
@override final  String? workoutId;

/// Create a copy of CycleDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleDayCopyWith<_CycleDay> get copyWith => __$CycleDayCopyWithImpl<_CycleDay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleDay&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId));
}


@override
int get hashCode => Object.hash(runtimeType,id,workoutId);

@override
String toString() {
  return 'CycleDay(id: $id, workoutId: $workoutId)';
}


}

/// @nodoc
abstract mixin class _$CycleDayCopyWith<$Res> implements $CycleDayCopyWith<$Res> {
  factory _$CycleDayCopyWith(_CycleDay value, $Res Function(_CycleDay) _then) = __$CycleDayCopyWithImpl;
@override @useResult
$Res call({
 String id, String? workoutId
});




}
/// @nodoc
class __$CycleDayCopyWithImpl<$Res>
    implements _$CycleDayCopyWith<$Res> {
  __$CycleDayCopyWithImpl(this._self, this._then);

  final _CycleDay _self;
  final $Res Function(_CycleDay) _then;

/// Create a copy of CycleDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutId = freezed,}) {
  return _then(_CycleDay(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Cycle {

 String get id; String get name; List<CycleDay> get days; bool get isActive;// UTC midnight of the phone's calendar day the anchor applies to.
 DateTime get startDate; int get startDayIndex;
/// Create a copy of Cycle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleCopyWith<Cycle> get copyWith => _$CycleCopyWithImpl<Cycle>(this as Cycle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cycle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startDayIndex, startDayIndex) || other.startDayIndex == startDayIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(days),isActive,startDate,startDayIndex);

@override
String toString() {
  return 'Cycle(id: $id, name: $name, days: $days, isActive: $isActive, startDate: $startDate, startDayIndex: $startDayIndex)';
}


}

/// @nodoc
abstract mixin class $CycleCopyWith<$Res>  {
  factory $CycleCopyWith(Cycle value, $Res Function(Cycle) _then) = _$CycleCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<CycleDay> days, bool isActive, DateTime startDate, int startDayIndex
});




}
/// @nodoc
class _$CycleCopyWithImpl<$Res>
    implements $CycleCopyWith<$Res> {
  _$CycleCopyWithImpl(this._self, this._then);

  final Cycle _self;
  final $Res Function(Cycle) _then;

/// Create a copy of Cycle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? days = null,Object? isActive = null,Object? startDate = null,Object? startDayIndex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<CycleDay>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,startDayIndex: null == startDayIndex ? _self.startDayIndex : startDayIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Cycle].
extension CyclePatterns on Cycle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cycle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cycle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cycle value)  $default,){
final _that = this;
switch (_that) {
case _Cycle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cycle value)?  $default,){
final _that = this;
switch (_that) {
case _Cycle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<CycleDay> days,  bool isActive,  DateTime startDate,  int startDayIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cycle() when $default != null:
return $default(_that.id,_that.name,_that.days,_that.isActive,_that.startDate,_that.startDayIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<CycleDay> days,  bool isActive,  DateTime startDate,  int startDayIndex)  $default,) {final _that = this;
switch (_that) {
case _Cycle():
return $default(_that.id,_that.name,_that.days,_that.isActive,_that.startDate,_that.startDayIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<CycleDay> days,  bool isActive,  DateTime startDate,  int startDayIndex)?  $default,) {final _that = this;
switch (_that) {
case _Cycle() when $default != null:
return $default(_that.id,_that.name,_that.days,_that.isActive,_that.startDate,_that.startDayIndex);case _:
  return null;

}
}

}

/// @nodoc


class _Cycle implements Cycle {
  const _Cycle({required this.id, required this.name, required final  List<CycleDay> days, required this.isActive, required this.startDate, required this.startDayIndex}): _days = days;
  

@override final  String id;
@override final  String name;
 final  List<CycleDay> _days;
@override List<CycleDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override final  bool isActive;
// UTC midnight of the phone's calendar day the anchor applies to.
@override final  DateTime startDate;
@override final  int startDayIndex;

/// Create a copy of Cycle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleCopyWith<_Cycle> get copyWith => __$CycleCopyWithImpl<_Cycle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cycle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.startDayIndex, startDayIndex) || other.startDayIndex == startDayIndex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_days),isActive,startDate,startDayIndex);

@override
String toString() {
  return 'Cycle(id: $id, name: $name, days: $days, isActive: $isActive, startDate: $startDate, startDayIndex: $startDayIndex)';
}


}

/// @nodoc
abstract mixin class _$CycleCopyWith<$Res> implements $CycleCopyWith<$Res> {
  factory _$CycleCopyWith(_Cycle value, $Res Function(_Cycle) _then) = __$CycleCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<CycleDay> days, bool isActive, DateTime startDate, int startDayIndex
});




}
/// @nodoc
class __$CycleCopyWithImpl<$Res>
    implements _$CycleCopyWith<$Res> {
  __$CycleCopyWithImpl(this._self, this._then);

  final _Cycle _self;
  final $Res Function(_Cycle) _then;

/// Create a copy of Cycle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? days = null,Object? isActive = null,Object? startDate = null,Object? startDayIndex = null,}) {
  return _then(_Cycle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<CycleDay>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,startDayIndex: null == startDayIndex ? _self.startDayIndex : startDayIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
