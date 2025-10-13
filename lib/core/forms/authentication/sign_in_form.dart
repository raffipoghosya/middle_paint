import 'package:middle_paint/core/forms/general_form.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SignInForm extends GeneralForm {
  static const _email = 'email';
  static const _password = 'password';

  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 16;

  SignInForm()
    : super(
        FormGroup({
          _email: FormControl<String>(
            validators: [Validators.required, Validators.email],
          ),

          _password: FormControl<String>(
            validators: [
              Validators.required,
              Validators.minLength(minPasswordLength),
              Validators.maxLength(maxPasswordLength),
            ],
          ),
        }),
      );

  FormControl<String> get emailControl =>
      formGroup.control(_email) as FormControl<String>;

  FormControl<String> get passwordControl =>
      formGroup.control(_password) as FormControl<String>;
}
