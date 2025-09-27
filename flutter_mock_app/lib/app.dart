import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';
import 'router/app_router.dart';
import 'theme/onekey_theme.dart';

class OneKeyMockApp extends ConsumerWidget {
  const OneKeyMockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> readiness = ref.watch(readinessProvider);

    return readiness.when(
      data: (_) => MaterialApp.router(
        title: 'OneKey UI Mock',
        routerConfig: ref.watch(appRouterProvider),
        theme: buildOneKeyTheme(brightness: Brightness.light),
        darkTheme: buildOneKeyTheme(brightness: Brightness.dark),
        themeMode: ThemeMode.system,
      ),
      loading: () => MaterialApp(
        theme: buildOneKeyTheme(brightness: Brightness.light),
        home: const _SplashScreen(),
      ),
      error: (Object error, StackTrace stackTrace) => MaterialApp(
        theme: buildOneKeyTheme(brightness: Brightness.light),
        home: _ErrorScreen(error: error),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Failed to initialize mocks: $error'),
      ),
    );
  }
}
