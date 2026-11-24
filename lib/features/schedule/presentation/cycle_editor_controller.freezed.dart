// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_editor_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CycleDraft implements DiagnosticableTreeMixin {

 String get id; CycleOrigin get origin; String get name; List<CycleDay> get days;// The chosen "Today is day n" (0-based) for a new cycle (AC4).
 int get startDay; CycleMode get mode;// The saved cycle being edited.
 Cycle? get original;
/// Create a copy of CycleDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleDraftCopyWith<CycleDraft> get copyWith => _$CycleDraftCopyWithImpl<CycleDraft>(this as CycleDraft, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CycleDraft'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('origin', origin))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('days', days))..add(DiagnosticsProperty('startDay', startDay))..add(DiagnosticsProperty('mode', mode))..add(DiagnosticsProperty('original', original));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.days, days)&&(identical(other.startDay, startDay) || other.startDay == startDay)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.original, original) || other.original == original));
}


@override
int get hashCode => Object.hash(runtimeType,id,origin,name,const DeepCollectionEquality().hash(days),startDay,mode,original);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CycleDraft(id: $id, origin: $origin, name: $name, days: $days, startDay: $startDay, mode: $mode, original: $original)';
}


}

/// @nodoc
abstract mixin class $CycleDraftCopyWith<$Res>  {
  factory $CycleDraftCopyWith(CycleDraft value, $Res Function(CycleDraft) _then) = _$CycleDraftCopyWithImpl;
@useResult
$Res call({
 String id, CycleOrigin origin, String name, List<CycleDay> days, int startDay, CycleMode mode, Cycle? original
});


$CycleCopyWith<$Res>? get original;

}
/// @nodoc
class _$CycleDraftCopyWithImpl<$Res>
    implements $CycleDraftCopyWith<$Res> {
  _$CycleDraftCopyWithImpl(this._self, this._then);

  final CycleDraft _self;
  final $Res Function(CycleDraft) _then;

/// Create a copy of CycleDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? origin = null,Object? name = null,Object? days = null,Object? startDay = null,Object? mode = null,Object? original = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as CycleOrigin,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<CycleDay>,startDay: null == startDay ? _self.startDay : startDay // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CycleMode,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Cycle?,
  ));
}
/// Create a copy of CycleDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CycleCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $CycleCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [CycleDraft].
extension CycleDraftPatterns on CycleDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleDraft value)  $default,){
final _that = this;
switch (_that) {
case _CycleDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleDraft value)?  $default,){
final _that = this;
switch (_that) {
case _CycleDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CycleOrigin origin,  String name,  List<CycleDay> days,  int startDay,  CycleMode mode,  Cycle? original)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleDraft() when $default != null:
return $default(_that.id,_that.origin,_that.name,_that.days,_that.startDay,_that.mode,_that.original);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CycleOrigin origin,  String name,  List<CycleDay> days,  int startDay,  CycleMode mode,  Cycle? original)  $default,) {final _that = this;
switch (_that) {
case _CycleDraft():
return $default(_that.id,_that.origin,_that.name,_that.days,_that.startDay,_that.mode,_that.original);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CycleOrigin origin,  String name,  List<CycleDay> days,  int startDay,  CycleMode mode,  Cycle? original)?  $default,) {final _that = this;
switch (_that) {
case _CycleDraft() when $default != null:
return $default(_that.id,_that.origin,_that.name,_that.days,_that.startDay,_that.mode,_that.original);case _:
  return null;

}
}

}

/// @nodoc


class _CycleDraft extends CycleDraft with DiagnosticableTreeMixin {
  const _CycleDraft({required this.id, required this.origin, required this.name, required final  List<CycleDay> days, this.startDay = 0, this.mode = CycleMode.rolling, this.original}): _days = days,super._();
  

@override final  String id;
@override final  CycleOrigin origin;
@override final  String name;
 final  List<CycleDay> _days;
@override List<CycleDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

// The chosen "Today is day n" (0-based) for a new cycle (AC4).
@override@JsonKey() final  int startDay;
@override@JsonKey() final  CycleMode mode;
// The saved cycle being edited.
@override final  Cycle? original;

/// Create a copy of CycleDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleDraftCopyWith<_CycleDraft> get copyWith => __$CycleDraftCopyWithImpl<_CycleDraft>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CycleDraft'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('origin', origin))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('days', days))..add(DiagnosticsProperty('startDay', startDay))..add(DiagnosticsProperty('mode', mode))..add(DiagnosticsProperty('original', original));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._days, _days)&&(identical(other.startDay, startDay) || other.startDay == startDay)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.original, original) || other.original == original));
}


@override
int get hashCode => Object.hash(runtimeType,id,origin,name,const DeepCollectionEquality().hash(_days),startDay,mode,original);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CycleDraft(id: $id, origin: $origin, name: $name, days: $days, startDay: $startDay, mode: $mode, original: $original)';
}


}

/// @nodoc
abstract mixin class _$CycleDraftCopyWith<$Res> implements $CycleDraftCopyWith<$Res> {
  factory _$CycleDraftCopyWith(_CycleDraft value, $Res Function(_CycleDraft) _then) = __$CycleDraftCopyWithImpl;
@override @useResult
$Res call({
 String id, CycleOrigin origin, String name, List<CycleDay> days, int startDay, CycleMode mode, Cycle? original
});


@override $CycleCopyWith<$Res>? get original;

}
/// @nodoc
class __$CycleDraftCopyWithImpl<$Res>
    implements _$CycleDraftCopyWith<$Res> {
  __$CycleDraftCopyWithImpl(this._self, this._then);

  final _CycleDraft _self;
  final $Res Function(_CycleDraft) _then;

/// Create a copy of CycleDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? origin = null,Object? name = null,Object? days = null,Object? startDay = null,Object? mode = null,Object? original = freezed,}) {
  return _then(_CycleDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as CycleOrigin,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<CycleDay>,startDay: null == startDay ? _self.startDay : startDay // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CycleMode,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Cycle?,
  ));
}

/// Create a copy of CycleDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CycleCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $CycleCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
