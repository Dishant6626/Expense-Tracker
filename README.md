# ExpenseAI — Flutter Expense Tracker
### NeoSoft Technical Assignment | Round 1

---

## 📁 Project Structure

```
lib/
├── main.dart
├── config/
│   ├── env/
│   │   └── environment.dart          # Dev/Prod env configs + Gemini API key
│   ├── inject/
│   │   ├── injector.dart             # Kiwi DI registrations
│   │   └── injector.g.dart           # Generated DI code
│   ├── routes/
│   │   └── app_routes.dart           # Route name constants
│   └── theme/
│       └── app_theme.dart            # Light theme, typography, component styles
│
├── core/
│   ├── base/
│   │   ├── base_bloc.dart            # BaseBloc, BaseState, ViewAction, ScreenState
│   │   └── event_bus.dart            # Cross-BLoC EventBus (PublishSubject)
│   ├── constants/
│   │   ├── app_constants.dart        # AppConstants, ExpenseCategory enum
│   │   └── color_constants.dart      # All app colors
│   └── services/
│       ├── navigation_service.dart   # GlobalKey<NavigatorState>
│       ├── hive_storage_service.dart # Hive init + box accessors
│       └── gemini_service.dart       # Gemini API: receipt scan + insights
│
└── features/
    ├── dashboard/
    │   ├── bloc/
    │   │   ├── dashboard_bloc.dart   # Load, Delete, Filter, Refresh
    │   │   ├── dashboard_state.dart  # built_value state + events
    │   │   └── dashboard_state.g.dart
    │   └── screens/
    │       ├── dashboard_screen.dart
    │       └── widgets/
    │           ├── spending_summary_card.dart
    │           ├── category_pie_chart.dart   # fl_chart pie
    │           ├── category_chip_filter.dart
    │           └── expense_list_tile.dart    # Dismissible swipe-to-delete
    │
    ├── expense/
    │   ├── bloc/
    │   │   ├── expense_bloc.dart     # Add/Edit/Scan/Save
    │   │   ├── expense_state.dart    # built_value state + events
    │   │   └── expense_state.g.dart
    │   ├── models/
    │   │   ├── expense_model.dart    # Hive @HiveType + ExtractedReceiptData
    │   │   └── expense_model.g.dart
    │   ├── repository/
    │   │   └── expense_repository.dart  # Hive CRUD + filters + stats
    │   └── screens/
    │       ├── add_edit_expense_screen.dart  # Form + AI scanner
    │       └── expense_detail_screen.dart
    │
    └── ai_insights/
        ├── bloc/
        │   ├── ai_insights_bloc.dart
        │   ├── ai_insights_state.dart
        │   └── ai_insights_state.g.dart
        ├── repository/
        │   └── ai_insights_repository.dart   # Wraps GeminiService + caching
        └── screens/
            └── ai_insights_screen.dart
```

---

## 🚀 Setup Instructions

### 1. Clone & Install

```bash
git clone <your-repo-url>
cd expense_tracker
flutter pub get
```

### 2. Add Your Gemini API Key

Open `lib/config/env/environment.dart` and replace the placeholder:

```dart
@override
String get geminiApiKey => 'YOUR_GEMINI_API_KEY';  // ← paste here
```

Get a free key at: https://aistudio.google.com/apikey

### 3. Run Code Generation

The project uses `built_value`, `kiwi_generator`, and `hive_generator`. The
`.g.dart` files are pre-written so you can run immediately, but if you modify
any state classes regenerate with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Production
flutter run --dart-define=ENVIRONMENT=prod
```

---

## 🏗️ Architecture Overview

This project strictly follows **dp_bloc_structure** — BLoC + Clean Architecture.

### Dependency Flow

```
UI Screen
  └── BaseState<XBloc, XWidget>
        └── XBloc extends BaseBloc<XEvent, XState>
              ├── XState (built_value immutable)
              ├── XRepository
              │     └── HiveStorageService / GeminiService
              └── EventBus (cross-BLoC communication)
```

### Key Patterns

| Pattern | Implementation |
|---|---|
| Immutable state | `built_value` with `rebuild()` |
| Side effects (nav/toast) | `PublishSubject<ViewAction>` in `BaseBloc` |
| DI | Kiwi with `@Register.factory` / `@Register.singleton` |
| Cross-BLoC events | `EventBus` (rxdart `PublishSubject`) |
| Local storage | Hive with typed boxes |
| Navigation | `NavigationService` via `GlobalKey<NavigatorState>` |
| API calls | Gemini REST via Dio (with error handling) |

### ScreenState Machine

Every BLoC state carries a `ScreenState`:
```
loading → content
loading → empty
loading → error → (retry) → loading
```

### ViewAction Side Effects

```dart
// In BLoC
dispatchViewEvent(NavigateScreen(DashboardTarget.addExpense));
dispatchViewEvent(DisplayMessage(message: 'Expense saved!'));
dispatchViewEvent(CloseScreen());

