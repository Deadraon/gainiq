import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import '../workout/workout_list_screen.dart';
import '../diet/diet_plan_screen.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Keep pages inside build() so they're always in sync with nav items
    final pages = [
      const HomeScreen(),
      const WorkoutListScreen(),
      const DietPlanScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bolt_fill),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.leaf_arrow_circlepath),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_square),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
