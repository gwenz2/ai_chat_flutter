import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_storage.dart';
import '../services/deepseek_service.dart';
import '../services/memory_extraction_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatStorage _chatStorage = ChatStorage();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  MemoryProviderInterface? _memoryProvider;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void setMemoryProvider(MemoryProviderInterface provider) {
    _memoryProvider = provider;
  }

  Future<void> init() async {
    await _chatStorage.init();
    _messages.addAll(_chatStorage.getAllMessages());
    notifyListeners();
  }

  Future<void> addUserMessage(String content) async {
    final message = ChatMessage.user(content);
    _messages.add(message);
    await _chatStorage.addMessage(message);
    notifyListeners();
  }

  Future<void> getAiResponse(
    String userMessage, {
    String memoriesContext = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Convert messages to format for API
      List<Map<String, String>> chatHistory = _messages
          .map(
            (msg) => {'content': msg.content, 'isUser': msg.isUser.toString()},
          )
          .toList();

      // Get response from DeepSeek with memories context
      final aiResponse = await DeepseekService.sendMessage(
        userMessage,
        chatHistory,
        memoriesContext: memoriesContext,
      );

      // Auto-extract memories from this exchange
      final extractedMemories = await MemoryExtractionService.extractMemories(
        userMessage,
        aiResponse,
      );

      // Auto-add extracted memories (skip duplicates and if auto-insert is enabled)
      if (extractedMemories.isNotEmpty &&
          _memoryProvider != null &&
          _memoryProvider!.autoInsertEnabled) {
        for (var memory in extractedMemories) {
          // Check if this fact already exists before adding
          if (!_memoryProvider!.factAlreadyExists(memory['fact']!)) {
            await _memoryProvider!.addMemory(
              memory['fact']!,
              memory['category']!,
            );
          }
        }
      }

      // Add AI response to messages with memory count
      final aiMessage = ChatMessage.ai(
        aiResponse,
        memoriesExtractedCount: extractedMemories.length,
      );
      _messages.add(aiMessage);
      await _chatStorage.addMessage(aiMessage);
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage.ai(
        'Sorry, I encountered an error: ${e.toString()}',
      );
      _messages.add(errorMessage);
      await _chatStorage.addMessage(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    _messages.clear();
    await _chatStorage.clearAllMessages();
    notifyListeners();
  }
}

// Interface for dependency injection
abstract class MemoryProviderInterface {
  Future<void> addMemory(String fact, String category);
  bool factAlreadyExists(String fact);
  bool get autoInsertEnabled;
}
