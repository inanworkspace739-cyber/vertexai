import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

/// Progress stepper showing lesson completion status
class ProgressStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final isUpcoming = index > currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _StepIndicator(
                    stepNumber: index + 1,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isUpcoming: isUpcoming,
                  ),
                ),
                if (index < totalSteps - 1)
                  Container(
                    width: 8,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.accentViolet
                          : AppTheme.textMuted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;
  final bool isUpcoming;

  const _StepIndicator({
    required this.stepNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 40 : 32,
          height: isCurrent ? 40 : 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isCompleted || isCurrent
                ? AppTheme.primaryGradient
                : null,
            color: isUpcoming ? Colors.transparent : null,
            border: Border.all(
              color: isUpcoming
                  ? AppTheme.textMuted.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.accentViolet.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    '$stepNumber',
                    style: GoogleFonts.lexend(
                      fontSize: isCurrent ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: isCurrent
                          ? Colors.white
                          : AppTheme.textMuted.withOpacity(0.5),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lesson $stepNumber',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            color: isCurrent
                ? AppTheme.textPrimary
                : AppTheme.textMuted.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
