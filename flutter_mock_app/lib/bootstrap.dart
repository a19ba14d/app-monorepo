import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mocks/data/mock_registry.dart';

final readinessProvider = FutureProvider<void>((ref) async {
  await MockRegistry.instance.initialize();
});

Future<void> bootstrapApp() async {
  await MockRegistry.instance.initialize();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
