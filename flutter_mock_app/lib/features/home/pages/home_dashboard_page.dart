import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../mocks/services/home_mock_service.dart';
import '../../../shared/widgets/primary_button.dart';

class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeMockViewModel> state = ref.watch(homeMockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: state.when(
        data: (HomeMockViewModel data) => RefreshIndicator(
          onRefresh: () => ref.read(homeMockProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              Text(
                data.balanceLabel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                data.balanceFormatted,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Send',
                onPressed: () => ref.read(homeMockProvider.notifier).triggerAction(HomeQuickAction.send),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Receive',
                onPressed: () => ref.read(homeMockProvider.notifier).triggerAction(HomeQuickAction.receive),
              ),
              const SizedBox(height: 24),
              Text('Assets', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              for (final AssetRow asset in data.assets)
                Card(
                  child: ListTile(
                    title: Text(asset.name),
                    subtitle: Text(asset.subtitle),
                    trailing: Text(asset.balance),
                  ),
                ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Text('Failed to load home: $error'),
        ),
      ),
    );
  }
}
