// lib/core/base/event_bus.dart

import 'package:rxdart/rxdart.dart';

abstract class BusEvent {}

abstract class EventBus {
  void sendEvent(BusEvent event);
  Stream<BusEvent> get events;
}

class EventBusImpl extends EventBus {
  final PublishSubject<BusEvent> _channel = PublishSubject();

  @override
  Stream<BusEvent> get events => _channel.stream;

  @override
  void sendEvent(BusEvent event) {
    _channel.sink.add(event);
  }
}

// Cross-BLoC events
class ExpenseAddedEvent extends BusEvent {
  final String expenseId;
  ExpenseAddedEvent({required this.expenseId});
}

class ExpenseUpdatedEvent extends BusEvent {
  final String expenseId;
  ExpenseUpdatedEvent({required this.expenseId});
}

class ExpenseDeletedEvent extends BusEvent {
  final String expenseId;
  ExpenseDeletedEvent({required this.expenseId});
}
