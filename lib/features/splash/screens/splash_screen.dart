// lib/features/splash/screens/splash_screen.dart

import 'package:expense_tracker/core/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/base/base_bloc.dart';
import '../../../core/constants/color_constants.dart';
import '../bloc/splash_screen_bloc.dart';
import '../bloc/splash_screen_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends BaseState<SplashScreenBloc, SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );


    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _logoController.forward();
    bloc.add(InitSplashScreenEvent());
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  void onViewEvent(ViewAction event) {
    if (event is NavigateScreen) {
      _handleNavigation(event.target);
    } else if (event is DisplayMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.message ?? ''),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleNavigation(String target) {
    switch (target) {
      case SplashScreenTarget.dashboard:
        Navigator.pushReplacementNamed(context, RouteNames.dashboard);
        break;
      case SplashScreenTarget.back:
        Navigator.pop(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashScreenBloc>(
      create: (_) => bloc,
      child: BlocBuilder<SplashScreenBloc, SplashScreenState>(
        builder: (context, data) {
          return Scaffold(
            backgroundColor: ColorConstants.primary,
            body: _Body(
              data: data,
              bloc: bloc,
              logoController: _logoController,
              logoScale: _logoScale,
              logoFade: _logoFade,
              textFade: _textFade,
              textSlide: _textSlide,
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.data,
    required this.bloc,
    required this.logoController,
    required this.logoScale,
    required this.logoFade,
    required this.textFade,
    required this.textSlide,
  });

  final SplashScreenState data;
  final SplashScreenBloc bloc;
  final AnimationController logoController;
  final Animation<double> logoScale;
  final Animation<double> logoFade;
  final Animation<double> textFade;
  final Animation<Offset> textSlide;

  @override
  Widget build(BuildContext context) {
    switch (data.state) {
      case ScreenState.error:
        return _ErrorContent(message: data.errorMessage, bloc: bloc);
      default:
        return _MainContent(
          logoController: logoController,
          logoScale: logoScale,
          logoFade: logoFade,
          textFade: textFade,
          textSlide: textSlide,
        );
    }
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.logoController,
    required this.logoScale,
    required this.logoFade,
    required this.textFade,
    required this.textSlide,
  });

  final AnimationController logoController;
  final Animation<double> logoScale;
  final Animation<double> logoFade;
  final Animation<double> textFade;
  final Animation<Offset> textSlide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative background circles (matches logo accents)
          Positioned(
            top: -60.h,
            right: -40.w,
            child: _BgCircle(size: 220.r, opacity: 0.06),
          ),
          Positioned(
            bottom: -80.h,
            left: -60.w,
            child: _BgCircle(size: 260.r, opacity: 0.06),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: logoFade.value,
                      child: Transform.scale(
                        scale: logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: const _AppLogo(),
                ),
                SizedBox(height: 28.h),
                SlideTransition(
                  position: textSlide,
                  child: FadeTransition(
                    opacity: textFade,
                    child: Column(
                      children: [
                        Text(
                          'ExpenseAI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Smarter spending, powered by AI',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: textFade,
              child: Column(
                children: [
                  SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.85)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Image.asset(ImageConstants.appLogo, width: 200, height: 200,),
    );
  }
}

class _BgCircle extends StatelessWidget {
  const _BgCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({this.message, required this.bloc});
  final String? message;
  final SplashScreenBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstants.background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: ColorConstants.error),
              SizedBox(height: 16.h),
              Text(
                message ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: ColorConstants.textSecondary),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => bloc.add(InitSplashScreenEvent()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
