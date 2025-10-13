import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_bloc.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_event.dart';
import 'package:middle_paint/core/models/artwork_model.dart';

class RenameArtworkDialog {
  static void show(
    BuildContext context, {
    required ArtworkModel artwork,
    required Function(String message, {bool isError}) showSnackBar,
  }) {
    TextEditingController controller = TextEditingController(
      text: artwork.name,
    );
    final artworkBloc = context.read<ArtworkBloc>();
    final TextTheme textTheme = Theme.of(context).textTheme;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(
            'Переименовать работу',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Введите новое имя',
              autofocus: true,
              maxLength: 50,
              decoration: BoxDecoration(
                color: AppColors.neutral50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(
                  color: AppColors.borderGray.withValues(alpha: 0.3),
                ),
              ),
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.primaryBlack,
              ),
              onTapOutside: (_) => FocusScope.of(dialogContext).unfocus(),
            ),
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Отмена',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.error200,
                ),
              ),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                final newName = controller.text.trim();

                if (newName.isNotEmpty && newName != artwork.name) {
                  artworkBloc.add(
                    RenameArtworkEvent(
                      artworkId: artwork.id,
                      newName: newName,
                      onSuccess: () {
                        showSnackBar('Работа переименована в "$newName"');
                      },
                      onError: (message) {
                        showSnackBar('Ошибка: $message', isError: true);
                      },
                    ),
                  );
                  Navigator.of(dialogContext).pop();
                } else if (newName.isEmpty) {
                  showSnackBar('Имя не может быть пустым', isError: true);
                } else {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'Сохранить',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
