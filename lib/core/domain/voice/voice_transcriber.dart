abstract interface class VoiceTranscriber {
  bool get isListening;

  Future<bool> initialize();

  Future<void> start({
    required void Function(String text) onText,
    required void Function(String message) onError,
    String localeId = 'pt_BR',
  });

  Future<void> stop();
}
