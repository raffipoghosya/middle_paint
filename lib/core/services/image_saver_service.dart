import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// A utility service for capturing content from a [RepaintBoundary] and
/// handling saving or sharing of the resulting image (PNG bytes).
class ImageSaverService {
  /// Captures the widget tree within the [repaintBoundaryKey] as PNG bytes.
  /// Supports optional cropping using a provided [cropRect] to only capture
  /// the drawing area, excluding UI elements.
  Future<Uint8List?> capturePngBytes(
    GlobalKey repaintBoundaryKey, {
    Rect? cropRect,
  }) async {
    try {
      if (repaintBoundaryKey.currentContext == null) {
        return null;
      }
      final RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      const double pixelRatio = 3.0;
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

      ui.Image imageToSave = image;
      if (cropRect != null) {
        final double cropLeft = cropRect.left * pixelRatio;
        final double cropTop = cropRect.top * pixelRatio;
        final int cropWidth = (cropRect.width * pixelRatio).round();
        final int cropHeight = (cropRect.height * pixelRatio).round();

        final ui.PictureRecorder recorder = ui.PictureRecorder();
        final ui.Canvas canvas = ui.Canvas(
          recorder,
          Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble()),
        );

        final ui.Rect src = ui.Rect.fromLTWH(
          cropLeft,
          cropTop,
          cropWidth.toDouble(),
          cropHeight.toDouble(),
        );

        final ui.Rect dst = ui.Rect.fromLTWH(
          0,
          0,
          cropWidth.toDouble(),
          cropHeight.toDouble(),
        );

        canvas.drawImageRect(image, src, dst, Paint());

        final ui.Picture picture = recorder.endRecording();
        imageToSave = await picture.toImage(cropWidth, cropHeight);
      }

      final byteData = await imageToSave.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData!.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Captures the image, saves it temporarily, and opens the system share dialog.
  Future<void> captureAndShare({
    required GlobalKey repaintBoundaryKey,
    Rect? cropRect,
    required Rect sharePositionOrigin,
  }) async {
    final Uint8List? pngBytes = await capturePngBytes(
      repaintBoundaryKey,
      cropRect: cropRect,
    );

    if (pngBytes == null) {
      throw Exception('Failed to prepare image for sharing.');
    }

    try {
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/middle_paint_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(imagePath);
      await file.writeAsBytes(pngBytes);

      final initialParams = ShareParams(
        files: [XFile(imagePath)],
        sharePositionOrigin: sharePositionOrigin,
      );
      await SharePlus.instance.share(initialParams);
    } catch (e) {
      throw Exception('Sharing process failed: $e');
    }
  }

  /// Downloads an image from a URL and saves it to the device's photo gallery.
  Future<String?> saveImageFromUrl(String url, {String? name}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return null;
      }
      final Uint8List imageBytes = response.bodyBytes;

      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: name ?? 'middle_paint_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        return 'Image saved successfully';
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
