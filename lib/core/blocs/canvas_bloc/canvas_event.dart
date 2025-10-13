import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:middle_paint/core/models/artwork_model.dart';

class CanvasEvent {}

class PickBackgroundImageEvent extends CanvasEvent {}

class ClearBackgroundImageEvent extends CanvasEvent {}

class StartEditArtworkEvent extends CanvasEvent {
  final ArtworkModel artwork;

  StartEditArtworkEvent({required this.artwork});
}

class ShareImageEvent extends CanvasEvent {
  final GlobalKey repaintBoundaryKey;
  final Rect? cropRect;
  final Rect sharePositionOrigin;

  ShareImageEvent({
    required this.repaintBoundaryKey,
    this.cropRect,
    required this.sharePositionOrigin,
  });
}

class SaveArtworkEvent extends CanvasEvent {
  final Uint8List pngBytes;
  final Rect? cropRect;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;
  final String? artworkId;

  SaveArtworkEvent({
    required this.pngBytes,
    this.cropRect,
    required this.onSuccess,
    required this.onError,
    this.artworkId,
  });
}
