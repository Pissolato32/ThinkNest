import '../../domain/dna/dna_extractor.dart';
import 'apply_dna_proposal.dart';

class ProcessDnaTurn {
  ProcessDnaTurn(this._extractor, this._applyProposal);

  final DnaExtractor _extractor;
  final ApplyDnaProposal _applyProposal;

  Future<DnaProcessingResult> call({
    required String projectId,
    required String text,
    bool approveSuggestions = false,
  }) {
    final inferences = _extractor.extract(text);
    return _applyProposal(
      projectId: projectId,
      inferences: inferences,
      approveSuggestions: approveSuggestions,
    );
  }
}
