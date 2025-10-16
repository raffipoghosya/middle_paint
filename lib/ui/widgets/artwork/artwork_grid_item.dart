import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/core/injector/injector.dart';
import 'package:middle_paint/core/models/artwork_model.dart';
import 'package:middle_paint/core/services/image_saver_service.dart';
import 'package:middle_paint/ui/canvas/canvas_screen.dart';
import 'package:middle_paint/ui/widgets/dialogs/delete_artwork_confirmation_dialog.dart';
import 'package:middle_paint/ui/widgets/dialogs/rename_artwork_dialog.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:middle_paint/core/blocs/connectivity_bloc/connectivity_bloc.dart';

class ArtworkGridItem extends StatefulWidget {
  final ArtworkModel artwork;
  final VoidCallback? onOfflineTap;

  const ArtworkGridItem({super.key, required this.artwork, this.onOfflineTap});

  @override
  State<ArtworkGridItem> createState() => _ArtworkGridItemState();
}

class _ArtworkGridItemState extends State<ArtworkGridItem> {
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.primary50),
        ),
        backgroundColor: isError ? AppColors.error200 : AppColors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSaveToPhoneTap(BuildContext context) async {
    final imageSaverService = sl<ImageSaverService>();
    _showSnackBar(context, 'Начинаю загрузку...', isError: false);

    final result = await imageSaverService.saveImageFromUrl(
      widget.artwork.imageUrl,
      name: widget.artwork.name,
    );

    if (!mounted) return;

    if (result != null) {
      _showSnackBar(
        context,
        'Рисунок "${widget.artwork.name}" сохранен в галерею.',
        isError: false,
      );
    } else {
      _showSnackBar(context, 'Не удалось сохранить рисунок.', isError: true);
    }
  }

  List<PullDownMenuEntry> _buildPullDownMenuItems(BuildContext context) {
    return <PullDownMenuEntry>[
      PullDownMenuItem(
        onTap:
            () => RenameArtworkDialog.show(
              context,
              artwork: widget.artwork,
              showSnackBar:
                  (message, {isError = false}) =>
                      _showSnackBar(context, message, isError: isError),
            ),
        title: 'Переименовать',
        iconWidget: Icon(CupertinoIcons.pencil, size: 16.r),
        iconColor: AppColors.neutral50,
      ),
      PullDownMenuItem(
        onTap: () => _onSaveToPhoneTap(context),
        title: 'Сохранить на телефон',
        iconWidget: Icon(CupertinoIcons.cloud_download, size: 16.r),
        iconColor: AppColors.neutral50,
      ),
      PullDownMenuItem(
        onTap:
            () => DeleteArtworkConfirmationDialog.show(
              context,
              artwork: widget.artwork,
              showSnackBar:
                  (message, {isError = false}) =>
                      _showSnackBar(context, message, isError: isError),
            ),
        title: 'Удалить',
        isDestructive: true,
        iconWidget: Icon(CupertinoIcons.delete, size: 16.r),
      ),
    ];
  }

  Widget _buildItemContent(BuildContext context, bool isMenuOpen) {
    final double elevation = isMenuOpen ? 20.0 : 0.0;
    final Color shadowColor = AppColors.shadowPurple.withValues(
      alpha: isMenuOpen ? 0.9 : 0.0,
    );

    Widget imageContent = CachedNetworkImage(
      key: ValueKey(widget.artwork.imageUrl),
      imageUrl: widget.artwork.imageUrl,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            color: AppColors.primaryBlack,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.borderGray,
                strokeWidth: 2,
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: AppColors.error200.withValues(alpha: 0.5),
            child: const Center(
              child: Icon(Icons.broken_image, color: AppColors.primary50),
            ),
          ),
    );

    if (isMenuOpen) {
      imageContent = Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: AppColors.primaryBlack.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned.fill(child: Opacity(opacity: 0.9, child: imageContent)),
        ],
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: elevation,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: imageContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PullDownButtonTheme customTheme = PullDownButtonTheme(
      routeTheme: PullDownMenuRouteTheme(
        backgroundColor: AppColors.primaryBlack.withValues(alpha: 0.9),
        shadow: BoxShadow(
          color: AppColors.shadowPurple.withValues(alpha: 0.5),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ),
      itemTheme: PullDownMenuItemTheme(
        textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.neutral50,
          fontSize: 10.sp,
        ),
        destructiveColor: AppColors.error200,
      ),
    );

    return PullDownButtonInheritedTheme(
      data: customTheme,
      child: PullDownButton(
        itemBuilder: (context) => _buildPullDownMenuItems(context),
        buttonBuilder: (context, showMenu) {
          return StatefulBuilder(
            builder: (context, setState) {
              bool isMenuOpen = false;

              void openMenu() {
                setState(() => isMenuOpen = true);
                showMenu().then((_) {
                  setState(() => isMenuOpen = false);
                });
              }

              return GestureDetector(
                onTap: () {
                  final netState = context.read<ConnectivityBloc>().state;
                  if (netState.isOnline == false) {
                    widget.onOfflineTap?.call();
                    return;
                  }
                  Navigator.of(
                    context,
                  ).pushNamed(CanvasScreen.name, arguments: widget.artwork);
                },
                onLongPress: openMenu,
                child: _buildItemContent(context, isMenuOpen),
              );
            },
          );
        },
        position: PullDownMenuPosition.automatic,
        buttonAnchor: PullDownMenuAnchor.center,
      ),
    );
  }
}
