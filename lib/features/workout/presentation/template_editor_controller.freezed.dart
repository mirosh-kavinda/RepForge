// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_editor_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorState implements DiagnosticableTreeMixin {

 String get id; bool get isNew; String get name; List<TemplateExercise> get exercises;// What Save would leave unchanged; null for an unsaved copy (AC10).
 WorkoutTemplate? get baseline; Map<String, Exercise> get catalog; bool get selecting; Set<int> get selection;
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorStateCopyWith<EditorState> get copyWith => _$EditorStateCopyWithImpl<EditorState>(this as EditorState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EditorState'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('isNew', isNew))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('exercises', exercises))..add(DiagnosticsProperty('baseline', baseline))..add(DiagnosticsProperty('catalog', catalog))..add(DiagnosticsProperty('selecting', selecting))..add(DiagnosticsProperty('selection', selection));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorState&&(identical(other.id, id) || other.id == id)&&(identical(other.isNew, isNew) || other.isNew == isNew)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.baseline, baseline) || other.baseline == baseline)&&const DeepCollectionEquality().equals(other.catalog, catalog)&&(identical(other.selecting, selecting) || other.selecting == selecting)&&const DeepCollectionEquality().equals(other.selection, selection));
}


@override
int get hashCode => Object.hash(runtimeType,id,isNew,name,const DeepCollectionEquality().hash(exercises),baseline,const DeepCollectionEquality().hash(catalog),selecting,const DeepCollectionEquality().hash(selection));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EditorState(id: $id, isNew: $isNew, name: $name, exercises: $exercises, baseline: $baseline, catalog: $catalog, selecting: $selecting, selection: $selection)';
}


}

/// @nodoc
abstract mixin class $EditorStateCopyWith<$Res>  {
  factory $EditorStateCopyWith(EditorState value, $Res Function(EditorState) _then) = _$EditorStateCopyWithImpl;
@useResult
$Res call({
 String id, bool isNew, String name, List<TemplateExercise> exercises, WorkoutTemplate? baseline, Map<String, Exercise> catalog, bool selecting, Set<int> selection
});


$WorkoutTemplateCopyWith<$Res>? get baseline;

}
/// @nodoc
class _$EditorStateCopyWithImpl<$Res>
    implements $EditorStateCopyWith<$Res> {
  _$EditorStateCopyWithImpl(this._self, this._then);

  final EditorState _self;
  final $Res Function(EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isNew = null,Object? name = null,Object? exercises = null,Object? baseline = freezed,Object? catalog = null,Object? selecting = null,Object? selection = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<TemplateExercise>,baseline: freezed == baseline ? _self.baseline : baseline // ignore: cast_nullable_to_non_nullable
as WorkoutTemplate?,catalog: null == catalog ? _self.catalog : catalog // ignore: cast_nullable_to_non_nullable
as Map<String, Exercise>,selecting: null == selecting ? _self.selecting : selecting // ignore: cast_nullable_to_non_nullable
as bool,selection: null == selection ? _self.selection : selection // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}
/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutTemplateCopyWith<$Res>? get baseline {
    if (_self.baseline == null) {
    return null;
  }

  return $WorkoutTemplateCopyWith<$Res>(_self.baseline!, (value) {
    return _then(_self.copyWith(baseline: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditorState].
extension EditorStatePatterns on EditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorState value)  $default,){
final _that = this;
switch (_that) {
case _EditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorState value)?  $default,){
final _that = this;
switch (_that) {
case _EditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isNew,  String name,  List<TemplateExercise> exercises,  WorkoutTemplate? baseline,  Map<String, Exercise> catalog,  bool selecting,  Set<int> selection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.id,_that.isNew,_that.name,_that.exercises,_that.baseline,_that.catalog,_that.selecting,_that.selection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isNew,  String name,  List<TemplateExercise> exercises,  WorkoutTemplate? baseline,  Map<String, Exercise> catalog,  bool selecting,  Set<int> selection)  $default,) {final _that = this;
switch (_that) {
case _EditorState():
return $default(_that.id,_that.isNew,_that.name,_that.exercises,_that.baseline,_that.catalog,_that.selecting,_that.selection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isNew,  String name,  List<TemplateExercise> exercises,  WorkoutTemplate? baseline,  Map<String, Exercise> catalog,  bool selecting,  Set<int> selection)?  $default,) {final _that = this;
switch (_that) {
case _EditorState() when $default != null:
return $default(_that.id,_that.isNew,_that.name,_that.exercises,_that.baseline,_that.catalog,_that.selecting,_that.selection);case _:
  return null;

}
}

}

/// @nodoc


class _EditorState extends EditorState with DiagnosticableTreeMixin {
  const _EditorState({required this.id, required this.isNew, required this.name, required final  List<TemplateExercise> exercises, required this.baseline, required final  Map<String, Exercise> catalog, this.selecting = false, final  Set<int> selection = const <int>{}}): _exercises = exercises,_catalog = catalog,_selection = selection,super._();
  

@override final  String id;
@override final  bool isNew;
@override final  String name;
 final  List<TemplateExercise> _exercises;
@override List<TemplateExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

// What Save would leave unchanged; null for an unsaved copy (AC10).
@override final  WorkoutTemplate? baseline;
 final  Map<String, Exercise> _catalog;
@override Map<String, Exercise> get catalog {
  if (_catalog is EqualUnmodifiableMapView) return _catalog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_catalog);
}

@override@JsonKey() final  bool selecting;
 final  Set<int> _selection;
@override@JsonKey() Set<int> get selection {
  if (_selection is EqualUnmodifiableSetView) return _selection;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selection);
}


/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorStateCopyWith<_EditorState> get copyWith => __$EditorStateCopyWithImpl<_EditorState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'EditorState'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('isNew', isNew))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('exercises', exercises))..add(DiagnosticsProperty('baseline', baseline))..add(DiagnosticsProperty('catalog', catalog))..add(DiagnosticsProperty('selecting', selecting))..add(DiagnosticsProperty('selection', selection));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorState&&(identical(other.id, id) || other.id == id)&&(identical(other.isNew, isNew) || other.isNew == isNew)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.baseline, baseline) || other.baseline == baseline)&&const DeepCollectionEquality().equals(other._catalog, _catalog)&&(identical(other.selecting, selecting) || other.selecting == selecting)&&const DeepCollectionEquality().equals(other._selection, _selection));
}


