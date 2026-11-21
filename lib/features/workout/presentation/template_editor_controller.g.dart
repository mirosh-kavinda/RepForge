// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TemplateEditor)
final templateEditorProvider = TemplateEditorFamily._();

final class TemplateEditorProvider
    extends $AsyncNotifierProvider<TemplateEditor, EditorState> {
  TemplateEditorProvider._({
    required TemplateEditorFamily super.from,
    required ({String? id, String? copyOf}) super.argument,
  }) : super(
         retry: null,
         name: r'templateEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$templateEditorHash();

  @override
  String toString() {
    return r'templateEditorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  TemplateEditor create() => TemplateEditor();

  @override
  bool operator ==(Object other) {
    return other is TemplateEditorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$templateEditorHash() => r'0598b86ae6c0793a0c076e27973baad20d9ee6f1';

final class TemplateEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          TemplateEditor,
          AsyncValue<EditorState>,
          EditorState,
          FutureOr<EditorState>,
          ({String? id, String? copyOf})
        > {
  TemplateEditorFamily._()
    : super(
        retry: null,
        name: r'templateEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TemplateEditorProvider call({String? id, String? copyOf}) =>
      TemplateEditorProvider._(argument: (id: id, copyOf: copyOf), from: this);

  @override
  String toString() => r'templateEditorProvider';
}

abstract class _$TemplateEditor extends $AsyncNotifier<EditorState> {
  late final _$args = ref.$arg as ({String? id, String? copyOf});
  String? get id => _$args.id;
  String? get copyOf => _$args.copyOf;

  FutureOr<EditorState> build({String? id, String? copyOf});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EditorState>, EditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EditorState>, EditorState>,
              AsyncValue<EditorState>,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(id: _$args.id, copyOf: _$args.copyOf),
    );
  }
}
