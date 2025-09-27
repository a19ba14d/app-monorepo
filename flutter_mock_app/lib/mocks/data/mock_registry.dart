import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'mock_scenarios.dart';

class MockRegistry {
  MockRegistry({required this.defaultScenario});

  final MockScenario defaultScenario;
  final Map<MockScenario, Future<Map<String, dynamic>>> _scenarioLoaders = <MockScenario, Future<Map<String, dynamic>>>{};
  bool _initialized = false;

  static final MockRegistry instance = MockRegistry(defaultScenario: MockScenario.defaultHappyPath);

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await _warmScenario(defaultScenario);
    _initialized = true;
  }

  Future<Map<String, dynamic>> loadScenario(MockScenario scenario) {
    return _scenarioLoaders.putIfAbsent(scenario, () async {
      final String assetPath = scenario.assetPath;
      final String json = await rootBundle.loadString(assetPath);
      return json.isEmpty ? <String, dynamic>{} : jsonDecode(json) as Map<String, dynamic>;
    });
  }

  Future<void> _warmScenario(MockScenario scenario) async {
    await loadScenario(scenario);
  }
}
