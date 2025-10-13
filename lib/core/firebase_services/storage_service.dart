import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:middle_paint/core/resources/response_state.dart';
import 'package:middle_paint/core/resources/base_exception.dart';

/// A service class for interacting with Firebase Cloud Storage.
/// It provides methods for uploading and deleting user-generated artwork images.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image byte array to a specific path in Firebase Storage.
  /// The path is structured as 'artworks/{userUid}/middle_paint_{imageName}.png'.
  /// Returns a [DataState<String>] containing the public download URL on success.
  Future<DataState<String>> uploadImage({
    required Uint8List imageBytes,
    required String userUid,
    required String imageName,
  }) async {
    try {
      final String path = 'artworks/$userUid/middle_paint_$imageName.png';
      final Reference ref = _storage.ref().child(path);

      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/png'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return DataSuccess(downloadUrl);
    } on FirebaseException catch (e) {
      return DataFailed(
        BaseException(
          message: 'Failed to upload image: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return DataFailed(
        BaseException(message: 'An unexpected error occurred during upload.'),
      );
    }
  }

  /// Deletes an image from Firebase Storage using its public URL.
  /// It parses the URL to get the correct storage reference.
  /// Returns a [DataState<void>] indicating success or failure.
  Future<DataState<void>> deleteImage({required String imageUrl}) async {
    try {
      final uri = Uri.parse(imageUrl);
      final cleanUrl =
          uri.removeFragment().replace(queryParameters: {}).toString();

      final Reference ref = _storage.refFromURL(cleanUrl);

      await ref.delete();
      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(
        BaseException(
          message: 'Не удалось удалить изображение: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return DataFailed(
        BaseException(
          message: 'Произошла непредвиденная ошибка при удалении изображения.',
        ),
      );
    }
  }
}
