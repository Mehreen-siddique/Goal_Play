import 'package:flutter/material.dart';
import 'package:goal_play/Screens/Utils/Constants/Constants.dart';

enum QuestType {
  health,
  study,
  exercise,
  social,
  sleep,
  custom,
}

enum QuestDifficulty {
  easy,
  medium,
  hard,
}





class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final int xpReward;
  final int statBonus;
  final int goldReward;
  final bool isCompleted;
  final DateTime? dueDate;
  final int? duration; // in minutes
  final IconData icon;
  final List<Color> gradientColors;
  final DateTime createdAt;
  final bool isDaily;
  final bool isCustom;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.difficulty = QuestDifficulty.medium,
    required this.xpReward,
    required this.statBonus,
    this.goldReward = 10,
    this.isCompleted = false,
    this.dueDate,
    this.duration,
    required this.icon,
    required this.gradientColors,
    DateTime? createdAt,
    this.isDaily = false,
    this.isCustom = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create a copy with modified fields
  Quest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    QuestDifficulty? difficulty,
    int? xpReward,
    int? statBonus,
    int? goldReward,
    bool? isCompleted,
    DateTime? dueDate,
    int? duration,
    IconData? icon,
    // gradient colors  parameter
    List<Color>? gradientColors,
    DateTime? createdAt,
    bool? isDaily,
    bool? isCustom,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      statBonus: statBonus ?? this.statBonus,
      goldReward: goldReward ?? this.goldReward,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      duration: duration ?? this.duration,
      icon: icon ?? this.icon,
      gradientColors: gradientColors ?? this.gradientColors,
      createdAt: createdAt ?? this.createdAt,
      isDaily: isDaily ?? this.isDaily,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  // Get difficulty text
  String get difficultyText {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 'Easy';
      case QuestDifficulty.medium:
        return 'Medium';
      case QuestDifficulty.hard:
        return 'Hard';
    }
  }
  // Get difficulty color
  List<Color> get difficultyGradient {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return AppColors.gradientEasy;
      case QuestDifficulty.medium:
        return AppColors.gradientMedium;
      case QuestDifficulty.hard:
        return AppColors.gradientHard;
    }
  }
}
