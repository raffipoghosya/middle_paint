import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';

class LogOutConfirmationDialog {
  static void show(BuildContext context, {required VoidCallback onConfirm}) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(
            'Выход',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlack,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите выйти из аккаунта?',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.primaryBlack,
              fontSize: 10.sp,
            ),
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Отмена',
                style: textTheme.labelMedium?.copyWith(color: AppColors.purple),
              ),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm.call();
              },
              child: Text(
                'Выйти',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.error200,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
