import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/ai/ai_provider.dart';

class OpenAiCompatibleProvider implements AiProvider {
  OpenAiCompatibleProvider({
    required this.baseUrl,
    required this.apiKey,
    this.providerId = 'openai-compatible',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final String providerId;
  final http.Client _client;

  @override
  String get id => providerId;

  @override
  Future<AiResponse> complete(AiRequest request) async {
    final response = await _client.post(
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(_body(request, stream: false)),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('AI provider returned HTTP ${response.statusCode}.');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>? ?? const [];
    final first = choices.isEmpty ? null : choices.first as Map<String, dynamic>;
    final message = first?['message'] as Map<String, dynamic>?;
    final usage = json['usage'] as Map<String, dynamic>?;
    return AiResponse(
      content: message?['content'] as String? ?? '',
      providerId: id,
      model: json['model'] as String?,
      inputTokens: usage?['prompt_tokens'] as int?,
      outputTokens: usage?['completion_tokens'] as int?,
    );
  }

  @override
  Stream<String> stream(AiRequest request) async* {
    final response = await _client.send(
      http.Request(
        'POST',
        Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}/chat/completions'),
      )
        ..headers.addAll({
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode(_body(request, stream: true)),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('AI provider returned HTTP ${response.statusCode}.');
    }
    await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload == '[DONE]') break;
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>? ?? const [];
      if (choices.isEmpty) continue;
      final delta = (choices.first as Map<String, dynamic>)['delta'] as Map<String, dynamic>?;
      final content = delta?['content'] as String?;
      if (content != null && content.isNotEmpty) yield content;
    }
  }

  Map<String, dynamic> _body(AiRequest request, {required bool stream}) => {
        'model': request.model ?? 'default',
        'temperature': request.temperature,
        'stream': stream,
        'messages': [
          {
            'role': 'system',
            'content': _systemPrompt(request),
          },
          ...request.messages.map((message) => {
                'role': message.role.name,
                'content': message.content,
              }),
        ],
      };

  String _systemPrompt(AiRequest request) =>
      'Você é o assistente do projeto ThinkNest. Use o Project DNA como contexto canônico. '
      'Não altere o DNA diretamente; apresente fatos, decisões e sugestões para aprovação humana. '
      'Project DNA: ${jsonEncode(request.dna.toJson())}';
}