@override
int get hashCode => Object.hash(runtimeType,id,isNew,name,const DeepCollectionEquality().hash(_exercises),baseline,const DeepCollectionEquality().hash(_catalog),selecting,const DeepCollectionEquality().hash(_selection));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'EditorState(id: $id, isNew: $isNew, name: $name, exercises: $exercises, baseline: $baseline, catalog: $catalog, selecting: $selecting, selection: $selection)';
}


}

/// @nodoc
abstract mixin class _$EditorStateCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory _$EditorStateCopyWith(_EditorState value, $Res Function(_EditorState) _then) = __$EditorStateCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isNew, String name, List<TemplateExercise> exercises, WorkoutTemplate? baseline, Map<String, Exercise> catalog, bool selecting, Set<int> selection
});


@override $WorkoutTemplateCopyWith<$Res>? get baseline;

}
/// @nodoc
class __$EditorStateCopyWithImpl<$Res>
    implements _$EditorStateCopyWith<$Res> {
  __$EditorStateCopyWithImpl(this._self, this._then);

  final _EditorState _self;
  final $Res Function(_EditorState) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isNew = null,Object? name = null,Object? exercises = null,Object? baseline = freezed,Object? catalog = null,Object? selecting = null,Object? selection = null,}) {
  return _then(_EditorState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<TemplateExercise>,baseline: freezed == baseline ? _self.baseline : baseline // ignore: cast_nullable_to_non_nullable
as WorkoutTemplate?,catalog: null == catalog ? _self._catalog : catalog // ignore: cast_nullable_to_non_nullable
as Map<String, Exercise>,selecting: null == selecting ? _self.selecting : selecting // ignore: cast_nullable_to_non_nullable
as bool,selection: null == selection ? _self._selection : selection // ignore: cast_nullable_to_non_nullable
as Set<int>,
  ));
}

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutTemplateCopyWith<$Res>? get baseline {
    if (_self.baseline == null) {
    return null;
  }

  return $WorkoutTemplateCopyWith<$Res>(_self.baseline!, (value) {
    return _then(_self.copyWith(baseline: value));
  });
}
}

// dart format on
