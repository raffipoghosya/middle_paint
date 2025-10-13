import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_bloc.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_event.dart';
import 'package:middle_paint/core/models/artwork_model.dart';

class DeleteArtworkConfirmationDialog {
  static void show(
    BuildContext context, {
    required ArtworkModel artwork,
    required Function(String message, {bool isError}) showSnackBar,
  }) {
    final artworkBloc = context.read<ArtworkBloc>();
    final TextTheme textTheme = Theme.of(context).textTheme;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: Text(
            'Удалить работу?',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите удалить работу "${artwork.name}"? Это действие необратимо.',
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
                artworkBloc.add(
                  DeleteArtworkEvent(
                    artworkId: artwork.id,
                    imageUrl: artwork.imageUrl,
                    onSuccess: () {
                      showSnackBar('Работа "${artwork.name}" удалена.');
                    },
                    onError: (message) {
                      showSnackBar('Ошибка: $message', isError: true);
                    },
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Удалить',
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
