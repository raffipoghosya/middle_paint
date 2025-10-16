import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_bloc.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_state.dart';
import 'package:middle_paint/ui/widgets/artwork/artwork_grid_item.dart';
import 'package:middle_paint/base/ui_helpers/detect_device_type.dart';

class ArtworkGrid extends StatelessWidget {
  final VoidCallback? onOfflineTap;

  const ArtworkGrid({super.key, this.onOfflineTap});

  int _getCrossAxisCount(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    final aspectRatio = mediaQuery.size.aspectRatio;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final deviceType = getDeviceType(
      shortestSide: shortestSide,
      aspectRatio: aspectRatio,
      isLandscape: isLandscape,
    );

    return deviceType == DetectDeviceType.ipadLandscape ? 3 : 2;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final crossAxisCount = _getCrossAxisCount(context);

    return BlocBuilder<ArtworkBloc, ArtworkState>(
      builder: (context, state) {
        if (state.loading && !state.initialLoadComplete) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.magenta),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Text(
              'Ошибка загрузки: ${state.errorMessage}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error200),
              textAlign: TextAlign.center,
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.only(top: 46.h, bottom: 20.h + bottomPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 15.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1,
          ),
          itemCount: state.artworks.length,
          itemBuilder: (context, index) {
            final artwork = state.artworks[index];
            return ArtworkGridItem(
              artwork: artwork,
              onOfflineTap: onOfflineTap,
            );
          },
        );
      },
    );
  }
}
