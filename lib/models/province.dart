class Province {
  final String id;
  final String name;
  final String nameVietnamese;
  final bool isUnlocked;
  final bool isExplored;
  final DateTime? unlockedDate;
  final int requiredScore;
  final int score;
  final String description;
  final List<String> facts;

  Province({
    required this.id,
    required this.name,
    required this.nameVietnamese,
    this.isUnlocked = false,
    this.isExplored = false,
    this.unlockedDate,
    this.requiredScore = 70,
    this.score = 0,
    required this.description,
    required this.facts,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
      nameVietnamese: json['nameVietnamese'],
      isUnlocked: json['isUnlocked'] ?? false,
      isExplored: json['isExplored'] ?? false,
      unlockedDate: json['unlockedDate'] != null 
          ? DateTime.parse(json['unlockedDate']) 
          : null,
      requiredScore: json['requiredScore'] ?? 70,
      score: json['score'] ?? 0,
      description: json['description'],
      facts: List<String>.from(json['facts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameVietnamese': nameVietnamese,
      'isUnlocked': isUnlocked,
      'isExplored': isExplored,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'requiredScore': requiredScore,
      'score': score,
      'description': description,
      'facts': facts,
    };
  }

  Province copyWith({
    String? id,
    String? name,
    String? nameVietnamese,
    bool? isUnlocked,
    bool? isExplored,
    DateTime? unlockedDate,
    int? requiredScore,
    int? score,
    String? description,
    List<String>? facts,
  }) {
    return Province(
      id: id ?? this.id,
      name: name ?? this.name,
      nameVietnamese: nameVietnamese ?? this.nameVietnamese,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isExplored: isExplored ?? this.isExplored,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      requiredScore: requiredScore ?? this.requiredScore,
      score: score ?? this.score,
      description: description ?? this.description,
      facts: facts ?? this.facts,
    );
  }
} 