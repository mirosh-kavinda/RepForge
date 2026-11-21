// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_answers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingAnswers {

 UnitSystem get units; TrainingGoal? get goal; TrainingLevel? get level; Sex? get sex; int? get birthYear; double? get heightCm; double? get weightKg; double? get waistCm; ActivityLevel? get activity;
/// Create a copy of OnboardingAnswers
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingAnswersCopyWith<OnboardingAnswers> get copyWith => _$OnboardingAnswersCopyWithImpl<OnboardingAnswers>(this as OnboardingAnswers, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingAnswers&&(identical(other.units, units) || other.units == units)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.level, level) || other.level == level)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthYear, birthYear) || other.birthYear == birthYear)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.waistCm, waistCm) || other.waistCm == waistCm)&&(identical(other.activity, activity) || other.activity == activity));
}


@override
int get hashCode => Object.hash(runtimeType,units,goal,level,sex,birthYear,heightCm,weightKg,waistCm,activity);

@override
String toString() {
  return 'OnboardingAnswers(units: $units, goal: $goal, level: $level, sex: $sex, birthYear: $birthYear, heightCm: $heightCm, weightKg: $weightKg, waistCm: $waistCm, activity: $activity)';
}


}

/// @nodoc
abstract mixin class $OnboardingAnswersCopyWith<$Res>  {
  factory $OnboardingAnswersCopyWith(OnboardingAnswers value, $Res Function(OnboardingAnswers) _then) = _$OnboardingAnswersCopyWithImpl;
@useResult
$Res call({
 UnitSystem units, TrainingGoal? goal, TrainingLevel? level, Sex? sex, int? birthYear, double? heightCm, double? weightKg, double? waistCm, ActivityLevel? activity
});




}
/// @nodoc
class _$OnboardingAnswersCopyWithImpl<$Res>
    implements $OnboardingAnswersCopyWith<$Res> {
  _$OnboardingAnswersCopyWithImpl(this._self, this._then);

  final OnboardingAnswers _self;
  final $Res Function(OnboardingAnswers) _then;

/// Create a copy of OnboardingAnswers
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? units = null,Object? goal = freezed,Object? level = freezed,Object? sex = freezed,Object? birthYear = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? waistCm = freezed,Object? activity = freezed,}) {
  return _then(_self.copyWith(
units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as UnitSystem,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as TrainingGoal?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as TrainingLevel?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as Sex?,birthYear: freezed == birthYear ? _self.birthYear : birthYear // ignore: cast_nullable_to_non_nullable
as int?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,waistCm: freezed == waistCm ? _self.waistCm : waistCm // ignore: cast_nullable_to_non_nullable
as double?,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivityLevel?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingAnswers].
extension OnboardingAnswersPatterns on OnboardingAnswers {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingAnswers value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingAnswers() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingAnswers value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingAnswers():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingAnswers value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingAnswers() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UnitSystem units,  TrainingGoal? goal,  TrainingLevel? level,  Sex? sex,  int? birthYear,  double? heightCm,  double? weightKg,  double? waistCm,  ActivityLevel? activity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingAnswers() when $default != null:
return $default(_that.units,_that.goal,_that.level,_that.sex,_that.birthYear,_that.heightCm,_that.weightKg,_that.waistCm,_that.activity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UnitSystem units,  TrainingGoal? goal,  TrainingLevel? level,  Sex? sex,  int? birthYear,  double? heightCm,  double? weightKg,  double? waistCm,  ActivityLevel? activity)  $default,) {final _that = this;
switch (_that) {
case _OnboardingAnswers():
return $default(_that.units,_that.goal,_that.level,_that.sex,_that.birthYear,_that.heightCm,_that.weightKg,_that.waistCm,_that.activity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UnitSystem units,  TrainingGoal? goal,  TrainingLevel? level,  Sex? sex,  int? birthYear,  double? heightCm,  double? weightKg,  double? waistCm,  ActivityLevel? activity)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingAnswers() when $default != null:
return $default(_that.units,_that.goal,_that.level,_that.sex,_that.birthYear,_that.heightCm,_that.weightKg,_that.waistCm,_that.activity);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingAnswers implements OnboardingAnswers {
  const _OnboardingAnswers({required this.units, this.goal, this.level, this.sex, this.birthYear, this.heightCm, this.weightKg, this.waistCm, this.activity});
  

@override final  UnitSystem units;
@override final  TrainingGoal? goal;
@override final  TrainingLevel? level;
@override final  Sex? sex;
@override final  int? birthYear;
@override final  double? heightCm;
@override final  double? weightKg;
@override final  double? waistCm;
@override final  ActivityLevel? activity;

/// Create a copy of OnboardingAnswers
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingAnswersCopyWith<_OnboardingAnswers> get copyWith => __$OnboardingAnswersCopyWithImpl<_OnboardingAnswers>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingAnswers&&(identical(other.units, units) || other.units == units)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.level, level) || other.level == level)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.birthYear, birthYear) || other.birthYear == birthYear)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.waistCm, waistCm) || other.waistCm == waistCm)&&(identical(other.activity, activity) || other.activity == activity));
}


@override
int get hashCode => Object.hash(runtimeType,units,goal,level,sex,birthYear,heightCm,weightKg,waistCm,activity);

@override
String toString() {
  return 'OnboardingAnswers(units: $units, goal: $goal, level: $level, sex: $sex, birthYear: $birthYear, heightCm: $heightCm, weightKg: $weightKg, waistCm: $waistCm, activity: $activity)';
}


}

/// @nodoc
abstract mixin class _$OnboardingAnswersCopyWith<$Res> implements $OnboardingAnswersCopyWith<$Res> {
  factory _$OnboardingAnswersCopyWith(_OnboardingAnswers value, $Res Function(_OnboardingAnswers) _then) = __$OnboardingAnswersCopyWithImpl;
@override @useResult
$Res call({
 UnitSystem units, TrainingGoal? goal, TrainingLevel? level, Sex? sex, int? birthYear, double? heightCm, double? weightKg, double? waistCm, ActivityLevel? activity
});




}
/// @nodoc
class __$OnboardingAnswersCopyWithImpl<$Res>
    implements _$OnboardingAnswersCopyWith<$Res> {
  __$OnboardingAnswersCopyWithImpl(this._self, this._then);

  final _OnboardingAnswers _self;
  final $Res Function(_OnboardingAnswers) _then;

/// Create a copy of OnboardingAnswers
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? units = null,Object? goal = freezed,Object? level = freezed,Object? sex = freezed,Object? birthYear = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? waistCm = freezed,Object? activity = freezed,}) {
  return _then(_OnboardingAnswers(
units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as UnitSystem,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as TrainingGoal?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as TrainingLevel?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as Sex?,birthYear: freezed == birthYear ? _self.birthYear : birthYear // ignore: cast_nullable_to_non_nullable
as int?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,waistCm: freezed == waistCm ? _self.waistCm : waistCm // ignore: cast_nullable_to_non_nullable
as double?,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as ActivityLevel?,
  ));
}


}

// dart format on
