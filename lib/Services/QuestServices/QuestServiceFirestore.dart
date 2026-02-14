import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goal_play/Screens/Models/Quest/QuestClass.dart';
import 'package:flutter/material.dart';
import 'package:goal_play/Screens/Utils/Constants/Constants.dart';

class QuestServiceFirestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new quest
  Future<String> createQuest(Quest quest) async {
    try {
      final docRef = await _firestore.collection('quests').add({
        'title': quest.title,
        'description': quest.description,
        'type': quest.type.toString(),
        'difficulty': quest.difficulty.toString(),
        'xpReward': quest.xpReward,
        'statBonus': quest.statBonus,
        'goldReward': quest.goldReward,
        'isCompleted': quest.isCompleted,
        'isDaily': quest.isDaily,
        'duration': quest.duration,
        'createdAt': quest.createdAt,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating quest: $e');
      rethrow;
    }
  }

  // Get all quests
  Future<List<Quest>> getAllQuests() async {
    try {
      final querySnapshot = await _firestore.collection('quests').get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Quest(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: _parseQuestType(data['type']),
          difficulty: _parseQuestDifficulty(data['difficulty']),
          xpReward: data['xpReward'] ?? 0,
          statBonus: data['statBonus'] ?? 0,
          goldReward: data['goldReward'] ?? 0,
          isCompleted: data['isCompleted'] ?? false,
          isDaily: data['isDaily'] ?? false,
          duration: data['duration'],
          icon: _getIconForQuestType(_parseQuestType(data['type'])),
          gradientColors: _getGradientForDifficulty(_parseQuestDifficulty(data['difficulty'])),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error fetching all quests: $e');
      return [];
    }
  }
  Future<Quest?> getQuestById(String questId) async {
    try {
      final docSnapshot = await _firestore.collection('quests').doc(questId).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return Quest(
          id: docSnapshot.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: _parseQuestType(data['type']),
          difficulty: _parseQuestDifficulty(data['difficulty']),
          xpReward: data['xpReward'] ?? 0,
          statBonus: data['statBonus'] ?? 0,
          goldReward: data['goldReward'] ?? 0,
          isCompleted: data['isCompleted'] ?? false,
          isDaily: data['isDaily'] ?? false,
          duration: data['duration'],
          createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
          icon: Icons.star,
          gradientColors: [Colors.blue, Colors.purple],
        );
      }
      return null;
    } catch (e) {
      print('Error getting quest by ID: $e');
      return null;
    }
  }

  // Get all quests for a user (simplified - returns all quests for now)
  Future<List<Quest>> getUserQuests(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('quests')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Quest(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: _parseQuestType(data['type']),
          difficulty: _parseQuestDifficulty(data['difficulty']),
          xpReward: data['xpReward'] ?? 0,
          statBonus: data['statBonus'] ?? 0,
          goldReward: data['goldReward'] ?? 0,
          isCompleted: data['isCompleted'] ?? false,
          isDaily: data['isDaily'] ?? false,
          duration: data['duration'],
          createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
          icon: Icons.star,
          gradientColors: [Colors.blue, Colors.purple],
        );
      }).toList();
    } catch (e) {
      print('Error getting user quests: $e');
      return [];
    }
  }

  // Update quest
  Future<void> updateQuest(Quest quest) async {
    try {
      await _firestore.collection('quests').doc(quest.id).update({
        'title': quest.title,
        'description': quest.description,
        'type': quest.type.toString(),
        'difficulty': quest.difficulty.toString(),
        'xpReward': quest.xpReward,
        'statBonus': quest.statBonus,
        'goldReward': quest.goldReward,
        'isCompleted': quest.isCompleted,
        'duration': quest.duration,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating quest: $e');
      rethrow;
    }
  }

  // Delete quest
  Future<void> deleteQuest(String questId) async {
    try {
      await _firestore.collection('quests').doc(questId).delete();
    } catch (e) {
      print('Error deleting quest: $e');
      rethrow;
    }
  }

  // Update quest completion status
  Future<void> updateQuestStatus(String questId, bool isCompleted) async {
    try {
      await _firestore.collection('quests').doc(questId).update({
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Quest status updated: $questId, completed: $isCompleted');
    } catch (e) {
      print('Error updating quest status: $e');
    }
  }

  // Helper methods
  QuestType _parseQuestType(String? typeString) {
    if (typeString == null) return QuestType.custom;
    
    switch (typeString) {
      case 'QuestType.health':
        return QuestType.health;
      case 'QuestType.study':
        return QuestType.study;
      case 'QuestType.exercise':
        return QuestType.exercise;
      case 'QuestType.social':
        return QuestType.social;
      case 'QuestType.sleep':
        return QuestType.sleep;
      default:
        return QuestType.custom;
    }
  }

  QuestDifficulty _parseQuestDifficulty(String? difficultyString) {
    if (difficultyString == null) return QuestDifficulty.easy;
    
    switch (difficultyString) {
      case 'QuestDifficulty.easy':
        return QuestDifficulty.easy;
      case 'QuestDifficulty.medium':
        return QuestDifficulty.medium;
      case 'QuestDifficulty.hard':
        return QuestDifficulty.hard;
      default:
        return QuestDifficulty.easy;
    }
  }

  // Helper method to get icon for quest type
  IconData _getIconForQuestType(QuestType type) {
    switch (type) {
      case QuestType.health:
        return Icons.favorite;
      case QuestType.study:
        return Icons.menu_book;
      case QuestType.exercise:
        return Icons.fitness_center;
      case QuestType.social:
        return Icons.people;
      case QuestType.sleep:
        return Icons.bedtime;
      case QuestType.custom:
      default:
        return Icons.star;
    }
  }

  // Helper method to get gradient for difficulty
  List<Color> _getGradientForDifficulty(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return AppColors.gradientEasy;
      case QuestDifficulty.medium:
        return AppColors.gradientMedium;
      case QuestDifficulty.hard:
        return AppColors.gradientHard;
      default:
        return AppColors.gradientMedium;
    }
  }
}
