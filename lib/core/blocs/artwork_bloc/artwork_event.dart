import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class ArtworkEvent extends Equatable {
  const ArtworkEvent();
}

class FetchUserArtworksStream extends ArtworkEvent {
  final String userUid;

  const FetchUserArtworksStream(this.userUid);

  @override
  List<Object> get props => [userUid];
}

class ArtworksUpdated extends ArtworkEvent {
  final List<dynamic> artworks;
  final String? errorMessage;

  const ArtworksUpdated(this.artworks, {this.errorMessage});

  @override
  List<Object?> get props => [artworks, errorMessage];
}

class RenameArtworkEvent extends ArtworkEvent {
  final String artworkId;
  final String newName;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  const RenameArtworkEvent({
    required this.artworkId,
    required this.newName,
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object> get props => [artworkId, newName];
}

class DeleteArtworkEvent extends ArtworkEvent {
  final String artworkId;
  final String imageUrl;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  const DeleteArtworkEvent({
    required this.artworkId,
    required this.imageUrl,
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object> get props => [artworkId, imageUrl];
}
