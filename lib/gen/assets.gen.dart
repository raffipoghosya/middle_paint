// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/icon.png
  AssetGenImage get icon => const AssetGenImage('assets/images/icon.png');

  /// File path: assets/images/splash.png
  AssetGenImage get splash => const AssetGenImage('assets/images/splash.png');

  /// List of all assets
  List<AssetGenImage> get values => [icon, splash];
}

class $AssetsJsonGen {
  const $AssetsJsonGen();

  /// File path: assets/json/color_palette.json
  String get colorPalette => 'assets/json/color_palette.json';

  /// File path: assets/json/splash.json
  String get splash => 'assets/json/splash.json';

  /// List of all assets
  List<String> get values => [colorPalette, splash];
}

class $AssetsVectorsGen {
  const $AssetsVectorsGen();

  /// File path: assets/vectors/arrow_left.svg
  String get arrowLeft => 'assets/vectors/arrow_left.svg';

  /// File path: assets/vectors/check.svg
  String get check => 'assets/vectors/check.svg';

  /// File path: assets/vectors/download.svg
  String get download => 'assets/vectors/download.svg';

  /// File path: assets/vectors/eraser.svg
  String get eraser => 'assets/vectors/eraser.svg';

  /// File path: assets/vectors/gallery.svg
  String get gallery => 'assets/vectors/gallery.svg';

  /// File path: assets/vectors/layers_minus.svg
  String get layersMinus => 'assets/vectors/layers_minus.svg';

  /// File path: assets/vectors/layers_plus.svg
  String get layersPlus => 'assets/vectors/layers_plus.svg';

  /// File path: assets/vectors/logout.svg
  String get logout => 'assets/vectors/logout.svg';

  /// File path: assets/vectors/paint.svg
  String get paint => 'assets/vectors/paint.svg';

  /// File path: assets/vectors/palette.svg
  String get palette => 'assets/vectors/palette.svg';

  /// File path: assets/vectors/pattern.svg
  String get pattern => 'assets/vectors/pattern.svg';

  /// File path: assets/vectors/pencil.svg
  String get pencil => 'assets/vectors/pencil.svg';

  /// File path: assets/vectors/redo.svg
  String get redo => 'assets/vectors/redo.svg';

  /// File path: assets/vectors/undo.svg
  String get undo => 'assets/vectors/undo.svg';

  /// List of all assets
  List<String> get values => [
    arrowLeft,
    check,
    download,
    eraser,
    gallery,
    layersMinus,
    layersPlus,
    logout,
    paint,
    palette,
    pattern,
    pencil,
    redo,
    undo,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
  static const $AssetsVectorsGen vectors = $AssetsVectorsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
