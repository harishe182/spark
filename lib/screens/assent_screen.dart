import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/glass/glass.dart';
import '../widgets/spark_character.dart';

/// Child assent / game intro shown before each session. Friendly, simple, and
/// game-framed — never mentions research, conditions, or AI. The child taps
/// the big button to begin. (Guardian consent is handled outside the app.)
class AssentScreen extends StatelessWidget {
  const AssentScreen({super.key, required this.onReady});

  /// Invoked when the child is ready to start.
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SparkCharacter(size: 140),
                const SizedBox(height: 24),
                Text(
                  'Welcome to the Creativity Challenge!',
                  textAlign: TextAlign.center,
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .navLargeTitleTextStyle
                      .copyWith(color: SparkTheme.sparkAmber),
                ),
                const SizedBox(height: 16),
                Text(
                  'You will think up fun ideas and make a drawing. '
                  'There are no wrong answers — just be creative and have fun!\n\n'
                  'You can play, or you can stop any time. '
                  'Ready to start?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                GlassButton(
                  label: "Let's play!",
                  icon: Icons.play_arrow,
                  color: SparkTheme.leafGreen,
                  minimumSize: const Size(220, 72),
                  onPressed: onReady,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
