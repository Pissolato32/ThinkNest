import '../../domain/document/document.dart';

class DocumentLifecycle {
  DocumentLifecycle._();

  static bool canTransition(DocumentStatus from, DocumentStatus to) {
    return switch (from) {
      DocumentStatus.draft => to == DocumentStatus.generated,
      DocumentStatus.generated => to == DocumentStatus.userReviewed,
      DocumentStatus.userReviewed => to == DocumentStatus.approved,
      DocumentStatus.approved => to == DocumentStatus.archived,
      DocumentStatus.archived => false,
    };
  }

  static void validate(DocumentStatus from, DocumentStatus to) {
    if (!canTransition(from, to)) {
      throw StateError(
        'Transição de documento inválida: ${from.name} → ${to.name}.',
      );
    }
  }
}
