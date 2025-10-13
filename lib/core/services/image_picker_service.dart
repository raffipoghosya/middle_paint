import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// A simple wrapper service around the `image_picker` plugin.
/// Centralizes the logic for picking an image from the device's gallery.
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Prompts the user to select an image from the gallery.
  /// Returns a [File] object on success, or null if cancelled.
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
