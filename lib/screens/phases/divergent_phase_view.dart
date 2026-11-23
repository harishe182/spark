import 'package:flutter/material.dart';

import '../../controllers/weekly_session_controller.dart';
import '../../core/constants.dart';
import '../../core/enums.dart';
import '../../core/theme.dart';
import '../../models/idea.dart';
import '../../widgets/glass/glass.dart';

/// Divergent phase: the child brainstorms ideas into a growing list. Accepted
/// Spark suggestions also land here (shown with a small Spark marker). The
/// child types ideas using a simple add field.
class DivergentPhaseView extends StatefulWidget {
  const DivergentPhaseView({
    super.key,
    required this.controller,
    required this.prompt,
  });

  final WeeklySessionController controller;
  final String prompt;

  @override
  State<DivergentPhaseView> createState() => _DivergentPhaseViewState();
}

class _DivergentPhaseViewState extends State<DivergentPhaseView> {
  final TextEditingController _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    await widget.controller.addChildIdea(text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ideas = widget.controller.ideas;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.prompt,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(ChildCopy.yourIdeas,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _input,
                  hintText: ChildCopy.addIdea,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              GlassButton(
                label: '',
                icon: Icons.add,
                color: SparkTheme.sparkAmber,
                minimumSize: const Size(64, 56),
                onPressed: _submit,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ideas.isEmpty
                ? Center(
                    child: Text('Type your first idea above!',
                        style: Theme.of(context).textTheme.bodyLarge),
                  )
                : ListView.separated(
                    itemCount: ideas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _IdeaTile(idea: ideas[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _IdeaTile extends StatelessWidget {
  const _IdeaTile({required this.idea});

  final Idea idea;

  @override
  Widget build(BuildContext context) {
    final fromSpark = idea.source != IdeaSource.child;
    return GlassCard(
      light: true,
      color: fromSpark
          ? SparkTheme.cream.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.55),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          fromSpark ? Icons.auto_awesome : Icons.lightbulb_outline,
          color: fromSpark ? SparkTheme.sparkAmber : SparkTheme.skyBlue,
        ),
        title: Text(idea.ideaText, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
