// Configuration for API keys and endpoints
// IMPORTANT: DO NOT commit api_config.dart to version control!
//
// Setup Instructions:
// 1. Copy this file: cp lib/config/api_config.example.dart lib/config/api_config.dart
// 2. Replace 'sk-your-api-key-here' with your actual DeepSeek API key
// 3. Get your key from: https://platform.deepseek.com
// 4. api_config.dart is in .gitignore, so it won't be committed

class ApiConfig {
  /// DeepSeek API Key
  /// Replace with your actual key from https://platform.deepseek.com
  static const String deepseekApiKey = 'sk-your-api-key-here';

  /// DeepSeek API URL
  static const String deepseekApiUrl =
      'https://api.deepseek.com/chat/completions';
}
