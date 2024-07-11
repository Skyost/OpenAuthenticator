import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:open_authenticator/utils/camera.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/stream.dart';
import 'package:open_authenticator/utils/utils.dart';

export 'package:camera/camera.dart' show ResolutionPreset;
export 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' show BarcodeFormat;

/// # Code Scanner
///
/// A flexible code scanner for QR codes, barcodes and many others. Using [Google's ML Kit](https://developers.google.com/ml-kit/vision/barcode-scanning). Use it as a Widget with a camera or use the methods provided, with a camera controller..
///
/// ## Features
///
/// * Scan Linear and 2D formats: QR Code, Barcode, ...
/// * Widget with integrated camera
/// * Listen for callbacks with every code scanned
/// * Choose which formats to scan
/// * Overlay the camera preview with a custom view
/// * Camera lifecycle
///
/// ## Scannable Formats
///
/// * Aztec
/// * Codabar
/// * Code 39
/// * Code 93
/// * Code 128
/// * Data Matrix
/// * EAN-8
/// * EAN-13
/// * ITF
/// * PDF417
/// * QR Code
/// * UPC-A
/// * UPC-E
class CodeScanner extends StatefulWidget {
  /// The camera controller.
  final CameraController? controller;

  /// Which camera to use:
  /// * front
  /// * back
  /// * external
  ///
  /// Default: `back`
  final CameraLensDirection direction;

  /// Quality of the camera:
  /// * low
  /// * medium
  /// * high
  /// * very high
  /// * ultra
  ///
  /// or
  ///
  /// * max
  ///
  /// Setting a lower resolution preset may not support scanning features on some devices.
  /// It's recommended to use the highest quality preset available, if performance is not an issue.
  ///
  /// Default: `high`
  final ResolutionPreset resolution;

  /// List of the scannable formats:
  /// * Aztec
  /// * Codabar
  /// * Code 39
  /// * Code 93
  /// * Code 128
  /// * Data Matrix
  /// * EAN-8
  /// * EAN-13
  /// * ITF
  /// * PDF417
  /// * QR Code
  /// * UPC-A
  /// * UPC-E
  final List<BarcodeFormat> formats;

  /// Duration of delay between scans, to prevent lag.
  final Duration scanInterval;

  /// Whether or not, when a code is scanned, the controller should close and no longer scan.
  ///
  /// Default: `false`
  final bool once;

  /// The aspect ratio.
  final double? aspectRatio;

  /// Called whenever a controller is created.
  ///
  /// A new controller is created when initializing the widget and when the life cycle is resumed.
  final void Function(CameraController controller)? onCreated;

  /// Triggered when no camera is found.
  final VoidCallback? onNoCameraFound;

  /// Called when a scan occurs.
  final void Function(String? code, Barcode details, CodeScannerCameraListener listener)? onScan;

  /// Called when multiple barcodes are scanned.
  final void Function(List<Barcode> barcodes, CodeScannerCameraListener listener)? onScanAll;

  /// Called when an error occurred.
  final void Function(Object error, CodeScannerCameraListener listener)? onError;

  /// Called whenever camera access permission is denied by the user.
  ///
  /// Return `true` to retry, else `false`. Not setting this callback, will automatically never retry.
  ///
  /// Careful when retrying, this permission could have been rejected automatically, if you keep trying then it will silently spam the permission in a cycle. The `error` given can be useful to check this.
  ///
  /// Another approach would be to request the permission preemptively, before creating this widget, so it will never be needed to handle it here.
  final Future<bool>? Function(CameraException error, CameraController controller)? onAccessDenied;

  /// Widget to show before the cameras are initialized.
  final Widget? loading;

  /// Widget to overlay on top of the camera.
  ///
  /// Default: `CodeScannerOverlay()`
  final Widget? overlay;

