// lib/core/services/navigation_service.dart

import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  NavigatorState? get navigator => rootNavKey.currentState;

  void showSnackBar(String message, {bool isError = false}) {
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
