// lib/core/base/base_bloc.dart

// ignore_for_file: avoid_catches_without_on_clauses
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../config/inject/injector.dart';

abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.state);

  final PublishSubject<ViewAction> _sideEffects = PublishSubject();

  Stream<ViewAction> get viewActions => _sideEffects.stream;

  final List<StreamSubscription> _subscriptions = [];
  final List<CancelToken> _tokens = [];

  @protected
  void dispatchViewEvent(ViewAction target) {
    _sideEffects.add(target);
  }

  @override
  Future<void> close() {
    for (var t in _tokens) {
      try {
        t.cancel();
      } catch (e) {
        debugPrint('$e');
      }
    }
    for (var f in _subscriptions) {
      f.cancel();
    }
    _sideEffects.close();
    return super.close();
  }

  @override
  void add(Event event) {
    if (!isClosed) {
      super.add(event);
    }
  }
}

extension StreamLifecycle on StreamSubscription {
  void bindToLifecycle(BaseBloc<dynamic, dynamic> bloc) {
    bloc._subscriptions.add(this);
  }
}

extension ApiLifecycle on CancelToken {
  void bindToLifecycle(BaseBloc<dynamic, dynamic> bloc) {
    bloc._tokens.add(this);
  }
}

abstract class ViewAction {}

enum DisplayMessageType { toast, dialog }

class DisplayMessage extends ViewAction {
  final String? message;
  final String? title;
  final DisplayMessageType type;
  final dynamic data;

  DisplayMessage({
    this.title,
    this.message,
    this.type = DisplayMessageType.toast,
    this.data,
  });

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes, hash_and_equals
  bool operator ==(Object other) {
    return other is DisplayMessage &&
        other.message == message &&
        other.title == title &&
        other.type == type &&
        other.data == data;
  }
}

class CloseScreen extends ViewAction {}

class ChangeTheme extends ViewAction {}

class NavigateScreen extends ViewAction {
  final String target;
  Object? data;

  NavigateScreen(this.target, {this.data});

  @override
  // ignore: hash_and_equals
  bool operator ==(other) {
    if (other is NavigateScreen) {
      return other.target == target && other.data == data;
    } else {
      return false;
    }
  }
}

enum ScreenState { loading, content, error, empty }

abstract class BaseState<Q extends BaseBloc, T extends StatefulWidget>
    extends State<T> {
  late Q bloc;

  BaseState() {
    bloc = Injector.resolve();
    _initViewEvents();
  }

  void _initViewEvents() {
    bloc.viewActions.listen(onViewEvent);
  }

  void onViewEvent(ViewAction event) {
    if (event is NavigateScreen) {
      onNavigationEvent(event.target);
    } else if (event is CloseScreen) {
      Navigator.pop(context);
    } else if (event is DisplayMessage) {
    } else if (event is ChangeTheme) {
      _forceRebuildWidgets();
    }
  }

  void _forceRebuildWidgets() {
    void rebuild(Element widget) {
      widget.markNeedsBuild();
      widget.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  void onNavigationEvent(dynamic target) {}

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
