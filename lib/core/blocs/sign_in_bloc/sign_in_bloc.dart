import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_event.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_state.dart';
import 'package:middle_paint/core/firebase_services/authentication.dart';
import 'package:middle_paint/core/forms/authentication/sign_in_form.dart';
import 'package:middle_paint/core/resources/response_state.dart';

/// BLoC for managing user sign-in state and logic.
/// Handles form validation, interacts with [AuthenticationService],
/// and updates the UI state with loading indicators and error messages.
class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthenticationService _authService;

  SignInBloc(this._authService)
    : super(SignInState(signInForm: SignInForm(), loading: false)) {
    on<SignInWithEmailEvent>(signInWithEmail);
    on<LogOutEvent>(logOut);
  }

  /// Handles the sign-in process.
  Future<void> signInWithEmail(
    SignInWithEmailEvent event,
    Emitter<SignInState> emit,
  ) async {
    final bool isValid = state.signInForm.validate();

    if (!isValid) {
      emit(state.copyWith(loading: false, errorMessage: null));
      return;
    }

    emit(state.copyWith(loading: true, errorMessage: null));

    final email = state.signInForm.emailControl.value!;
    final password = state.signInForm.passwordControl.value!;

    final response = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (response is DataSuccess) {
      final user = response.data!.user!;

      emit(state.copyWith(loading: false, user: user, errorMessage: null));
      event.onSuccess.call();
    } else if (response is DataFailed) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: response.exception!.message,
        ),
      );
      event.onError.call(state.errorMessage!);
    }
  }

  /// Handles the user log-out process by calling the authentication service.
  /// It resets the BLoC state to an unauthenticated, initial form state.
  Future<void> logOut(LogOutEvent event, Emitter<SignInState> emit) async {
    emit(state.copyWith(loading: true, errorMessage: null));

    try {
      await _authService.logOut();

      emit(
        SignInState(
          signInForm: SignInForm(),
          loading: false,
          user: null,
          errorMessage: null,
        ),
      );
      event.onSuccess.call();
    } catch (e) {
      emit(
        state.copyWith(loading: false, errorMessage: 'Failed to log out: $e'),
      );
      event.onSuccess.call();
    }
  }
}
