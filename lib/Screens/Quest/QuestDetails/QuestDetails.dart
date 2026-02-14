import 'package:flutter/material.dart';

import 'package:goal_play/Screens/Models/Quest/QuestClass.dart';

import 'package:goal_play/Screens/Quest/Editquest/EditQuest.dart';

import 'package:goal_play/Screens/Utils/Constants/Constants.dart';

import 'package:goal_play/Services/QuestServices/QuestServices.dart';

import 'package:goal_play/Services/QuestServices/QuestServiceFirestore.dart';

import 'package:goal_play/Services/DataService/DataService.dart';

import 'package:google_fonts/google_fonts.dart';







class QuestDetailScreen extends StatefulWidget {

  final String? questId;

  final Quest? quest;

  const QuestDetailScreen({Key? key, this.questId, this.quest}) : super(key: key);



  @override

  State<QuestDetailScreen> createState() => _QuestDetailScreenState();

}



class _QuestDetailScreenState extends State<QuestDetailScreen> {

  // initialization:

  final QuestService _questService = QuestService();

  final QuestServiceFirestore _questServiceFirestore = QuestServiceFirestore();

  late Quest _quest;

  bool _isTimerRunning = false;

  int _elapsedSeconds = 0;

  bool _isLoading = false;





  @override

  void initState() {

    super.initState();

    if (widget.quest != null) {

      _quest = widget.quest!;

    } else if (widget.questId != null) {

      _loadQuestFromDatabase();

    } else {

      // Handle error case - no quest provided

      _quest = Quest(

        id: 'error',

        title: 'Quest Not Found',

        description: 'The quest you are looking for does not exist.',

        type: QuestType.custom,

        xpReward: 0,

        statBonus: 0,

        icon: Icons.error,

        gradientColors: [Colors.grey, Colors.grey],

      );

    }

  }



  Future<void> _loadQuestFromDatabase() async {

    // If quest is already passed, use it directly
    if (widget.quest != null) {

      print('DEBUG: QuestDetails - Using passed quest: ${widget.quest!.title}');

      setState(() {

        _quest = widget.quest!;

        _isLoading = false;

      });

      return;

    }

    // Otherwise, try to load by ID
    if (widget.questId == null) return;

    

    print('DEBUG: QuestDetails - Loading quest with ID: ${widget.questId}');

    setState(() {

      _isLoading = true;

    });



    try {

      // Try to load from Firestore first

      print('DEBUG: QuestDetails - Trying Firestore first...');

      final quest = await _questServiceFirestore.getQuestById(widget.questId!);

      if (quest != null) {

        print('DEBUG: QuestDetails - Quest found in Firestore: ${quest.title}');

        setState(() {

          _quest = quest;

          _isLoading = false;

        });

      } else {

        print('DEBUG: QuestDetails - Quest not found in Firestore, trying Realtime Database...');

        // Fallback to Realtime Database if not found in Firestore

        final fallbackQuest = await _questService.getQuestById(widget.questId!);

        if (fallbackQuest != null) {

          print('DEBUG: QuestDetails - Quest found in Realtime Database: ${fallbackQuest.title}');

          setState(() {

            _quest = fallbackQuest;

            _isLoading = false;

          });

        } else {

          print('DEBUG: QuestDetails - Quest not found anywhere');

          // Quest not found

          setState(() {

            _quest = Quest(

              id: widget.questId!,

              title: 'Quest Not Found',

              description: 'The quest you are looking for does not exist.',

              type: QuestType.custom,

              xpReward: 0,

              statBonus: 0,

              icon: Icons.error,

              gradientColors: [Colors.grey, Colors.grey],

            );

          });

        }

      }

    } catch (e) {

      print('DEBUG: QuestDetails - Error loading quest: $e');

      setState(() {

        _quest = Quest(

          id: widget.questId!,

          title: 'Error Loading Quest',

          description: 'Failed to load quest details. Please try again.',

          type: QuestType.custom,

          xpReward: 0,

          statBonus: 0,

          icon: Icons.error,

          gradientColors: [Colors.red, Colors.orange],

        );

      });

    } finally {

      setState(() {

        _isLoading = false;

      });

    }
  }
  
