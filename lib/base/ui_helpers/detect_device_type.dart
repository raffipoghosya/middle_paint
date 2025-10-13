enum DetectDeviceType {
  iphoneSe,
  iphoneSmallBase,
  iphoneBase,
  iphoneBigBase,
  ipadPortrait,
  ipadLandscape,
}

const double _aspectRatioTolerance = 0.01;
const double _ipadMinWidth = 744.0;
const double _iphoneBigBaseThreshold = 410.0;
const double _iphoneSmallBaseThreshold = 385.0;

DetectDeviceType getDeviceType({
  required double shortestSide,
  required double aspectRatio,
  required bool isLandscape,
}) {
  if (shortestSide >= _ipadMinWidth) {
    return isLandscape
        ? DetectDeviceType.ipadLandscape
        : DetectDeviceType.ipadPortrait;
  }

  if (shortestSide > _iphoneBigBaseThreshold) {
    return DetectDeviceType.iphoneBigBase;
  }

  if (shortestSide <= _iphoneSmallBaseThreshold) {
    const targetRatio = 9 / 16;
    final is9by16 = (aspectRatio - targetRatio).abs() <= _aspectRatioTolerance;

    if (is9by16) {
      return DetectDeviceType.iphoneSe;
    }

    return DetectDeviceType.iphoneSmallBase;
  }

  return DetectDeviceType.iphoneBase;
}
