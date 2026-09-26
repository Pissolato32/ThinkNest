import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/core/application/dna/rule_based_dna_extractor.dart';
import 'package:thinknest/core/domain/dna/dna_inference.dart';

void main() {
  test('extracts explicitly marked user facts', () {
    const extractor = RuleBasedDnaExtractor();
    final result = extractor.extract(
      'Objetivo: reduzir retrabalho. Restrição: offline-first. '
      'Decisão: Flutter. Risco: custo de IA.',
    );

    expect(result, hasLength(4));
    expect(result.map((item) => item.type), [
      DnaInferenceType.corePillar,
      DnaInferenceType.technicalConstraint,
      DnaInferenceType.decision,
      DnaInferenceType.risk,
    ]);
    expect(result.first.value, 'reduzir retrabalho.');
    expect(result.every((item) => item.confidence > 0.95), isTrue);
  });

  test('ignores text without explicit DNA markers', () {
    const extractor = RuleBasedDnaExtractor();
    expect(extractor.extract('Quero conversar sobre a ideia.'), isEmpty);
  });
}
