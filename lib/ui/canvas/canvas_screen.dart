import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:middle_paint/base/colors/app_colors.dart';
import 'package:middle_paint/base/constants/constants.dart';
import 'package:middle_paint/core/controllers/drawing_controller.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_bloc.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_event.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_state.dart';
import 'package:middle_paint/gen/assets.gen.dart';
import 'package:middle_paint/ui/widgets/app_bar.dart/custom_app_bar.dart';
import 'package:middle_paint/ui/widgets/background/custom_background.dart';
import 'package:middle_paint/ui/widgets/buttons/tool_icon.dart';
import 'package:middle_paint/ui/widgets/canvas/drawing_area.dart';
import 'package:middle_paint/ui/widgets/canvas/stroke_width_slider_popup.dart';
import 'package:middle_paint/ui/widgets/canvas/color_picker_popup.dart';
import 'package:middle_paint/core/services/image_saver_service.dart';
import 'package:middle_paint/core/injector/injector.dart';
import 'package:middle_paint/core/firebase_services/authentication.dart';
import 'package:middle_paint/core/models/artwork_model.dart';
import 'package:middle_paint/core/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:middle_paint/ui/gallery/home_screen.dart';

class CanvasScreen extends StatefulWidget {
  static const name = '/canvas';

  final ArtworkModel? artworkToEdit;

  const CanvasScreen({super.key, this.artworkToEdit});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late final DrawingController _drawingController;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final GlobalKey _shareIconKey = GlobalKey();
  bool _showStrokeSlider = false;
  bool _showColorPalette = false;
  bool _isPencilMode = true;
  late CanvasBloc _canvasBloc;
  Rect? _currentDrawingBounds;
  final ImageSaverService _imageSaverService = sl<ImageSaverService>();
  final AuthenticationService _authService = sl<AuthenticationService>();
  bool _flashOfflineBanner = false;