  /// # Code Scanner
  ///
  /// A flexible code scanner for QR codes, barcodes and many others. Using [Google's ML Kit](https://developers.google.com/ml-kit/vision/barcode-scanning). Use it as a Widget with a camera or use the methods provided, with a camera controller.
  ///
  /// ## Features
  ///
  /// * Scan Linear and 2D formats: QR Code, Barcode, ...
  /// * Widget with integrated camera
  /// * Listen for callbacks with every code scanned
  /// * Choose which formats to scan
  /// * Overlay the camera preview with a custom view
  ///
  /// ## Simple Usage
  /// ```dart
  /// CodeScanner(
  ///   onScan: (code, details, controller) => ...,
  ///   formats: [ BarcodeFormat.qrCode ],
  ///   once: true,
  ///   onAccessDenied: (error, controller) {
  ///     Navigator.of(context).pop();
  ///     return false;
  ///   },
  /// )
  /// ```
  const CodeScanner({
    super.key,
    this.controller,
    this.direction = CameraLensDirection.back,
    this.resolution = ResolutionPreset.high,
    this.formats = const [BarcodeFormat.all],
    this.scanInterval = const Duration(seconds: 1),
    this.once = false,
    this.aspectRatio,
    this.onCreated,
    this.onNoCameraFound,
    this.onScan,
    this.onScanAll,
    this.onAccessDenied,
    this.onError,
    this.loading,
    this.overlay,
  });

  @override
  State<CodeScanner> createState() => _CodeScannerState();
}

/// The code scanner state.
class _CodeScannerState extends State<CodeScanner> with WidgetsBindingObserver {
  /// The camera controller.
  CameraController? controller;

  /// The camera listener.
  CodeScannerCameraListener? listener;

  /// Whether to retry for when camera permission is denied.
  bool retry = true;

  /// Whether it's initialized.
  bool initialized = false;

  /// Whether the controller is internal.
  bool isInternalController = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameraController();
  }

  @override
  void dispose() {
    listener?.dispose().then((_) => controller?.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!isInternalController || controller == null || !controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController();
    }
  }

  /// Initializes the camera controller.
  Future<void> _initCameraController() async {
    CameraController controller;
    CameraController? widgetController = widget.controller;

    if (widgetController != null) {
      isInternalController = false;
      controller = widgetController;
    } else {
      isInternalController = true;
      CameraController? cameraController = await _createCameraController();
      if (cameraController == null) {
        widget.onNoCameraFound?.call();
        return;
      }
      controller = cameraController;
      try {
        await controller.initialize();
      } on CameraException catch (error) {
        controller.dispose();
        retry = await widget.onAccessDenied?.call(error, controller) ?? false;
        initialized = true;
        return;
      }
    }

    widget.onCreated?.call(controller);
    callback() => this.controller = controller;
    if (mounted) {
      setState(callback);
    } else {
      callback();
    }

    if (listener != null) {
      listener!.dispose();
    }
    listener = CodeScannerCameraListener(
      this.controller!,
      onScan: (code, details, listener) async {
        widget.onScan?.call(code, details, listener);
        if (widget.once) {
          setState(() {
            this.controller = null;
            listener.stop();
          });
        }
      },
      onScanAll: (barcodes, listener) async {
        widget.onScanAll?.call(barcodes, listener);
        if (widget.once) {
          setState(() {
            this.controller = null;
            listener.stop();
          });
        }
      },
      formats: widget.formats,
      interval: widget.scanInterval,
    );

    initialized = true;
  }

  /// Creates the camera controller.
  Future<CameraController?> _createCameraController() async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription? camera = cameras.firstWhereOrNull((camera) => camera.lensDirection == widget.direction) ?? cameras.firstOrNull;
    return camera == null
        ? null
        : CameraController(
            camera,
            widget.resolution,
            enableAudio: false,
            imageFormatGroup: currentPlatform == Platform.android ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
          );
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return widget.loading ?? Container();
    }
    return CodeScannerCameraView(
      controller: controller!,
      overlay: widget.overlay,
      aspectRatio: widget.aspectRatio,
    );
  }
}

/// Widget to show a camera with an overlay, this widget tries to expand.
class CodeScannerCameraView extends StatelessWidget {
  /// The camera controller instance.
  final CameraController controller;

  /// The widget overlay.
  final Widget? overlay;

  /// The aspect ratio.
  final double? aspectRatio;

