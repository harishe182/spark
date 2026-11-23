import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums.dart';
import '../core/navigation.dart';
import '../core/theme.dart';
import '../models/participant.dart';
import '../providers/providers.dart';
import '../widgets/glass/glass.dart';
import 'assent_screen.dart';
import 'independent_test_screen.dart';
import 'weekly_session_screen.dart';

/// Facilitator chooses which session to run for a participant: pre-test, one
/// of the 10 weekly sessions, or post-test. Phase 1 wires up pre-test and
/// post-test (independent drawing). Weekly sessions arrive in Phase 2.
class SessionSelectScreen extends ConsumerWidget {
  const SessionSelectScreen({super.key, required this.participant});

  final Participant participant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAi = participant.assignedCondition == StudyCondition.aiSpark;
    final conditionLabel = isAi ? 'AI-Spark' : 'Static-Spark';
    final conditionColor = isAi ? SparkTheme.leafGreen : SparkTheme.coral;

    return GlassPage(
      title: 'Sessions — ${participant.participantId}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 24),
        children: [
          GlassGroupedSection(
            header: 'Info',
            tintColor: conditionColor.withValues(alpha: 0.22),
            children: [
              GlassListRow(
                title: 'Condition: $conditionLabel',
                subtitle: 'Age group ${participant.ageGroup.value}',
                emphasized: true,
                leading: GlassAccentIcon(
                  icon: CupertinoIcons.info,
                  color: conditionColor,
                ),
                trailing: Text(
                  conditionLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: conditionColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassGroupedSection(
            header: 'Settings',
            light: true,
            children: [
              GlassToggleRow(
                title: 'Pilot mode (fast timings)',
                subtitle: 'For testing only — compresses durations',
                value: ref.watch(pilotModeProvider),
                onChanged: (v) => ref.read(pilotModeProvider.notifier).set(v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassGroupedSection(
            header: 'Tests',
            light: true,
            children: [
              GlassListRow(
                title: 'Pre-Test',
                subtitle: 'Independent warm-up • no hints',
                emphasized: true,
                leading: const GlassAccentIcon(
                  icon: CupertinoIcons.flag_fill,
                  color: SparkTheme.skyBlue,
                ),
                showChevron: true,
                onTap: () => _openIndependentTest(
                  context,
                  ref,
                  participant,
                  SessionMode.preTest,
                ),
              ),
              GlassListRow(
                title: 'Post-Test',
                subtitle: 'Independent final • no hints',
                emphasized: true,
                leading: const GlassAccentIcon(
                  icon: CupertinoIcons.star_fill,
                  color: SparkTheme.leafGreen,
                ),
                showChevron: true,
                onTap: () => _openIndependentTest(
                  context,
                  ref,
                  participant,
                  SessionMode.postTest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassGroupedSection(
            header: 'Weekly Sessions',
            light: true,
            children: [
              for (var week = 1; week <= 10; week++)
                GlassListRow(
                  title: 'Week $week',
                  subtitle: 'Weekly creativity session',
                  emphasized: true,
                  leading: const GlassAccentIcon(
                    icon: CupertinoIcons.calendar,
                    color: SparkTheme.sparkAmber,
                  ),
                  showChevron: true,
                  onTap: () => _openWeeklySession(context, participant, week),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openIndependentTest(
    BuildContext context,
    WidgetRef ref,
    Participant participant,
    SessionMode mode,
  ) {
    _openWithAssent(
      context,
      (_) => IndependentTestScreen(participant: participant, mode: mode),
    );
  }

  void _openWeeklySession(
    BuildContext context,
    Participant participant,
    int week,
  ) {
    _openWithAssent(
      context,
      (_) => WeeklySessionScreen(participant: participant, weekNumber: week),
    );
  }

  void _openWithAssent(
    BuildContext context,
    WidgetBuilder sessionBuilder,
  ) {
    pushSparkPage(
      context,
      Builder(
        builder: (assentContext) => AssentScreen(
          onReady: () => pushSparkReplacement<void, void>(
            assentContext,
            sessionBuilder(assentContext),
          ),
        ),
      ),
    );
  }
}
