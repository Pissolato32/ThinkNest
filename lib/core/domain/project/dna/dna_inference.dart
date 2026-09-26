enum DnaInferenceType {
  identity,
  corePillar,
  technicalConstraint,
  decision,
  uncertainty,
  risk,
}

class DnaInference {
  const DnaInference({
    required this.type,
    required this.key,
    required this.value,
    required this.confidence,
    this.rationale = '',
  });

  final DnaInferenceType type;
  final String key;
  final Object? value;
  final double confidence;
  final String rationale;
}

enum DnaConfidenceAction {
  autoApply,
  suggestApproval,
  requestClarification,
}

class DnaConfidenceGate {
  const DnaConfidenceGate();

  DnaConfidenceAction evaluate(double confidence) {
    if (confidence > 0.95) return DnaConfidenceAction.autoApply;
    if (confidence >= 0.80) return DnaConfidenceAction.suggestApproval;
    return DnaConfidenceAction.requestClarification;
  }
}
