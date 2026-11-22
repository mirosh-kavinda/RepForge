// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

final class OnboardingControllerProvider
    extends $NotifierProvider<OnboardingController, OnboardingDraft> {
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingDraft>(value),
    );
  }
}

String _$onboardingControllerHash() =>
    r'307458fa8b46fb50b22e8c98c8a7acd6383df189';

abstract class _$OnboardingController extends $Notifier<OnboardingDraft> {
  OnboardingDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingDraft, OnboardingDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingDraft, OnboardingDraft>,
              OnboardingDraft,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
