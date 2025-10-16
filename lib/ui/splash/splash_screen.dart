import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/gen/assets.gen.dart';
import 'package:middle_paint/ui/authentication/sign_in.dart';
import '../widgets/background/custom_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:middle_paint/ui/gallery/home_screen.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  static const name = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    final user = FirebaseAuth.instance.currentUser;
    final String nextRoute = user == null ? SignInScreen.name : HomeScreen.name;
    context.go(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: CustomBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20.h),
              Lottie.asset(
                Assets.json.splash,
                width: 150.w,
                height: 150.h,
                repeat: false,
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
