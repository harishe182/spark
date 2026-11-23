import 'package:flutter/material.dart';

import '../../controllers/weekly_session_controller.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../widgets/glass/glass.dart';
import '../../widgets/reflection_rating_scale.dart';
import '../../widgets/spark_character.dart';

/// Reflection phase: the three 1–5 questions. Identical wording for both
/// conditions so the responses are comparable. Saving advances the session to
/// completion (facilitator notes follow).
class ReflectionPhaseView extends StatefulWidget {
  const ReflectionPhaseView({super.key, required this.controller});

  final WeeklySessionController controller;

  @override
  State<ReflectionPhaseView> createState() => _ReflectionPhaseViewState();
}

class _ReflectionPhaseViewState extends State<ReflectionPhaseView> {
  int? _ownership;
  int? _creativity;
  int? _helpfulness;
  bool _saving = false;

  int get _answered =>
      [_ownership, _creativity, _helpfulness].where((v) => v != null).length;

  bool get _complete => _answered == 3;

  Future<void> _finish() async {
    if (!_complete || _saving) return;
    setState(() => _saving = true);
    await widget.controller.saveReflection(
      ownership: _ownership!,
      creativity: _creativity!,
      helpfulness: _helpfulness!,
    );
    await widget.controller.advancePhase(manual: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      const SparkCharacter(size: 84),
                      const SizedBox(height: 12),
                      Text(
                        'A few quick questions!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: SparkTheme.sparkAmber,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap a face for each one.',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ReflectionRatingScale(
                        index: 1,
                        question: ReflectionQuestions.ownership,
                        value: _ownership,
                        onChanged: (v) => setState(() => _ownership = v),
                      ),
                      const SizedBox(height: 16),
                      ReflectionRatingScale(
                        index: 2,
                        question: ReflectionQuestions.creativity,
                        value: _creativity,
                        onChanged: (v) => setState(() => _creativity = v),
                      ),
                      const SizedBox(height: 16),
                      ReflectionRatingScale(
                        index: 3,
                        question: ReflectionQuestions.helpfulness,
                        value: _helpfulness,
                        onChanged: (v) => setState(() => _helpfulness = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _BottomBar(
            answered: _answered,
            saving: _saving,
            onFinish: _complete ? _finish : null,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.answered,
    required this.saving,
    required this.onFinish,
  });

  final int answered;
  final bool saving;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final ready = onFinish != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i <= answered
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i <= answered
                          ? SparkTheme.sparkAmber
                          : Colors.grey.shade300,
                      size: 26,
                    ),
                  ),
                const SizedBox(width: 8),
                Text('$answered of 3',
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: ready ? 'All done!' : 'Answer all 3 to finish',
                icon: Icons.celebration,
                color: ready ? SparkTheme.leafGreen : Colors.grey.shade400,
                minimumSize: const Size.fromHeight(64),
                onPressed: saving ? null : onFinish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
