import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../Screens/Models/Quest/QuestClass.dart';

class QuestService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== CREATE QUEST ====================
  Future<String> createQuest(Quest quest) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('DEBUG: Creating quest in Realtime Database');
      print('  - Quest ID: ${quest.id}');
      print('  - Quest Title: ${quest.title}');
      print('  - Quest Type: ${quest.type}');
      print('  - User ID: ${user.uid}');

      final questRef = _database.ref().child('quests').child(quest.id);
      
      await questRef.set({
        'id': quest.id,
        'title': quest.title,
        'description': quest.description,
        'type': quest.type.toString(),
        'difficulty': quest.difficulty.toString(),
        'xpReward': quest.xpReward,
        'statBonus': quest.statBonus,
        'goldReward': quest.goldReward,
        'isCompleted': quest.isCompleted,
        'dueDate': quest.dueDate?.millisecondsSinceEpoch,
        'duration': quest.duration,
        'createdAt': quest.createdAt.millisecondsSinceEpoch,
        'isDaily': quest.isDaily,
        'isCustom': quest.isCustom,
        'createdBy': user.uid,
        'updatedAt': ServerValue.timestamp,
      });

      // Update user stats
      await _updateUserQuestStats(user.uid, 'questsCreated');

      print('DEBUG: Quest created successfully in Realtime Database');
      return quest.id;
    } catch (e) {
      print('Error creating quest: $e');
      rethrow;
    }
  }

  // ==================== GET QUEST BY ID ====================
  Future<Quest?> getQuestById(String questId) async {
    try {
      print('DEBUG: Fetching quest from Realtime Database: $questId');
      
      final questSnapshot = await _database.ref().child('quests').child(questId).get();
      
      if (questSnapshot.exists) {
        final data = questSnapshot.value as Map<dynamic, dynamic>;
        print('DEBUG: Quest found: ${data['title']}');
        
        return Quest(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          type: _parseQuestType(data['type']),
          difficulty: _parseQuestDifficulty(data['difficulty']),
          xpReward: data['xpReward'],
          statBonus: data['statBonus'],
          goldReward: data['goldReward'],
          isCompleted: data['isCompleted'],
          dueDate: data['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(data['dueDate']) : null,
          duration: data['duration'],
          icon: _getQuestIcon(_parseQuestType(data['type'])),
          gradientColors: _getQuestGradient(_parseQuestDifficulty(data['difficulty'])),
          createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
          isDaily: data['isDaily'],
          isCustom: data['isCustom'],
        );
      } else {
        print('DEBUG: Quest not found: $questId');
        return null;
      }
    } catch (e) {
      print('Error fetching quest: $e');
      return null;
    }
  }

  // ==================== GET USER QUESTS ====================
  Future<List<Quest>> getUserQuests() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('DEBUG: Fetching user quests from Realtime Database');
      
      final questsSnapshot = await _database.ref().child('quests')
          .orderByChild('createdBy')
          .equalTo(user.uid)
          .get();

      List<Quest> quests = [];
      
      if (questsSnapshot.exists) {
        final data = questsSnapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          final questData = value as Map<dynamic, dynamic>;
          quests.add(Quest(
            id: questData['id'],
            title: questData['title'],
            description: questData['description'],
            type: _parseQuestType(questData['type']),
            difficulty: _parseQuestDifficulty(questData['difficulty']),
            xpReward: questData['xpReward'],
            statBonus: questData['statBonus'],
            goldReward: questData['goldReward'],
            isCompleted: questData['isCompleted'],
            dueDate: questData['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(questData['dueDate']) : null,
            duration: questData['duration'],
            icon: _getQuestIcon(_parseQuestType(questData['type'])),
            gradientColors: _getQuestGradient(_parseQuestDifficulty(questData['difficulty'])),
            createdAt: DateTime.fromMillisecondsSinceEpoch(questData['createdAt']),
            isDaily: questData['isDaily'],
            isCustom: questData['isCustom'],
          ));
        });
      }
      
      print('DEBUG: Found ${quests.length} quests for user');
      return quests;
    } catch (e) {
      print('Error fetching user quests: $e');
      return [];
    }
  }

  // ==================== UPDATE QUEST ====================
  Future<void> updateQuest(String questId, Map<String, dynamic> updates) async {
    try {
      print('DEBUG: Updating quest: $questId');
      
      await _database.ref().child('quests').child(questId).update({
        ...updates,
        'updatedAt': ServerValue.timestamp,
      });
      
      print('DEBUG: Quest updated successfully');
    } catch (e) {
      print('Error updating quest: $e');
      rethrow;
    }
  }

  // ==================== DELETE QUEST ====================
  Future<void> deleteQuest(String questId) async {
    try {
      print('DEBUG: Deleting quest: $questId');
      
      await _database.ref().child('quests').child(questId).remove();
      
      print('DEBUG: Quest deleted successfully');
    } catch (e) {
      print('Error deleting quest: $e');
      rethrow;
    }
  }

  // ==================== UPDATE USER QUEST STATS ====================
  Future<void> _updateUserQuestStats(String userId, String statType) async {
    try {
      final userRef = _database.ref().child('users').child(userId).child('stats');
      
      // Get current stats
      final snapshot = await userRef.get();
      Map<dynamic, dynamic> currentStats = {};
      
      if (snapshot.exists) {
        currentStats = Map<dynamic, dynamic>.from(snapshot.value as Map);
      }
      
      // Update the stat
      currentStats[statType] = (currentStats[statType] ?? 0) + 1;
      
      // Save back
      await userRef.set(currentStats);
      
      print('DEBUG: User quest stats updated: $statType');
    } catch (e) {
      print('Error updating user quest stats: $e');
    }
  }

  // ==================== HELPER METHODS ====================
  QuestType _parseQuestType(String typeString) {
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
      case 'QuestType.custom':
        return QuestType.custom;
      default:
        return QuestType.custom;
    }
  }

  QuestDifficulty _parseQuestDifficulty(String difficultyString) {
    switch (difficultyString) {
      case 'QuestDifficulty.easy':
        return QuestDifficulty.easy;
      case 'QuestDifficulty.medium':
        return QuestDifficulty.medium;
      case 'QuestDifficulty.hard':
        return QuestDifficulty.hard;
      default:
        return QuestDifficulty.medium;
    }
  }

  IconData _getQuestIcon(QuestType type) {
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
        return Icons.star;
    }
  }

  List<Color> _getQuestGradient(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return [Color(0xFF4CAF50), Color(0xFF8BC34A)]; // Green gradient
      case QuestDifficulty.medium:
        return [Color(0xFF2196F3), Color(0xFF03A9F4)]; // Blue gradient
      case QuestDifficulty.hard:
        return [Color(0xFFFF5722), Color(0xFFFF9800)]; // Orange gradient
    }
  }
}
