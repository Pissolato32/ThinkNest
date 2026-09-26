enum ExportProfile { generic, cursor, claudeCode, codex, openHands, markdown }

class ImplementationPackFile {
  const ImplementationPackFile({
    required this.path,
    required this.content,
    required this.sha256,
  });

  final String path;
  final String content;
  final String sha256;
}

class ImplementationPack {
  const ImplementationPack({
    required this.exportId,
    required this.version,
    required this.projectId,
    required this.profile,
    required this.createdAt,
    required this.files,
    required this.manifest,
    required this.zipBytes,
  });

  final String exportId;
  final int version;
  final String projectId;
  final ExportProfile profile;
  final DateTime createdAt;
  final List<ImplementationPackFile> files;
  final String manifest;
  final List<int> zipBytes;
}
