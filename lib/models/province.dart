class Province {
  final String id;
  final String name;
  final String nameVietnamese;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final int requiredScore;
  final String description;
  final List<String> facts;

  Province({
    required this.id,
    required this.name,
    required this.nameVietnamese,
    this.isUnlocked = false,
    this.unlockedDate,
    this.requiredScore = 70,
    required this.description,
    required this.facts,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
      nameVietnamese: json['nameVietnamese'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedDate: json['unlockedDate'] != null 
          ? DateTime.parse(json['unlockedDate']) 
          : null,
      requiredScore: json['requiredScore'] ?? 70,
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
      'unlockedDate': unlockedDate?.toIso8601String(),
      'requiredScore': requiredScore,
      'description': description,
      'facts': facts,
    };
  }

  Province copyWith({
    String? id,
    String? name,
    String? nameVietnamese,
    bool? isUnlocked,
    DateTime? unlockedDate,
    int? requiredScore,
    String? description,
    List<String>? facts,
  }) {
    return Province(
      id: id ?? this.id,
      name: name ?? this.name,
      nameVietnamese: nameVietnamese ?? this.nameVietnamese,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      requiredScore: requiredScore ?? this.requiredScore,
      description: description ?? this.description,
      facts: facts ?? this.facts,
    );
  }
} 