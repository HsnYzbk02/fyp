import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recovery_record.dart';
import '../models/workout_session.dart';
import '../services/health_service.dart';
import '../services/ai_recommendation_service.dart';

class DashboardViewModel extends ChangeNotifier {
  HealthService _healthService;
  final AIRecommendationService _aiService = AIRecommendationService();

  bool isLoading = false;
  String? errorMessage;

  double recoveryScore = 0;
  double? hrv;
  double? restingHR;
  double? latestHeartRate;
  int todaySteps = 0;
  Map<String, double> sleepData = {};
  RecoveryRecommendation? todayRecommendation;
  List<WorkoutSession> recentWorkouts = [];
  String recoveryStatusLabel = 'Loading...';

  DashboardViewModel(this._healthService) {
    // loadDashboard(); // Comment out to prevent crash
  }

  void updateHealthService(HealthService hs) {
    _healthService = hs;
  }

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Request HealthKit auth if needed
      await _healthService.requestAuthorization();

      // Fetch all data in parallel
      final results = await Future.wait([
        _healthService.calculateRecoveryScore(),
        _healthService.getLatestHRV(),
        _healthService.getRestingHeartRate(),
        _healthService.getLatestHeartRate(),
        _healthService.getTodaySteps(),
        _healthService.getLastNightSleep(),
      ]);

      recoveryScore = results[0] as double;
      hrv = results[1] as double?;
      restingHR = results[2] as double?;
      latestHeartRate = results[3] as double?;
      todaySteps = results[4] as int;
      sleepData = results[5] as Map<String, double>;

      // Load recent workouts from local storage
      final workoutsBox = Hive.box<WorkoutSession>('workouts');
      recentWorkouts = workoutsBox.values
          .toList()
          .reversed
          .take(10)
          .toList()
          .cast<WorkoutSession>();

      // Set recovery status label
      recoveryStatusLabel = _getStatusLabel(recoveryScore);

      // Generate AI recommendation
      todayRecommendation = await _aiService.generateRecommendation(
        recoveryScore: recoveryScore,
        hrv: hrv ?? 50.0,
        restingHR: restingHR ?? 65.0,
        sleepData: sleepData,
        recentWorkouts: recentWorkouts,
        fitnessLevel: 'Intermediate',
        goals: ['Build Muscle', 'Improve Recovery'],
      );

      // Save today's recovery record
      _saveRecoveryRecord();
    } catch (e) {
      errorMessage =
          'Could not load health data. Make sure Apple Watch is paired.';
      debugPrint('[Dashboard] Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void _saveRecoveryRecord() {
    if (todayRecommendation == null) return;
    final box = Hive.box<RecoveryRecord>('recovery_records');
    final record = RecoveryRecord(
      id: DateTime.now().toIso8601String(),
      date: DateTime.now(),
      overallScore: recoveryScore,
      sleepQuality: sleepData['qualityScore'] ?? 0,
      sleepDurationHours: sleepData['totalHours'] ?? 0,
      hrv: hrv ?? 0,
      restingHeartRate: restingHR ?? 0,
      hydrationLevel: 70,
      recommendations: todayRecommendation!.recommendations
          .map((r) => r['title'] as String)
          .toList(),
      muscleGroupRecovery: Map<String, double>.from(
        todayRecommendation!.muscleRecoveryEstimate
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      aiSummary: todayRecommendation!.summary,
    );
    box.add(record);
  }

  String _getStatusLabel(double score) {
    if (score >= 80) return 'Optimal';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Moderate';
    return 'Rest Needed';
  }

  List<RecoveryRecord> getRecoveryHistory({int days = 14}) {
    final box = Hive.box<RecoveryRecord>('recovery_records');
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return box.values.where((r) => r.date.isAfter(cutoff)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
