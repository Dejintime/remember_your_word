import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Word {
  final String id;
  final String english;
  final String chinese;
  final String? pronunciation; // 发音
  final String? example; // 例句
  final List<String> tags; // 标签，如：难度、类别等
  final DateTime createdAt;
  DateTime lastReviewedAt;
  int reviewCount; // 复习次数
  int correctCount; // 正确次数
  double familiarity; // 熟悉度 0.0-1.0

  Word({
    required this.id,
    required this.english,
    required this.chinese,
    this.pronunciation,
    this.example,
    this.tags = const [],
    required this.createdAt,
    required this.lastReviewedAt,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.familiarity = 0.0,
  });

  // 计算准确率
  double get accuracy => reviewCount > 0 ? correctCount / reviewCount : 0.0;

  // 是否需要复习（基于间隔重复算法）
  bool get needsReview {
    final daysSinceLastReview = DateTime.now().difference(lastReviewedAt).inDays;
    final interval = _calculateReviewInterval();
    return daysSinceLastReview >= interval;
  }

  // 计算复习间隔（简化版间隔重复算法）
  int _calculateReviewInterval() {
    if (familiarity < 0.3) return 1; // 不熟悉的单词，1天后复习
    if (familiarity < 0.6) return 3; // 一般熟悉，3天后复习
    if (familiarity < 0.8) return 7; // 比较熟悉，1周后复习
    return 30; // 很熟悉，1个月后复习
  }

  // 更新复习记录
  Word updateReview({required bool isCorrect}) {
    final newReviewCount = reviewCount + 1;
    final newCorrectCount = isCorrect ? correctCount + 1 : correctCount;
    
    // 更新熟悉度
    double newFamiliarity = familiarity;
    if (isCorrect) {
      newFamiliarity = (familiarity + 0.1).clamp(0.0, 1.0);
    } else {
      newFamiliarity = (familiarity - 0.2).clamp(0.0, 1.0);
    }

    return Word(
      id: id,
      english: english,
      chinese: chinese,
      pronunciation: pronunciation,
      example: example,
      tags: tags,
      createdAt: createdAt,
      lastReviewedAt: DateTime.now(),
      reviewCount: newReviewCount,
      correctCount: newCorrectCount,
      familiarity: newFamiliarity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english': english,
      'chinese': chinese,
      'pronunciation': pronunciation,
      'example': example,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt.toIso8601String(),
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'familiarity': familiarity,
    };
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      english: json['english'] as String,
      chinese: json['chinese'] as String,
      pronunciation: json['pronunciation'] as String?,
      example: json['example'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastReviewedAt: DateTime.parse(json['lastReviewedAt'] as String),
      reviewCount: json['reviewCount'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      familiarity: (json['familiarity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Word copyWith({
    String? id,
    String? english,
    String? chinese,
    String? pronunciation,
    String? example,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
    int? reviewCount,
    int? correctCount,
    double? familiarity,
  }) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      chinese: chinese ?? this.chinese,
      pronunciation: pronunciation ?? this.pronunciation,
      example: example ?? this.example,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      familiarity: familiarity ?? this.familiarity,
    );
  }
}