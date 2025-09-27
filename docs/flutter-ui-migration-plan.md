# OneKey Mobile UI Migration Plan (React Native ➜ Flutter)

## 1. Current React Native Architecture Overview

### 1.1 Application Shell and Providers
- The mobile entry point renders the shared `KitProvider` inside a Sentry error boundary, so the Flutter app needs an equivalent top-level provider tree and crash boundary wrapper.【F:apps/mobile/App.tsx†L1-L8】
- `KitProvider` loads the Inter font family, mounts safe-area and gesture handlers, wraps navigation in theming, and injects multiple global providers (keyboard, splash, locale tracker, Jotai readiness, etc.), which informs the Flutter provider stack and initialization order.【F:packages/kit/src/provider/index.tsx†L1-L91】
- Global Jotai readiness gates rendering until persisted UI state is hydrated; the Flutter app should mirror this by delaying rendering until mock stores are ready.【F:packages/kit/src/components/GlobalJotaiReady/GlobalJotaiReady.tsx†L1-L23】

### 1.2 Navigation Structure
- A root stack (`rootRouter`) orchestrates the main tab navigator, modal stack, and iOS fullscreen flows, with optional permission and developer routes in dev builds.【F:packages/kit/src/routes/router.ts†L1-L78】
- The tab navigator composes Home, Market, Swap, Earn, Discovery, Perp, Refer Friends, Device Management, Me, and Developer sections, toggled by runtime flags. Each tab embeds its own stack navigator and custom tab bar behavior.【F:packages/kit/src/routes/Tab/router.ts†L1-L260】
- The shared navigation components rely on `@react-navigation` stack/tab APIs with device-aware layouts (bottom vs. left tab bar, lazy loading), which will map to Flutter's `Navigator`/`go_router` or `auto_route` with responsive bottom/navigation rail widgets.【F:packages/components/src/layouts/Navigation/Navigator/TabStackNavigator.tsx†L1-L140】

### 1.3 Screen Inventory and Feature Areas
- Feature directories in `packages/kit/src/views` define the full screen catalog (e.g., Home, Market, Swap, Onboarding, Device Management, Approval Management, Signature flows, Cloud Backup, etc.), each containing `pages`, `components`, `hooks`, and `router` definitions.
- These directories reveal the functional surface that must be visually replicated in Flutter, including onboarding, account/wallet management, asset details, DeFi, staking, market data, discovery browser, notifications, settings, support utilities, and developer/test modals.

#### 1.3.1 Screen Inventory Breakdown
The table below lists the primary React Native feature folders, the representative screens contained in each, and the corresponding Flutter feature module that must be produced. Screen names are derived from the `pages/` sub-directories for each feature.

