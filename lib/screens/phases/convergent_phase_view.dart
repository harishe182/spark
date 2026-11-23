import 'package:flutter/material.dart';

import '../../controllers/weekly_session_controller.dart';
import '../../core/theme.dart';
import '../../widgets/drawing_canvas_widget.dart';
import '../../widgets/glass/glass.dart';

/// Convergent phase: the child develops their chosen idea into a final
/// drawing. The controller takes periodic snapshots and exports the final
/// image automatically when the phase ends. A small reminder shows the
/// selected idea so the child stays on task.
class ConvergentPhaseView extends StatelessWidget {
  const ConvergentPhaseView({
    super.key,
    required this.controller,
    required this.prompt,
  });

  final WeeklySessionController controller;
  final String prompt;

  @override
  Widget build(BuildContext context) {
    // One or more ideas may have been selected.
    final selectedTexts =
        controller.selectedIdeas.map((i) => i.ideaText).toList();
    final selected =
        selectedTexts.isEmpty ? null : selectedTexts.join(', ');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (selected != null)
            GlassCard(
              color: SparkTheme.leafGreen.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(12),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Text('Drawing: $selected',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: DrawingCanvasWidget(
              controller: controller.drawingController,
            ),
          ),
        ],
      ),
    );
  }
}
