import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/core/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:middle_paint/core/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:middle_paint/core/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:middle_paint/ui/gallery/home_screen.dart';
import 'package:middle_paint/ui/widgets/auth/auth_title.dart';
import 'package:middle_paint/ui/widgets/buttons/auth_button.dart';
import 'package:middle_paint/ui/widgets/background/custom_background.dart';
import 'package:middle_paint/ui/widgets/fields/custom_text_field.dart';
import 'package:middle_paint/ui/widgets/spaces/bottom_padding.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  static const name = '/signUp';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late SignUpBloc signUpBloc;

  @override
  void initState() {
    super.initState();
    signUpBloc = context.read<SignUpBloc>();
  }

  void _onSignUpTap(SignUpState state) {
    FocusScope.of(context).unfocus();

    signUpBloc.add(
      SignUpWithEmailEvent(
        onSuccess: () {
          signUpBloc.state.signUpForm.clear();
          context.go(HomeScreen.name);
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
  void dispose() {
    signUpBloc.state.signUpForm.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 12) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBlack,
        body: CustomBackground(
          child: BlocBuilder<SignUpBloc, SignUpState>(
            builder: (context, state) {
              final formGroup = state.signUpForm.formGroup;
              return Padding(
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
                                AuthTitle('Регистрация'),
                                SizedBox(height: 20.h),

                                CustomTextField(
                                  labelText: 'Имя',
                                  hintText: 'Введите ваше имя',
                                  formControl: state.signUpForm.nameControl,
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: 20.h),

                                CustomTextField(
                                  labelText: 'e-mail',
                                  hintText: 'Ваша электронная почта',
                                  keyboardType: TextInputType.emailAddress,
                                  formControl: state.signUpForm.emailControl,
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: 40.h),

                                CustomTextField(
                                  labelText: 'Пароль',
                                  hintText: '6-16 символов',
                                  isPassword: true,
                                  formControl: state.signUpForm.passwordControl,
                                  textInputAction: TextInputAction.next,
                                ),
                                SizedBox(height: 20.h),

                                CustomTextField(
                                  labelText: 'Подтверждение пароля',
                                  hintText: '6-16 символов',
                                  isPassword: true,
                                  formControl:
                                      state.signUpForm.confirmPasswordControl,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _onSignUpTap(state),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ),

                      ReactiveFormConsumer(
                        builder: (context, form, child) {
                          return AuthButton(
                            disabled: !form.valid || state.loading,
                            loading: state.loading,
                            buttonName: 'Зарегистрироваться',
                            onTap: () => _onSignUpTap(state),
                          );
                        },
                      ),

                      BottomPadding(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
