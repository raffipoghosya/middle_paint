import 'package:reactive_forms/reactive_forms.dart';

/// Abstract base class for all forms in the application using [ReactiveForms].
/// Provides standardized methods for validation and clearing form controls.
abstract class GeneralForm {
  FormGroup formGroup;

  GeneralForm(this.formGroup);

  /// Triggers validation across the entire form group and marks all controls as touched.
  /// Returns true if the form is valid.
  bool validate() {
    formGroup
      ..markAllAsTouched()
      ..updateValueAndValidity();

    return formGroup.valid;
  }

  /// Clears the value and validation status of all controls in the form group.
  void clear() {
    formGroup.controls.forEach((name, control) {
      control
        ..markAsUntouched()
        ..updateValue(null);
    });
  }
}

/// A custom validator to ensure that two specific form controls have matching values
/// (e.g., password and confirm password).
class MustMatchCustomValidator extends Validator<dynamic> {
  final String controlName;
  final String matchingControlName;
  final bool markAsDirty;

  const MustMatchCustomValidator(
    this.controlName,
    this.matchingControlName, {
    this.markAsDirty = true,
  }) : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    if (control is! FormGroup) return null;

    final formControl = control.control(controlName);
    final matchingFormControl = control.control(matchingControlName);

    final error = {ValidationMessage.mustMatch: true};

    matchingFormControl.removeError(
      ValidationMessage.mustMatch,
      markAsDirty: false,
    );

    if (formControl.value != null &&
        matchingFormControl.value != null &&
        formControl.value != matchingFormControl.value) {
      matchingFormControl.setErrors(error, markAsDirty: markAsDirty);
    }

    return null;
  }
}
