import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The button that allows to switch camera.
class SwitchCameraButton extends StatelessWidget {
  /// The mobile scanner controller instance.
  final MobileScannerController controller;

  /// Creates a new switch camera button instance.
  const SwitchCameraButton({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, child) {
          if (!state.isInitialized || !state.isRunning) {
            return const SizedBox.shrink();
          }

          int? availableCameras = state.availableCameras;

          if (availableCameras != null && availableCameras < 2) {
            return const SizedBox.shrink();
          }

          return IconButton(
            color: Colors.white,
            iconSize: 32.0,
            icon: switch (state.cameraDirection) {
              CameraFacing.front => const Icon(Icons.camera_front),
              CameraFacing.back => const Icon(Icons.camera_rear),
            },
            onPressed: () async {
              await controller.switchCamera();
            },
          );
        },
      );
}

/// The button that allows to toggle the flashlight.
class ToggleFlashlightButton extends StatelessWidget {
  /// The mobile scanner controller instance.
  final MobileScannerController controller;

  /// Creates a new toggle flashlight button instance.
  const ToggleFlashlightButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, child) {
          if (!state.isInitialized || !state.isRunning) {
            return const SizedBox.shrink();
          }

          switch (state.torchState) {
            case TorchState.auto:
              return IconButton(
                color: Colors.white,
                iconSize: 32.0,
                icon: const Icon(Icons.flash_auto),
                onPressed: () async {
                  await controller.toggleTorch();
                },
              );
            case TorchState.off:
              return IconButton(
                color: Colors.white,
                iconSize: 32.0,
                icon: const Icon(Icons.flash_off),
                onPressed: () async {
                  await controller.toggleTorch();
                },
              );
            case TorchState.on:
              return IconButton(
                color: Colors.white,
                iconSize: 32.0,
                icon: const Icon(Icons.flash_on),
                onPressed: () async {
                  await controller.toggleTorch();
                },
              );
            case TorchState.unavailable:
              return const SizedBox.square(
                dimension: 48.0,
                child: Icon(
                  Icons.no_flash,
                  size: 32.0,
                  color: Colors.grey,
                ),
              );
          }
        },
      );
}
