// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rolling.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CycleToday {

 int get index; bool get doneToday;// Passed dates the current training day has waited (AC8).
 int get missedDays; int get next;// Mark done / Undo are not offered: the clock is behind a day already
// seen, or today is already recorded missed / rest (edge: clock back).
 bool get readOnly;
/// Create a copy of CycleToday
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleTodayCopyWith<CycleToday> get copyWith => _$CycleTodayCopyWithImpl<CycleToday>(this as CycleToday, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleToday&&(identical(other.index, index) || other.index == index)&&(identical(other.doneToday, doneToday) || other.doneToday == doneToday)&&(identical(other.missedDays, missedDays) || other.missedDays == missedDays)&&(identical(other.next, next) || other.next == next)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly));
}


@override
int get hashCode => Object.hash(runtimeType,index,doneToday,missedDays,next,readOnly);

@override
String toString() {
  return 'CycleToday(index: $index, doneToday: $doneToday, missedDays: $missedDays, next: $next, readOnly: $readOnly)';
}


}

/// @nodoc
abstract mixin class $CycleTodayCopyWith<$Res>  {
  factory $CycleTodayCopyWith(CycleToday value, $Res Function(CycleToday) _then) = _$CycleTodayCopyWithImpl;
@useResult
$Res call({
 int index, bool doneToday, int missedDays, int next, bool readOnly
});




}
/// @nodoc
class _$CycleTodayCopyWithImpl<$Res>
    implements $CycleTodayCopyWith<$Res> {
  _$CycleTodayCopyWithImpl(this._self, this._then);

  final CycleToday _self;
  final $Res Function(CycleToday) _then;

/// Create a copy of CycleToday
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? doneToday = null,Object? missedDays = null,Object? next = null,Object? readOnly = null,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,doneToday: null == doneToday ? _self.doneToday : doneToday // ignore: cast_nullable_to_non_nullable
as bool,missedDays: null == missedDays ? _self.missedDays : missedDays // ignore: cast_nullable_to_non_nullable
as int,next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as int,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CycleToday].
extension CycleTodayPatterns on CycleToday {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleToday value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleToday() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleToday value)  $default,){
final _that = this;
switch (_that) {
case _CycleToday():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleToday value)?  $default,){
final _that = this;
switch (_that) {
case _CycleToday() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  bool doneToday,  int missedDays,  int next,  bool readOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleToday() when $default != null:
return $default(_that.index,_that.doneToday,_that.missedDays,_that.next,_that.readOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  bool doneToday,  int missedDays,  int next,  bool readOnly)  $default,) {final _that = this;
switch (_that) {
case _CycleToday():
return $default(_that.index,_that.doneToday,_that.missedDays,_that.next,_that.readOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  bool doneToday,  int missedDays,  int next,  bool readOnly)?  $default,) {final _that = this;
switch (_that) {
case _CycleToday() when $default != null:
return $default(_that.index,_that.doneToday,_that.missedDays,_that.next,_that.readOnly);case _:
  return null;

}
}

}

/// @nodoc


class _CycleToday implements CycleToday {
  const _CycleToday({required this.index, required this.doneToday, required this.missedDays, required this.next, this.readOnly = false});
  

@override final  int index;
@override final  bool doneToday;
// Passed dates the current training day has waited (AC8).
@override final  int missedDays;
@override final  int next;
// Mark done / Undo are not offered: the clock is behind a day already
// seen, or today is already recorded missed / rest (edge: clock back).
@override@JsonKey() final  bool readOnly;

/// Create a copy of CycleToday
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleTodayCopyWith<_CycleToday> get copyWith => __$CycleTodayCopyWithImpl<_CycleToday>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleToday&&(identical(other.index, index) || other.index == index)&&(identical(other.doneToday, doneToday) || other.doneToday == doneToday)&&(identical(other.missedDays, missedDays) || other.missedDays == missedDays)&&(identical(other.next, next) || other.next == next)&&(identical(other.readOnly, readOnly) || other.readOnly == readOnly));
}


@override
int get hashCode => Object.hash(runtimeType,index,doneToday,missedDays,next,readOnly);

@override
String toString() {
  return 'CycleToday(index: $index, doneToday: $doneToday, missedDays: $missedDays, next: $next, readOnly: $readOnly)';
}


}

/// @nodoc
abstract mixin class _$CycleTodayCopyWith<$Res> implements $CycleTodayCopyWith<$Res> {
  factory _$CycleTodayCopyWith(_CycleToday value, $Res Function(_CycleToday) _then) = __$CycleTodayCopyWithImpl;
@override @useResult
$Res call({
 int index, bool doneToday, int missedDays, int next, bool readOnly
});




}
/// @nodoc
class __$CycleTodayCopyWithImpl<$Res>
    implements _$CycleTodayCopyWith<$Res> {
  __$CycleTodayCopyWithImpl(this._self, this._then);

  final _CycleToday _self;
  final $Res Function(_CycleToday) _then;

/// Create a copy of CycleToday
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? doneToday = null,Object? missedDays = null,Object? next = null,Object? readOnly = null,}) {
  return _then(_CycleToday(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,doneToday: null == doneToday ? _self.doneToday : doneToday // ignore: cast_nullable_to_non_nullable
as bool,missedDays: null == missedDays ? _self.missedDays : missedDays // ignore: cast_nullable_to_non_nullable
as int,next: null == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as int,readOnly: null == readOnly ? _self.readOnly : readOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
