import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../recovery/recovery_screen.dart';
import '../workout/workout_screen.dart';
import '../profile/profile_screen.dart';
import '../../theme/app_theme.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const RecoveryScreen(),
    const WorkoutScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          indicatorColor: AppTheme.primaryBlue.withOpacity(0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(CupertinoIcons.home),
              selectedIcon: Icon(CupertinoIcons.house_fill),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.heart),
              selectedIcon: Icon(CupertinoIcons.heart_fill),
              label: 'Recovery',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.flame),
              selectedIcon: Icon(CupertinoIcons.flame_fill),
              label: 'Workout',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.person),
              selectedIcon: Icon(CupertinoIcons.person_fill),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
