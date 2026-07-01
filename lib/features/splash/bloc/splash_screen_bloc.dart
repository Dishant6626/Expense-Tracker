// lib/features/splash/bloc/splash_screen_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/base/base_bloc.dart';
import '../../../core/base/event_bus.dart';
import '../../expense/repository/expense_repository.dart';
import 'splash_screen_state.dart';

class SplashScreenBloc
    extends BaseBloc<SplashScreenEvent, SplashScreenState> {
  SplashScreenBloc(this._repo, this._eventBus) : super(initState) {
    on<InitSplashScreenEvent>(_initSplashScreenEvent);
    on<BackSplashScreenEvent>(_backSplashScreenEvent);
    on<UpdateSplashScreenState>((event, emit) => emit(event.state));
    _eventBus.events.listen(_handlersEvent).bindToLifecycle(this);
  }

  final ExpenseRepository _repo;
  final EventBus _eventBus;

  static SplashScreenState get initState => (SplashScreenStateBuilder()
        ..state = ScreenState.loading
        ..errorMessage = '')
      .build();

  Future<void> _initSplashScreenEvent(
    InitSplashScreenEvent event,
    Emitter<SplashScreenState> emit,
  ) async {
    try {
      // Warm up local storage / verify Hive boxes are ready.
      // Also gives the logo animation time to play (min display duration).
      final minDisplay = Future.delayed(const Duration(milliseconds: 1800));
      final warmUp = _repo.getAllExpenses();

      await Future.wait([minDisplay, warmUp]);

      emit(state.rebuild((b) => b..state = ScreenState.content));

      dispatchViewEvent(NavigateScreen(SplashScreenTarget.dashboard));
    } catch (e) {
      emit(state.rebuild((b) => b
        ..state = ScreenState.error
        ..errorMessage = 'Failed to initialize app. Please restart.'));
    }
  }

  void _backSplashScreenEvent(
    BackSplashScreenEvent event,
    Emitter<SplashScreenState> emit,
  ) =>
      dispatchViewEvent(NavigateScreen(SplashScreenTarget.back));

  void _handlersEvent(BusEvent event) {
    // No cross-BLoC events needed on splash currently.
  }
}
