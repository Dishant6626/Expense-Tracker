// lib/features/splash/bloc/splash_screen_state.dart

import 'package:built_value/built_value.dart';
import '../../../core/base/base_bloc.dart';

part 'splash_screen_state.g.dart';

abstract class SplashScreenState
    implements Built<SplashScreenState, SplashScreenStateBuilder> {
  factory SplashScreenState(
          [void Function(SplashScreenStateBuilder) updates]) =
      _$SplashScreenState;

  SplashScreenState._();

  ScreenState get state;

  String? get errorMessage;
}

// ── Events ───────────────────────────────────────────────────────────────────

abstract class SplashScreenEvent {}

class InitSplashScreenEvent extends SplashScreenEvent {}

class BackSplashScreenEvent extends SplashScreenEvent {}

class UpdateSplashScreenState extends SplashScreenEvent {
  final SplashScreenState state;

  UpdateSplashScreenState(this.state);
}

// ── Navigation targets ──────────────────────────────────────────────────────

abstract class SplashScreenTarget {
  static const String back = 'back';
  static const String dashboard = 'dashboard';
}
