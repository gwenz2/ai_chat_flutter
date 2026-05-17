import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class DeepseekService {
  static String get _apiKey => ApiConfig.deepseekApiKey;
  static String get _apiUrl => ApiConfig.deepseekApiUrl;

  static Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> chatHistory, {
    String memoriesContext = '',
  }) async {
    try {
      // Build messages list with history
      List<Map<String, dynamic>> messages = [];

      // Add system message with memories if available
      String systemMessage =
          'You are a helpful AI assistant. Be concise and friendly.';
      if (memoriesContext.isNotEmpty) {
        systemMessage += '\n\n$memoriesContext';
      }

      messages.add({'role': 'system', 'content': systemMessage});

      // Add previous messages for context
      for (var msg in chatHistory) {
        messages.add({
          'role': msg['isUser'] == 'true' ? 'user' : 'assistant',
          'content': msg['content']!,
        });
      }

      // Add current user message
      messages.add({'role': 'user', 'content': userMessage});

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'deepseek-chat',
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 500,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('API request timeout'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final aiResponse = jsonResponse['choices'][0]['message']['content'];
        return aiResponse;
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }
}
