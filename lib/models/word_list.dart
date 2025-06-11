import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class WordList {
  final String id;
  final String name;
  final String description;
  final List<String> wordIds; // 关联的单词ID列表
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category; // 分类，如：CET4, CET6, TOEFL等

  WordList({
    required this.id,
    required this.name,
    required this.description,
    required this.wordIds,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  // 计算词汇表的完成度
  double calculateProgress(Map<String, double> wordFamiliarityMap) {
    if (wordIds.isEmpty) return 0.0;
    
    double totalFamiliarity = 0.0;
    for (String wordId in wordIds) {
      totalFamiliarity += wordFamiliarityMap[wordId] ?? 0.0;
    }
    
    return totalFamiliarity / wordIds.length;
  }

  WordList copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? wordIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
  }) {
    return WordList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      wordIds: wordIds ?? this.wordIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'wordIds': wordIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': category,
    };
  }

  factory WordList.fromJson(Map<String, dynamic> json) {
    return WordList(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      wordIds: List<String>.from(json['wordIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String,
    );
  }
}