import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:middle_paint/core/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:middle_paint/core/blocs/sign_up_bloc/sign_up_state.dart';
import 'package:middle_paint/core/firebase_services/authentication.dart';
import 'package:middle_paint/core/firebase_services/firestore_database.dart';
import 'package:middle_paint/core/forms/authentication/sign_up_form.dart';
import 'package:middle_paint/core/models/user_model.dart';
import 'package:middle_paint/core/resources/response_state.dart';

/// BLoC for managing user sign-up state and business logic.
/// Coordinates authentication ([AuthenticationService]) and user data
/// storage ([FirestoreDatabaseService]) during registration.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthenticationService _authService;
  final FirestoreDatabaseService _firestoreService;

  SignUpBloc(this._authService, this._firestoreService)
    : super(SignUpState(signUpForm: SignUpForm(), loading: false)) {
    on<SignUpWithEmailEvent>(signUpWithEmail);
  }

  /// Handles the new user registration process.
  Future<void> signUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<SignUpState> emit,
  ) async {
    final bool isValid = state.signUpForm.validate();

    if (!isValid) {
      emit(state.copyWith(loading: false, errorMessage: null));
      return;
    }

    emit(state.copyWith(loading: true, errorMessage: null));

    final name = state.signUpForm.nameControl.value!;
    final email = state.signUpForm.emailControl.value!;
    final password = state.signUpForm.passwordControl.value!;

    final response = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    if (response is DataSuccess) {
      final user = response.data!.user!;

      try {
        final appUser = AppUser(
          uid: user.uid,
          name: name,
          email: email,
          creationDate: Timestamp.now(),
        );

        await _firestoreService.createUser(appUser);

        emit(state.copyWith(loading: false, user: user, errorMessage: null));
        event.onSuccess.call();
      } catch (e) {
        // If Firestore fails, delete the Auth user to prevent orphaned accounts
        await user.delete();
        emit(
          state.copyWith(
            loading: false,
            errorMessage:
                'Account created, but failed to save user data. Please try again.',
          ),
        );
        event.onError.call(state.errorMessage!);
      }
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
}