// In UI (BaseState.onViewEvent)
switch (event.runtimeType) {
  case const (NavigateScreen): ...
  case const (DisplayMessage): ...
}
```

---

## 🤖 AI Features

### Feature 1: AI Receipt Scanner

1. User taps "Scan Receipt" → picks camera/gallery image
2. Image is base64-encoded and sent to `gemini-1.5-flash`
3. Gemini extracts: merchant name, date, amount, category
4. `ExtractedReceiptData` is shown in a bottom sheet
5. User can **Apply** (auto-fills form) or **Discard**
6. Handles: invalid images, API errors, partial data, rate limits

**Prompt strategy:** Strict JSON-only response, no markdown — makes parsing reliable.

### Feature 2: AI Spending Insights

1. User navigates to AI Insights screen
2. Taps "Generate Insights"
3. All expenses are summarized (category totals, month comparison, top spenders)
4. Summary is sent to Gemini with a persona prompt
5. Natural language response is displayed + cached in Hive
6. Cached insight shown on next open; user can regenerate on demand

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC state management |
| `built_value` | Immutable state classes |
| `kiwi` | Dependency injection |
| `rxdart` | `PublishSubject` for side effects & event bus |
| `hive_flutter` | Local storage (expenses + cached insights) |
| `dio` | HTTP client for Gemini API |
| `image_picker` | Camera/gallery access |
| `fl_chart` | Category pie chart |
| `flutter_screenutil` | Responsive sizing |
| `intl` | Date + currency formatting |
| `uuid` | Unique expense IDs |
| `dartz` | Functional utilities |

---

## ✅ Edge Cases Handled

- **Empty state** — separate `ScreenState.empty` with friendly UI
- **AI scan fails** — error banner with descriptive message; form still usable
- **Partial AI extraction** — shows what was found, user reviews before applying
- **Non-receipt image** — Gemini detects and returns error flag
- **API rate limit (429)** — user-friendly message, no crash
- **Network timeout** — caught with `DioException`, shown as toast
- **Amount validation** — must be positive number, 2 decimal precision enforced
- **Delete confirmation** — AlertDialog prevents accidental deletion
- **Swipe to delete** — Dismissible with `confirmDismiss: false` (shows dialog instead)
- **Edit mode** — form pre-populated, existing `id`/`createdAt` preserved
- **Empty insights** — shows empty state prompt instead of blank screen
- **Insight caching** — cached insights shown instantly; regenerate on demand
- **Category filter** — chips filter expense list without re-fetching from Hive
- **Cross-BLoC sync** — `EventBus` ensures Dashboard refreshes after add/edit/delete

---

## 🎨 Logo & Splash Screen

**Logo** (`assets/icons/app_logo.svg`): a wallet card with a receipt peeking out
and a pulsing AI sparkle badge, on the brand purple gradient (`#6C63FF → #9C63FF`).
Preview it by opening `logo_preview.html`.

To use it as your actual app icon, export it to PNG (1024×1024) using any SVG tool
(Figma, Inkscape, or an online converter), save as `assets/icons/app_logo.png`, then:

```bash
flutter pub add flutter_launcher_icons --dev
# add a flutter_launcher_icons config block to pubspec.yaml pointing at app_logo.png
flutter pub run flutter_launcher_icons
```

**Splash screen** — two layers, both driven by the same design:

1. **Native OS splash** (shown instantly before Flutter even boots) — configured via
   `flutter_native_splash` in `pubspec.yaml`. Generate it with:
   ```bash
   flutter pub run flutter_native_splash:create
   ```
2. **In-app animated splash** (`lib/features/splash/`) — follows the exact
   `dp_bloc_structure` pattern:
   - `bloc/splash_screen_state.dart` — `built_value` state + events
   - `bloc/splash_screen_bloc.dart` — extends `BaseBloc`, warms up Hive, waits
     a minimum 1.8s for the animation, then dispatches `NavigateScreen(dashboard)`
   - `screens/splash_screen.dart` — extends `BaseState<SplashScreenBloc, ...>`,
     hand-drawn animated logo (no external image needed) with:
     - Elastic scale + fade entrance for the wallet card
     - Pulsing AI sparkle badge (auto-awesome icon, scale+opacity loop)
     - Slide-up + fade for app name and tagline
     - Bottom loading spinner
   - Wired into `RouteNames.splash` (`/`) as `initialRoute` in `main.dart`
   - Registered in DI via `@Register.factory(SplashScreenBloc)`



- Gradient summary card with this-month + all-time totals
- Interactive pie chart (tap segment to highlight)
- Category emoji chips for visual filter
- Swipe-to-delete gesture on expense tiles
- AI badge on AI-extracted expenses
- Bottom sheet for AI-extracted data review
- Unified `ScreenState` loading/error/empty handling across all screens
