// lib/features/ai_insights/bloc/ai_insights_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/base/base_bloc.dart';
import '../../../core/base/event_bus.dart';
import '../repository/ai_insights_repository.dart';
import 'ai_insights_state.dart';

class AiInsightsBloc extends BaseBloc<AiInsightsEvent, AiInsightsState> {
  AiInsightsBloc(this._repo, this._eventBus) : super(initState) {
    on<LoadInsightsEvent>(_onLoad);
    on<GenerateInsightsEvent>(_onGenerate);
    on<UpdateAiInsightsState>((event, emit) => emit(event.state));
  }

  final AiInsightsRepository _repo;
  final EventBus _eventBus;

  static AiInsightsState get initState => (AiInsightsStateBuilder()
        ..state = ScreenState.loading
        ..isGenerating = false)
      .build();

  Future<void> _onLoad(LoadInsightsEvent event, Emitter<AiInsightsState> emit) async {
    emit(state.rebuild((b) => b..state = ScreenState.loading));

    final cached = await _repo.getCachedInsight();
    final lastDate = await _repo.getLastInsightDate();

    final dateLabel = lastDate != null
        ? DateFormat('MMM d, yyyy • h:mm a').format(lastDate)
        : null;

    if (cached != null) {
      emit(state.rebuild((b) => b
        ..state = ScreenState.content
        ..cachedInsightText = cached
        ..insightText = cached
        ..lastGeneratedDate = dateLabel));
    } else {
      emit(state.rebuild((b) => b..state = ScreenState.empty));
    }
  }

  Future<void> _onGenerate(GenerateInsightsEvent event, Emitter<AiInsightsState> emit) async {
    emit(state.rebuild((b) => b
      ..isGenerating = true
      ..errorMessage = null));

    try {
      final insight = await _repo.generateInsights();
      final now = DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now());

      emit(state.rebuild((b) => b
        ..state = ScreenState.content
        ..insightText = insight
        ..cachedInsightText = insight
        ..lastGeneratedDate = now
        ..isGenerating = false));
    } catch (e) {
      emit(state.rebuild((b) => b
        ..isGenerating = false
        ..errorMessage = 'Failed to generate insights. Please try again.'));
      dispatchViewEvent(DisplayMessage(
        message: 'Could not generate insights. Check your connection.',
      ));
    }
  }
}
