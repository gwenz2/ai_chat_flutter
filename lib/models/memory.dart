import 'package:hive/hive.dart';

part 'memory.g.dart';

@HiveType(typeId: 1)
class Memory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fact;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  Memory({
    required this.id,
    required this.fact,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });

  factory Memory.create({required String fact, required String category}) {
    return Memory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fact: fact,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  Memory copyWith({
    String? id,
    String? fact,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      fact: fact ?? this.fact,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
