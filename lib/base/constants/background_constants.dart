import 'package:middle_paint/base/ui_helpers/detect_device_type.dart';

class DesignConstants {
  static double getSvgScaleFactor(DetectDeviceType deviceType) {
    switch (deviceType) {
      case DetectDeviceType.ipadPortrait:
      case DetectDeviceType.ipadLandscape:
        return 2.4;

      case DetectDeviceType.iphoneBigBase:
      case DetectDeviceType.iphoneBase:
      case DetectDeviceType.iphoneSmallBase:
        return 1.5;

      case DetectDeviceType.iphoneSe:
        return 1.8;
    }
  }

  static double getSvgTopFactor(DetectDeviceType deviceType) {
    switch (deviceType) {
      case DetectDeviceType.ipadPortrait:
        return -0.2;
      case DetectDeviceType.ipadLandscape:
        return -1.05;

      case DetectDeviceType.iphoneBigBase:
        return 0.03;

      case DetectDeviceType.iphoneBase:
        return 0.05;

      case DetectDeviceType.iphoneSmallBase:
        return 0.04;

      case DetectDeviceType.iphoneSe:
        return -0.05;
    }
  }

  static double getSvgLeftOffset(DetectDeviceType deviceType) {
    switch (deviceType) {
      case DetectDeviceType.ipadPortrait:
        return -10.0;
      case DetectDeviceType.ipadLandscape:
        return 600.0;

      case DetectDeviceType.iphoneBigBase:
        return -8.0;

      case DetectDeviceType.iphoneBase:
        return -5.0;

      case DetectDeviceType.iphoneSmallBase:
        return -5.0;

      case DetectDeviceType.iphoneSe:
        return -10;
    }
  }
}
