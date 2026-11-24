// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Goal {

 String get id; GoalType get type;// Strength only.
 String? get exerciseId; double get startValue; double get target;// UTC midnight of the phone's calendar day.
 DateTime? get deadline; bool get pinned; DateTime get createdAt;// The date the target was reached, or marked achieved.
 DateTime? get achievedAt;
/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalCopyWith<Goal> get copyWith => _$GoalCopyWithImpl<Goal>(this as Goal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.startValue, startValue) || other.startValue == startValue)&&(identical(other.target, target) || other.target == target)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,exerciseId,startValue,target,deadline,pinned,createdAt,achievedAt);

@override
String toString() {
  return 'Goal(id: $id, type: $type, exerciseId: $exerciseId, startValue: $startValue, target: $target, deadline: $deadline, pinned: $pinned, createdAt: $createdAt, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class $GoalCopyWith<$Res>  {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) _then) = _$GoalCopyWithImpl;
@useResult
$Res call({
 String id, GoalType type, String? exerciseId, double startValue, double target, DateTime? deadline, bool pinned, DateTime createdAt, DateTime? achievedAt
});




}
/// @nodoc
class _$GoalCopyWithImpl<$Res>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._self, this._then);

  final Goal _self;
  final $Res Function(Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? exerciseId = freezed,Object? startValue = null,Object? target = null,Object? deadline = freezed,Object? pinned = null,Object? createdAt = null,Object? achievedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GoalType,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,startValue: null == startValue ? _self.startValue : startValue // ignore: cast_nullable_to_non_nullable
as double,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Goal].
extension GoalPatterns on Goal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Goal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Goal value)  $default,){
final _that = this;
switch (_that) {
case _Goal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Goal value)?  $default,){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  GoalType type,  String? exerciseId,  double startValue,  double target,  DateTime? deadline,  bool pinned,  DateTime createdAt,  DateTime? achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.type,_that.exerciseId,_that.startValue,_that.target,_that.deadline,_that.pinned,_that.createdAt,_that.achievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  GoalType type,  String? exerciseId,  double startValue,  double target,  DateTime? deadline,  bool pinned,  DateTime createdAt,  DateTime? achievedAt)  $default,) {final _that = this;
switch (_that) {
case _Goal():
return $default(_that.id,_that.type,_that.exerciseId,_that.startValue,_that.target,_that.deadline,_that.pinned,_that.createdAt,_that.achievedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  GoalType type,  String? exerciseId,  double startValue,  double target,  DateTime? deadline,  bool pinned,  DateTime createdAt,  DateTime? achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.type,_that.exerciseId,_that.startValue,_that.target,_that.deadline,_that.pinned,_that.createdAt,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Goal extends Goal {
  const _Goal({required this.id, required this.type, this.exerciseId, required this.startValue, required this.target, this.deadline, this.pinned = false, required this.createdAt, this.achievedAt}): super._();
  

@override final  String id;
@override final  GoalType type;
// Strength only.
@override final  String? exerciseId;
@override final  double startValue;
@override final  double target;
// UTC midnight of the phone's calendar day.
@override final  DateTime? deadline;
@override@JsonKey() final  bool pinned;
@override final  DateTime createdAt;
// The date the target was reached, or marked achieved.
@override final  DateTime? achievedAt;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalCopyWith<_Goal> get copyWith => __$GoalCopyWithImpl<_Goal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.startValue, startValue) || other.startValue == startValue)&&(identical(other.target, target) || other.target == target)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,exerciseId,startValue,target,deadline,pinned,createdAt,achievedAt);

@override
String toString() {
  return 'Goal(id: $id, type: $type, exerciseId: $exerciseId, startValue: $startValue, target: $target, deadline: $deadline, pinned: $pinned, createdAt: $createdAt, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$GoalCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$GoalCopyWith(_Goal value, $Res Function(_Goal) _then) = __$GoalCopyWithImpl;
@override @useResult
$Res call({
 String id, GoalType type, String? exerciseId, double startValue, double target, DateTime? deadline, bool pinned, DateTime createdAt, DateTime? achievedAt
});




}
/// @nodoc
class __$GoalCopyWithImpl<$Res>
    implements _$GoalCopyWith<$Res> {
  __$GoalCopyWithImpl(this._self, this._then);

  final _Goal _self;
  final $Res Function(_Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? exerciseId = freezed,Object? startValue = null,Object? target = null,Object? deadline = freezed,Object? pinned = null,Object? createdAt = null,Object? achievedAt = freezed,}) {
  return _then(_Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GoalType,exerciseId: freezed == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String?,startValue: null == startValue ? _self.startValue : startValue // ignore: cast_nullable_to_non_nullable
as double,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as double,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
