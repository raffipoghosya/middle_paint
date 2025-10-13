import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_event.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_state.dart';
import 'package:middle_paint/core/services/image_picker_service.dart';
import 'package:middle_paint/core/services/image_saver_service.dart';
import 'package:middle_paint/core/firebase_services/authentication.dart';
import 'package:middle_paint/core/firebase_services/firestore_database.dart';
import 'package:middle_paint/core/firebase_services/storage_service.dart';
import 'package:middle_paint/core/models/artwork_model.dart';
import 'package:middle_paint/core/resources/response_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:middle_paint/core/resources/base_exception.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:middle_paint/core/services/notification_service.dart';

/// BLoC for handling all canvas-related business logic, including:
class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  final ImagePickerService _imagePickerService;
  final ImageSaverService _imageSaverService;
  final AuthenticationService _authService;
  final FirestoreDatabaseService _firestoreService;
  final StorageService _storageService;
  final NotificationService _notificationService;

  CanvasBloc(
    this._imagePickerService,
    this._imageSaverService,
    this._authService,
    this._firestoreService,
    this._storageService,
    this._notificationService,
  ) : super(const CanvasState()) {
    on<PickBackgroundImageEvent>(_onPickBackgroundImage);
    on<ClearBackgroundImageEvent>(_onClearBackgroundImage);
    on<ShareImageEvent>(_onShareImage);
    on<SaveArtworkEvent>(_onSaveArtwork);
    on<StartEditArtworkEvent>(_onStartEditArtwork);
  }

  /// Calculates the natural size of a local image file. Used to correctly scale
  /// the drawing area to match the image's aspect ratio.
  Future<Size?> _getImageSize(File file) async {
    final Completer<Size> completer = Completer();

    final stream = Image.file(file).image.resolve(ImageConfiguration.empty);

    stream.addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          if (!completer.isCompleted) {
            completer.complete(
              Size(info.image.width.toDouble(), info.image.height.toDouble()),
            );
          }
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(exception!, stackTrace);
          }
        },
      ),
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } catch (_) {
      return null;
    }
  }

  /// Initiates the process of fetching an artwork's image from a URL,
  /// saving it temporarily, and updating the state for editing mode.
  Future<void> _onStartEditArtwork(
    StartEditArtworkEvent event,
    Emitter<CanvasState> emit,
  ) async {
    emit(const CanvasState(loading: true, saveMessage: null));

    try {
      final uri = Uri.parse(event.artwork.imageUrl);

      // Fetch the image bytes from the cloud URL
      final response = await http.get(
        uri,
        // Bypass caching to ensure we get the latest version if the URL is reused
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download image (status: ${response.statusCode}).',
        );
      }

      final Uint8List imageBytes = response.bodyBytes;

      // Save the bytes to a temporary local file for use in Image.file
      final directory = await getTemporaryDirectory();
      final tempFile = File(
        '${directory.path}/${event.artwork.id}_${DateTime.now().millisecondsSinceEpoch}_edit.png',
      );
      await tempFile.writeAsBytes(imageBytes);

      final imageSize = await _getImageSize(tempFile);

      // Update state to enter edit mode with the image
      emit(
        state.copyWith(
          backgroundImagePath: tempFile.path,
          imageNaturalSize: imageSize,
          loading: false,
          artworkIdToEdit: event.artwork.id,
          originalArtworkUrl: event.artwork.imageUrl,
        ),
      );
    } catch (e) {
      final errorMessage =
          'нe удалось загрузить изображение для редактирования: ${e.toString()}';
      emit(
        state.copyWith(
          loading: false,
          saveMessage: errorMessage,
          artworkIdToEdit: null,
          originalArtworkUrl: null,
        ),
      );
    }
  }

  /// Handles selecting a background image from the device gallery.
  Future<void> _onPickBackgroundImage(
    PickBackgroundImageEvent event,
    Emitter<CanvasState> emit,
  ) async {
    final file = await _imagePickerService.pickImageFromGallery();

    if (file != null) {
      emit(state.copyWith(loading: true));

      final imageSize = await _getImageSize(file);

      // Reset state and set new background image path
      emit(
        const CanvasState().copyWith(
          backgroundImagePath: file.path,
          imageNaturalSize: imageSize,
          loading: false,
        ),
      );
    } else {
      emit(state.copyWith(loading: false));
    }
  }

  /// Resets the canvas state by clearing the background image.
  void _onClearBackgroundImage(
    ClearBackgroundImageEvent event,
    Emitter<CanvasState> emit,
  ) {
    emit(const CanvasState());
  }

  /// Captures the current canvas, saves it temporarily, and invokes the
  /// native share sheet.
  Future<void> _onShareImage(
    ShareImageEvent event,
    Emitter<CanvasState> emit,
  ) async {
    emit(state.copyWith(loading: true, saveMessage: null));

    final result = await _imageSaverService.captureAndShare(
      event.repaintBoundaryKey,
      cropRect: event.cropRect,
      sharePositionOrigin: event.sharePositionOrigin,
    );

    if (result != null) {
      final isSuccess = !result.contains('cancelled');

      emit(
        state.copyWith(
          loading: false,
          saveMessage: isSuccess ? 'Изображение готово к отправке!' : null,
        ),
      );
    } else {
      final errorMessage = 'Не удалось подготовить изображение для отправки.';
      emit(state.copyWith(loading: false, saveMessage: errorMessage));
    }
  }

  /// Handles saving a new or updating an existing artwork.
  /// This involves: 1. Uploading PNG bytes to Storage. 2. Saving metadata to Firestore.
  /// 3. Sending a local notification for feedback.
  Future<void> _onSaveArtwork(
    SaveArtworkEvent event,
    Emitter<CanvasState> emit,
  ) async {
    final user = _authService.currentUser;
    if (user == null) {
      const errorMessage = 'Пользователь не авторизован.';
      emit(state.copyWith(loading: false, saveMessage: errorMessage));
      event.onError.call(errorMessage);
      return;
    }

    emit(state.copyWith(loading: true, saveMessage: null));

    final String userUid = user.uid;

    final isUpdate = event.artworkId != null;
    final String artworkId =
        event.artworkId ?? _firestoreService.generateArtworkId();

    final String imageName = DateTime.now().millisecondsSinceEpoch.toString();

    final storageResponse = await _storageService.uploadImage(
      imageBytes: event.pngBytes,
      userUid: userUid,
      imageName: imageName,
    );

    if (storageResponse is DataSuccess) {
      final String newImageUrl = storageResponse.data!;

      try {
        final newArtwork = ArtworkModel(
          id: artworkId,
          userUid: userUid,
          imageUrl: newImageUrl,
          name: isUpdate ? 'Рисунок $artworkId' : 'Рисунок $imageName',
          creationDate: Timestamp.now(),
        );

        await _firestoreService.saveArtwork(newArtwork);

        final successMessage =
            isUpdate
                ? 'Рисунок успешно обновлен!'
                : 'Рисунок успешно сохранен в облаке!';

        emit(
          state.copyWith(
            loading: false,
            saveMessage: successMessage,
            artworkIdToEdit: null,
            originalArtworkUrl: null,
          ),
        );

        _notificationService.showNotification(
          id: artworkId.hashCode,
          title: 'Сохранено',
          body: successMessage,
          payload: artworkId,
        );

        event.onSuccess.call();
      } catch (e) {
        final exception =
            e is FirebaseException
                ? BaseException(
                  message:
                      'Ошибка базы данных: ${e.message ?? 'Неизвестная ошибка.'}',
                  code: e.code,
                  error: e,
                )
                : BaseException(
                  message: 'Не удалось сохранить данные об рисунке.',
                  error: e,
                );

        emit(state.copyWith(loading: false, saveMessage: exception.message));
        event.onError.call(exception.message!);
      }
    } else if (storageResponse is DataFailed) {
      final errorMessage =
          storageResponse.exception!.message ?? 'Ошибка загрузки изображения.';
      emit(state.copyWith(loading: false, saveMessage: errorMessage));
      event.onError.call(errorMessage);
    }
  }
}
