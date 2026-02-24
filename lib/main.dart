import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/workout_session.dart';
import 'models/recovery_record.dart';
import 'models/user_profile.dart';
import 'services/health_service.dart';
import 'services/notification_service.dart';
import 'services/watch_service.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/recovery_viewmodel.dart';
import 'viewmodels/workout_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'theme/app_theme.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/home/main_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local database
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutSessionAdapter());
  Hive.registerAdapter(RecoveryRecordAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  await Hive.openBox<WorkoutSession>('workouts');
  await Hive.openBox<RecoveryRecord>('recovery_records');
  await Hive.openBox<UserProfile>('user_profile');
  await Hive.openBox('settings');

  // Initialize services
  await NotificationService.instance.initialize();

  runApp(const MuscleRecoveryApp());
}

class MuscleRecoveryApp extends StatelessWidget {
  const MuscleRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HealthService>(create: (_) => HealthService()),
        Provider<WatchService>(create: (_) => WatchService()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProxyProvider<HealthService, DashboardViewModel>(
          create: (ctx) => DashboardViewModel(ctx.read<HealthService>()),
          update: (ctx, health, vm) => vm!..updateHealthService(health),
        ),
        ChangeNotifierProxyProvider<HealthService, RecoveryViewModel>(
          create: (ctx) => RecoveryViewModel(ctx.read<HealthService>()),
          update: (ctx, health, vm) => vm!..updateHealthService(health),
        ),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
      ],
      child: MaterialApp(
        title: 'MuscleRecovery AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: _LandingRouter(),
      ),
    );
  }
}

class _LandingRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Hive.box('settings');
    final hasOnboarded = settings.get('has_onboarded', defaultValue: false);
    return hasOnboarded ? const MainNavScreen() : const OnboardingScreen();
  }
}
