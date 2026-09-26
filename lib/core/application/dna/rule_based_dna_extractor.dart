import '../../domain/dna/dna_extractor.dart';
import '../../domain/dna/dna_inference.dart';

class RuleBasedDnaExtractor implements DnaExtractor {
  const RuleBasedDnaExtractor();

  @override
  List<DnaInference> extract(String text) {
    final inferences = <DnaInference>[];
    final patterns = <String, DnaInferenceType>{
      'objetivo:': DnaInferenceType.corePillar,
      'público:': DnaInferenceType.corePillar,
      'restrição:': DnaInferenceType.technicalConstraint,
      'decisão:': DnaInferenceType.decision,
      'incerteza:': DnaInferenceType.uncertainty,
      'risco:': DnaInferenceType.risk,
    };

    for (final entry in patterns.entries) {
      final index = text.toLowerCase().indexOf(entry.key);
      if (index == -1) continue;
      final value = text.substring(index + entry.key.length).trim();
      if (value.isEmpty) continue;

      inferences.add(
        DnaInference(
          type: entry.value,
          key: entry.key.substring(0, entry.key.length - 1),
          value: value,
          confidence: 0.99,
          rationale: 'Fato explicitamente marcado pelo usuário.',
        ),
      );
    }
    return inferences;
  }
}
