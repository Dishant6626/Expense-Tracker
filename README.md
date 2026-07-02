# ExpenseAI — Flutter Expense Tracker

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

### 1. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Run the App

```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Production
flutter run --dart-define=ENVIRONMENT=prod
```

---
