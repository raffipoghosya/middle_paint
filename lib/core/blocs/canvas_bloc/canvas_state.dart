import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CanvasState extends Equatable {
  final String? backgroundImagePath;
  final Size? imageNaturalSize;
  final bool loading;
  final String? saveMessage;
  final String? artworkIdToEdit;
  final String? originalArtworkUrl;
  final String? overlayImagePath;
  final Rect? overlayRect;
  final bool isPlacingOverlay;
  final List<PlacedOverlay> placedOverlays;

  const CanvasState({
    this.backgroundImagePath,
    this.imageNaturalSize,
    this.loading = false,
    this.saveMessage,
    this.artworkIdToEdit,
    this.originalArtworkUrl,
    this.overlayImagePath,
    this.overlayRect,
    this.isPlacingOverlay = false,
    this.placedOverlays = const [],
  });

  CanvasState copyWith({
    String? backgroundImagePath,
    Size? imageNaturalSize,
    bool? loading,
    String? saveMessage,
    String? artworkIdToEdit,
    String? originalArtworkUrl,
    String? overlayImagePath,
    Rect? overlayRect,
    bool? isPlacingOverlay,
    List<PlacedOverlay>? placedOverlays,
  }) {
    return CanvasState(
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      imageNaturalSize: imageNaturalSize ?? this.imageNaturalSize,
      loading: loading ?? this.loading,
      saveMessage: saveMessage,
      artworkIdToEdit: artworkIdToEdit,
      originalArtworkUrl: originalArtworkUrl,
      overlayImagePath: overlayImagePath ?? this.overlayImagePath,
      overlayRect: overlayRect ?? this.overlayRect,
      isPlacingOverlay: isPlacingOverlay ?? this.isPlacingOverlay,
      placedOverlays: placedOverlays ?? this.placedOverlays,
    );
  }

  @override
  List<Object?> get props => [
    backgroundImagePath,
    imageNaturalSize,
    loading,
    saveMessage,
    artworkIdToEdit,
    originalArtworkUrl,
    overlayImagePath,
    overlayRect,
    isPlacingOverlay,
    placedOverlays,
  ];
}

class PlacedOverlay extends Equatable {
  final String imagePath;
  final Rect rect;

  const PlacedOverlay({required this.imagePath, required this.rect});

  @override
  List<Object?> get props => [imagePath, rect];
}
