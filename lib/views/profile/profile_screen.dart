import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        final p = vm.profile;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.pencil),
                onPressed: () => _showEditSheet(context, vm),
              ),
            ],
          ),
          body: p == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.person_circle,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No profile set up yet'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _showEditSheet(context, vm),
                        child: const Text('Set Up Profile'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBlue),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(p.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      Text(p.fitnessLevel,
                          style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        children: [
                          _StatCard(label: 'Age', value: '${p.age}'),
                          const SizedBox(width: 12),
                          _StatCard(
                              label: 'Weight',
                              value: '${p.weightKg.toStringAsFixed(0)} kg'),
                          const SizedBox(width: 12),
                          _StatCard(
                              label: 'BMI',
                              value: p.bmi.toStringAsFixed(1)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Goals
                      _InfoSection(
                        title: 'Goals',
                        content: p.primaryGoals.join(' · '),
                      ),

                      const SizedBox(height: 12),

                      // Apple Watch
                      _InfoSection(
                        title: 'Apple Watch',
                        content: p.hasAppleWatch
                            ? '✅ Connected${p.appleWatchModel != null ? " · ${p.appleWatchModel}" : ""}'
                            : '❌ Not Connected',
                      ),

                      const SizedBox(height: 12),

                      _InfoSection(
                        title: 'Sleep Target',
                        content: '${p.targetSleepHours} hours/night',
                      ),

                      const SizedBox(height: 12),

                      _InfoSection(
                        title: 'Daily Water Target',
                        content: '${(p.dailyWaterTargetMl / 1000).toStringAsFixed(1)} L',
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, ProfileViewModel vm) {
    // Simplified — in production, show a full edit form
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Profile Setup'),
        content: const Text(
            'Profile editing UI would go here with full form fields for name, age, weight, height, fitness level, goals, and Apple Watch settings.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  const _InfoSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(content,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
