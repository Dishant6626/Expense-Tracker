// lib/config/inject/injector.dart

import 'package:kiwi/kiwi.dart';

import '../../core/base/event_bus.dart';
import '../../core/services/navigation_service.dart';
import '../../features/expense/repository/expense_repository.dart';
import '../../features/expense/bloc/expense_bloc.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/ai_insights/repository/ai_insights_repository.dart';
import '../../features/ai_insights/bloc/ai_insights_bloc.dart';
import '../../features/splash/bloc/splash_screen_bloc.dart';

part 'injector.g.dart';

abstract class Injector {
  static late KiwiContainer container;

  static Future<bool> setup() async {
    container = KiwiContainer();
    _$Injector()._configure();
    return true;
  }

  static final T Function<T>([String?]) resolve = container.resolve;

  void _configure() {
    _configureBus();
    _registerServices();
    _registerRepositories();
    _registerBlocs();
  }

  void _configureBus() {
    container.registerSingleton<EventBus>((c) => EventBusImpl());
  }

  @Register.singleton(NavigationService)
  void _registerServices();

  @Register.singleton(ExpenseRepository)
  @Register.singleton(AiInsightsRepository)
  void _registerRepositories();

  @Register.factory(DashboardBloc)
  @Register.factory(ExpenseBloc)
  @Register.factory(AiInsightsBloc)
  @Register.factory(SplashScreenBloc)
  void _registerBlocs();
}
