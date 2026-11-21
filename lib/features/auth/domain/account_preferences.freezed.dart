// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountPreferences {

 bool get backUpBodyMetrics; bool get backUpPhotos; bool get useProviderProfile; bool get syncSettings; bool get remindersEverywhere;
/// Create a copy of AccountPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountPreferencesCopyWith<AccountPreferences> get copyWith => _$AccountPreferencesCopyWithImpl<AccountPreferences>(this as AccountPreferences, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountPreferences&&(identical(other.backUpBodyMetrics, backUpBodyMetrics) || other.backUpBodyMetrics == backUpBodyMetrics)&&(identical(other.backUpPhotos, backUpPhotos) || other.backUpPhotos == backUpPhotos)&&(identical(other.useProviderProfile, useProviderProfile) || other.useProviderProfile == useProviderProfile)&&(identical(other.syncSettings, syncSettings) || other.syncSettings == syncSettings)&&(identical(other.remindersEverywhere, remindersEverywhere) || other.remindersEverywhere == remindersEverywhere));
}


@override
int get hashCode => Object.hash(runtimeType,backUpBodyMetrics,backUpPhotos,useProviderProfile,syncSettings,remindersEverywhere);

@override
String toString() {
  return 'AccountPreferences(backUpBodyMetrics: $backUpBodyMetrics, backUpPhotos: $backUpPhotos, useProviderProfile: $useProviderProfile, syncSettings: $syncSettings, remindersEverywhere: $remindersEverywhere)';
}


}

/// @nodoc
abstract mixin class $AccountPreferencesCopyWith<$Res>  {
  factory $AccountPreferencesCopyWith(AccountPreferences value, $Res Function(AccountPreferences) _then) = _$AccountPreferencesCopyWithImpl;
@useResult
$Res call({
 bool backUpBodyMetrics, bool backUpPhotos, bool useProviderProfile, bool syncSettings, bool remindersEverywhere
});




}
/// @nodoc
class _$AccountPreferencesCopyWithImpl<$Res>
    implements $AccountPreferencesCopyWith<$Res> {
  _$AccountPreferencesCopyWithImpl(this._self, this._then);

  final AccountPreferences _self;
  final $Res Function(AccountPreferences) _then;

/// Create a copy of AccountPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? backUpBodyMetrics = null,Object? backUpPhotos = null,Object? useProviderProfile = null,Object? syncSettings = null,Object? remindersEverywhere = null,}) {
  return _then(_self.copyWith(
backUpBodyMetrics: null == backUpBodyMetrics ? _self.backUpBodyMetrics : backUpBodyMetrics // ignore: cast_nullable_to_non_nullable
as bool,backUpPhotos: null == backUpPhotos ? _self.backUpPhotos : backUpPhotos // ignore: cast_nullable_to_non_nullable
as bool,useProviderProfile: null == useProviderProfile ? _self.useProviderProfile : useProviderProfile // ignore: cast_nullable_to_non_nullable
as bool,syncSettings: null == syncSettings ? _self.syncSettings : syncSettings // ignore: cast_nullable_to_non_nullable
as bool,remindersEverywhere: null == remindersEverywhere ? _self.remindersEverywhere : remindersEverywhere // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountPreferences].
extension AccountPreferencesPatterns on AccountPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountPreferences value)  $default,){
final _that = this;
switch (_that) {
case _AccountPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _AccountPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool backUpBodyMetrics,  bool backUpPhotos,  bool useProviderProfile,  bool syncSettings,  bool remindersEverywhere)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountPreferences() when $default != null:
return $default(_that.backUpBodyMetrics,_that.backUpPhotos,_that.useProviderProfile,_that.syncSettings,_that.remindersEverywhere);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool backUpBodyMetrics,  bool backUpPhotos,  bool useProviderProfile,  bool syncSettings,  bool remindersEverywhere)  $default,) {final _that = this;
switch (_that) {
case _AccountPreferences():
return $default(_that.backUpBodyMetrics,_that.backUpPhotos,_that.useProviderProfile,_that.syncSettings,_that.remindersEverywhere);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool backUpBodyMetrics,  bool backUpPhotos,  bool useProviderProfile,  bool syncSettings,  bool remindersEverywhere)?  $default,) {final _that = this;
switch (_that) {
case _AccountPreferences() when $default != null:
return $default(_that.backUpBodyMetrics,_that.backUpPhotos,_that.useProviderProfile,_that.syncSettings,_that.remindersEverywhere);case _:
  return null;

}
}

}

