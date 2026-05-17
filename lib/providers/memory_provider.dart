import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../services/memory_storage.dart';
import 'chat_provider.dart';

class MemoryProvider extends ChangeNotifier implements MemoryProviderInterface {
  final MemoryStorage _memoryStorage = MemoryStorage();
  final List<Memory> _memories = [];
  String _selectedCategory = 'All';
  bool _autoInsertEnabled = true;

  List<Memory> get memories => _memories;
  List<Memory> get filteredMemories {
    if (_selectedCategory == 'All') {
      return _memories;
    }
    return _memories.where((m) => m.category == _selectedCategory).toList();
  }

  List<String> get categories {
    final cats = _memoryStorage.getCategories();
    return ['All', ...cats];
  }

  String get selectedCategory => _selectedCategory;
  @override
  bool get autoInsertEnabled => _autoInsertEnabled;

  void toggleAutoInsert() {
    _autoInsertEnabled = !_autoInsertEnabled;
    notifyListeners();
  }

  Future<void> init() async {
    await _memoryStorage.init();
    _memories.addAll(_memoryStorage.getAllMemories());
    notifyListeners();
  }

  @override
  Future<void> addMemory(String fact, String category) async {
    final memory = Memory.create(fact: fact, category: category);
    _memories.add(memory);
    await _memoryStorage.addMemory(memory);
    notifyListeners();
  }

  Future<void> updateMemory(int index, String fact, String category) async {
    if (index >= 0 && index < _memories.length) {
      final oldMemory = _memories[index];
      final updatedMemory = oldMemory.copyWith(fact: fact, category: category);
      _memories[index] = updatedMemory;
      await _memoryStorage.updateMemory(index, updatedMemory);
      notifyListeners();
    }
  }

  Future<void> deleteMemory(int index) async {
    if (index >= 0 && index < _memories.length) {
      _memories.removeAt(index);
      await _memoryStorage.deleteMemory(index);
      notifyListeners();
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> clearAllMemories() async {
    _memories.clear();
    await _memoryStorage.clearAllMemories();
    notifyListeners();
  }

  String getMemoriesAsPrompt() {
    if (_memories.isEmpty) {
      return '';
    }

    final grouped = <String, List<String>>{};
    for (var memory in _memories) {
      if (!grouped.containsKey(memory.category)) {
        grouped[memory.category] = [];
      }
      grouped[memory.category]!.add(memory.fact);
    }

    final buffer = StringBuffer('Important facts about the user:\n\n');
    grouped.forEach((category, facts) {
      buffer.writeln('$category:');
      for (var fact in facts) {
        buffer.writeln('- $fact');
      }
      buffer.writeln();
    });

    return buffer.toString();
  }

  /// Check if a similar fact already exists in memories
  /// Uses fuzzy matching to detect duplicate facts
  @override
  bool factAlreadyExists(String newFact) {
    final newFactLower = newFact.toLowerCase().trim();

    return _memories.any((memory) {
      final existingFactLower = memory.fact.toLowerCase().trim();

      // Exact match
      if (existingFactLower == newFactLower) return true;

      // Contain each other (handles similar phrasing)
      if (existingFactLower.contains(newFactLower) ||
          newFactLower.contains(existingFactLower)) {
        return true;
      }

      // Check if they're about the same thing (share key words)
      final existingWords = existingFactLower.split(RegExp(r'\s+'));
      final newWords = newFactLower.split(RegExp(r'\s+'));

      final commonWords = existingWords
          .where((w) => w.length > 4 && newWords.contains(w))
          .length;

      // If they share significant key words (> 50% overlap), consider it duplicate
      final threshold =
          (existingWords.length > newWords.length
              ? newWords.length
              : existingWords.length) *
          0.5;
      return commonWords >= threshold;
    });
  }
}
