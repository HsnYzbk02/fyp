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
  print('Starting main...');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local database
  print('Initializing Hive...');
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutSessionAdapter());
  Hive.registerAdapter(RecoveryRecordAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  await Hive.openBox<WorkoutSession>('workouts');
  await Hive.openBox<RecoveryRecord>('recovery_records');
  await Hive.openBox<UserProfile>('user_profile');
  await Hive.openBox('settings');
  print('Hive initialized');

  // Initialize services
  print('Initializing NotificationService...');
  await NotificationService.instance.initialize();
  print('NotificationService initialized');

  // Set onboarding as complete for testing
  print('Setting onboarding...');
  final settingsBox = await Hive.openBox('settings');
  await settingsBox.put('has_onboarded', true);
  print('Onboarding set');

  print('Running app...');
  runApp(const MuscleRecoveryApp());
}

class MuscleRecoveryApp extends StatelessWidget {
  const MuscleRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building MuscleRecoveryApp...');
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
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: _LandingRouter(),
      ),
    );
  }
}

class _LandingRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Building _LandingRouter...');
    try {
      final settings = Hive.box('settings');
      // settings.put('has_onboarded', true); // Uncomment to force onboarding complete
      final hasOnboarded = settings.get('has_onboarded', defaultValue: false);
      print('hasOnboarded: $hasOnboarded');
      return hasOnboarded ? const MainNavScreen() : const OnboardingScreen();
    } catch (e) {
      print('Error in _LandingRouter: $e');
      return Scaffold(
        body: Center(
          child: Text('Error loading app: $e'),
        ),
      );
    }
  }
}