/// @nodoc


class _AccountPreferences implements AccountPreferences {
  const _AccountPreferences({this.backUpBodyMetrics = true, this.backUpPhotos = true, this.useProviderProfile = true, this.syncSettings = true, this.remindersEverywhere = true});
  

@override@JsonKey() final  bool backUpBodyMetrics;
@override@JsonKey() final  bool backUpPhotos;
@override@JsonKey() final  bool useProviderProfile;
@override@JsonKey() final  bool syncSettings;
@override@JsonKey() final  bool remindersEverywhere;

/// Create a copy of AccountPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountPreferencesCopyWith<_AccountPreferences> get copyWith => __$AccountPreferencesCopyWithImpl<_AccountPreferences>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountPreferences&&(identical(other.backUpBodyMetrics, backUpBodyMetrics) || other.backUpBodyMetrics == backUpBodyMetrics)&&(identical(other.backUpPhotos, backUpPhotos) || other.backUpPhotos == backUpPhotos)&&(identical(other.useProviderProfile, useProviderProfile) || other.useProviderProfile == useProviderProfile)&&(identical(other.syncSettings, syncSettings) || other.syncSettings == syncSettings)&&(identical(other.remindersEverywhere, remindersEverywhere) || other.remindersEverywhere == remindersEverywhere));
}


@override
int get hashCode => Object.hash(runtimeType,backUpBodyMetrics,backUpPhotos,useProviderProfile,syncSettings,remindersEverywhere);

@override
String toString() {
  return 'AccountPreferences(backUpBodyMetrics: $backUpBodyMetrics, backUpPhotos: $backUpPhotos, useProviderProfile: $useProviderProfile, syncSettings: $syncSettings, remindersEverywhere: $remindersEverywhere)';
}


}

/// @nodoc
abstract mixin class _$AccountPreferencesCopyWith<$Res> implements $AccountPreferencesCopyWith<$Res> {
  factory _$AccountPreferencesCopyWith(_AccountPreferences value, $Res Function(_AccountPreferences) _then) = __$AccountPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool backUpBodyMetrics, bool backUpPhotos, bool useProviderProfile, bool syncSettings, bool remindersEverywhere
});




}
/// @nodoc
class __$AccountPreferencesCopyWithImpl<$Res>
    implements _$AccountPreferencesCopyWith<$Res> {
  __$AccountPreferencesCopyWithImpl(this._self, this._then);

  final _AccountPreferences _self;
  final $Res Function(_AccountPreferences) _then;

/// Create a copy of AccountPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backUpBodyMetrics = null,Object? backUpPhotos = null,Object? useProviderProfile = null,Object? syncSettings = null,Object? remindersEverywhere = null,}) {
  return _then(_AccountPreferences(
backUpBodyMetrics: null == backUpBodyMetrics ? _self.backUpBodyMetrics : backUpBodyMetrics // ignore: cast_nullable_to_non_nullable
as bool,backUpPhotos: null == backUpPhotos ? _self.backUpPhotos : backUpPhotos // ignore: cast_nullable_to_non_nullable
as bool,useProviderProfile: null == useProviderProfile ? _self.useProviderProfile : useProviderProfile // ignore: cast_nullable_to_non_nullable
as bool,syncSettings: null == syncSettings ? _self.syncSettings : syncSettings // ignore: cast_nullable_to_non_nullable
as bool,remindersEverywhere: null == remindersEverywhere ? _self.remindersEverywhere : remindersEverywhere // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
