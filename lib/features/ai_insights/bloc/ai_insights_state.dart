// lib/features/ai_insights/bloc/ai_insights_state.dart

import 'package:built_value/built_value.dart';
import '../../../core/base/base_bloc.dart';

part 'ai_insights_state.g.dart';

abstract class AiInsightsState
    implements Built<AiInsightsState, AiInsightsStateBuilder> {
  factory AiInsightsState([void Function(AiInsightsStateBuilder) updates]) =
      _$AiInsightsState;

  AiInsightsState._();

  ScreenState get state;
  String? get insightText;
  String? get cachedInsightText;
  String? get lastGeneratedDate;
  bool get isGenerating;
  String? get errorMessage;
}

abstract class AiInsightsEvent {}

class LoadInsightsEvent extends AiInsightsEvent {}
class GenerateInsightsEvent extends AiInsightsEvent {}
class UpdateAiInsightsState extends AiInsightsEvent {
  final AiInsightsState state;
  UpdateAiInsightsState(this.state);
}

abstract class AiInsightsTarget {
  static const String back = 'back';
}
