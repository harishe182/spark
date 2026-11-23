import '../core/enums.dart';

/// Pure allocation policy for participants — extracted from
/// [ParticipantService] so the research-critical ID and condition rules can be
/// unit-tested without a database.
class ParticipantAllocation {
  ParticipantAllocation._();

  /// Next sequential id ("P001", "P002", …) given the existing ids. Ignores
  /// any non-conforming ids and continues from the max numeric suffix.
  static String nextParticipantId(Iterable<String> existingIds) {
    var maxN = 0;
    for (final id in existingIds) {
      final match = RegExp(r'^P(\d+)$').firstMatch(id);
      if (match != null) {
        final n = int.parse(match.group(1)!);
        if (n > maxN) maxN = n;
      }
    }
    return 'P${(maxN + 1).toString().padLeft(3, '0')}';
  }

  /// Balanced condition assignment: the arm with fewer existing participants,
  /// ties breaking to AI-Spark. Approximates random-but-balanced allocation.
  static StudyCondition balancedCondition(
      Iterable<StudyCondition> existing) {
    final list = existing.toList();
    final ai =
        list.where((c) => c == StudyCondition.aiSpark).length;
    final stat = list.length - ai;
    return ai <= stat ? StudyCondition.aiSpark : StudyCondition.staticSpark;
  }
}
