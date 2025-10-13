import 'package:equatable/equatable.dart';
import 'package:middle_paint/core/forms/authentication/sign_up_form.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpState extends Equatable {
  final SignUpForm signUpForm;
  final bool loading;
  final User? user;
  final String? errorMessage;

  const SignUpState({
    required this.signUpForm,
    this.loading = false,
    this.user,
    this.errorMessage,
  });

  SignUpState copyWith({
    SignUpForm? signUpForm,
    bool? loading,
    User? user,
    String? errorMessage,
  }) {
    return SignUpState(
      signUpForm: signUpForm ?? this.signUpForm,
      loading: loading ?? this.loading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [signUpForm, loading, user, errorMessage];
}
