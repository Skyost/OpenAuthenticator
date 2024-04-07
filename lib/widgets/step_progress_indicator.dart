import 'package:flutter/material.dart';

/// Allows to display the current progress of an operation.
class StepProgressIndicator extends StatelessWidget {
  /// The step count.
  final int steps;

  /// The current step.
  final int currentStep;

  /// Steps size.
  final double stepsSize;

  /// Current step size.
  final double currentStepSize;

  /// Creates a new step progress indicator instance.
  const StepProgressIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
    this.stepsSize = 6,
    this.currentStepSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: (steps - 1) * stepsSize + currentStepSize + 10 * steps,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < steps; i++)
            if (i == currentStep - 1)
              Container(
                color: colorScheme.primary,
                width: currentStepSize,
                height: currentStepSize,
              )
            else
              Container(
                color: colorScheme.secondaryContainer,
                width: stepsSize,
                height: stepsSize,
              ),
        ],
      ),
    );
  }
}
