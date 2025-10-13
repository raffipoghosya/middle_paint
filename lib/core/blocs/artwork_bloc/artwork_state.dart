import 'package:equatable/equatable.dart';
import 'package:middle_paint/core/models/artwork_model.dart';

class ArtworkState extends Equatable {
  final List<ArtworkModel> artworks;
  final bool loading;
  final String? errorMessage;
  final bool initialLoadComplete;

  const ArtworkState({
    this.artworks = const [],
    this.loading = false,
    this.errorMessage,
    this.initialLoadComplete = false,
  });

  ArtworkState copyWith({
    List<ArtworkModel>? artworks,
    bool? loading,
    String? errorMessage,
    bool? initialLoadComplete,
  }) {
    return ArtworkState(
      artworks: artworks ?? this.artworks,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      initialLoadComplete: initialLoadComplete ?? this.initialLoadComplete,
    );
  }

  @override
  List<Object?> get props => [
    artworks,
    loading,
    errorMessage,
    initialLoadComplete,
  ];
}
