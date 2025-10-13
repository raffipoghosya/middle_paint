import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:middle_paint/core/models/user_model.dart';
import 'package:middle_paint/core/models/artwork_model.dart';

/// A service class for handling CRUD operations with Firestore.
/// This encapsulates all direct database interactions for user and artwork data.
class FirestoreDatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates or updates a user document in the 'users' collection.
  Future<void> createUser(AppUser user) async {
    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> userExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// Generates a new, unique document ID for an artwork.
  String generateArtworkId() {
    return _db.collection('artworks').doc().id;
  }

  /// Saves a new or updates an existing [ArtworkModel] document in Firestore.
  Future<void> saveArtwork(ArtworkModel artwork) async {
    try {
      final docRef = _db.collection('artworks').doc(artwork.id);
      await docRef.set(artwork.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Updates only the 'name' field of a specific artwork document.
  Future<void> updateArtworkName(String artworkId, String newName) async {
    try {
      await _db.collection('artworks').doc(artworkId).update({'name': newName});
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes an artwork document from Firestore.
  Future<void> deleteArtwork(String artworkId) async {
    try {
      await _db.collection('artworks').doc(artworkId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Provides a real-time stream of artworks for a specific user,
  /// ordered by creation date (newest first).
  Stream<List<ArtworkModel>> getUserArtworksStream(String userUid) {
    return _db
        .collection('artworks')
        .where('userUid', isEqualTo: userUid)
        .orderBy('creationDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ArtworkModel.fromMap(doc.data()))
              .toList();
        });
  }
}
