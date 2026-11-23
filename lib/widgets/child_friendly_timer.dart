import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'glass/glass.dart';

/// A calm, non-stressful countdown for the child: a soft circular progress
/// ring that gently fills. No red flashing, no ticking numbers screaming
/// down — the study calls for a low-pressure timer. The facilitator gets the
/// precise mm:ss elsewhere ([FacilitatorTimerBar]).
class ChildFriendlyTimer extends StatelessWidget {
  const ChildFriendlyTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.size = 64,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fraction =
        totalSeconds <= 0 ? 0.0 : (remainingSeconds / totalSeconds).clamp(0, 1);
    return GlassSurface(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      blurSigma: 12,
      tintOpacity: 0.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size - 8,
            height: size - 8,
            child: CircularProgressIndicator(
              value: fraction.toDouble(),
              strokeWidth: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(SparkTheme.leafGreen),
            ),
          ),
          Icon(Icons.access_time_rounded,
              color: SparkTheme.ink.withValues(alpha: 0.6), size: size * 0.35),
        ],
      ),
    );
  }
}

/// Facilitator-facing timer bar: precise remaining time, phase label, and a
/// manual "Next" override button. Overrides are logged by the controller.
class FacilitatorTimerBar extends StatelessWidget {
  const FacilitatorTimerBar({
    super.key,
    required this.phaseLabel,
    required this.stepIndex,
    required this.totalSteps,
    required this.remainingSeconds,
    required this.onAdvance,
    required this.onEndEarly,
  });

  final String phaseLabel;
  final int stepIndex;
  final int totalSteps;
  final int remainingSeconds;
  final VoidCallback onAdvance;
  final VoidCallback onEndEarly;

  String get _mmss {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: SparkTheme.ink,
        );
    final timerStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: SparkTheme.ink,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: GlassSurface(
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        blurSigma: 20,
        tintOpacity: SparkGlassTheme.defaultTintOpacity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Phase ${stepIndex + 1}/$totalSteps · $phaseLabel',
                  style: labelStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(_mmss, style: timerStyle),
              const SizedBox(width: 10),
              GlassBarButton(
                label: 'Next',
                icon: Icons.skip_next_rounded,
                color: SparkTheme.sparkAmber,
                onPressed: onAdvance,
              ),
              const SizedBox(width: 6),
              GlassBarIconButton(
                icon: Icons.flag_rounded,
                color: SparkTheme.coral,
                tooltip: 'End session early',
                onPressed: onEndEarly,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
