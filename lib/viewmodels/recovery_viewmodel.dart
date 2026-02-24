import 'package:flutter/foundation.dart';
import '../services/health_service.dart';
import '../services/ai_recommendation_service.dart';

class RecoveryViewModel extends ChangeNotifier {
  HealthService _healthService;
  final AIRecommendationService _aiService = AIRecommendationService();

  bool isLoading = false;
  RecoveryRecommendation? recommendation;
  Map<String, double> muscleRecovery = {};
  List<Map<String, dynamic>> weeklyScores = [];

  RecoveryViewModel(this._healthService);

  void updateHealthService(HealthService hs) {
    _healthService = hs;
  }

  Future<void> loadRecoveryDetails() async {
    isLoading = true;
    notifyListeners();

    final score = await _healthService.calculateRecoveryScore();
    final hrv = await _healthService.getLatestHRV() ?? 50.0;
    final rhr = await _healthService.getRestingHeartRate() ?? 65.0;
    final sleep = await _healthService.getLastNightSleep();

    recommendation = await _aiService.generateRecommendation(
      recoveryScore: score,
      hrv: hrv,
      restingHR: rhr,
      sleepData: sleep,
      recentWorkouts: [],
      fitnessLevel: 'Intermediate',
      goals: ['Build Muscle'],
    );

    if (recommendation != null) {
      muscleRecovery = Map<String, double>.from(
        recommendation!.muscleRecoveryEstimate
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
    }

    isLoading = false;
    notifyListeners();
  }

  String getMuscleStatus(double value) {
    if (value >= 80) return 'Recovered';
    if (value >= 60) return 'Recovering';
    if (value >= 40) return 'Fatigued';
    return 'Very Fatigued';
  }
}
