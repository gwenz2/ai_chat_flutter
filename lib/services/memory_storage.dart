import 'package:hive/hive.dart';
import '../models/memory.dart';

class MemoryStorage {
  static const String _memoryBoxName = 'memories';
  late Box<Memory> _memoryBox;

  Future<void> init() async {
    _memoryBox = await Hive.openBox<Memory>(_memoryBoxName);
  }

  Future<void> addMemory(Memory memory) async {
    await _memoryBox.add(memory);
  }

  List<Memory> getAllMemories() {
    return _memoryBox.values.toList();
  }

  List<Memory> getMemoriesByCategory(String category) {
    return _memoryBox.values
        .where((memory) => memory.category == category)
        .toList();
  }

  Future<void> updateMemory(int index, Memory memory) async {
    await _memoryBox.putAt(index, memory);
  }

  Future<void> deleteMemory(int index) async {
    await _memoryBox.deleteAt(index);
  }

  Future<void> deleteMemoryById(String id) async {
    final index = _memoryBox.values.toList().indexWhere((m) => m.id == id);
    if (index != -1) {
      await _memoryBox.deleteAt(index);
    }
  }

  Future<void> clearAllMemories() async {
    await _memoryBox.clear();
  }

  int getMemoryCount() {
    return _memoryBox.length;
  }

  Memory? getMemoryAt(int index) {
    if (index >= 0 && index < _memoryBox.length) {
      return _memoryBox.getAt(index);
    }
    return null;
  }

  List<String> getCategories() {
    return _memoryBox.values
        .map((memory) => memory.category)
        .toSet()
        .toList();
  }

  Future<void> close() async {
    await _memoryBox.close();
  }
}
