// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingDraft {

 UnitSystem get units; TrainingGoal? get goal; TrainingLevel? get level; SexChoice? get sex; String get birthYear; String get height; String get heightInches; String get weight; String get waist; ActivityLevel? get activity;// Set when a unit switch re-expresses a value; cleared when the field is
// edited, so switching back and forth never drifts what was typed.
 double? get exactHeightCm; double? get exactWeightKg; double? get exactWaistCm;
/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingDraftCopyWith<OnboardingDraft> get copyWith => _$OnboardingDraftCopyWithImpl<OnboardingDraft>(this as OnboardingDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingDraft&&(identical(other.units, units) || other.units == units)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.level, level) || other.level == level)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthYear, birthYear) || other.birthYear == birthYear)&&(identical(other.height, height) || other.height == height)&&(identical(other.heightInches, heightInches) || other.heightInches == heightInches)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.waist, waist) || other.waist == waist)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.exactHeightCm, exactHeightCm) || other.exactHeightCm == exactHeightCm)&&(identical(other.exactWeightKg, exactWeightKg) || other.exactWeightKg == exactWeightKg)&&(identical(other.exactWaistCm, exactWaistCm) || other.exactWaistCm == exactWaistCm));
}


@override
int get hashCode => Object.hash(runtimeType,units,goal,level,sex,birthYear,height,heightInches,weight,waist,activity,exactHeightCm,exactWeightKg,exactWaistCm);

@override
String toString() {
  return 'OnboardingDraft(units: $units, goal: $goal, level: $level, sex: $sex, birthYear: $birthYear, height: $height, heightInches: $heightInches, weight: $weight, waist: $waist, activity: $activity, exactHeightCm: $exactHeightCm, exactWeightKg: $exactWeightKg, exactWaistCm: $exactWaistCm)';
}


}

/// @nodoc
abstract mixin class $OnboardingDraftCopyWith<$Res>  {
  factory $OnboardingDraftCopyWith(OnboardingDraft value, $Res Function(OnboardingDraft) _then) = _$OnboardingDraftCopyWithImpl;
@useResult
$Res call({
 UnitSystem units, TrainingGoal? goal, TrainingLevel? level, SexChoice? sex, String birthYear, String height, String heightInches, String weight, String waist, ActivityLevel? activity, double? exactHeightCm, double? exactWeightKg, double? exactWaistCm
});




}
/// @nodoc
class _$OnboardingDraftCopyWithImpl<$Res>
    implements $OnboardingDraftCopyWith<$Res> {
  _$OnboardingDraftCopyWithImpl(this._self, this._then);

  final OnboardingDraft _self;
  final $Res Function(OnboardingDraft) _then;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? units = null,Object? goal = freezed,Object? level = freezed,Object? sex = freezed,Object? birthYear = null,Object? height = null,Object? heightInches = null,Object? weight = null,Object? waist = null,Object? activity = freezed,Object? exactHeightCm = freezed,Object? exactWeightKg = freezed,Object? exactWaistCm = freezed,}) {
  return _then(_self.copyWith(
units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as UnitSystem,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as TrainingGoal?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as TrainingLevel?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as SexChoice?,birthYear: null == birthYear ? _self.birthYear : birthYear // ignore: cast_nullable_to_non_nullable
as String,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as String,heightInches: null == heightInches ? _self.heightInches : heightInches // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as String,waist: null == waist ? _self.waist : waist // ignore: cast_nullable_to_non_nullable
as String,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivityLevel?,exactHeightCm: freezed == exactHeightCm ? _self.exactHeightCm : exactHeightCm // ignore: cast_nullable_to_non_nullable
as double?,exactWeightKg: freezed == exactWeightKg ? _self.exactWeightKg : exactWeightKg // ignore: cast_nullable_to_non_nullable
as double?,exactWaistCm: freezed == exactWaistCm ? _self.exactWaistCm : exactWaistCm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingDraft].
extension OnboardingDraftPatterns on OnboardingDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingDraft value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingDraft value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UnitSystem units,  TrainingGoal? goal,  TrainingLevel? level,  SexChoice? sex,  String birthYear,  String height,  String heightInches,  String weight,  String waist,  ActivityLevel? activity,  double? exactHeightCm,  double? exactWeightKg,  double? exactWaistCm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that.units,_that.goal,_that.level,_that.sex,_that.birthYear,_that.height,_that.heightInches,_that.weight,_that.waist,_that.activity,_that.exactHeightCm,_that.exactWeightKg,_that.exactWaistCm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UnitSystem units,  TrainingGoal? goal,  TrainingLevel? level,  SexChoice? sex,  String birthYear,  String height,  String heightInches,  String weight,  String waist,  ActivityLevel? activity,  double? exactHeightCm,  double? exactWeightKg,  double? exactWaistCm)  $default,) {final _that = this;
switch (_that) {
case _OnboardingDraft():
return $default(_that.units,_that.goal,_that.level,_that.sex,_that.birthYear,_that.height,_that.heightInches,_that.weight,_that.waist,_that.activity,_that.exactHeightCm,_that.exactWeightKg,_that.exactWaistCm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UnitSystem units,  TrainingGoal? goal,  TrainingLevel? level,  SexChoice? sex,  String birthYear,  String height,  String heightInches,  String weight,  String waist,  ActivityLevel? activity,  double? exactHeightCm,  double? exactWeightKg,  double? exactWaistCm)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingDraft() when $default != null:
return $default(_that.units,_that.goal,_that.level,_that.sex,_that.birthYear,_that.height,_that.heightInches,_that.weight,_that.waist,_that.activity,_that.exactHeightCm,_that.exactWeightKg,_that.exactWaistCm);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingDraft extends OnboardingDraft {
  const _OnboardingDraft({required this.units, this.goal, this.level, this.sex, this.birthYear = '', this.height = '', this.heightInches = '', this.weight = '', this.waist = '', this.activity, this.exactHeightCm, this.exactWeightKg, this.exactWaistCm}): super._();
  

@override final  UnitSystem units;
@override final  TrainingGoal? goal;
@override final  TrainingLevel? level;
@override final  SexChoice? sex;
@override@JsonKey() final  String birthYear;
@override@JsonKey() final  String height;
@override@JsonKey() final  String heightInches;
@override@JsonKey() final  String weight;
@override@JsonKey() final  String waist;
@override final  ActivityLevel? activity;
// Set when a unit switch re-expresses a value; cleared when the field is
// edited, so switching back and forth never drifts what was typed.
@override final  double? exactHeightCm;
@override final  double? exactWeightKg;
@override final  double? exactWaistCm;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingDraftCopyWith<_OnboardingDraft> get copyWith => __$OnboardingDraftCopyWithImpl<_OnboardingDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingDraft&&(identical(other.units, units) || other.units == units)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.level, level) || other.level == level)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthYear, birthYear) || other.birthYear == birthYear)&&(identical(other.height, height) || other.height == height)&&(identical(other.heightInches, heightInches) || other.heightInches == heightInches)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.waist, waist) || other.waist == waist)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.exactHeightCm, exactHeightCm) || other.exactHeightCm == exactHeightCm)&&(identical(other.exactWeightKg, exactWeightKg) || other.exactWeightKg == exactWeightKg)&&(identical(other.exactWaistCm, exactWaistCm) || other.exactWaistCm == exactWaistCm));
}


