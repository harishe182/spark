import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/sync_record.dart';
import '../providers/providers.dart';
import '../services/export_service.dart';
import '../services/sync_service.dart';
import '../widgets/glass/glass.dart';

/// Facilitator/researcher export screen. Offers a full export (all data +
/// images) and a blind rater export (images only, no condition/identity).
/// Shows the resulting folder path, file count, and integrity checksum.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _busy = false;
  ExportResult? _lastResult;
  String? _error;

  Future<void> _run(Future<ExportResult> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await action();
      setState(() => _lastResult = result);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(exportServiceProvider);
    return GlassPage(
      title: 'Export Data',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          const _CloudSyncSection(),
          const SizedBox(height: 8),
          GlassGroupedSection(
            header: 'Export',
            footer:
                'Export research data locally. Files are written to the app '
                'documents folder and can be synced or transferred securely.',
            children: [
              GlassListRow(
                title: 'Full export',
                subtitle: 'All sessions, ideas, events, reflections, and images',
                showChevron: true,
                enabled: !_busy,
                onTap: _busy ? null : () => _run(service.exportFull),
              ),
              GlassListRow(
                title: 'Blind rater export',
                subtitle: 'Images only, opaque codes, separate key file',
                showChevron: true,
                enabled: !_busy,
                onTap: _busy ? null : () => _run(service.exportBlind),
              ),
            ],
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            GlassGroupedSection(
              children: [
                GlassListRow(
                  title: 'Export failed',
                  subtitle: _error,
                ),
              ],
            ),
          ],
          if (_lastResult != null && !_busy) ...[
            const SizedBox(height: 8),
            _ResultSection(result: _lastResult!),
          ],
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.result});

  final ExportResult result;

  @override
  Widget build(BuildContext context) {
    return GlassGroupedSection(
      header: 'Result',
      children: [
        GlassListRow(
          title: result.blind ? 'Blind export ready' : 'Export ready',
          leading: const Icon(
            CupertinoIcons.checkmark_circle,
            color: SparkTheme.leafGreen,
          ),
        ),
        GlassListRow(title: 'Files', trailing: Text('${result.fileCount}')),
        GlassListRow(
          title: 'Folder',
          subtitle: result.directoryPath,
        ),
        GlassListRow(
          title: 'Checksum',
          subtitle: result.checksum,
        ),
      ],
    );
  }
}

class _CloudSyncSection extends ConsumerStatefulWidget {
  const _CloudSyncSection();

  @override
  ConsumerState<_CloudSyncSection> createState() => _CloudSyncSectionState();
}

class _CloudSyncSectionState extends ConsumerState<_CloudSyncSection> {
  bool _syncing = false;
  Map<SyncStatus, int> _counts = const {};
  String? _message;

  @override
  void initState() {
    super.initState();
    _refreshCounts();
  }

  Future<void> _refreshCounts() async {
    final counts = await ref.read(syncServiceProvider).statusCounts();
    if (mounted) setState(() => _counts = counts);
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    final outcome = await ref.read(syncServiceProvider).syncPending();
    await _refreshCounts();
    if (mounted) {
      setState(() {
        _syncing = false;
        _message = _describe(outcome);
      });
    }
  }

  String _describe(SyncOutcome o) {
    if (o.reason != null) return o.reason!;
    return 'Synced ${o.synced}, failed ${o.failed}.';
  }

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(firebaseAvailableProvider);
    final enabled = ref.watch(syncEnabledProvider);
    final pending = _counts[SyncStatus.pending] ?? 0;
    final synced = _counts[SyncStatus.synced] ?? 0;
    final failed = _counts[SyncStatus.failed] ?? 0;

    final statusFooter = available
        ? 'Queued: $pending   ·   Synced: $synced   ·   Failed: $failed'
        : 'Not configured yet — sessions are queued locally and will '
            'upload once Firebase is set up.';

    final footer = _message != null ? '$_message\n$statusFooter' : statusFooter;

    return GlassGroupedSection(
      header: 'Cloud backup',
      footer: footer,
      children: [
        GlassToggleRow(
          title: 'Auto-sync over Wi-Fi',
          subtitle: 'Uploads completed sessions automatically',
          value: enabled,
          onChanged: (v) => ref.read(syncEnabledProvider.notifier).set(v),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: GlassBarButton(
              label: 'Sync now',
              icon: CupertinoIcons.arrow_2_circlepath,
              loading: _syncing,
              onPressed: _syncing ? null : _syncNow,
            ),
          ),
        ),
      ],
    );
  }
}
