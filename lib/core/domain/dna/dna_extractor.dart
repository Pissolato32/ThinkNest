import 'dna_inference.dart';

abstract interface class DnaExtractor {
  List<DnaInference> extract(String text);
}
