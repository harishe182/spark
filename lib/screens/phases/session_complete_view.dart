import 'package:flutter/material.dart';

import '../../controllers/weekly_session_controller.dart';
import '../../core/theme.dart';
import '../../widgets/glass/glass.dart';
import '../../widgets/spark_character.dart';

/// Shown after the child finishes. The child sees a celebration; the
/// facilitator can record an engagement rating and notes, then exits. Notes
/// are optional — saving is allowed with them blank.
class SessionCompleteView extends StatefulWidget {
  const SessionCompleteView({super.key, required this.controller});

  final WeeklySessionController controller;

  @override
  State<SessionCompleteView> createState() => _SessionCompleteViewState();
}

class _SessionCompleteViewState extends State<SessionCompleteView> {
  final TextEditingController _notes = TextEditingController();
  int? _engagement;
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _saveAndExit() async {
    setState(() => _saving = true);
    await widget.controller.saveFacilitatorNote(
      engagement: _engagement,
      notes: _notes.text,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const SparkCharacter(size: 120),
          const SizedBox(height: 16),
          Text('Great work!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SparkTheme.sparkAmber,
                  )),
          const SizedBox(height: 8),
          const Text('Your drawing and ideas are saved.'),
          const SizedBox(height: 32),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Facilitator notes (optional)',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Engagement:'),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      ChoiceChip(
                        label: Text('$i'),
                        selected: _engagement == i,
                        onSelected: (_) => setState(() => _engagement = i),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassTextField(
            controller: _notes,
            hintText: 'Observations…',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          GlassButton(
            label: 'Save & finish',
            icon: Icons.save,
            color: SparkTheme.leafGreen,
            onPressed: _saving ? null : _saveAndExit,
          ),
        ],
      ),
    );
  }
}
