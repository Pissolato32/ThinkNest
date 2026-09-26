import '../../domain/ai/ai_provider.dart';

class EchoProvider implements AiProvider {
  const EchoProvider();

  @override
  String get id => 'echo';

  @override
  Future<AiResponse> complete(AiRequest request) async => AiResponse(
        content:
            'Recebi sua mensagem. Vamos estruturá-la no contexto deste projeto.',
        providerId: id,
        model: 'local-test',
      );

  @override
  Stream<String> stream(AiRequest request) async* {
    yield* Stream.fromIterable([
      'Recebi sua mensagem. ',
      'Vamos estruturá-la no contexto deste projeto.',
    ]);
  }
}
