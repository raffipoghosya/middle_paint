import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_event.dart';
import 'package:middle_paint/core/routes/routes.dart';
import 'package:middle_paint/gen/assets.gen.dart';
import 'package:middle_paint/ui/authentication/sign_in.dart';
import 'package:middle_paint/ui/widgets/app_bar.dart/custom_app_bar.dart';
import 'package:middle_paint/ui/widgets/background/custom_background.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/ui/widgets/buttons/main_button.dart';
import 'package:middle_paint/ui/widgets/spaces/bottom_padding.dart';
import 'package:middle_paint/base/constants/constants.dart';
import 'package:middle_paint/ui/canvas/canvas_screen.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_bloc.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_event.dart';
import 'package:middle_paint/ui/widgets/artwork/artwork_grid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_state.dart';
import 'package:middle_paint/ui/widgets/dialogs/log_out_confirmation_dialog.dart';
import 'package:middle_paint/core/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:middle_paint/core/injector/injector.dart';

class HomeScreen extends StatefulWidget {
  static const name = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _flashOfflineBanner = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<ArtworkBloc>().add(FetchUserArtworksStream(user.uid));
      }
    });
  }

  void _onLogOutTap(BuildContext context) {
    LogOutConfirmationDialog.show(
      context,
      onConfirm: () {
        context.read<SignInBloc>().add(
          LogOutEvent(
            onSuccess: () {
              Navigator.of(context).pushAndRemoveUntil(
                AppRoutes.slideTransitionRoute(
                  const SignInScreen(),
                  const RouteSettings(name: SignInScreen.name),
                  reverse: true,
                ),
                (route) => false,
              );
            },
          ),
        );
      },
    );
  }

  void _onCreateTap() {
    Navigator.of(context).pushNamed(CanvasScreen.name);
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return BlocBuilder<ArtworkBloc, ArtworkState>(
      builder: (context, artworkState) {
        final bool showBottomButton =
            artworkState.artworks.isEmpty && artworkState.initialLoadComplete;

        final bool showAppBarButton = artworkState.artworks.isNotEmpty;

        List<Widget>? appBarActions;
        if (showAppBarButton) {
          appBarActions = [
            GestureDetector(
              onTap: _onCreateTap,
              child: SvgPicture.asset(
                Assets.vectors.paint,
                width: 24.r,
                colorFilter: const ColorFilter.mode(
                  AppColors.neutral50,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ];
        }

        return BlocProvider(
          create: (_) => sl<ConnectivityBloc>()..add(ConnectivityStarted()),
          child: Scaffold(
          backgroundColor: AppColors.primaryBlack,
          body: Stack(
            children: [
              CustomBackground(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                  child: Column(
                    children: [
                      SizedBox(height: topPadding + AppConstants.contentHeight),

                      Expanded(
                        child: ArtworkGrid(
                          onOfflineTap: () {
                            setState(() => _flashOfflineBanner = true);
                            Future.delayed(const Duration(milliseconds: 900), () {
                              if (mounted) setState(() => _flashOfflineBanner = false);
                            });
                          },
                        ),
                      ),

                      if (showBottomButton)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MainButton(
                              onTap: _onCreateTap,
                              buttonText: 'Создать',
                              textColor: AppColors.neutral50,
                              buttonColors: [
                                AppColors.magenta,
                                AppColors.purple,
                              ],
                            ),

                            const BottomPadding(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: topPadding + AppConstants.contentHeight,
                left: 0,
                right: 0,
                child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
                  builder: (context, netState) {
                    if (netState.isOnline == false) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                        color: _flashOfflineBanner
                            ? AppColors.error200.withValues(alpha: 0.5)
                            : AppColors.error200.withValues(alpha: 0.2),
                        child: Text(
                          'Нет подключения к Интернету',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary50,
                              ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              CustomAppBar(
                leading: GestureDetector(
                  onTap: () => _onLogOutTap(context),
                  child: SvgPicture.asset(Assets.vectors.logout, width: 24.r),
                ),
                title: 'Галерея',
                actions: appBarActions,
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}
