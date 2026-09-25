enum ProjectMaturity {
  captured,
  exploring,
  structured,
  validated,
  implementationReady,
}

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.maturity = ProjectMaturity.captured,
    this.isPinned = false,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final String? category;
  final ProjectMaturity maturity;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project copyWith({
    String? title,
    String? category,
    ProjectMaturity? maturity,
    bool? isPinned,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      maturity: maturity ?? this.maturity,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }
}
