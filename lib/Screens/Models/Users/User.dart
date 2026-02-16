class UserModel {
  final String id;
  final String name;
  final String? email;
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final int health;
  final int maxHealth;
  final int strength;
  final int maxStrength;
  final int intelligence;
  final int maxIntelligence;
  final int goldCoins;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.level,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.health,
    required this.maxHealth,
    required this.strength,
    required this.maxStrength,
    required this.intelligence,
    required this.maxIntelligence,
    required this.goldCoins,
    this.avatarUrl = '',
  });

  // XP progress percentage
  double get xpProgress => currentXP / xpForNextLevel;

  // Health progress percentage
  double get healthProgress => health / maxHealth;

  // Strength progress percentage
  double get strengthProgress => strength / maxStrength;

  // Intelligence progress percentage
  double get intelligenceProgress => intelligence / maxIntelligence;
  
  // Copy with method for updating stats
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? level,
    int? currentXP,
    int? xpForNextLevel,
    int? health,
    int? maxHealth,
    int? strength,
    int? maxStrength,
    int? intelligence,
    int? maxIntelligence,
    int? goldCoins,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      currentXP: currentXP ?? this.currentXP,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
      strength: strength ?? this.strength,
      maxStrength: maxStrength ?? this.maxStrength,
      intelligence: intelligence ?? this.intelligence,
      maxIntelligence: maxIntelligence ?? this.maxIntelligence,
      goldCoins: goldCoins ?? this.goldCoins,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
