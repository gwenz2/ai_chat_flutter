import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class MemoryExtractionService {
  static String get _apiKey => ApiConfig.deepseekApiKey;
  static String get _apiUrl => ApiConfig.deepseekApiUrl;

  /// Extract structured facts from a conversation
  static Future<List<Map<String, String>>> extractMemories(
    String userMessage,
    String aiResponse,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'deepseek-chat',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '''You are a memory extraction assistant. Extract factual information about the USER from this conversation. 
Return a JSON array of objects with "fact" and "category" keys. Categories: Personal, Skills, Preferences, Work, Hobbies, Goals.
Only extract NEW information we didn't already know. Be concise.
Example: [{"fact": "User likes Python", "category": "Skills"}, {"fact": "Works as a developer", "category": "Work"}]
Return ONLY valid JSON array, no other text.''',
                },
                {
                  'role': 'user',
                  'content':
                      'User said: "$userMessage"\n\nI replied: "$aiResponse"\n\nWhat did we learn about the user?',
                },
              ],
              'temperature': 0.5,
              'max_tokens': 300,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Extraction timeout'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];

        // Parse the JSON array
        try {
          final extracted = jsonDecode(content) as List;
          return extracted
              .map(
                (item) => {
                  'fact': item['fact'].toString(),
                  'category': item['category'].toString(),
                },
              )
              .toList();
        } catch (e) {
          // If extraction fails, return empty
          return [];
        }
      }
      return [];
    } catch (e) {
      // Silently fail on extraction errors
      return [];
    }
  }
}
