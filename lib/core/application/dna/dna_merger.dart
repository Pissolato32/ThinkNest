import '../../domain/project/dna/dna_inference.dart';
import '../../domain/project/project_dna.dart';

class DnaMergeResult {
  const DnaMergeResult({
    required this.dna,
    required this.changed,
  });

  final ProjectDna dna;
  final bool changed;
}

class DnaMerger {
  const DnaMerger();

  DnaMergeResult merge(
    ProjectDna current,
    Iterable<DnaInference> inferences, {
    required DateTime updatedAt,
  }) {
    final identity = Map<String, Object?>.from(current.identity);
    final corePillars = Map<String, Object?>.from(current.corePillars);
    final technicalConstraints =
        Map<String, Object?>.from(current.technicalConstraints);
    final decisions = current.keyDecisions
        .map((item) => Map<String, Object?>.from(item))
        .toList();
    final uncertainties = List<String>.from(current.openUncertainties);
    final risks = List<String>.from(current.knownRisks);
    var changed = false;

    for (final inference in inferences) {
      switch (inference.type) {
        case DnaInferenceType.identity:
          changed |= _put(identity, inference.key, inference.value);
        case DnaInferenceType.corePillar:
          changed |= _put(corePillars, inference.key, inference.value);
        case DnaInferenceType.technicalConstraint:
          changed |= _put(technicalConstraints, inference.key, inference.value);
        case DnaInferenceType.decision:
          changed |= _mergeDecision(decisions, inference);
        case DnaInferenceType.uncertainty:
          changed |= _addUniqueString(uncertainties, inference.value);
        case DnaInferenceType.risk:
          changed |= _addUniqueString(risks, inference.value);
      }
    }

    if (!changed) return DnaMergeResult(dna: current, changed: false);

    return DnaMergeResult(
      dna: current.copyWith(
        version: current.version + 1,
        updatedAt: updatedAt,
        identity: identity,
        corePillars: corePillars,
        technicalConstraints: technicalConstraints,
        keyDecisions: decisions,
        openUncertainties: uncertainties,
        knownRisks: risks,
      ),
      changed: true,
    );
  }

  bool _put(Map<String, Object?> target, String key, Object? value) {
    if (key.trim().isEmpty || target[key] == value) return false;
    target[key] = value;
    return true;
  }

  bool _mergeDecision(
    List<Map<String, Object?>> decisions,
    DnaInference inference,
  ) {
    final index = decisions.indexWhere(
      (item) => item['topic'] == inference.key,
    );
    final value = <String, Object?>{
      'id': 'decision_${inference.key}',
      'topic': inference.key,
      'decision': inference.value,
      'rationale': inference.rationale,
    };
    if (index == -1) {
      decisions.add(value);
      return true;
    }
    if (decisions[index].toString() == value.toString()) return false;
    decisions[index] = value;
    return true;
  }

  bool _addUniqueString(List<String> target, Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || target.contains(text)) return false;
    target.add(text);
    return true;
  }
}
