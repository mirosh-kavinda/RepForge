// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure()';
}


}

/// @nodoc
class $AuthFailureCopyWith<$Res>  {
$AuthFailureCopyWith(AuthFailure _, $Res Function(AuthFailure) __);
}


/// Adds pattern-matching-related methods to [AuthFailure].
extension AuthFailurePatterns on AuthFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthCancelled value)?  cancelled,TResult Function( AuthOffline value)?  offline,TResult Function( AuthWrongPassword value)?  wrongPassword,TResult Function( AuthWeakPassword value)?  weakPassword,TResult Function( AuthInvalidEmail value)?  invalidEmail,TResult Function( AuthAccountExists value)?  accountExists,TResult Function( AuthUseProvider value)?  useProvider,TResult Function( AuthUnknown value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthCancelled() when cancelled != null:
return cancelled(_that);case AuthOffline() when offline != null:
return offline(_that);case AuthWrongPassword() when wrongPassword != null:
return wrongPassword(_that);case AuthWeakPassword() when weakPassword != null:
return weakPassword(_that);case AuthInvalidEmail() when invalidEmail != null:
return invalidEmail(_that);case AuthAccountExists() when accountExists != null:
return accountExists(_that);case AuthUseProvider() when useProvider != null:
return useProvider(_that);case AuthUnknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthCancelled value)  cancelled,required TResult Function( AuthOffline value)  offline,required TResult Function( AuthWrongPassword value)  wrongPassword,required TResult Function( AuthWeakPassword value)  weakPassword,required TResult Function( AuthInvalidEmail value)  invalidEmail,required TResult Function( AuthAccountExists value)  accountExists,required TResult Function( AuthUseProvider value)  useProvider,required TResult Function( AuthUnknown value)  unknown,}){
final _that = this;
switch (_that) {
case AuthCancelled():
return cancelled(_that);case AuthOffline():
return offline(_that);case AuthWrongPassword():
return wrongPassword(_that);case AuthWeakPassword():
return weakPassword(_that);case AuthInvalidEmail():
return invalidEmail(_that);case AuthAccountExists():
return accountExists(_that);case AuthUseProvider():
return useProvider(_that);case AuthUnknown():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthCancelled value)?  cancelled,TResult? Function( AuthOffline value)?  offline,TResult? Function( AuthWrongPassword value)?  wrongPassword,TResult? Function( AuthWeakPassword value)?  weakPassword,TResult? Function( AuthInvalidEmail value)?  invalidEmail,TResult? Function( AuthAccountExists value)?  accountExists,TResult? Function( AuthUseProvider value)?  useProvider,TResult? Function( AuthUnknown value)?  unknown,}){
final _that = this;
switch (_that) {
case AuthCancelled() when cancelled != null:
return cancelled(_that);case AuthOffline() when offline != null:
return offline(_that);case AuthWrongPassword() when wrongPassword != null:
return wrongPassword(_that);case AuthWeakPassword() when weakPassword != null:
return weakPassword(_that);case AuthInvalidEmail() when invalidEmail != null:
return invalidEmail(_that);case AuthAccountExists() when accountExists != null:
return accountExists(_that);case AuthUseProvider() when useProvider != null:
return useProvider(_that);case AuthUnknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  cancelled,TResult Function()?  offline,TResult Function()?  wrongPassword,TResult Function()?  weakPassword,TResult Function()?  invalidEmail,TResult Function( PendingCredential pending)?  accountExists,TResult Function( SignInProvider provider)?  useProvider,TResult Function( String code)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthCancelled() when cancelled != null:
return cancelled();case AuthOffline() when offline != null:
return offline();case AuthWrongPassword() when wrongPassword != null:
return wrongPassword();case AuthWeakPassword() when weakPassword != null:
return weakPassword();case AuthInvalidEmail() when invalidEmail != null:
return invalidEmail();case AuthAccountExists() when accountExists != null:
return accountExists(_that.pending);case AuthUseProvider() when useProvider != null:
return useProvider(_that.provider);case AuthUnknown() when unknown != null:
return unknown(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  cancelled,required TResult Function()  offline,required TResult Function()  wrongPassword,required TResult Function()  weakPassword,required TResult Function()  invalidEmail,required TResult Function( PendingCredential pending)  accountExists,required TResult Function( SignInProvider provider)  useProvider,required TResult Function( String code)  unknown,}) {final _that = this;
switch (_that) {
case AuthCancelled():
return cancelled();case AuthOffline():
return offline();case AuthWrongPassword():
return wrongPassword();case AuthWeakPassword():
return weakPassword();case AuthInvalidEmail():
return invalidEmail();case AuthAccountExists():
return accountExists(_that.pending);case AuthUseProvider():
return useProvider(_that.provider);case AuthUnknown():
return unknown(_that.code);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  cancelled,TResult? Function()?  offline,TResult? Function()?  wrongPassword,TResult? Function()?  weakPassword,TResult? Function()?  invalidEmail,TResult? Function( PendingCredential pending)?  accountExists,TResult? Function( SignInProvider provider)?  useProvider,TResult? Function( String code)?  unknown,}) {final _that = this;
switch (_that) {
case AuthCancelled() when cancelled != null:
return cancelled();case AuthOffline() when offline != null:
return offline();case AuthWrongPassword() when wrongPassword != null:
return wrongPassword();case AuthWeakPassword() when weakPassword != null:
return weakPassword();case AuthInvalidEmail() when invalidEmail != null:
return invalidEmail();case AuthAccountExists() when accountExists != null:
return accountExists(_that.pending);case AuthUseProvider() when useProvider != null:
return useProvider(_that.provider);case AuthUnknown() when unknown != null:
return unknown(_that.code);case _:
  return null;

}
}

}

