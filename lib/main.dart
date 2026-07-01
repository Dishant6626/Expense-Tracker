// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/env/environment.dart';
import 'config/inject/injector.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'core/services/hive_storage_service.dart';
import 'core/services/navigation_service.dart';
import 'core/utils/navigation_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveStorageService().init();

  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.prod,
  );
  Environment().initConfig(environment);
  await Injector.setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        title: 'ExpenseAI',
        navigatorKey: Injector.resolve<NavigationService>().rootNavKey,
        scaffoldMessengerKey: Injector.resolve<NavigationService>().scaffoldKey,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: RouteNames.splash,
        onGenerateRoute: NavigationUtils.generateRoute,
      ),
    );
  }
}
