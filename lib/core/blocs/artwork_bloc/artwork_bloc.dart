import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_event.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_state.dart';
import 'package:middle_paint/core/firebase_services/firestore_database.dart';
import 'package:middle_paint/core/models/artwork_model.dart';
import 'package:middle_paint/core/firebase_services/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:middle_paint/core/firebase_services/storage_service.dart';

/// BLoC responsible for managing the state and actions of user artworks.
/// It primarily connects the UI to the real-time stream of artworks from Firestore,
/// and handles rename/delete operations via Storage and Firestore services.
class ArtworkBloc extends Bloc<ArtworkEvent, ArtworkState> {
  final FirestoreDatabaseService _firestoreService;
  final AuthenticationService _authService;
  final StorageService _storageService;
  StreamSubscription? _artworksSubscription;

  ArtworkBloc(this._firestoreService, this._authService, this._storageService)
    : super(const ArtworkState(loading: true)) {
    on<FetchUserArtworksStream>(_onFetchUserArtworksStream);
    on<ArtworksUpdated>(_onArtworksUpdated);
    on<RenameArtworkEvent>(_onRenameArtwork);
    on<DeleteArtworkEvent>(_onDeleteArtwork);
  }

  /// Subscribes to the real-time artwork stream from Firestore for the current user.
  /// If a subscription already exists, it is cancelled first.
  void _onFetchUserArtworksStream(
    FetchUserArtworksStream event,
    Emitter<ArtworkState> emit,
  ) {
    _artworksSubscription?.cancel();

    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'User not authenticated.',
          artworks: [],
          initialLoadComplete: true,
        ),
      );
      return;
    }

    emit(state.copyWith(loading: true, errorMessage: null));

    _artworksSubscription = _firestoreService
        .getUserArtworksStream(currentUser.uid)
        .listen(
          (artworks) {
            add(ArtworksUpdated(artworks));
          },
          onError: (error) {
            add(
              ArtworksUpdated(
                [],
                errorMessage: 'Failed to load artworks: ${error.toString()}',
              ),
            );
          },
        );
  }

  /// Handler for stream updates. Converts the list of dynamic documents
  /// into a typed list of [ArtworkModel] and updates the state.
  void _onArtworksUpdated(ArtworksUpdated event, Emitter<ArtworkState> emit) {
    if (event.errorMessage != null) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: event.errorMessage,
          initialLoadComplete: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          artworks: event.artworks as List<ArtworkModel>,
          loading: false,
          errorMessage: null,
          initialLoadComplete: true,
        ),
      );
    }
  }

  /// Renames an artwork by updating the 'name' field in Firestore.
  Future<void> _onRenameArtwork(
    RenameArtworkEvent event,
    Emitter<ArtworkState> emit,
  ) async {
    try {
      await _firestoreService.updateArtworkName(event.artworkId, event.newName);

      event.onSuccess.call();
    } catch (e) {
      const errorMessage = 'Не удалось переименовать работу.';
      event.onError.call(errorMessage);
    }
  }

  /// Deletes an artwork by first removing the image from Storage,
  /// and then removing the document from Firestore.
  Future<void> _onDeleteArtwork(
    DeleteArtworkEvent event,
    Emitter<ArtworkState> emit,
  ) async {
    try {
      await _storageService.deleteImage(imageUrl: event.imageUrl);

      await _firestoreService.deleteArtwork(event.artworkId);

      event.onSuccess.call();
    } catch (e) {
      const errorMessage = 'Не удалось удалить работу.';
      event.onError.call(errorMessage);
    }
  }

  /// Cleans up the stream subscription when the BLoC is closed.
  @override
  Future<void> close() {
    _artworksSubscription?.cancel();
    return super.close();
  }
}