/// @nodoc


class AuthCancelled implements AuthFailure {
  const AuthCancelled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthCancelled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.cancelled()';
}


}




/// @nodoc


class AuthOffline implements AuthFailure {
  const AuthOffline();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthOffline);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.offline()';
}


}




/// @nodoc


class AuthWrongPassword implements AuthFailure {
  const AuthWrongPassword();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthWrongPassword);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.wrongPassword()';
}


}




/// @nodoc


class AuthWeakPassword implements AuthFailure {
  const AuthWeakPassword();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthWeakPassword);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.weakPassword()';
}


}




/// @nodoc


class AuthInvalidEmail implements AuthFailure {
  const AuthInvalidEmail();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthInvalidEmail);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.invalidEmail()';
}


}




/// @nodoc


class AuthAccountExists implements AuthFailure {
  const AuthAccountExists(this.pending);
  

 final  PendingCredential pending;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAccountExistsCopyWith<AuthAccountExists> get copyWith => _$AuthAccountExistsCopyWithImpl<AuthAccountExists>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAccountExists&&(identical(other.pending, pending) || other.pending == pending));
}


@override
int get hashCode => Object.hash(runtimeType,pending);

@override
String toString() {
  return 'AuthFailure.accountExists(pending: $pending)';
}


}

/// @nodoc
abstract mixin class $AuthAccountExistsCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory $AuthAccountExistsCopyWith(AuthAccountExists value, $Res Function(AuthAccountExists) _then) = _$AuthAccountExistsCopyWithImpl;
@useResult
$Res call({
 PendingCredential pending
});




}
/// @nodoc
class _$AuthAccountExistsCopyWithImpl<$Res>
    implements $AuthAccountExistsCopyWith<$Res> {
  _$AuthAccountExistsCopyWithImpl(this._self, this._then);

  final AuthAccountExists _self;
  final $Res Function(AuthAccountExists) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? pending = null,}) {
  return _then(AuthAccountExists(
null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as PendingCredential,
  ));
}


}

/// @nodoc


class AuthUseProvider implements AuthFailure {
  const AuthUseProvider(this.provider);
  

 final  SignInProvider provider;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUseProviderCopyWith<AuthUseProvider> get copyWith => _$AuthUseProviderCopyWithImpl<AuthUseProvider>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUseProvider&&(identical(other.provider, provider) || other.provider == provider));
}


@override
int get hashCode => Object.hash(runtimeType,provider);

@override
String toString() {
  return 'AuthFailure.useProvider(provider: $provider)';
}


}

/// @nodoc
abstract mixin class $AuthUseProviderCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory $AuthUseProviderCopyWith(AuthUseProvider value, $Res Function(AuthUseProvider) _then) = _$AuthUseProviderCopyWithImpl;
@useResult
$Res call({
 SignInProvider provider
});




}
/// @nodoc
class _$AuthUseProviderCopyWithImpl<$Res>
    implements $AuthUseProviderCopyWith<$Res> {
  _$AuthUseProviderCopyWithImpl(this._self, this._then);

  final AuthUseProvider _self;
  final $Res Function(AuthUseProvider) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? provider = null,}) {
  return _then(AuthUseProvider(
null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SignInProvider,
  ));
}


}

/// @nodoc


class AuthUnknown implements AuthFailure {
  const AuthUnknown(this.code);
  

 final  String code;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUnknownCopyWith<AuthUnknown> get copyWith => _$AuthUnknownCopyWithImpl<AuthUnknown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUnknown&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'AuthFailure.unknown(code: $code)';
}


}

/// @nodoc
abstract mixin class $AuthUnknownCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory $AuthUnknownCopyWith(AuthUnknown value, $Res Function(AuthUnknown) _then) = _$AuthUnknownCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$AuthUnknownCopyWithImpl<$Res>
    implements $AuthUnknownCopyWith<$Res> {
  _$AuthUnknownCopyWithImpl(this._self, this._then);

  final AuthUnknown _self;
  final $Res Function(AuthUnknown) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(AuthUnknown(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
