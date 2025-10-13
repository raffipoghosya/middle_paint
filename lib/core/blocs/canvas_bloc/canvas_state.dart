import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CanvasState extends Equatable {
  final String? backgroundImagePath;
  final Size? imageNaturalSize;
  final bool loading;
  final String? saveMessage;
  final String? artworkIdToEdit;
  final String? originalArtworkUrl;

  const CanvasState({
    this.backgroundImagePath,
    this.imageNaturalSize,
    this.loading = false,
    this.saveMessage,
    this.artworkIdToEdit,
    this.originalArtworkUrl,
  });

  CanvasState copyWith({
    String? backgroundImagePath,
    Size? imageNaturalSize,
    bool? loading,
    String? saveMessage,
    String? artworkIdToEdit,
    String? originalArtworkUrl,
  }) {
    return CanvasState(
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      imageNaturalSize: imageNaturalSize ?? this.imageNaturalSize,
      loading: loading ?? this.loading,
      saveMessage: saveMessage,
      artworkIdToEdit: artworkIdToEdit,
      originalArtworkUrl: originalArtworkUrl,
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
  ];
}
