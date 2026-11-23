import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums.dart';
import '../core/prompts.dart';
import '../core/theme.dart';
import '../models/participant.dart';
import '../models/session.dart';
import '../providers/providers.dart';
import '../widgets/drawing_canvas_widget.dart';
import '../widgets/glass/glass.dart';

/// Pre-test / post-test screen: an independent creativity drawing task with
/// NO Spark, NO hints (study requirement). The child sees a prompt and draws;
/// on save the drawing is exported to PNG and the session is completed.
class IndependentTestScreen extends ConsumerStatefulWidget {
  const IndependentTestScreen({
    super.key,
    required this.participant,
    required this.mode,
  }) : assert(
          mode == SessionMode.preTest || mode == SessionMode.postTest,
          'IndependentTestScreen is only for pre/post tests',
        );

  final Participant participant;
  final SessionMode mode;

  @override
  ConsumerState<IndependentTestScreen> createState() =>
      _IndependentTestScreenState();
}

class _IndependentTestScreenState extends ConsumerState<IndependentTestScreen> {
  final DrawingController _controller = DrawingController();
  late final Prompt _prompt = PromptBank.forSession(widget.mode);

  Session? _session;
  bool _starting = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    final session = await ref.read(sessionServiceProvider).startSession(
          participantId: widget.participant.participantId,
          mode: widget.mode,
          promptId: _prompt.id,
        );
    if (mounted) {
      setState(() {
        _session = session;
        _starting = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final session = _session;
    if (session == null || _saving) return;
    setState(() => _saving = true);

    try {
      final data = await _controller.getImageData();
      if (data == null) {
        throw StateError('Canvas produced no image data');
      }
      final pngBytes = data.buffer.asUint8List();
      final artifactType = widget.mode == SessionMode.preTest
          ? ArtifactType.preTest
          : ArtifactType.postTest;

      await ref.read(drawingServiceProvider).saveArtifact(
            sessionId: session.sessionId,
            type: artifactType,
            pngBytes: Uint8List.fromList(pngBytes),
          );
      await ref.read(sessionServiceProvider).completeSession(session);
      await ref.read(syncServiceProvider).enqueue(session.sessionId);

      if (mounted) _showSavedAndExit();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save drawing: $e')),
        );
      }
    }
  }

  void _showSavedAndExit() {
    showGlassDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GlassAlertDialog(
        title: const Text('Saved!'),
        content: const Text('Great work — your drawing has been saved.'),
        actions: [
          GlassButton(
            label: 'Done',
            color: SparkTheme.leafGreen,
            minimumSize: const Size(100, 48),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPre = widget.mode == SessionMode.preTest;
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(isPre ? 'Warm-Up Challenge' : 'Final Challenge'),
        actions: [
          if (!_starting)
            GlassBarButton(
              label: 'Save',
              icon: Icons.check,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
        ],
      ),
      safeArea: false,
      body: SafeArea(
        child: _starting
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _PromptBanner(prompt: _prompt),
                    const SizedBox(height: 12),
                    Expanded(
                      child: DrawingCanvasWidget(controller: _controller),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PromptBanner extends StatelessWidget {
  const _PromptBanner({required this.prompt});

  final Prompt prompt;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: SparkTheme.skyBlue.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(16),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(prompt.body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
