import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../mocks/services/onboarding_mock_service.dart';
import '../../../shared/widgets/primary_button.dart';

class GetStartedPage extends ConsumerWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<OnboardingMockViewModel> viewModel = ref.watch(onboardingMockProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: viewModel.when(
            data: (OnboardingMockViewModel data) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  data.headline,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView.builder(
                    itemCount: data.steps,
                    itemBuilder: (BuildContext context, int index) {
                      return _OnboardingStep(index: index + 1, total: data.steps);
                    },
                  ),
                ),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () => ref.read(onboardingMockProvider.notifier).completeOnboarding(),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => Center(
              child: Text('Failed to load onboarding: $error'),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Step $index of $total'),
        const SizedBox(height: 12),
        const Placeholder(fallbackHeight: 200),
      ],
    );
  }
}
