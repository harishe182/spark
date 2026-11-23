import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../services/spark_session.dart';
import 'glass/glass.dart';
import 'spark_character.dart';

/// Displays a single Spark suggestion with Accept / Reject. Visually identical
/// for both study conditions (AI vs static) — the child must never be able to
/// tell which arm they are in. No "AI" wording appears anywhere here.
class SparkSuggestionCard extends StatelessWidget {
  const SparkSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onAccept,
    required this.onReject,
  });

  final SparkSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SparkCharacter(size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ChildCopy.sparkHasIdea,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SparkTheme.sparkAmber,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(ChildCopy.wantToAdd,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GlassButton(
                label: ChildCopy.reject,
                icon: Icons.close,
                color: Colors.grey.shade500,
                onPressed: onReject,
              ),
              GlassButton(
                label: ChildCopy.accept,
                icon: Icons.check,
                color: SparkTheme.leafGreen,
                onPressed: onAccept,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