  @override
  void initState() {
    super.initState();
    _drawingController = DrawingController();
    _drawingController.setDrawMode();
    _canvasBloc = context.read<CanvasBloc>();

    if (widget.artworkToEdit != null) {
      _canvasBloc.add(StartEditArtworkEvent(artwork: widget.artworkToEdit!));
    }
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  void _hideAllPopups() {
    if (_showStrokeSlider || _showColorPalette) {
      setState(() {
        _showStrokeSlider = false;
        _showColorPalette = false;
      });
    }
  }

  void _onDrawingBoundsCalculated(Rect? bounds) {
    if (bounds != null && bounds != _currentDrawingBounds) {
      _currentDrawingBounds = bounds;
    }
  }

  void _onPencilTap() {
    _showColorPalette = false;
    _drawingController.setDrawMode();

    setState(() {
      _showStrokeSlider = _isPencilMode ? !_showStrokeSlider : true;
      _isPencilMode = true;
    });
  }

  void _onEraserTap() {
    _showColorPalette = false;
    _drawingController.setEraseMode();

    setState(() {
      _showStrokeSlider = !_isPencilMode ? !_showStrokeSlider : true;
      _isPencilMode = false;
    });
  }

  void _onShareImageTap() {
    _hideAllPopups();

    final RenderBox? box =
        _shareIconKey.currentContext?.findRenderObject() as RenderBox?;

    final Rect sharePositionOrigin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : Rect.zero;

    _canvasBloc.add(
      ShareImageEvent(
        repaintBoundaryKey: _repaintBoundaryKey,
        cropRect: _currentDrawingBounds,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<void> _onSaveToCloudTap(BuildContext tapContext, String? artworkIdToEdit) async {
    _hideAllPopups();

    final isOnline = tapContext.read<ConnectivityBloc>().state.isOnline;
    if (isOnline == false) {
      setState(() => _flashOfflineBanner = true);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _flashOfflineBanner = false);
      });
      return;
    }

    if (_authService.currentUser == null) {
      _showSaveSnackBar(
        'Для сохранения работы в облаке необходимо авторизоваться.',
        false,
      );
      return;
    }

    final pngBytes = await _imageSaverService.capturePngBytes(
      _repaintBoundaryKey,
      cropRect: _currentDrawingBounds,
    );

    if (pngBytes == null) {
      _showSaveSnackBar(
        'Не удалось подготовить изображение для сохранения.',
        false,
      );
      return;
    }

    _canvasBloc.add(
      SaveArtworkEvent(
        pngBytes: pngBytes,
        cropRect: _currentDrawingBounds,
        onSuccess: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(HomeScreen.name);
          }
        },
        onError: (message) {},
        artworkId: artworkIdToEdit,
      ),
    );
  }

  void _onUndoTap() {
    _hideAllPopups();
    _drawingController.undo();
  }

  void _onRedoTap() {
    _hideAllPopups();
    _drawingController.redo();
  }

  void _onMoveLayerUpTap() {
    _hideAllPopups();
    _drawingController.movePathUp();
  }

  void _onMoveLayerDownTap() {
    _hideAllPopups();
    _drawingController.movePathDown();
  }

  void _onGalleryTap(bool isEditMode) {
    _hideAllPopups();
    if (isEditMode) {
      _canvasBloc.add(PickOverlayImageEvent());
    } else {
      _canvasBloc.add(PickBackgroundImageEvent());
    }
  }

  void _onPaletteTap() {
    _showStrokeSlider = false;

    setState(() {
      _showColorPalette = !_showColorPalette;
      _drawingController.setDrawMode();
      _isPencilMode = true;
    });
  }

  void _onStrokeWidthChanged(double newWidth) {
    _drawingController.setCurrentStrokeWidth(newWidth);
  }

  void _onColorChanged(Color newColor) {
    _drawingController.setCurrentColor(newColor);
  }

  void _onTapOutsidePopup() {
    _hideAllPopups();
  }

  void _showSaveSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.primary50),
        ),
        backgroundColor: isSuccess ? AppColors.purple : AppColors.error200,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildLayerControls() {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 24.h + bottomPadding,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListenableBuilder(
          listenable: _drawingController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToolIcon(
                  assetName: Assets.vectors.undo,
                  onTap: _onUndoTap,
                  isEnabled: _drawingController.canUndo,
                  leftPadding: 0.0,
                  isSmall: true,
                ),
                ToolIcon(
                  assetName: Assets.vectors.redo,
                  onTap: _onRedoTap,
                  isEnabled: _drawingController.canRedo,
                  leftPadding: 12.0,
                  isSmall: true,
                ),

                SizedBox(width: 32.w),

                ToolIcon(
                  assetName: Assets.vectors.layersMinus,
                  onTap: _onMoveLayerDownTap,
                  isEnabled: _drawingController.canMoveDown,
                  leftPadding: 0.0,
                  isSmall: true,
                ),
                SizedBox(width: 24.w),
                ToolIcon(
                  assetName: Assets.vectors.layersPlus,
                  onTap: _onMoveLayerUpTap,
                  isEnabled: _drawingController.canMoveUp,
                  leftPadding: 0.0,
                  isSmall: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double appBarHeight = AppConstants.contentHeight + topPadding;

    final pencilIconColor =
        _isPencilMode && _showStrokeSlider ? AppColors.purple : null;

    final eraserIconColor =
        !_isPencilMode && _showStrokeSlider ? AppColors.purple : null;

    final paletteIconColor = _showColorPalette ? AppColors.purple : null;

    return BlocConsumer<CanvasBloc, CanvasState>(
      listener: (context, state) {
        if (state.saveMessage != null) {
          final message = state.saveMessage!;

          final isFirebaseSuccess =
              message.contains('успешно сохранен') ||
              message.contains('успешно обновлен');

          final isShareSuccess = message.contains('готово к отправке');

          if (!isFirebaseSuccess) {
            final isSuccess =
                message.contains('сохранено') ||
                isFirebaseSuccess ||
                isShareSuccess;
            _showSaveSnackBar(message, isSuccess);
          }

          // ignore: invalid_use_of_visible_for_testing_member
          context.read<CanvasBloc>().emit(state.copyWith(saveMessage: null));
          if (isFirebaseSuccess) {
            context.read<CanvasBloc>().add(ClearBackgroundImageEvent());
          }
        }
        if (widget.artworkToEdit != null &&
            state.backgroundImagePath == null) {}
      },
      builder: (context, canvasState) {
        final bool isScreenEditMode = widget.artworkToEdit != null;

        return BlocProvider(
          create: (_) => sl<ConnectivityBloc>()..add(ConnectivityStarted()),
          child: Scaffold(
          backgroundColor: AppColors.primaryBlack,
          body: Stack(
            children: [
              const CustomBackground(child: SizedBox.expand()),

              Positioned(
                top: appBarHeight,
                left: 0,
                right: 0,
                child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
                  builder: (context, netState) {
                    if (netState.isOnline == false) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        color: _flashOfflineBanner
                            ? AppColors.error200.withValues(alpha: 0.5)
                            : AppColors.error200.withValues(alpha: 0.2),
                        child: Text(
                          'Нет подключения к Интернету',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary50,
                              ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              DrawingArea(
                appBarHeight: appBarHeight,
                controller: _drawingController,
                backgroundImagePath: canvasState.backgroundImagePath,
                imageNaturalSize: canvasState.imageNaturalSize,
                repaintBoundaryKey: _repaintBoundaryKey,
                onBoundsCalculated: _onDrawingBoundsCalculated,
              ),

              Positioned(
                top: appBarHeight,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 24.h,
                  ),
                  child: ListenableBuilder(
                    listenable: _drawingController,
                    builder: (context, child) {
                      final bool isPlacingOverlay = canvasState.isPlacingOverlay;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ToolIcon(
                                key: _shareIconKey, 
                                assetName: Assets.vectors.download,
                                onTap: _onShareImageTap,
                                leftPadding: 0.0,
                              ),
                              ToolIcon(
                                assetName: Assets.vectors.gallery,
                                onTap: () => _onGalleryTap(isScreenEditMode),
                                isEnabled: !isPlacingOverlay,
                                leftPadding: 12.0,
                              ),
                              ToolIcon(
                                assetName: Assets.vectors.pencil,
                                onTap: _onPencilTap,
                                color: pencilIconColor,
                                leftPadding: 12.0,
                              ),
                              ToolIcon(
                                assetName: Assets.vectors.eraser,
                                onTap: _onEraserTap,
                                color: eraserIconColor,
                                leftPadding: 12.0,
                              ),
                              ToolIcon(
                                assetName: Assets.vectors.palette,
                                onTap: _onPaletteTap,
                                color: paletteIconColor,
                                leftPadding: 12.0,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              if (_showStrokeSlider)
                StrokeWidthSliderPopup(
                  initialValue: _drawingController.currentStrokeWidth,
                  onChanged: _onStrokeWidthChanged,
                  onTapOutside: _onTapOutsidePopup,
                ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child:
                    _showColorPalette
                        ? ListenableBuilder(
                          key: const ValueKey('ColorPickerPopup'),
                          listenable: _drawingController,
                          builder: (context, child) {
                            return ColorPickerPopup(
                              initialColor: _drawingController.currentColor,
                              onColorChanged: _onColorChanged,
                              onTapOutside: _onTapOutsidePopup,
                            );
                          },
                        )
                        : const SizedBox.shrink(key: ValueKey('Empty')),
              ),

              _buildLayerControls(),

              if (canvasState.loading)
                Positioned.fill(
                  child: Container(
                    color: AppColors.primaryBlack.withValues(alpha: 0.6),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.magenta,
                      ),
                    ),
                  ),
                ),

              CustomAppBar(
                leading: GestureDetector(
                  onTap: () {
                    context.read<CanvasBloc>().add(ClearBackgroundImageEvent());
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(HomeScreen.name);
                    }
                  },
                  child: SvgPicture.asset(
                    Assets.vectors.arrowLeft,
                    width: 24.r,
                  ),
                ),
                title:
                    isScreenEditMode ? 'Редактирование' : 'Новое изображение',
                actions: [
                  if (canvasState.isPlacingOverlay)
                    GestureDetector(
                      onTap: () {
                        context.read<CanvasBloc>().add(CommitOverlayEvent());
                        _drawingController.setDrawMode();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          'Сохранить',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.neutral50,
                              ),
                        ),
                      ),
                    )
                  else
                    Builder( 
                      builder: (builderContext) {
                        return GestureDetector(
                          onTap:
                              () => _onSaveToCloudTap(
                                builderContext,
                                canvasState.artworkIdToEdit ?? widget.artworkToEdit?.id,
                              ),
                          child: SvgPicture.asset(Assets.vectors.check, width: 24.r),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}