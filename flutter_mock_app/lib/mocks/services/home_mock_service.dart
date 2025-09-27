import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_registry.dart';
import '../data/mock_scenarios.dart';

final AutoDisposeAsyncNotifierProvider<HomeMockNotifier, HomeMockViewModel> homeMockProvider =
    AutoDisposeAsyncNotifierProvider<HomeMockNotifier, HomeMockViewModel>(HomeMockNotifier.new);

enum HomeQuickAction { send, receive, buy, swap }

class HomeMockNotifier extends AutoDisposeAsyncNotifier<HomeMockViewModel> {
  @override
  Future<HomeMockViewModel> build() async {
    final Map<String, dynamic> data = await MockRegistry.instance.loadScenario(MockScenario.defaultHappyPath);
    final Map<String, dynamic> home = (data['home'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final List<dynamic> assetsRaw = home['assets'] as List<dynamic>? ?? <dynamic>[];
    return HomeMockViewModel(
      balanceLabel: home['balanceLabel'] as String? ?? 'Total Balance',
      balanceFormatted: home['balanceFormatted'] as String? ?? '$123,456.78',
      assets: assetsRaw
          .map((dynamic item) => AssetRow(
                name: item['name'] as String? ?? 'Token',
                subtitle: item['subtitle'] as String? ?? 'Network',
                balance: item['balance'] as String? ?? '0.00',
              ))
          .toList(),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  void triggerAction(HomeQuickAction action) {
    // Later this will fan out to navigation events or mock flows.
  }
}

class HomeMockViewModel {
  const HomeMockViewModel({required this.balanceLabel, required this.balanceFormatted, required this.assets});

  final String balanceLabel;
  final String balanceFormatted;
  final List<AssetRow> assets;
}

class AssetRow {
  const AssetRow({required this.name, required this.subtitle, required this.balance});

  final String name;
  final String subtitle;
  final String balance;
}
