import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/research_guide.dart';
import '../core/theme.dart';
import 'glass/glass.dart';

/// Opens a scrollable research guide for facilitators.
Future<void> showResearchInfoSheet(BuildContext context) {
  return showGlassSheet<void>(
    context: context,
    builder: (_) => const FractionallySizedBox(
      heightFactor: 0.92,
      child: ResearchInfoSheet(),
    ),
  );
}

class ResearchInfoSheet extends StatelessWidget {
  const ResearchInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassSheetPanel(
      fillHeight: true,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ResearchGuide.title,
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .navLargeTitleTextStyle
                            .copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ResearchGuide.subtitle,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 28,
                    color: SparkTheme.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                for (final section in ResearchGuide.sections) ...[
                  _SectionBlock(section: section),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final ResearchGuideSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: SparkTheme.sparkAmber,
              ),
        ),
        const SizedBox(height: 8),
        if (section.body != null)
          Text(
            section.body!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
          ),
        if (section.bullets.isNotEmpty) ...[
          if (section.body != null) const SizedBox(height: 8),
          for (final bullet in section.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: SparkTheme.secondaryLabel,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bullet,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
