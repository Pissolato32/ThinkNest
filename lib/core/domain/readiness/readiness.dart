enum ReadinessStatus {
  notReady,
  readyWithWarnings,
  ready,
  blocked,
}

enum ReadinessFindingSeverity {
  blocker,
  warning,
}

class ReadinessDimension {
  const ReadinessDimension({
    required this.key,
    required this.label,
    required this.satisfied,
    this.detail,
  });

  final String key;
  final String label;
  final bool satisfied;
  final String? detail;
}

class ReadinessFinding {
  const ReadinessFinding({
    required this.code,
    required this.severity,
    required this.message,
    required this.recommendation,
  });

  final String code;
  final ReadinessFindingSeverity severity;
  final String message;
  final String recommendation;
}

class ReadinessReport {
  const ReadinessReport({
    required this.status,
    required this.dimensions,
    required this.blockers,
    required this.warnings,
    required this.recommendations,
  });

  final ReadinessStatus status;
  final List<ReadinessDimension> dimensions;
  final List<ReadinessFinding> blockers;
  final List<ReadinessFinding> warnings;
  final List<String> recommendations;

  bool get isReady =>
      status == ReadinessStatus.ready ||
      status == ReadinessStatus.readyWithWarnings;
}