  void _completeQuest() {
    showDialog(
      context: context,
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
              // Success Animation Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientHard,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.highlightGold.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
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
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Title with gradient effect
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
                  'Quest Completed!',
                  style: const TextStyle(
                    fontSize: 22,
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
                ),
              ),
              const SizedBox(height: 16),
              // Quest title
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
                  _quest.title,
                  style: AppTextStyles.subheading.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              // Rewards Section
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
                      'Rewards Earned',
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
                        _buildRewardItem(
                          icon: Icons.stars,
                          value: '+${_quest.xpReward}',
                          label: 'XP',
                          color: AppColors.highlightGold,
                        ),
                        _buildRewardItem(
                          icon: Icons.favorite,
                          value: '+${_quest.statBonus}',
                          label: 'Health',
                          color: AppColors.accentGreen,
                        ),
                        _buildRewardItem(
                          icon: Icons.monetization_on,
                          value: '+${_quest.goldReward}',
                          label: 'Gold',
                          color: AppColors.highlightGold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Awesome Button
              Container(
                width: double.infinity,
                height: AppSizes.buttonHeight,
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
                  onPressed: () async {
                    Navigator.pop(context);
                    
                    // Update quest in Firestore
                    try {
                      final questService = QuestServiceFirestore();
                      await questService.updateQuestStatus(_quest.id, true);
                      
                      // Update user stats
                      final dataService = DataService();
                      final currentUser = dataService.currentUser!;
                      
                      await dataService.updateUserStats(
                        currentXP: currentUser.currentXP + _quest.xpReward,
                        goldCoins: currentUser.goldCoins + _quest.goldReward,
                        health: currentUser.health + _quest.statBonus,
                        // Update level if needed
                        level: (currentUser.currentXP + _quest.xpReward) >= currentUser.xpForNextLevel 
                            ? currentUser.level + 1 
                            : currentUser.level,
                        xpForNextLevel: (currentUser.currentXP + _quest.xpReward) >= currentUser.xpForNextLevel 
                            ? (currentUser.level + 1) * 100 
                            : currentUser.xpForNextLevel,
                      );
                      
                      // Refresh data
                      await dataService.refreshData();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                const Text('Quest completed! Rewards added.'),
                              ],
                            ),
                            backgroundColor: AppColors.accentGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        Navigator.pop(context, true);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.error, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text('Error completing quest: $e'),
                              ],
                            ),
                            backgroundColor: AppColors.errorRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
            ],
          ),
        ),
      ),
    );
  }
  
  void _deleteQuest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.whiteBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Quest?'),
        content: const Text('Are you sure you want to delete this quest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _questServiceFirestore.deleteQuest(_quest.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Quest deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting quest: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.highlightGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }





  Widget _buildTag({

    required IconData icon,

    required String text,

    required List<Color> gradientColors, // sirf colors list chahiye

  }) {

    final gradient = LinearGradient(colors: gradientColors);



    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),

      decoration: BoxDecoration(

        gradient: gradient,

        borderRadius: BorderRadius.circular(30),

        border: Border.all(

          color: gradientColors.first.withOpacity(0.5),

          width: 1.5,

        ),

      ),

      child: Row(

        mainAxisSize: MainAxisSize.min,

        children: [



          Icon(icon, size: 18, color: Colors.white),

          const SizedBox(width: 6),

          Text(

            text,

            style: const TextStyle(

              fontSize: 13,

              fontWeight: FontWeight.bold,

              color: Colors.white,

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildInfoCard({

    required String title,

    required IconData icon,

    required Widget child,

  }) {

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: AppColors.whiteBackground,

        borderRadius: BorderRadius.circular(AppSizes.radius),

        boxShadow: AppShadows.cardShadow,

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Icon(icon, color: AppColors.primaryPurple, size: 24),

              const SizedBox(width: 12),

              Text(

                title,

                style: AppTextStyles.subheading.copyWith(fontSize: 18),

              ),

            ],

          ),

          const SizedBox(height: 16),

          child,

        ],

      ),

    );

  }



  Widget _buildRewardColumn({

    required IconData icon,

    required String value,

    required String label,

    required Color color,

  }) {

    return Column(

      children: [

        Container(

          width: 60,

          height: 60,

          decoration: BoxDecoration(

            color: color.withOpacity(0.15),

            shape: BoxShape.circle,

          ),

          child: Icon(icon, color: color, size: 30),

        ),

        const SizedBox(height: 8),

        Text(

          value,

          style: TextStyle(

            fontSize: 20,

            fontWeight: FontWeight.bold,

            color: color,

          ),

        ),

        Text(

          label,

          style: AppTextStyles.caption.copyWith(fontSize: 12),

        ),

      ],

    );

  }



  Widget _buildRewardItem({

    required IconData icon,

    required String value,

    required String label,

    required Color color,

  }) {

    return Column(

      children: [

        Icon(icon, color: color, size: 32),

        const SizedBox(height: 4),

        Text(

          value,

          style: TextStyle(

            fontSize: 18,

            fontWeight: FontWeight.bold,

            color: color,

          ),

        ),

        Text(

          label,

          style: AppTextStyles.caption,

        ),

      ],

    );

  }











  @override

  Widget build(BuildContext context) {

    if (_isLoading) {

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

                'Loading Quest...',

                style: AppTextStyles.bodyDark,

              ),

            ],

          ),

        ),

      );

    }



    return

      Scaffold(

        backgroundColor: AppColors.lightBackground,

        body: CustomScrollView(

          slivers: [



            //AppBar

            SliverAppBar(

              expandedHeight: 200,

              pinned: true,

              backgroundColor: Colors.transparent,

              leading: IconButton(

                icon: const Icon(Icons.arrow_back, color: Colors.white),

                onPressed: () => Navigator.pop(context),

              ),

              actions: [

                Container(

                  decoration: BoxDecoration(

                    color: Colors.white.withOpacity(0.1),

                    shape: BoxShape.circle,

                  ),

                  child: IconButton(onPressed: (){

                    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditQuestScreen(quest: _quest,)));

                  },

                    icon: const Icon(

                      Icons.edit,

                      color: Colors.white,

                      size: 20,

                    ),





                  ),

                ),

                SizedBox(width: 10,),

                Container(

                  decoration: BoxDecoration(

                    color: Colors.white.withOpacity(0.1),

                    shape: BoxShape.circle,

                  ),

                  child: IconButton(

                    icon: const Icon(

                      Icons.delete,

                      color: Colors.white,

                      size: 20,

                    ),

                    onPressed: _deleteQuest,

                  ),

                ),

                SizedBox(width: 10,),

              ],

              flexibleSpace: FlexibleSpaceBar(

                background: Container(

                  decoration: BoxDecoration(

                    gradient: LinearGradient(

                      colors: _quest.gradientColors,

                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,

                    ),

                    borderRadius: BorderRadius.only(

                      bottomRight: Radius.circular(40),

                      bottomLeft: Radius.circular(40),

                    ),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black38.withOpacity(0.1),

                        spreadRadius: 5,

                        blurRadius: 15,

                        offset: Offset(0, 4),

                      ),

                    ],



                  ),

                  child: Center(

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        SizedBox(height: 40),

                        Container(

                          width: 100,

                          height: 100,

                          decoration: BoxDecoration(

                            color: Colors.white.withOpacity(0.1),

                            shape: BoxShape.circle,

                          ),

                          child: Icon(

                            _quest.icon, size: 60,

                            color: Colors.white,

                          ),

                        )

                      ],

                    ),

                  ),

                ),

              ),



            ),

            SliverToBoxAdapter(



              child: Padding(

                padding: const EdgeInsets.all(24),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // Title

                    Text(

                      _quest.title,

                      style: AppTextStyles.heading.copyWith(fontSize: 28),

                    ),

                    const SizedBox(height: 12),



                    // Tags

                    Wrap(

                      spacing: 8,

                      runSpacing: 8,

                      children: [

                        _buildTag(

                          icon: Icons.whatshot,

                          text: _quest.difficultyText,

                          gradientColors: _quest.gradientColors,



                        ),

                        if (_quest.isDaily)

                          _buildTag(

                            icon: Icons.repeat,

                            text: 'Daily Quest',

                            gradientColors: _quest.gradientColors,

                          ),



                        if (_quest.duration != null)

                          _buildTag(

                            icon: Icons.timer,

                            text: '${_quest.duration} minutes',

                            gradientColors: _quest.gradientColors,

                          ),

                      ],

                    ),

                    const SizedBox(height: 24),



                    // Description Card

                    _buildInfoCard(

                      title: 'Description',

                      icon: Icons.description,

                      child: Text(

                        _quest.description,

                        style: AppTextStyles.body.copyWith(

                          fontSize: 16,

                          height: 1.6,

                        ),

                      ),

                    ),

                    const SizedBox(height: 16),



                    // Rewards Card

                    _buildInfoCard(

                      title: 'Rewards',

                      icon: Icons.card_giftcard,

                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [

                          _buildRewardColumn(

                            icon: Icons.stars,

                            value: '${_quest.xpReward}',

                            label: 'XP',

                            color: AppColors.highlightGold,

                          ),

                          _buildRewardColumn(

                            icon: Icons.favorite,

                            value: '${_quest.statBonus}',

                            label: 'Stats',

                            color: AppColors.accentGreen,

                          ),

                          _buildRewardColumn(

                            icon: Icons.monetization_on,

                            value: '${_quest.goldReward}',

                            label: 'Gold',

                            color: AppColors.highlightGold,

                          ),

                        ],

                      ),

                    ),

                    const SizedBox(height: 16),



                    // Progress Card

                    if (!_quest.isCompleted)

                      _buildInfoCard(

                        title: 'Progress Tracker',

                        icon: Icons.trending_up,

                        child: Column(

                          children: [

                            Row(

                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [

                                Text(

                                  _isTimerRunning ? 'In Progress...' : 'Not Started',

                                  style: AppTextStyles.bodyDark.copyWith(

                                    fontWeight: FontWeight.bold,

                                  ),

                                ),

                                Text(

                                  '${(_elapsedSeconds / 60).floor()} min',

                                  style: AppTextStyles.bodyDark.copyWith(

                                    fontWeight: FontWeight.bold,

                                    color: AppColors.primaryPurple,

                                  ),

                                ),

                              ],

                            ),

                            const SizedBox(height: 12),

                            ClipRRect(

                              borderRadius: BorderRadius.circular(8),

                              child: LinearProgressIndicator(

                                value: _quest.duration != null

                                    ? (_elapsedSeconds / (_quest.duration! * 60)).clamp(0.0, 1.0)

                                    : 0.0,

                                minHeight: 12,

                                backgroundColor: AppColors.lightBackground,

                                valueColor: AlwaysStoppedAnimation<Color>(

                                  AppColors.primaryPurple,



                                ),

                              ),

                            ),

                          ],

                        ),

                      ),

                    const SizedBox(height: 20),

                    if (!_quest.isCompleted)

                      Align(

                        alignment: Alignment.bottomCenter,

                        child: Container(

                          width: double.infinity,

                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24 + 34), // 34 for safe area

                          decoration: BoxDecoration(

                            gradient: LinearGradient(

                              begin: Alignment.topCenter,

                              end: Alignment.bottomCenter,

                              colors: [

                                Colors.transparent,

                                Colors.black.withOpacity(0.05),

                                Colors.black.withOpacity(0.15),

                              ],

                            ),

                          ),

                          child: SizedBox(

                            height: AppSizes.buttonHeight,

                            child: ElevatedButton(

                              onPressed: _completeQuest,

                              style: ElevatedButton.styleFrom(

                                backgroundColor: _quest.gradientColors.first,

                                foregroundColor: Colors.white,

                                shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),

                                ),

                                elevation: 8,

                                shadowColor: AppColors.primaryPurple.withOpacity(0.4),

                              ),

                              child: Row(

                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [

                                  const Icon(Icons.check_circle, size: 26),

                                  const SizedBox(width: 12),

                                  Text(

                                    'Complete Quest',

                                    style: AppTextStyles.button.copyWith(

                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,

                                    ),

                                  ),

                                ],

                              ),

                            ),

                          ),

                        ),

                      ),



                  ],

                ),

              ),

            ),



          ],

        ),





        // Bottom Action Button





      );

  }





}

