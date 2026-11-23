import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import 'glass/glass.dart';

/// A single reflection question shown as a friendly card: the question text
/// plus a row of five progressively happier faces. Each face has its own
/// warm→cool color; the selected one fills in, scales up, and shows a white
/// icon. Big touch targets for small fingers.
class ReflectionRatingScale extends StatelessWidget {
  const ReflectionRatingScale({
    super.key,
    required this.index,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  /// 1-based position of this question (used for the little number badge).
  final int index;
  final String question;
  final int? value;
  final ValueChanged<int> onChanged;

  static const _faces = <IconData>[
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  /// Warm (low) → cool/green (high) so the scale reads at a glance.
  static const _colors = <Color>[
    SparkTheme.coral,
    Color(0xFFFFA726), // orange
    SparkTheme.sparkYellow,
    Color(0xFF9CCC65), // light green
    SparkTheme.leafGreen,
  ];

  @override
  Widget build(BuildContext context) {
    final answered = value != null;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: answered
          ? SparkTheme.leafGreen.withValues(alpha: 0.6)
          : SparkGlassTheme.edgeLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NumberBadge(index: index, done: answered),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = ReflectionQuestions.minRating;
                  i <= ReflectionQuestions.maxRating;
                  i++)
                _FaceButton(
                  icon: _faces[i - 1],
                  color: _colors[i - 1],
                  selected: value == i,
                  onTap: () => onChanged(i),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(ReflectionQuestions.lowLabel,
                  style: TextStyle(color: Colors.black45, fontSize: 13)),
              Text(ReflectionQuestions.highLabel,
                  style: TextStyle(color: Colors.black45, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.index, required this.done});

  final int index;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: done ? SparkTheme.leafGreen : SparkTheme.skyBlue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: done
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : Text('$index',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _FaceButton extends StatelessWidget {
  const _FaceButton({
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: selected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 40,
            color: selected ? Colors.white : color.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}
