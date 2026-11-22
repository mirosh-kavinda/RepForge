// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CycleEditor)
final cycleEditorProvider = CycleEditorFamily._();

final class CycleEditorProvider
    extends $AsyncNotifierProvider<CycleEditor, CycleDraft> {
  CycleEditorProvider._({
    required CycleEditorFamily super.from,
    required ({String? id, String? copyOf}) super.argument,
  }) : super(
         retry: null,
         name: r'cycleEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cycleEditorHash();

  @override
  String toString() {
    return r'cycleEditorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CycleEditor create() => CycleEditor();

  @override
  bool operator ==(Object other) {
    return other is CycleEditorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cycleEditorHash() => r'a3e132d23562d7826bdceaee063ad398a4be1ff1';

final class CycleEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          CycleEditor,
          AsyncValue<CycleDraft>,
          CycleDraft,
          FutureOr<CycleDraft>,
          ({String? id, String? copyOf})
        > {
  CycleEditorFamily._()
    : super(
        retry: null,
        name: r'cycleEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CycleEditorProvider call({String? id, String? copyOf}) =>
      CycleEditorProvider._(argument: (id: id, copyOf: copyOf), from: this);

  @override
  String toString() => r'cycleEditorProvider';
}

abstract class _$CycleEditor extends $AsyncNotifier<CycleDraft> {
  late final _$args = ref.$arg as ({String? id, String? copyOf});
  String? get id => _$args.id;
  String? get copyOf => _$args.copyOf;

  FutureOr<CycleDraft> build({String? id, String? copyOf});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CycleDraft>, CycleDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CycleDraft>, CycleDraft>,
              AsyncValue<CycleDraft>,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(id: _$args.id, copyOf: _$args.copyOf),
    );
  }
}
