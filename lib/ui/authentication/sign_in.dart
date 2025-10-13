import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_event.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_state.dart';
import 'package:middle_paint/ui/authentication/sign_up.dart';
import 'package:middle_paint/ui/gallery/home_screen.dart';
import 'package:middle_paint/ui/widgets/auth/auth_title.dart';
import 'package:middle_paint/ui/widgets/buttons/auth_button.dart';
import 'package:middle_paint/ui/widgets/buttons/main_button.dart';
import 'package:middle_paint/ui/widgets/background/custom_background.dart';
import 'package:middle_paint/ui/widgets/fields/custom_text_field.dart';
import 'package:middle_paint/ui/widgets/spaces/bottom_padding.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SignInScreen extends StatefulWidget {
  static const name = '/signIn';

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late SignInBloc signInBloc;

  @override
  void initState() {
    super.initState();
    signInBloc = context.read<SignInBloc>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSignInTap(SignInState state) {
    FocusScope.of(context).unfocus();

    signInBloc.add(
      SignInWithEmailEvent(
        onSuccess: () {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(HomeScreen.name, (route) => false);
        },
        onError: (errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.primary50),
              ),
              backgroundColor: AppColors.magenta,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        final formGroup = state.signInForm.formGroup;
        final signInForm = state.signInForm;

        return Scaffold(
          backgroundColor: AppColors.primaryBlack,
          body: CustomBackground(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0.w),
              child: ReactiveForm(
                formGroup: formGroup,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthTitle('Вход'),
                              SizedBox(height: 20.h),
                              CustomTextField(
                                labelText: 'e-mail',
                                hintText: 'Введите электронную почту',
                                keyboardType: TextInputType.emailAddress,
                                formControl: signInForm.emailControl,
                              ),
                              SizedBox(height: 20.h),
                              CustomTextField(
                                labelText: 'Пароль',
                                hintText: 'Введите пароль',
                                isPassword: true,
                                formControl: signInForm.passwordControl,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ReactiveFormConsumer(
                      builder: (context, form, child) {
                        return AuthButton(
                          disabled: false,
                          loading: state.loading,
                          buttonName: 'Войти',
                          onTap: () => _onSignInTap(state),
                        );
                      },
                    ),
                    SizedBox(height: 19.h),
                    MainButton(
                      onTap: () {
                        signInBloc.state.signInForm.clear();
                        Navigator.pushNamed(context, SignUpScreen.name);
                      },
                      buttonText: 'Регистрация',
                      textColor: AppColors.primaryBlack,
                      buttonColors: [AppColors.neutral50],
                    ),
                    const BottomPadding(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