  /// Creates a new code scanner camera view instance.
  const CodeScannerCameraView({
    super.key,
    required this.controller,
    this.overlay,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    double cameraAspectRatio = controller.value.aspectRatio;
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * cameraAspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
          overlay ?? CodeScannerOverlay(width: constraints.maxWidth, height: constraints.minHeight),
        ],
      ),
    );
  }
}

/// Create a camera listener to plug it with any camera controller, to scan for codes
class CodeScannerCameraListener {
  /// The camera controller instance.
  final CameraController controller;

  /// The image stream controller.
  final StreamController<CameraImage> imageController = StreamController<CameraImage>();

  /// The scanner instance.
  final BarcodeScanner scanner;

  /// Called when a scan occurs.
  final void Function(String? code, Barcode details, CodeScannerCameraListener listener)? onScan;

  /// Called when multiple barcodes are scanned.
  final void Function(List<Barcode> barcodes, CodeScannerCameraListener listener)? onScanAll;

  /// Called when an error occurred.
  final void Function(Object error, CodeScannerCameraListener listener)? onError;

  /// Indicates whether the first `CameraImage` from the Image Stream has been discarded.
  bool _firstImageDiscarded = false;

  /// Creates a new code scanner camera listener instance.
  CodeScannerCameraListener(
    this.controller, {
    List<BarcodeFormat> formats = const [BarcodeFormat.all],
    Duration interval = const Duration(milliseconds: 500),
    this.onScan,
    this.onScanAll,
    this.onError,
  }) : scanner = BarcodeScanner(formats: formats) {
    start();
    imageController.stream.throttle(interval, trailing: true).listen((image) async {
      try {
        await _onImage(image);
      } catch (error) {
        onError?.call(error, this);
      }
    });
  }

  /// Starts the camera image controller.
  void start() {
    if (!controller.value.isStreamingImages) {
      controller.startImageStream((CameraImage image) {
        if (!imageController.isClosed) {
          imageController.add(image);
        }
      });
    }
  }

  /// Stops the camera image controller and image stream.
  Future<void> stop() async {
    await imageController.close();
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    await controller.dispose();
    await scanner.close();
  }

  /// Alias of the `.stop()` method, for consistency with the flutter environment.
  Future<void> dispose() async => await stop();

  /// Triggered when an image is being scanned.
  Future<void> _onImage(CameraImage image) async {
    // Check if the first CameraImage has been discarded
    if (!_firstImageDiscarded) {
      // Update the boolean flag to true.
      _firstImageDiscarded = true;
      // Return immediately without processing the image, effectively discarding it.
      return;
    }
    if (!controller.value.isStreamingImages) {
      throw Exception('Camera is not streaming images');
    }
    if (onScan == null && onScanAll == null) {
      throw Exception('No listener');
    }

    /*
    final cropWidth = image.width * 0.5;
    final cropHeight = cropWidth * 0.5;
    final cropX = image.width * 0.25;
    final cropY = image.height * 0.5 - cropHeight / 2;
    */

    InputImage? inputImage = image
        //.crop(cropX.toInt(), cropY.toInt(), cropWidth.toInt(), cropHeight.toInt())
        .toInputImage(controller);

    await _onImageProcessed(inputImage == null ? [] : await scanner.processImage(inputImage));
  }

  /// Should be triggered when an image is being processed.
  Future<void> _onImageProcessed(List<Barcode> barcodes) async {
    if (!controller.value.isStreamingImages || barcodes.isEmpty) {
      return;
    }
    onScan?.call(barcodes.first.rawValue, barcodes.first, this);
    onScanAll?.call(barcodes, this);
  }
}

/// Default overlay displayed on top of the camera
class CodeScannerOverlay extends StatelessWidget {
  /// The width.
  final double width;

  /// The height.
  final double height;

  /// Creates a new code scanner overlay instance.
  const CodeScannerOverlay({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Center(
            child: Container(
              width: width * 0.8,
              height: 0.8,
              color: Colors.redAccent.withOpacity(0.4),
            ),
          ),
          Center(
            child: Container(
              width: width * 0.8,
              height: width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.3), width: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.srcOut),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstIn,
                  ),
                ),
                Center(
                  child: Container(
                    width: width * 0.8,
                    height: width * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
