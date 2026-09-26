class ProjectDna {
  const ProjectDna({
    required this.projectId,
    required this.version,
    required this.updatedAt,
    this.identity = const <String, Object?>{},
    this.corePillars = const <String, Object?>{},
    this.technicalConstraints = const <String, Object?>{},
    this.keyDecisions = const <Map<String, Object?>>[],
    this.openUncertainties = const <String>[],
    this.knownRisks = const <String>[],
    this.specialistState = const <String, Object?>{},
  });

  final String projectId;
  final int version;
  final DateTime updatedAt;
  final Map<String, Object?> identity;
  final Map<String, Object?> corePillars;
  final Map<String, Object?> technicalConstraints;
  final List<Map<String, Object?>> keyDecisions;
  final List<String> openUncertainties;
  final List<String> knownRisks;
  final Map<String, Object?> specialistState;

  ProjectDna copyWith({
    int? version,
    DateTime? updatedAt,
    Map<String, Object?>? identity,
    Map<String, Object?>? corePillars,
    Map<String, Object?>? technicalConstraints,
    List<Map<String, Object?>>? keyDecisions,
    List<String>? openUncertainties,
    List<String>? knownRisks,
    Map<String, Object?>? specialistState,
  }) {
    return ProjectDna(
      projectId: projectId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
      identity: identity ?? this.identity,
      corePillars: corePillars ?? this.corePillars,
      technicalConstraints: technicalConstraints ?? this.technicalConstraints,
      keyDecisions: keyDecisions ?? this.keyDecisions,
      openUncertainties: openUncertainties ?? this.openUncertainties,
      knownRisks: knownRisks ?? this.knownRisks,
      specialistState: specialistState ?? this.specialistState,
    );
  }

  Map<String, Object?> toJson() => {
        'project_id': projectId,
        'version': version,
        'last_updated': updatedAt.toIso8601String(),
        'identity': identity,
        'core_pillars': corePillars,
        'technical_constraints': technicalConstraints,
        'key_decisions': keyDecisions,
        'open_uncertainties': openUncertainties,
        'known_risks': knownRisks,
        'specialist_state': specialistState,
      };
}
