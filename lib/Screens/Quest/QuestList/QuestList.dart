// screens/quest/quest_list_screen.dart



import 'package:flutter/material.dart';

import 'package:goal_play/Screens/Models/Quest/QuestClass.dart';

import 'package:goal_play/Screens/Quest/CreateQuest/CreateQuest.dart';

import 'package:goal_play/Screens/Quest/QuestDetails/QuestDetails.dart';

import 'package:goal_play/Screens/Utils/Constants/Constants.dart';

import 'package:goal_play/Screens/Widgets/QuestCard/questCard.dart';

import 'package:goal_play/Services/QuestServices/QuestServiceFirestore.dart';

import 'package:goal_play/Services/DataService/DataService.dart';




class QuestListScreen extends StatefulWidget {

  const QuestListScreen({Key? key}) : super(key: key);



  @override

  State<QuestListScreen> createState() => _QuestListScreenState();

}



class _QuestListScreenState extends State<QuestListScreen>

    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  int _selectedTabIndex = 0;

  bool _isLoading = true;

  final DataService _dataService = DataService();


  @override

  void initState() {

    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _loadQuests();

  }


  void _loadQuests() {

    setState(() {

      _isLoading = true;

    });

    // Check if DataService is initialized
    if (_dataService.isInitialized) {

      setState(() {

        _isLoading = false;

      });

    } else {

      // Wait a moment and try again
      Future.delayed(Duration(milliseconds: 500), () {

        _loadQuests();

      });

    }

  }



  @override

  void dispose() {

    _tabController.dispose();

    super.dispose();

  }

  List<Quest> _getSelectedQuests() {
    switch (_selectedTabIndex) {
      case 0:
        return _dataService.allQuests;
      case 1:
        return _dataService.allQuests.where((q) => !q.isCompleted).toList();
      case 2:
        return _dataService.allQuests.where((q) => q.isCompleted).toList();
      default:
        return _dataService.allQuests;
    }
  }

// header section

  Widget _buildHeader() {

    return Padding(

      padding: const EdgeInsets.only(left: 10, right: 10),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            'Quest Log',style: AppTextStyles.screenHeading,

          ),

          SizedBox(height: 10,),

          TextField(

            decoration: InputDecoration(

              hintText: 'Search quest',

              hintStyle: TextStyle(

                color: AppColors.textGray,

              ),



              prefixIcon: Icon(

                Icons.search,

                color: AppColors.textGray,

              ),

              filled: true,

              fillColor: AppColors.lightPurple,





              contentPadding: const EdgeInsets.symmetric(

                vertical: 14,

                horizontal: 20,

              ),

              enabledBorder: OutlineInputBorder(

                borderRadius: BorderRadius.circular(10),

                borderSide: BorderSide(

                  color: AppColors.strokeColor,

                  width: 1,

                ),

              ),



              focusedBorder: OutlineInputBorder(

                borderRadius: BorderRadius.circular(10),

                borderSide: BorderSide(

                  color: AppColors.strokeColor,

                  width: 1.5,

                ),

              ),

            ),

          )





        ],

      ),

    );

  }





  Widget _buildTabBar() {

    return Padding(

      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),

      child: Container(

        child: Row(

          children: [

            // All Quest Button

            Expanded(

              child: _buildTabButton(

                title: "All Quest",

                count: _dataService.allQuests.length,

                isSelected: _selectedTabIndex == 0,

                onTap: () {

                  setState(() {

                    _selectedTabIndex = 0;

                    _tabController.index = 0;

                  });

                },

              ),

            ),

            const SizedBox(width: 8),



            // Active Button

            Expanded(

              child: _buildTabButton(

                title: "Active",

                count: _dataService.allQuests.where((q) => !q.isCompleted).length,

                isSelected: _selectedTabIndex == 1,

                onTap: () {

                  setState(() {

                    _selectedTabIndex = 1;

                    _tabController.index = 1;

                  });

                },

              ),

            ),

            const SizedBox(width: 8),



            // completed Button

            Expanded(

              child: _buildTabButton(

                title: "completed",

                count: _dataService.allQuests.where((q) => q.isCompleted).length,

                isSelected: _selectedTabIndex == 2,

                onTap: () {

                  setState(() {

                    _selectedTabIndex = 2;

                    _tabController.index = 2;

                  });

                },

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildTabButton({

    required String title,

    required int count,

    required bool isSelected,

    required VoidCallback onTap,

  }) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: const EdgeInsets.symmetric(vertical: 12),

        decoration: BoxDecoration(

          gradient: isSelected

              ? AppGradients.secondaryPurple

              : null,

          color: isSelected ? null : AppColors.lightBackgroundBox,

          borderRadius: BorderRadius.circular(12),

        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Text(

                title,

                style: isSelected? AppTextStyles.tabSelected: AppTextStyles.tabUnselected

            ),

            const SizedBox(height: 4),

            Text(

                count.toString(),

                style: isSelected? AppTextStyles.tabSelected : AppTextStyles.tabUnselected



            ),

          ],

        ),

      ),

    );

  }



// quest card section

  Widget _buildQuestList(List<Quest> quests) {

    if (quests.isEmpty) {

      return Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(

              Icons.inbox_outlined,

              size: 80,

              color: AppColors.textGray.withOpacity(0.3),

            ),

            const SizedBox(height: 16),

            Text(

              'No quests here',

              style: AppTextStyles.subheading.copyWith(

                color: AppColors.textGray,

              ),

            ),

            const SizedBox(height: 8),

            Text(

              'Create your first quest to get started!',

              style: AppTextStyles.body,

            ),

          ],

        ),

      );

    }



    return ListView.builder(

      padding: const EdgeInsets.all(16),

      itemCount: _getSelectedQuests().length,

      itemBuilder: (context, index) {

        final quest = _getSelectedQuests()[index];

        return QuestCard(

          quest: quest,

          onTap: () async {

            final result = await Navigator.push(

              context,

              MaterialPageRoute(

                builder: (context) => QuestDetailScreen(quest: quest),

              ),

            );



            if (result == true) {

              _dataService.refreshData();

            }

          },

        );

      },

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

                'Loading Quests...',

                style: AppTextStyles.bodyDark,

              ),

            ],

          ),

        ),

      );

    }

    return

      Scaffold(

        extendBody: true,

        backgroundColor: AppColors.lightBackground,

        body: SafeArea(

          child: Column(

            children: [



              //header section

              _buildHeader(),

              // Tab Bar

              _buildTabBar(),



              // Tab Views

              Expanded(

                child: TabBarView(

                  controller: _tabController,

                  children: [

                    _buildQuestList(_dataService.allQuests),

                    _buildQuestList(_dataService.allQuests.where((q) => !q.isCompleted).toList()),

                    _buildQuestList(_dataService.allQuests.where((q) => q.isCompleted).toList()),

                  ],

                ),

              ),

            ],

          ),

        ),





        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,



        floatingActionButton: Padding(

          padding: const EdgeInsets.only(bottom:90),

          child: FloatingActionButton.extended(

            onPressed: () async {
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context)=>CreateQuestScreen())
              );
              
              // Refresh data when user returns from CreateQuest
              if (result == true || mounted) {
                _dataService.refreshData();
                setState(() {});
              }
            },

            backgroundColor: AppColors.primaryPurple,

            icon: Icon(Icons.add,

              color: AppColors.lightBackground,

            ),

            label: Text('New Quest',

              style: AppTextStyles.bodyWhite,

            ),

          ),

        ),

      );

  }













}