| React Native Feature Folder | Representative Screens / Flows | Flutter Module Target |
| --- | --- | --- |
| `Onboarding` | Welcome carousel, create/import wallet flow, biometric opt-in, passcode setup, legal terms, experience mode switcher.【F:packages/kit/src/views/Onboarding/pages/GetStarted/GetStarted.tsx†L1-L58】【F:packages/kit/src/views/Onboarding/pages/FinalizeWalletSetup.tsx†L1-L200】 | `features/onboarding/` with `pages/` mirroring each step and shared reusable widgets for forms, carousel indicators, and passcode keypad. |
| `Home` | Dashboard overview, portfolio chart, token/NFT lists, transaction history, quick actions sheet, approval list.【F:packages/kit/src/views/Home/pages/HomePageView.tsx†L1-L160】【F:packages/kit/src/views/Home/pages/TokenListContainer.tsx†L1-L160】 | `features/home/` containing composable dashboards, list views, and tab header widgets backed by mock portfolio providers. |
| `AccountManagerStacks` & `WalletAddress` | Account selector sheet, wallet overview, derivation path chooser, linked accounts, address detail view with QR, account edit flow.【F:packages/kit/src/views/AccountManagerStacks/pages/AccountSelectorStack/index.tsx†L1-L80】【F:packages/kit/src/views/WalletAddress/pages/WalletAddress/index.tsx†L1-L200】 | `features/account_management/` with nested navigation for sheet-style pickers and QR preview dialogs. |
| `AssetDetails`, `AssetList`, `Market` | Token detail header, charts, activity tabs, price alert modals, market explorer, watchlist, top movers.【F:packages/kit/src/views/AssetDetails/pages/TokenDetails/TokenDetailsView.tsx†L1-L157】【F:packages/kit/src/views/Market/MarketHomeV2/MarketHomeV2.tsx†L1-L120】 | `features/market/` exposing modular widgets for charts (mocked), segmented controls, and filter drawers. |
| `Swap`, `Perp`, `Earn`, `Staking` | Swap form, quote review, slippage settings, DEX routing summary, perpetual trading layout, staking/earn product cards and detail sheets.【F:packages/kit/src/views/Swap/pages/SwapPageContainer.tsx†L1-L22】【F:packages/kit/src/views/Perp/pages/Perp.tsx†L1-L200】【F:packages/kit/src/views/Earn/EarnHome.tsx†L1-L160】【F:packages/kit/src/views/Staking/pages/Stake/index.tsx†L1-L200】 | `features/trade/` subdivided into `swap/`, `perp/`, `earn/`, `staking/` with specialized controllers simulating quotes and yields. |
| `Send`, `Receive`, `ApprovalManagement`, `SignatureConfirm`, `SignAndVerifyMessage` | Send asset wizard (amount, address, fee), QR receive sheet, pending approval queue, signature confirmation modals, message signing interface.【F:packages/kit/src/views/Send/pages/SendDataInput/SendDataInputContainer.tsx†L1-L200】【F:packages/kit/src/views/ApprovalManagement/pages/ApprovalList.tsx†L1-L200】【F:packages/kit/src/views/SignatureConfirm/pages/TxConfirm/TxConfirm.tsx†L1-L200】 | `features/transactions/` covering send/receive/approval/signature flows with bottom sheet routing and validation messaging. |
| `DeviceManagement`, `FirmwareUpdate`, `ManualBackup`, `CloudBackup`, `KeyTag` | Hardware wallet pairing wizard, firmware upgrade status, manual backup checklist, cloud backup steps, key tag engraving preview.【F:packages/kit/src/views/DeviceManagement/pages/DeviceDetailsModal/index.tsx†L1-L148】【F:packages/kit/src/views/ManualBackup/router/index.tsx†L1-L24】【F:packages/kit/src/views/CloudBackup/pages/Home/index.tsx†L1-L148】【F:packages/kit/src/views/KeyTag/pages/BackupWallet/index.tsx†L1-L120】 | `features/security/` for device, backup, and key tag flows with progress steppers, checklist widgets, and mock connectivity states. |
| `Discovery`, `WebView`, `DAppConnection`, `UniversalSearch` | DApp browser tabs, featured dApp cards, webview wrapper, dApp permission prompt, global search UI with categories.【F:packages/kit/src/views/Discovery/pages/Browser/Browser.native.tsx†L1-L200】【F:packages/kit/src/views/DAppConnection/pages/ConnectionModal.tsx†L1-L200】【F:packages/kit/src/views/UniversalSearch/pages/UniversalSearch.tsx†L1-L200】 | `features/discovery/` providing mock webview placeholders, dApp catalog lists, search results, and permission modals. |
| `Notifications`, `RewardCenter`, `ReferFriends`, `Prime`, `LightningNetwork` | Notification center, reward missions, refer friends invite flow, Prime subscription upsell, Lightning network status views.【F:packages/kit/src/views/Notifications/pages/NotificationList.tsx†L1-L200】【F:packages/kit/src/views/RewardCenter/pages/RewardCenter.tsx†L1-L200】【F:packages/kit/src/views/ReferFriends/pages/ReferAFriend/index.tsx†L1-L160】【F:packages/kit/src/views/Prime/pages/PrimeDashboard/PrimeBenefitsList.tsx†L1-L160】【F:packages/kit/src/views/LightningNetwork/pages/Send/LnurlPayRequestModal.tsx†L1-L200】 | `features/engagement/` to handle feeds, progress trackers, reward cards, and sharing sheets. |
| `Setting`, `Developer`, `TestModal`, `Permission`, `AppUpdate`, `Shortcuts` | Settings categories, language/theme selection, developer toggles, runtime permission prompts, app update dialog, shortcuts editor.【F:packages/kit/src/views/Setting/pages/Tab/SubSettings.tsx†L1-L51】【F:packages/kit/src/views/Developer/pages/DevHome.tsx†L1-L160】【F:packages/kit/src/views/TestModal/pages/TestSimpleModal.tsx†L1-L160】【F:packages/kit/src/views/Permission/PromptWebDeviceAccessPage.tsx†L1-L145】【F:packages/kit/src/views/AppUpdate/pages/UpdatePreview.tsx†L1-L78】【F:packages/kit/src/views/Shortcuts/pages/ShortcutsPreview.tsx†L1-L197】 | `features/settings/` encapsulating deeply nested navigation, grouped preference tiles, debug utilities, and modal overlays. |

