import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_bloc.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:middle_paint/middle_paint.dart';
import 'package:middle_paint/ui/splash/splash_screen.dart';
import 'package:middle_paint/core/injector/injector.dart' as di;
import 'package:middle_paint/core/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/constants/constants.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_bloc.dart';
import 'package:middle_paint/core/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    appleProvider: AppleProvider.deviceCheck,
  );

  di.call();

  await di.sl<NotificationService>().initialize();

  String initialRoute = SplashScreen.name;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SignUpBloc>(create: (context) => di.sl<SignUpBloc>()),
        BlocProvider<SignInBloc>(create: (context) => di.sl<SignInBloc>()),
        BlocProvider<CanvasBloc>(create: (context) => di.sl<CanvasBloc>()),
        BlocProvider<ArtworkBloc>(create: (context) => di.sl<ArtworkBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(
          AppConstants.originalWidth,
          AppConstants.originalHeight,
        ),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MiddlePaint(initialRoute),
      ),
    ),
  );
}
