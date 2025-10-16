import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.formControl,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.isPassword = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final FormControl<dynamic> formControl;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final ReactiveFormFieldCallback<dynamic>? onSubmitted;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ReactiveFormConfig(
      validationMessages: {
        ValidationMessage.required: (error) => 'Поле не может быть пустым',
        ValidationMessage.email: (error) => 'Введите корректный e-mail',
        ValidationMessage.minLength:
            (error) => 'Минимум ${(error as Map)['requiredLength']} символов',
        ValidationMessage.maxLength:
            (error) => 'Максимум ${(error as Map)['requiredLength']} символов',
        ValidationMessage.mustMatch: (error) => 'Пароли не совпадают',
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGray, width: 0.5),
          color: AppColors.primaryBlack,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowPurple,
                  offset: const Offset(0, -82),
                  blurRadius: 68.r,
                  spreadRadius: -64.r,
                ),
                BoxShadow(
                  color: AppColors.shadowGray.withValues(alpha: 0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 40.r,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.labelText != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        widget.labelText!,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.borderGray,
                        ),
                      ),
                    ),
                  ReactiveTextField(
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.neutral50,
                    ),
                    formControl: widget.formControl,
                    obscureText: _obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onSubmitted: widget.onSubmitted,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(bottom: 4.h),
                      isDense: true,
                      hintText: widget.hintText,
                      hintStyle: textTheme.bodySmall?.copyWith(
                        color: AppColors.borderGray,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.borderGray,
                          width: 0.3,
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.borderGray,
                          width: 0.3,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.borderGray,
                          width: 0.3,
                        ),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.error200,
                          width: 0.5,
                        ),
                      ),
                      focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.error200,
                          width: 0.5,
                        ),
                      ),
                    ),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
