import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums.dart';
import '../core/navigation.dart';
import '../core/theme.dart';
import '../models/participant.dart';
import '../providers/providers.dart';
import '../widgets/glass/glass.dart';
import 'export_screen.dart';
import 'session_select_screen.dart';

/// Facilitator screen to create a new participant or pick an existing one.
/// Condition is shown here (facilitator-only) and can be auto-balanced or set
/// explicitly. The child never sees this screen.
class ParticipantSetupScreen extends ConsumerWidget {
  const ParticipantSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantListProvider);

    return GlassPage(
      title: 'Participants',
      actions: [
        GlassNavAction(
          label: 'New',
          icon: CupertinoIcons.add,
          onPressed: () => _showCreateSheet(context, ref),
        ),
        GlassNavIconAction(
          icon: CupertinoIcons.arrow_down_circle,
          tooltip: 'Export data',
          onPressed: () => pushSparkPage(context, const ExportScreen()),
        ),
      ],
      body: participantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (participants) {
          if (participants.isEmpty) {
            return Center(
              child: Text(
                'No participants yet. Tap New to add one.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SparkTheme.secondaryLabel,
                    ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
            children: [
              GlassGroupedSection(
                header: 'Participants',
                children: [
                  for (final p in participants) _ParticipantRow(participant: p),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context, WidgetRef ref) async {
    await showGlassSheet<void>(
      context: context,
      builder: (_) => const _CreateParticipantSheet(),
    );
  }
}

class _ParticipantRow extends ConsumerWidget {
  const _ParticipantRow({required this.participant});

  final Participant participant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAi = participant.assignedCondition == StudyCondition.aiSpark;
    final conditionLabel = isAi ? 'AI-Spark' : 'Static-Spark';

    return GlassListRow(
      title: participant.participantId,
      subtitle: 'Age ${participant.ageGroup.value}',
      trailing: Text(
        conditionLabel,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      showChevron: true,
      onTap: () => pushSparkPage(
        context,
        SessionSelectScreen(participant: participant),
      ),
    );
  }
}

class _CreateParticipantSheet extends ConsumerStatefulWidget {
  const _CreateParticipantSheet();

  @override
  ConsumerState<_CreateParticipantSheet> createState() =>
      _CreateParticipantSheetState();
}

class _CreateParticipantSheetState extends ConsumerState<_CreateParticipantSheet> {
  AgeGroup _ageGroup = AgeGroup.youngerEightToNine;
  StudyCondition? _condition;
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return GlassSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New participant',
            style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
          ),
          const SizedBox(height: 24),
          _SheetField(
            label: 'Age group',
            child: GlassSegmentedControl<AgeGroup>(
              padding: EdgeInsets.zero,
              groupValue: _ageGroup,
              onValueChanged: (v) => setState(() => _ageGroup = v),
              children: const {
                AgeGroup.youngerEightToNine: Text('8–9'),
                AgeGroup.olderTenToEleven: Text('10–11'),
              },
            ),
          ),
          const SizedBox(height: 20),
          _SheetField(
            label: 'Condition',
            footer: _condition == null
                ? 'Auto keeps the two groups balanced.'
                : 'Manually assigned — use only for your randomization.',
            child: GlassSegmentedControl<_ConditionChoice>(
              padding: EdgeInsets.zero,
              groupValue: _choiceFromCondition(),
              onValueChanged: (v) =>
                  setState(() => _condition = _conditionFromChoice(v)),
              children: const {
                _ConditionChoice.auto: Text('Auto'),
                _ConditionChoice.ai: Text('AI'),
                _ConditionChoice.static_: Text('Static'),
              },
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SparkTheme.coral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _error!,
                style: TextStyle(
                  color: SparkTheme.coral,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          GlassSheetPrimaryButton(
            label: _saving ? 'Creating…' : 'Create',
            loading: _saving,
            onPressed: _saving ? null : _create,
          ),
          CupertinoButton(
            padding: const EdgeInsets.only(top: 8),
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: CupertinoTheme.of(context).textTheme.actionTextStyle.copyWith(
                    color: SparkTheme.secondaryLabel,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  _ConditionChoice _choiceFromCondition() {
    return switch (_condition) {
      null => _ConditionChoice.auto,
      StudyCondition.aiSpark => _ConditionChoice.ai,
      StudyCondition.staticSpark => _ConditionChoice.static_,
    };
  }

  StudyCondition? _conditionFromChoice(_ConditionChoice choice) {
    return switch (choice) {
      _ConditionChoice.auto => null,
      _ConditionChoice.ai => StudyCondition.aiSpark,
      _ConditionChoice.static_ => StudyCondition.staticSpark,
    };
  }

  Future<void> _create() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(participantServiceProvider).createParticipant(
            ageGroup: _ageGroup,
            condition: _condition,
          );
      ref.invalidate(participantListProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not create participant: $e';
        });
      }
    }
  }
}

enum _ConditionChoice { auto, ai, static_ }

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.child,
    this.footer,
  });

  final String label;
  final Widget child;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: SparkTheme.sectionHeader,
          ),
        ),
        child,
        if (footer != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(footer!, style: SparkTheme.sectionHeader),
          ),
        ],
      ],
    );
  }
}
