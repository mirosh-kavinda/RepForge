// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExerciseQuery {

 String get text; Set<Muscle> get muscles; Set<Equipment> get equipment; Set<ExerciseLevel> get levels; Set<ExerciseCategory> get categories;
/// Create a copy of ExerciseQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseQueryCopyWith<ExerciseQuery> get copyWith => _$ExerciseQueryCopyWithImpl<ExerciseQuery>(this as ExerciseQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseQuery&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.muscles, muscles)&&const DeepCollectionEquality().equals(other.equipment, equipment)&&const DeepCollectionEquality().equals(other.levels, levels)&&const DeepCollectionEquality().equals(other.categories, categories));
}


@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(muscles),const DeepCollectionEquality().hash(equipment),const DeepCollectionEquality().hash(levels),const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'ExerciseQuery(text: $text, muscles: $muscles, equipment: $equipment, levels: $levels, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $ExerciseQueryCopyWith<$Res>  {
  factory $ExerciseQueryCopyWith(ExerciseQuery value, $Res Function(ExerciseQuery) _then) = _$ExerciseQueryCopyWithImpl;
@useResult
$Res call({
 String text, Set<Muscle> muscles, Set<Equipment> equipment, Set<ExerciseLevel> levels, Set<ExerciseCategory> categories
});




}
/// @nodoc
class _$ExerciseQueryCopyWithImpl<$Res>
    implements $ExerciseQueryCopyWith<$Res> {
  _$ExerciseQueryCopyWithImpl(this._self, this._then);

  final ExerciseQuery _self;
  final $Res Function(ExerciseQuery) _then;

/// Create a copy of ExerciseQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? muscles = null,Object? equipment = null,Object? levels = null,Object? categories = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,muscles: null == muscles ? _self.muscles : muscles // ignore: cast_nullable_to_non_nullable
as Set<Muscle>,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as Set<Equipment>,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as Set<ExerciseLevel>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as Set<ExerciseCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseQuery].
extension ExerciseQueryPatterns on ExerciseQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseQuery value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseQuery value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  Set<Muscle> muscles,  Set<Equipment> equipment,  Set<ExerciseLevel> levels,  Set<ExerciseCategory> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseQuery() when $default != null:
return $default(_that.text,_that.muscles,_that.equipment,_that.levels,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  Set<Muscle> muscles,  Set<Equipment> equipment,  Set<ExerciseLevel> levels,  Set<ExerciseCategory> categories)  $default,) {final _that = this;
switch (_that) {
case _ExerciseQuery():
return $default(_that.text,_that.muscles,_that.equipment,_that.levels,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  Set<Muscle> muscles,  Set<Equipment> equipment,  Set<ExerciseLevel> levels,  Set<ExerciseCategory> categories)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseQuery() when $default != null:
return $default(_that.text,_that.muscles,_that.equipment,_that.levels,_that.categories);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseQuery extends ExerciseQuery {
  const _ExerciseQuery({this.text = '', final  Set<Muscle> muscles = const <Muscle>{}, final  Set<Equipment> equipment = const <Equipment>{}, final  Set<ExerciseLevel> levels = const <ExerciseLevel>{}, final  Set<ExerciseCategory> categories = const <ExerciseCategory>{}}): _muscles = muscles,_equipment = equipment,_levels = levels,_categories = categories,super._();
  

@override@JsonKey() final  String text;
 final  Set<Muscle> _muscles;
@override@JsonKey() Set<Muscle> get muscles {
  if (_muscles is EqualUnmodifiableSetView) return _muscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_muscles);
}

 final  Set<Equipment> _equipment;
@override@JsonKey() Set<Equipment> get equipment {
  if (_equipment is EqualUnmodifiableSetView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_equipment);
}

 final  Set<ExerciseLevel> _levels;
@override@JsonKey() Set<ExerciseLevel> get levels {
  if (_levels is EqualUnmodifiableSetView) return _levels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_levels);
}

 final  Set<ExerciseCategory> _categories;
@override@JsonKey() Set<ExerciseCategory> get categories {
  if (_categories is EqualUnmodifiableSetView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_categories);
}


/// Create a copy of ExerciseQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseQueryCopyWith<_ExerciseQuery> get copyWith => __$ExerciseQueryCopyWithImpl<_ExerciseQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseQuery&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._muscles, _muscles)&&const DeepCollectionEquality().equals(other._equipment, _equipment)&&const DeepCollectionEquality().equals(other._levels, _levels)&&const DeepCollectionEquality().equals(other._categories, _categories));
}


@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_muscles),const DeepCollectionEquality().hash(_equipment),const DeepCollectionEquality().hash(_levels),const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'ExerciseQuery(text: $text, muscles: $muscles, equipment: $equipment, levels: $levels, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$ExerciseQueryCopyWith<$Res> implements $ExerciseQueryCopyWith<$Res> {
  factory _$ExerciseQueryCopyWith(_ExerciseQuery value, $Res Function(_ExerciseQuery) _then) = __$ExerciseQueryCopyWithImpl;
@override @useResult
$Res call({
 String text, Set<Muscle> muscles, Set<Equipment> equipment, Set<ExerciseLevel> levels, Set<ExerciseCategory> categories
});




}
/// @nodoc
class __$ExerciseQueryCopyWithImpl<$Res>
    implements _$ExerciseQueryCopyWith<$Res> {
  __$ExerciseQueryCopyWithImpl(this._self, this._then);

  final _ExerciseQuery _self;
  final $Res Function(_ExerciseQuery) _then;

/// Create a copy of ExerciseQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? muscles = null,Object? equipment = null,Object? levels = null,Object? categories = null,}) {
  return _then(_ExerciseQuery(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,muscles: null == muscles ? _self._muscles : muscles // ignore: cast_nullable_to_non_nullable
as Set<Muscle>,equipment: null == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as Set<Equipment>,levels: null == levels ? _self._levels : levels // ignore: cast_nullable_to_non_nullable
as Set<ExerciseLevel>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as Set<ExerciseCategory>,
  ));
}


}

// dart format on
