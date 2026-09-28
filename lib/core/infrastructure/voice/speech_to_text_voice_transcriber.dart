import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/voice/voice_transcriber.dart';

class SpeechToTextVoiceTranscriber implements VoiceTranscriber {
  SpeechToTextVoiceTranscriber({SpeechToText? speech})
      : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize() {
    return _speech.initialize(
      onError: _onError,
    );
  }

  @override
  Future<void> start({
    required void Function(String text) onText,
    required void Function(String message) onError,
    String localeId = 'pt_BR',
  }) async {
    _externalError = onError;
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onText(result.recognizedWords);
      },
      listenOptions: const SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        autoPunctuation: true,
      ),
      localeId: localeId,
    );
  }

  @override
  Future<void> stop() async {
    await _speech.stop();
  }

  void Function(String message)? _externalError;

  void _onError(SpeechRecognitionError error) {
    _externalError?.call(error.errorMsg);
  }
}
