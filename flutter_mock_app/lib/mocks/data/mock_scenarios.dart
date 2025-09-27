enum MockScenario {
  defaultHappyPath('assets/mocks/default.json'),
  emptyState('assets/mocks/empty.json'),
  errorState('assets/mocks/error.json');

  const MockScenario(this.assetPath);

  final String assetPath;
}