This inventory should be validated during the discovery phase by cross-referencing navigation route registrations (e.g., `packages/kit/src/routes`) to ensure no modal or secondary screen is omitted.

### 1.4 UI Composition and Theming
- The React Native stack centralizes UI primitives inside `@onekeyhq/components`, providing design tokens, themed navigation containers, and responsive hooks. Flutter must recreate these primitives (typography, colors, elevation, spacings) as reusable widgets to ensure consistency.【F:packages/components/src/layouts/Navigation/Navigator/TabStackNavigator.tsx†L19-L139】
- Platform guards (`platformEnv`) drive conditional UI variants (e.g., discover tab visibility, landscape iPad tab rail). Flutter should inspect `Platform`/`MediaQuery` to reproduce equivalent behavior.【F:packages/kit/src/routes/Tab/router.ts†L72-L260】

### 1.5 UI State Management Patterns
- UI state is primarily handled via Jotai atoms persisted through background services, with readiness gating (`GlobalJotaiReady`) before rendering.【F:packages/kit/src/components/GlobalJotaiReady/GlobalJotaiReady.tsx†L1-L23】
- Background interactions (`backgroundApiProxy`) trigger side effects for tab presses and modals; in the mock Flutter app these calls will be replaced with local controllers and simulated responses.【F:packages/kit/src/routes/Tab/router.ts†L27-L256】

## 2. Target Flutter Architecture

### 2.1 Project Setup
- Create a standalone Flutter project (`onekey_ui_mock/`) targeting Android and iOS with Flutter 3.x, Dart 3.x, null safety enabled, and modern folder layout (`lib/`, `assets/`, `test/`, `integration_test/`).
- Enforce linting (`flutter_lints`), localization (`intl`), and theming via centralized design tokens (`ThemeData` extensions) to mirror OneKey's style guide.

