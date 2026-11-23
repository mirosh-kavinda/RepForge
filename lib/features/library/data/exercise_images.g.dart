// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_images.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exerciseImage)
final exerciseImageProvider = ExerciseImageProvider._();

final class ExerciseImageProvider
    extends
        $FunctionalProvider<
          ImageProvider<Object> Function(String path),
          ImageProvider<Object> Function(String path),
          ImageProvider<Object> Function(String path)
        >
    with $Provider<ImageProvider<Object> Function(String path)> {
  ExerciseImageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseImageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseImageHash();

  @$internal
  @override
  $ProviderElement<ImageProvider<Object> Function(String path)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImageProvider<Object> Function(String path) create(Ref ref) {
    return exerciseImage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ImageProvider<Object> Function(String path) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<ImageProvider<Object> Function(String path)>(
            value,
          ),
    );
  }
}

String _$exerciseImageHash() => r'01a66859e07e23a0de6f026c5f852f0d7b6dbff7';
