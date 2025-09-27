import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_registry.dart';
import '../data/mock_scenarios.dart';

final AutoDisposeAsyncNotifierProvider<OnboardingMockNotifier, OnboardingMockViewModel> onboardingMockProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingMockNotifier, OnboardingMockViewModel>(OnboardingMockNotifier.new);

class OnboardingMockNotifier extends AutoDisposeAsyncNotifier<OnboardingMockViewModel> {
  @override
  Future<OnboardingMockViewModel> build() async {
    final Map<String, dynamic> data = await MockRegistry.instance.loadScenario(MockScenario.defaultHappyPath);
    final Map<String, dynamic> onboarding = (data['onboarding'] as Map<String, dynamic>? ?? <String, dynamic>{});
    return OnboardingMockViewModel(
      headline: onboarding['headline'] as String? ?? 'Welcome',
      steps: onboarding['steps'] as int? ?? 3,
    );
  }

  void completeOnboarding() {
    ref.invalidateSelf();
  }
}

class OnboardingMockViewModel {
  const OnboardingMockViewModel({required this.headline, required this.steps});

  final String headline;
  final int steps;
}
