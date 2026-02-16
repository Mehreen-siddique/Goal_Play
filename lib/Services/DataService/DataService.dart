import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goal_play/Screens/Models/Users/User.dart';
import 'package:goal_play/Screens/Models/Quest/QuestClass.dart';
import 'package:goal_play/Services/QuestServices/QuestServices.dart';
import 'package:goal_play/Services/QuestServices/QuestServiceFirestore.dart';
import 'package:goal_play/Services/AuthServices/AuthServices.dart';
import 'package:flutter/foundation.dart';

class DataService with ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final QuestServiceFirestore _questService = QuestServiceFirestore();
  
  // Cached data
  List<Quest> _cachedQuests = [];
  List<Quest> _cachedTodayQuests = [];
  UserModel? _cachedUser;
  bool _isInitialized = false;

  // Getters for cached data
  List<Quest> get allQuests => _cachedQuests;
  List<Quest> get todayQuests => _getTodayQuests();
  UserModel? get currentUser => _cachedUser;
  bool get isInitialized => _isInitialized;

  // Initialize data - call this after login
  Future<void> initializeData() async {
    if (_isInitialized) return;
    
    print('DataService: Initializing data...');
    
    try {
      // Fetch user data and quests in parallel
      await Future.wait([
        _fetchUserData(),
        _fetchQuestData(),
      ]);
      
      _isInitialized = true;
      print('DataService: Data initialized successfully');
    } catch (e) {
      print('DataService: Error initializing data: $e');
    }
  }

  // Fetch user data from Firebase
  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final username = userData['username'] ?? 'User';
        
        // Use stored stats from Firebase, or calculate if not present
        _cachedUser = UserModel(
          id: user.uid,
          name: username,
          level: (userData['level'] as num?)?.toInt() ?? 1,
          currentXP: (userData['currentXP'] as num?)?.toInt() ?? 0,
          xpForNextLevel: (userData['xpForNextLevel'] as num?)?.toInt() ?? 100,
          health: (userData['health'] as num?)?.toInt() ?? 50,
          maxHealth: (userData['maxHealth'] as num?)?.toInt() ?? 100,
          strength: (userData['strength'] as num?)?.toInt() ?? 30,
          maxStrength: (userData['maxStrength'] as num?)?.toInt() ?? 100,
          intelligence: (userData['intelligence'] as num?)?.toInt() ?? 25,
          maxIntelligence: (userData['maxIntelligence'] as num?)?.toInt() ?? 100,
          goldCoins: (userData['goldCoins'] as num?)?.toInt() ?? 0,
        );
        
        print('DataService: User data loaded from Firebase - $_cachedUser?.name');
      } else {
        // Create initial user data if not exists
        await _createInitialUserData(user.uid);
      }
    } catch (e) {
      print('DataService: Error fetching user data: $e');
    }
  }
  
  // Create initial user data in Firebase
  Future<void> _createInitialUserData(String uid) async {
    try {
      final initialUserData = {
        'username': 'User',
        'level': 1,
        'currentXP': 0,
        'xpForNextLevel': 100,
        'health': 50,
        'maxHealth': 100,
        'strength': 30,
        'maxStrength': 100,
        'intelligence': 25,
        'maxIntelligence': 100,
        'goldCoins': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection('users').doc(uid).set(initialUserData);
      print('DataService: Initial user data created for $uid');
    } catch (e) {
      print('DataService: Error creating initial user data: $e');
    }
  }

  // Fetch quest data
  Future<void> _fetchQuestData() async {
    try {
      final quests = await _questService.getAllQuests();
      _cachedQuests = quests;
      print('DataService: ${quests.length} quests cached');
    } catch (e) {
      print('DataService: Error fetching quest data: $e');
    }
  }

  // Get today's quests (recent quests from today)
  List<Quest> _getTodayQuests() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final todayQuests = _cachedQuests.where((quest) {
      // Check if quest was created today (any quest, not just daily)
      final questDate = quest.createdAt;
      final questDay = DateTime(questDate.year, questDate.month, questDate.day);
      
      return questDay.isAtSameMomentAs(today);
    }).toList();
    
    // Sort by creation time (newest first)
    todayQuests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    print('DataService: Found ${todayQuests.length} quests for today');
    return todayQuests;
  }

  // Refresh data (call when quests are updated)
  Future<void> refreshData() async {
    print('DataService: Refreshing data...');
    _isInitialized = false;
    await initializeData();
    // Notify all listeners about the update
    notifyListeners();
  }
  
  // Add real-time quest listener
  void startRealtimeQuestUpdates() {
    print('DataService: Starting real-time quest updates...');
    _firestore.collection('quests').snapshots().listen((snapshot) {
      print('DataService: Quest data updated, refreshing...');
      _isInitialized = false;
      initializeData();
      notifyListeners();
    });
  }
  
  // Add new quest and update today's quests immediately
  Future<void> addQuestAndUpdateToday(Quest newQuest) async {
    try {
      print('DataService: Adding new quest and updating today\'s quests...');
      
      // Add quest to Firestore
      final questService = QuestServiceFirestore();
      await questService.createQuest(newQuest);
      
      // Immediately refresh data to update today's quests
      await refreshData();
    } catch (e) {
      print('DataService: Error adding quest: $e');
    }
  }
  
  // Update user stats in Firebase
  Future<void> updateUserStats({
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
  }) async {
    try {
      if (_cachedUser == null) return;
      
      final updateData = <String, dynamic>{};
      
      if (level != null) updateData['level'] = level;
      if (currentXP != null) updateData['currentXP'] = currentXP;
      if (xpForNextLevel != null) updateData['xpForNextLevel'] = xpForNextLevel;
      if (health != null) updateData['health'] = health;
      if (maxHealth != null) updateData['maxHealth'] = maxHealth;
      if (strength != null) updateData['strength'] = strength;
      if (maxStrength != null) updateData['maxStrength'] = maxStrength;
      if (intelligence != null) updateData['intelligence'] = intelligence;
      if (maxIntelligence != null) updateData['maxIntelligence'] = maxIntelligence;
      if (goldCoins != null) updateData['goldCoins'] = goldCoins;
      
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(_cachedUser!.id).update(updateData);
      
      // Update local cache
      _cachedUser = _cachedUser!.copyWith(
        level: level ?? _cachedUser!.level,
        currentXP: currentXP ?? _cachedUser!.currentXP,
        xpForNextLevel: xpForNextLevel ?? _cachedUser!.xpForNextLevel,
        health: health ?? _cachedUser!.health,
        maxHealth: maxHealth ?? _cachedUser!.maxHealth,
        strength: strength ?? _cachedUser!.strength,
        maxStrength: maxStrength ?? _cachedUser!.maxStrength,
        intelligence: intelligence ?? _cachedUser!.intelligence,
        maxIntelligence: maxIntelligence ?? _cachedUser!.maxIntelligence,
        goldCoins: goldCoins ?? _cachedUser!.goldCoins,
      );
      
      print('DataService: User stats updated in Firebase');
    } catch (e) {
      print('DataService: Error updating user stats: $e');
    }
  }

  // Clear cache (call on logout)
  void clearCache() {
    print('DataService: Clearing cache...');
    _cachedQuests.clear();
    _cachedTodayQuests.clear();
    _cachedUser = null;
    _isInitialized = false;
  }

  // Update quest in cache
  void updateQuestInCache(Quest updatedQuest) {
    final index = _cachedQuests.indexWhere((q) => q.id == updatedQuest.id);
    if (index != -1) {
      _cachedQuests[index] = updatedQuest;
      print('DataService: Updated quest in cache - ${updatedQuest.title}');
    }
  }

  // Add new quest to cache
  void addQuestToCache(Quest newQuest) {
    _cachedQuests.insert(0, newQuest); // Add to beginning
    print('DataService: Added new quest to cache - ${newQuest.title}');
  }
}
