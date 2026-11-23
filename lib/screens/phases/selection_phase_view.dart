import 'package:flutter/material.dart';

import '../../controllers/weekly_session_controller.dart';
import '../../core/theme.dart';
import '../../widgets/glass/glass.dart';

/// Selection phase: the child taps the idea(s) they want to develop into a
/// final drawing. Multiple selections are allowed. Each chosen idea is flagged
/// [selectedForFinal] so analysis can trace which sources (child vs Spark)
/// became the final idea(s).
class SelectionPhaseView extends StatelessWidget {
  const SelectionPhaseView({super.key, required this.controller});

  final WeeklySessionController controller;

  @override
  Widget build(BuildContext context) {
    final ideas = controller.ideas;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pick your favorite ideas!',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Choose one or more to draw.'),
          const SizedBox(height: 12),
          Expanded(
            child: ideas.isEmpty
                ? const Center(child: Text('No ideas to choose from.'))
                : ListView.separated(
                    itemCount: ideas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final idea = ideas[i];
                      final selected =
                          controller.selectedIdeaIds.contains(idea.ideaId);
                      return GlassCard(
                        light: true,
                        color: selected
                            ? SparkTheme.leafGreen.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.55),
                        borderColor: selected
                            ? SparkTheme.leafGreen.withValues(alpha: 0.6)
                            : null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        onTap: () => controller.toggleSelected(idea.ideaId),
                        child: ListTile(
                          leading: Icon(
                            selected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: selected
                                ? SparkTheme.leafGreen
                                : Colors.grey,
                            size: 32,
                          ),
                          title: Text(idea.ideaText,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
