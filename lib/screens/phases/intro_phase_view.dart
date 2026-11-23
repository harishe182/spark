import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/glass/glass.dart';
import '../../widgets/child_friendly_timer.dart';
import '../../widgets/spark_character.dart';

/// Intro phase: shows the prompt and a friendly "I'm ready!" button. The
/// facilitator (or the timer) advances to idea generation.
class IntroPhaseView extends StatelessWidget {
  const IntroPhaseView({
    super.key,
    required this.title,
    required this.body,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.onReady,
  });

  final String title;
  final String body;
  final int remainingSeconds;
  final int totalSeconds;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SparkCharacter(size: 120),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: SparkTheme.sparkAmber,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              ChildFriendlyTimer(
                remainingSeconds: remainingSeconds,
                totalSeconds: totalSeconds,
              ),
              const SizedBox(height: 32),
              GlassButton(
                label: "I'm ready!",
                icon: Icons.rocket_launch,
                color: SparkTheme.sparkAmber,
                onPressed: onReady,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
