import 'package:hive/hive.dart';
import '../models/chat_message.dart';

class ChatStorage {
  static const String _chatBoxName = 'chat_messages';
  late Box<ChatMessage> _chatBox;

  Future<void> init() async {
    _chatBox = await Hive.openBox<ChatMessage>(_chatBoxName);
  }

  Future<void> addMessage(ChatMessage message) async {
    await _chatBox.add(message);
  }

  List<ChatMessage> getAllMessages() {
    return _chatBox.values.toList();
  }

  Future<void> clearAllMessages() async {
    await _chatBox.clear();
  }

  Future<void> deleteMessage(int index) async {
    await _chatBox.deleteAt(index);
  }

  int getMessageCount() {
    return _chatBox.length;
  }

  ChatMessage? getMessageAt(int index) {
    if (index >= 0 && index < _chatBox.length) {
      return _chatBox.getAt(index);
    }
    return null;
  }

  Future<void> close() async {
    await _chatBox.close();
  }
}
