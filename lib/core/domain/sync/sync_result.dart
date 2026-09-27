class SyncResult {
  const SyncResult({
    required this.pushed,
    required this.pulled,
    required this.failed,
  });

  final int pushed;
  final int pulled;
  final int failed;
}
