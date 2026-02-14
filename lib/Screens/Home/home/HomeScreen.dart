// screens/home_screen.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:goal_play/Screens/Models/Quest/QuestClass.dart';
import 'package:goal_play/Screens/Models/Users/User.dart';
import 'package:goal_play/Screens/Utils/Constants/Constants.dart';
import 'package:goal_play/Screens/Widgets/ProgressBar/XpProgressBar.dart';
import 'package:goal_play/Screens/Widgets/QuestCard/questCard.dart';
import 'package:goal_play/Screens/Widgets/StatsBar/StatsBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goal_play/Services/DataService/DataService.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // DataService for cached data
  final DataService _dataService = DataService();
  
  late UserModel user;
  late List<Quest> quests;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromService();
  }

  void _loadDataFromService() {
    // Check if DataService is initialized
    if (_dataService.isInitialized) {
      setState(() {
        user = _dataService.currentUser!;
        quests = _dataService.todayQuests; // Use today's quests only
        isLoading = false;
      });
    } else {
      // Wait a moment and try again
      Future.delayed(Duration(milliseconds: 500), () {
        _loadDataFromService();
      });
    }
  }

  void _completeQuest(Quest quest) {
    setState(() {
      int index = quests.indexWhere((q) => q.id == quest.id);
      if (index != -1) {
        quests[index] = Quest(
          id: quest.id,
          title: quest.title,
          description: quest.description,
          type: quest.type,
          xpReward: quest.xpReward,
          statBonus: quest.statBonus,
          isCompleted: true,
          icon: quest.icon,
          gradientColors: quest.gradientColors,
        );

        user = UserModel(
          id: user.id,
          name: user.name,
          level: user.level,
          currentXP: user.currentXP + quest.xpReward,
          xpForNextLevel: user.xpForNextLevel,
          health: user.health + quest.statBonus,
          maxHealth: user.maxHealth,
          strength: user.strength,
          maxStrength: user.maxStrength,
          intelligence: user.intelligence,
          maxIntelligence: user.maxIntelligence,
          goldCoins: user.goldCoins + 10,
        );

        _showCompletionAnimation(quest);
      }
    });
  }

  void _showCompletionAnimation(Quest quest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.leaderboardSilver.withOpacity(0.9),
                    AppColors.cardBackground,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.leaderboardSilver, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.leaderboardSilver.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.accentGreen,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quest Completed!',
                    style: AppTextStyles.heading.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quest.title,
                    style: AppTextStyles.subheading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.highlightGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${quest.xpReward} XP',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${quest.statBonus} Health',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }


  void _showQuestDialog(Quest quest) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryPurple.withOpacity(0.95),
                AppColors.accentMagenta.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.highlightGold.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quest Icon with enhanced styling
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: quest.gradientColors,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: quest.gradientColors.first.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring animation
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    // Center icon
                    Icon(
                      quest.icon,
                      color: Colors.white,
                      size: 45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Quest title with enhanced styling
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.highlightGold,
                      AppColors.leaderboardGold,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  quest.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              // Quest description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  quest.description,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Enhanced rewards section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.highlightGold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Quest Rewards',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.highlightGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildEnhancedRewardChip(
                          icon: Icons.stars,
                          color: AppColors.highlightGold,
                          text: '+${quest.xpReward} XP',
                          label: 'Experience',
                        ),
                        _buildEnhancedRewardChip(
                          icon: Icons.favorite,
                          color: AppColors.accentGreen,
                          text: '+${quest.statBonus}',
                          label: 'Health',
                        ),
                        _buildEnhancedRewardChip(
                          icon: Icons.monetization_on,
                          color: AppColors.highlightGold,
                          text: '+${quest.goldReward}',
                          label: 'Gold',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Enhanced action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.highlightGold,
                            AppColors.leaderboardGold,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.highlightGold.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _completeQuest(quest);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Complete Quest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
    );
  }


  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple,
                border: Border.all(color: AppColors.highlightGold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.highlightGold.withOpacity(0.3),
                    blurRadius: 3,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  user.name,
                  style: AppTextStyles.heading.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.highlightGold,
            borderRadius: BorderRadius.circular(20),

          ),
          child: Row(
            children: [
              const Icon(
                FontAwesomeIcons.coins,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${user.goldCoins}',
                style: AppTextStyles.statValue.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.statsBackground.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield,
                color: AppColors.highlightGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Character Stats',
                style: AppTextStyles.subheading,
              ),
            ],
          ),
          const SizedBox(height: 20),

          StatBar(
            label: 'Health',
            current: user.health,
            max: user.maxHealth,
            color: AppColors.accentGreen,
            icon: Icons.favorite,
          ),

          SizedBox(height: 10,),
          StatBar(
            label: 'Strength',
            current: user.strength,
            max: user.maxStrength,
            color: Color(0xFFF87171),
            icon: Icons.fitness_center,
          ),

          SizedBox(height: 10,),

          StatBar(
            label: 'Intelligence',
            current: user.intelligence,
            max: user.maxIntelligence,
            color: AppColors.accentBlue,
            icon: Icons.school,
          ),
        ],
      ),
    );
  }


  Widget _buildQuestsSection(int completed, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 8),
            Text(

              'Today\'s Quests',
              style: AppTextStyles.subheading.copyWith(
                  fontSize: 20,
                  color: AppColors.primaryPurple

              ),
            ),
            SizedBox(width: 150,),
            Text(
              '$completed/$total',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textGray,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quests.length,
          itemBuilder: (context, index) {
            return QuestCard(
              quest: quests[index],
              onTap: () {
                if (!quests[index].isCompleted) {
                  _showQuestDialog(quests[index]);
                }
              },
            );
          },
        ),
      ],
    );
  }


  Widget _buildEnhancedRewardChip({
    required IconData icon,
    required Color color,
    required String text,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
              ),
              SizedBox(height: 16),
              Text(
                'Loading Home...',
                style: AppTextStyles.bodyDark,
              ),
            ],
          ),
        ),
      );
    }

    int completedQuests = quests
        .where((q) => q.isCompleted)
        .length;
    int totalQuests = quests.length;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBody: true,
      body: Container(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                XPProgressBar(
                  level: user.level,
                  currentXP: user.currentXP,
                  xpForNextLevel: user.xpForNextLevel,
                ),
                const SizedBox(height: 24),

                _buildCharacterStats(),
                const SizedBox(height: 24),

                _buildQuestsSection(completedQuests, totalQuests),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
