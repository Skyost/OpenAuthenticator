import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:open_authenticator/utils/platform.dart';

/// Allows to convert a camera image to an input image.
extension CameraImageToInputImage on CameraImage {
  /// Contains all available orientations.
  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// Converts the current camera image to an input image.
  InputImage? toInputImage(CameraController controller) {
    CameraDescription camera = controller.description;
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    int sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (currentPlatform == Platform.iOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (currentPlatform == Platform.android) {
      int rotationCompensation = _orientations[controller.value.deviceOrientation] ?? 0;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    rotation ??= InputImageRotation.rotation0deg;
    // print('final rotation: $rotation');

    // get image format
    InputImageFormat format = InputImageFormatValue.fromRawValue(this.format.raw) ?? (currentPlatform == Platform.android ? InputImageFormat.nv21 : InputImageFormat.bgra8888);
    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (planes.isEmpty) {
      return null;
    }
    Plane plane = planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size((plane.width ?? width).toDouble(), (plane.height ?? height).toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