### 2.2 Flutter Folder Structure
```
onekey_ui_mock/
├── lib/
│   ├── app.dart                # Root widgets, providers, navigation shell
│   ├── bootstrap.dart          # Mock data bootstrapping & readiness gating
│   ├── theme/                  # Color schemes, typography, spacing constants
│   ├── router/                 # Navigator 2.0 configuration mirroring stacks/modals
│   ├── features/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── market/
│   │   ├── swap/
│   │   ├── earn/
│   │   ├── discovery/
│   │   ├── perp/
│   │   ├── device_management/
│   │   ├── approvals/
│   │   ├── notifications/
│   │   ├── settings/
│   │   ├── staking/
│   │   ├── cloud_backup/
│   │   ├── address_book/
│   │   └── ... (mirrors every `views/*` directory)
│   ├── shared/
│   │   ├── widgets/            # Reusable Flutter components equivalent to RN kit
│   │   ├── layout/             # Responsive scaffolds, modals, tab bars
│   │   ├── controllers/        # Mock state notifiers replacing Jotai atoms
│   │   └── services/           # Mock service layer for simulated operations
│   └── mocks/
│       ├── data/               # JSON/yaml fixtures for accounts, assets, history
│       ├── scenarios/          # Edge-case datasets (empty, error, large lists)
│       └── adapters/           # Helper classes to serve mock responses
└── assets/
    ├── fonts/
    ├── images/
    └── lottie/
```

### 2.3 Navigation Design
- Adopt `go_router` or `auto_route` to replicate stacked navigation, nested tab flows, and modal/fullscreen presentations. Configure:
  - Root shell with tabs (Home, Market, Swap, Earn, Discovery/Perp, Refer Friends, Device, Settings/More) matching `rootRouter` and `useTabRouterConfig` semantics.
  - Nested `ShellRoute`/`StatefulNavigationShell` to mimic per-tab stacks and allow deep linking.
  - Custom `BottomNavigationBar` that can switch to a side rail for tablets/landscape per the RN implementation.
  - Modal routes using `showModalBottomSheet`, `PageRouteBuilder`, or `go_router` `CustomTransitionPage` to imitate React Navigation modal stack behaviors.

### 2.4 Widget Mapping Strategy
| React Native Concept | Flutter Equivalent | Notes |
| --- | --- | --- |
| `SafeAreaProvider`, gesture root, keyboard provider | `SafeArea`, `GestureDetector`, `FocusScope`, `RawKeyboardListener` wrappers | Compose inside a root `GestureBinding` friendly widget. |
| `@onekeyhq/components` buttons, forms, icons | Flutter `Widget` library + custom themed `Button`, `FormField`, `Icon` widgets built atop `Material 3` components | Centralize tokens in `theme/`. |
| React Navigation stack/tab/modal | `go_router` / `Navigator` with `Page` API, custom `BottomNavigationBar`, `ModalRoute` | Provide fade/slide animations consistent with RN. |
| `LazyLoad` dynamic imports | Deferred widget initialization with `FutureBuilder`/`DeferredWidget` + `compute` if needed | Keep skeleton/loading states identical. |
| Jotai atoms | `Riverpod` or `Provider` + `StateNotifier` with `FutureProvider` for async mocks | Enables modular mock data injection. |
| Animated RN components (`reanimated`) | Flutter `ImplicitlyAnimatedWidget`, `AnimationController`, `Hero`, `AnimatedSwitcher` | Ensure micro-interactions replicate current UX. |

### 2.5 Component Library Parity Plan
- Build a dedicated `shared/widgets` package featuring atomic widgets that match `@onekeyhq/components` primitives (buttons, icon buttons, list items, segmented controls, switches, text fields). Each widget should expose the same prop surface as the RN counterpart to simplify QA comparisons.
- Provide theming extensions (`ThemeData` + custom `OneKeyTheme`) for color roles (surface, elevation overlay, status colors), text styles, spacing, corner radii, and shadows derived from the existing design tokens in `packages/components/src/Provider/theme.ts`.
- Mirror utility hooks (`useIsVerticalLayout`, `useMedia`, `useNavigation`) as Flutter services/classes so screen ports can stay close to the RN implementation semantics.
- Maintain a Storybook-style `WidgetGallery` screen in Flutter for designers to sign off on component parity before integrating into feature screens.

### 2.6 Platform Adaptations
- Use `MediaQuery`, `LayoutBuilder`, and `flutter_displaymode` (optional) to handle responsive layout toggles analogous to `useMedia`/`platformEnv` flags.【F:packages/kit/src/routes/Tab/router.ts†L72-L260】
- Mirror haptic feedback (`HapticFeedback`) and safe-area padding adjustments for iOS/Android parity.

## 3. Mock Data and API Simulation

### 3.1 Mock Data Principles
- Replace background services with mock repositories returning deterministic responses for wallet accounts, assets, market data, swap quotes, earning products, device lists, notification feeds, and settings.
- Store fixtures as JSON and load via `rootBundle` during bootstrap to ensure offline stability.

### 3.2 State & Scenario Coverage
- Provide multiple datasets per feature: default (happy path), empty, error, loading skeleton, stress (large lists), and edge cases (expired approvals, pending swaps, staking lockups, etc.).
- Build scenario toggles (debug drawer) that allows switching mock datasets at runtime, replacing developer/test modals currently available in RN builds.

### 3.3 Interaction Simulation
- Define mock controllers for actions (send transaction, backup seed, connect dApp, approve signature) that update UI state locally and emit toast/snackbar feedback to emulate success/failure.
- For navigation-triggering actions (e.g., pressing Refer Friends or Device Management tab), intercept the event and open the appropriate modal/tab without performing network operations.【F:packages/kit/src/routes/Tab/router.ts†L200-L256】
- Use `Future.delayed` to mimic latency and animate skeleton placeholders before resolving UI states.

### 3.4 Testing Mock Data
- Write widget tests ensuring each screen renders correctly for all mock scenarios.
- Create integration tests covering core journeys (onboarding ➜ wallet home ➜ send ➜ confirmations) using mock controllers.

### 3.5 Mock Data Schemas and Storage
- Define strongly typed Dart models for every UI surface (e.g., `WalletAccount`, `TokenPosition`, `SwapQuote`, `DeviceStatus`, `RewardMission`) that mirror the TypeScript interfaces used today (`packages/kit/src/store/types`). Keep fields comprehensive enough to drive all states, including metadata such as tooltips, tags, deep-link targets, and experiment flags.【F:packages/kit/src/store/types.ts†L1-L240】
- Organize mock fixtures under `lib/mocks/data/` grouped by feature; each dataset should include localized strings, image asset references, and timestamps so UI formatting logic can be exercised.
- Provide scenario descriptors (`MockScenario` enum) and a central registry mapping scenarios to fixture loaders. This supports runtime scenario switching and automated tests that iterate through all states.
- Store base fixtures as JSON; use adapters to hydrate Dart models and allow overrides so QA can craft additional datasets without touching code.

## 4. Flutter State Management Blueprint
- Adopt `Riverpod` (or `flutter_bloc` if preferred) to encapsulate UI state per feature, aligning with how Jotai atoms isolate concerns today.【F:packages/kit/src/components/GlobalJotaiReady/GlobalJotaiReady.tsx†L1-L23】
- Initialize providers in `bootstrap.dart`, load fixtures asynchronously, and expose readiness via a `FutureProvider`, mirroring `GlobalJotaiReady` gating.
- Encapsulate navigation-triggering side effects (e.g., `backgroundApiProxy` calls) in `AsyncNotifier` classes returning `MockResult` objects to keep UI reactive without backend dependencies.【F:packages/kit/src/routes/Tab/router.ts†L27-L256】
- Compose feature providers so they can be swapped for real implementations later by exposing interfaces (e.g., `abstract class WalletRepository`). Mock repositories implement these interfaces today, while production repositories can be injected through the same Riverpod overrides during future integration work.
- Introduce a lightweight `EventBus` or `StreamController` wrapper to mimic cross-feature toasts, banners, and dialogs triggered from background calls in the RN app. Riverpod providers can publish events consumed by presentation widgets.
- Ensure each provider exposes loading/error/empty unions (e.g., sealed classes using `freezed`) so UI widgets can bind to the appropriate state without additional glue logic.

## 5. Implementation Roadmap (UI Priority Order)

1. **Foundation (Week 1-2)**
   - Scaffold Flutter project, theming system, typography, iconography, and custom tab/navigation shell.
   - Implement mock bootstrap pipeline and readiness gate replicating provider tree semantics.
2. **Primary Wallet Journeys (Week 3-5)**
   - Onboarding, account creation/import, landing dashboard, account switchers, portfolio charts, asset lists/details, receive/send flows.
   - Ensure modal flows (address selection, QR scanner mock, confirmation sheets) match RN transitions.
3. **Trading & Market Features (Week 5-7)**
   - Market overview, asset search, swap UI, earn/staking products, Perp UI (with stubbed charts and order books), fiat on-ramp mock integrations.
4. **Device & Security Management (Week 7-8)**
   - Device management dashboards, firmware update screens, manual/cloud backup flows, approval management, signature confirmation, key tag, shortcuts.
5. **Discovery & Notifications (Week 8-9)**
   - Discovery browser shell with tabbed dApp catalog (mock webview screenshots or placeholders), notifications center, refer friends program, reward center.
6. **Settings & Utilities (Week 9-10)**
   - Comprehensive settings, developer/test modals, address book, universal search, QR scanner mocks, app update prompts, prime membership surfaces, landing/landing alternatives.
7. **Polish & QA (Week 10-11)**
   - Animation tuning, responsive breakpoints, tablet optimizations, accessibility (semantics, screen reader order), localization scaffolding, regression widget tests.

8. **Sign-off & Transition (Week 12)**
   - Conduct side-by-side device reviews with designers, create visual diff reports, document known gaps, and prepare a backlog for post-mock integration tasks (e.g., replacing mocks with real APIs once available).

## 6. Delivery Checklist
- ✔️ Flutter project repository with documented setup instructions.
- ✔️ Navigation graph mirroring RN routes and modal hierarchies.
- ✔️ Feature modules mapped 1:1 with React Native `views/*` directories.
- ✔️ Mock data catalog covering all UI states and toggleable scenarios.
- ✔️ Component library reproducing OneKey visuals (buttons, forms, cards, list rows, charts, toasts).
- ✔️ Automated widget/integration tests for core journeys and edge cases.
- ✔️ Design parity review checklist comparing each Flutter screen to the existing RN counterpart.

## 7. Execution Kickoff Snapshot
- Scaffolded the standalone Flutter workspace under `flutter_mock_app/` with linting, theming, router shell, and mock bootstrap aligned with the architecture blueprint.【F:flutter_mock_app/README.md†L1-L36】【F:flutter_mock_app/lib/app.dart†L1-L54】
- Seeded foundational feature modules (Onboarding, Home) driven by Riverpod-powered mock services to validate the mock data registry and navigation flow.【F:flutter_mock_app/lib/features/onboarding/pages/get_started_page.dart†L1-L74】【F:flutter_mock_app/lib/features/home/pages/home_dashboard_page.dart†L1-L60】
- Implemented a centralized mock scenario loader with JSON fixtures to underpin future feature development and scenario toggling.【F:flutter_mock_app/lib/mocks/data/mock_registry.dart†L1-L36】【F:flutter_mock_app/assets/mocks/default.json†L1-L16】
