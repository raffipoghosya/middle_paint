import 'package:equatable/equatable.dart';
import 'package:middle_paint/core/forms/authentication/sign_in_form.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInState extends Equatable {
  final SignInForm signInForm;
  final bool loading;
  final User? user;
  final String? errorMessage;

  const SignInState({
    required this.signInForm,
    this.loading = false,
    this.user,
    this.errorMessage,
  });

  SignInState copyWith({
    SignInForm? signInForm,
    bool? loading,
    User? user,
    String? errorMessage,
  }) {
    return SignInState(
      signInForm: signInForm ?? this.signInForm,
      loading: loading ?? this.loading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [signInForm, loading, user, errorMessage];
}
