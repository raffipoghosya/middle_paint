import 'package:middle_paint/core/forms/general_form.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SignUpForm extends GeneralForm {
  static const _name = 'name';
  static const _email = 'email';
  static const _password = 'password';
  static const _confirmPassword = 'confirm_password';

  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 16;

  SignUpForm()
    : super(
        FormGroup(
          {
            _name: FormControl<String>(),
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

            _confirmPassword: FormControl<String>(
              validators: [Validators.required],
            ),
          },
          validators: [
            const MustMatchCustomValidator(_password, _confirmPassword),
          ],
        ),
      );

  FormControl<String> get nameControl =>
      formGroup.control(_name) as FormControl<String>;

  FormControl<String> get emailControl =>
      formGroup.control(_email) as FormControl<String>;

  FormControl<String> get passwordControl =>
      formGroup.control(_password) as FormControl<String>;

  FormControl<String> get confirmPasswordControl =>
      formGroup.control(_confirmPassword) as FormControl<String>;
}
