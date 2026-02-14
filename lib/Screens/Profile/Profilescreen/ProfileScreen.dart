import 'package:flutter/material.dart';
import 'package:goal_play/Screens/Profile/AchievementScreen/AchievementScreen.dart';
import 'package:goal_play/Screens/Profile/editProfile/EditProfile.dart';
import 'package:goal_play/Screens/Settings/SettingScreen/SettingScreen.dart';
import 'package:goal_play/Screens/Utils/Constants/Constants.dart';
import 'package:goal_play/Services/DataService/DataService.dart';
import 'package:goal_play/Services/AuthServices/AuthServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // DataService for cached data
  final DataService _dataService = DataService();
  
  bool isLoading = true;
  
  // Local variables for UI
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String userClass = 'Explorer';
  int userLevel = 1;
  int currentXP = 0;
  int requiredXP = 100;
  int totalQuests = 0;
  int completedQuests = 0;
  int daysActive = 0;
  int health = 100;
  int strength = 50;
  int intelligence = 50;
  int gold = 0;
  int unlockedAchievements = 0;
  int totalAchievements = 15;

  @override
  void initState() {
    super.initState();
    _loadDataFromService();
  }

  void _loadDataFromService() {
    // Check if DataService is initialized
    if (_dataService.isInitialized) {
      final user = _dataService.currentUser!;
      setState(() {
        userName = user.name;
        userEmail = user.name + '@email.com'; // Simple email fallback
        userLevel = user.level;
        currentXP = user.currentXP;
        requiredXP = user.xpForNextLevel;
        totalQuests = _dataService.allQuests.length;
        completedQuests = _dataService.allQuests.where((q) => q.isCompleted).length;
        health = user.health;
        strength = user.strength;
        intelligence = user.intelligence;
        gold = user.goldCoins;
        unlockedAchievements = (completedQuests ~/ 5);
        isLoading = false;
      });
    } else {
      // Wait a moment and try again
      Future.delayed(Duration(milliseconds: 500), () {
        _loadDataFromService();
      });
    }
  }

  // Recent achievements (just for display)
  final List<Map<String, dynamic>> recentAchievements = [
    {
      'title': '7 Day Streak',
      'icon': Icons.local_fire_department,
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    },
    {
      'title': 'Quest Master',
      'icon': Icons.emoji_events,
      'gradient': [Color(0xFFFFD700), Color(0xFFFFA500)],
    },
    {
      'title': 'Level 10',
      'icon': Icons.stars,
      'gradient': AppColors.gradientPrimaryPurple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Use DataService for cached data
    if (!_dataService.isInitialized) {
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
                'Loading Profile...',
                style: AppTextStyles.bodyDark,
              ),
            ],
          ),
        ),
      );
    }

    final double xpProgress = userLevel > 0 ? currentXP / requiredXP : 0.0;
    final int successRate = totalQuests > 0 ? ((completedQuests / totalQuests) * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: AppSizes.paddingMD),
                _buildProfileHeader(xpProgress),
                SizedBox(height: AppSizes.paddingLG),
                _buildStatsSection(),
                SizedBox(height: AppSizes.paddingLG),
                _buildAchievementsSection(),
                SizedBox(height: AppSizes.paddingLG),
                _buildGeneralStats(successRate),
                SizedBox(height: AppSizes.paddingLG),
                _buildActionButtons(),
                SizedBox(height: AppSizes.paddingXL),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.secondaryPurple,
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            'Profile',
            style: AppTextStyles.headingWhite.copyWith(fontSize: 20),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: AppColors.textWhite),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(double xpProgress) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.primaryPurple,
                border: Border.all(
                  color: AppColors.borderGold,
                  width: 3,
                ),
                boxShadow: AppShadows.glowPurple,
              ),
              child: Center(
                child: Text(
                  userName.substring(0, 1),
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.padding),

            // Name & Class
            Text(
              _dataService.currentUser?.name ?? 'User',
              style: AppTextStyles.heading,
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSM + 4,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryPurple,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Text(
                'Level ${_dataService.currentUser?.level ?? 1}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ),
            SizedBox(height: 8),
            // Email
            Text(
              _dataService.currentUser?.name ?? 'User@email.com',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textDark,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppSizes.padding),

            // Level & XP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stars, color: AppColors.highlightGold, size: 24),
                SizedBox(width: 8),
                Text(
                  'Level $userLevel',
                  style: AppTextStyles.subheading.copyWith(
                    color: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.paddingSM),

            // XP Progress Bar
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    backgroundColor: AppColors.statsBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                    minHeight: 10,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$currentXP / $requiredXP XP',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Character Stats',
            style: AppTextStyles.subheading,
          ),
          SizedBox(height: AppSizes.paddingSM),
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                _buildStatBar('Health', health, Icons.favorite, AppColors.errorRed),
                SizedBox(height: AppSizes.paddingSM),
                _buildStatBar('Strength', strength, Icons.fitness_center, AppColors.accentGreen),
                SizedBox(height: AppSizes.paddingSM),
                _buildStatBar('Intelligence', intelligence, Icons.lightbulb, AppColors.accentBlue),
                SizedBox(height: AppSizes.paddingSM),
                Divider(),
                SizedBox(height: AppSizes.paddingSM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on, color: AppColors.highlightGold, size: 28),
                    SizedBox(width: 8),
                    Text(
                      '$gold Gold',
                      style: AppTextStyles.statValueLarge.copyWith(
                        color: AppColors.highlightGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: AppSizes.paddingSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyles.body),
                  Text(
                    '$value/100',
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                child: LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: AppColors.statsBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: AppTextStyles.subheading,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AchievementsScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingSM),
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                // Achievement Progress Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: AppColors.highlightGold, size: 28),
                    SizedBox(width: 8),
                    Text(
                      '${((completedQuests ~/ 5) / 15)}',
                      style: AppTextStyles.statValueLarge.copyWith(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  child: LinearProgressIndicator(
                    value: _dataService.allQuests.isNotEmpty ? 
                        ((_dataService.allQuests.where((q) => q.isCompleted).length ~/ 5) / 15) : 0.0,
                    backgroundColor: AppColors.statsBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.highlightGold),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_dataService.allQuests.isNotEmpty ? 
                      (((_dataService.allQuests.where((q) => q.isCompleted).length ~/ 5) / 15) * 100).toInt() : 0}% Complete',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSizes.padding),
                Divider(),
                SizedBox(height: AppSizes.paddingSM),

                // Recent Achievements
                Text(
                  'Recent Unlocked',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: AppSizes.paddingSM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: recentAchievements.map((achievement) {
                    return _buildAchievementBadge(
                      achievement['title'] as String,
                      achievement['icon'] as IconData,
                      achievement['gradient'] as List<Color>,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, List<Color> gradient) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textWhite, size: 28),
        ),
        SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralStats(int successRate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: AppTextStyles.subheading,
          ),
          SizedBox(height: AppSizes.paddingSM),
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                _buildStatItem(
                  'Total Quests',
                  totalQuests.toString(),
                  Icons.list_alt,
                  AppColors.primaryPurple,
                ),
                SizedBox(height: AppSizes.padding),
                _buildStatItem(
                  'Completed',
                  completedQuests.toString(),
                  Icons.check_circle,
                  AppColors.accentGreen,
                ),
                SizedBox(height: AppSizes.padding),
                _buildStatItem(
                  'Success Rate',
                  '$successRate%',
                  Icons.trending_up,
                  AppColors.accentBlue,
                ),
                SizedBox(height: AppSizes.padding),
                _buildStatItem(
                  'Days Active',
                  daysActive.toString(),
                  Icons.calendar_today,
                  AppColors.highlightGold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.paddingSM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: AppSizes.padding),
        Expanded(
          child: Text(label, style: AppTextStyles.body),
        ),
        SizedBox(width: AppSizes.padding),
        Text(
          value,
          style: AppTextStyles.statValue.copyWith(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  EditProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                elevation: 0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryPurple,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 4),
                alignment: Alignment.center,
                child: Text(
                  'Edit Profile',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.paddingSM),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  AchievementsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 4),
                side: BorderSide(color: AppColors.primaryPurple, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
              ),
              child: Text(
                'View Achievements',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