@override
int get hashCode => Object.hash(runtimeType,units,goal,level,sex,birthYear,height,heightInches,weight,waist,activity,exactHeightCm,exactWeightKg,exactWaistCm);

@override
String toString() {
  return 'OnboardingDraft(units: $units, goal: $goal, level: $level, sex: $sex, birthYear: $birthYear, height: $height, heightInches: $heightInches, weight: $weight, waist: $waist, activity: $activity, exactHeightCm: $exactHeightCm, exactWeightKg: $exactWeightKg, exactWaistCm: $exactWaistCm)';
}


}

/// @nodoc
abstract mixin class _$OnboardingDraftCopyWith<$Res> implements $OnboardingDraftCopyWith<$Res> {
  factory _$OnboardingDraftCopyWith(_OnboardingDraft value, $Res Function(_OnboardingDraft) _then) = __$OnboardingDraftCopyWithImpl;
@override @useResult
$Res call({
 UnitSystem units, TrainingGoal? goal, TrainingLevel? level, SexChoice? sex, String birthYear, String height, String heightInches, String weight, String waist, ActivityLevel? activity, double? exactHeightCm, double? exactWeightKg, double? exactWaistCm
});




}
/// @nodoc
class __$OnboardingDraftCopyWithImpl<$Res>
    implements _$OnboardingDraftCopyWith<$Res> {
  __$OnboardingDraftCopyWithImpl(this._self, this._then);

  final _OnboardingDraft _self;
  final $Res Function(_OnboardingDraft) _then;

/// Create a copy of OnboardingDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? units = null,Object? goal = freezed,Object? level = freezed,Object? sex = freezed,Object? birthYear = null,Object? height = null,Object? heightInches = null,Object? weight = null,Object? waist = null,Object? activity = freezed,Object? exactHeightCm = freezed,Object? exactWeightKg = freezed,Object? exactWaistCm = freezed,}) {
  return _then(_OnboardingDraft(
units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as UnitSystem,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as TrainingGoal?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as TrainingLevel?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as SexChoice?,birthYear: null == birthYear ? _self.birthYear : birthYear // ignore: cast_nullable_to_non_nullable
as String,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as String,heightInches: null == heightInches ? _self.heightInches : heightInches // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as String,waist: null == waist ? _self.waist : waist // ignore: cast_nullable_to_non_nullable
as String,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivityLevel?,exactHeightCm: freezed == exactHeightCm ? _self.exactHeightCm : exactHeightCm // ignore: cast_nullable_to_non_nullable
as double?,exactWeightKg: freezed == exactWeightKg ? _self.exactWeightKg : exactWeightKg // ignore: cast_nullable_to_non_nullable
as double?,exactWaistCm: freezed == exactWaistCm ? _self.exactWaistCm : exactWaistCm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
