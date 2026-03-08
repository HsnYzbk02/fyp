import 'package:hive/hive.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 0)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String workoutType; // e.g. "Running", "Weightlifting", "HIIT"

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final double averageHeartRate; // bpm

  @HiveField(5)
  final double maxHeartRate;

  @HiveField(6)
  final double caloriesBurned;

  @HiveField(7)
  final double? hrv; // Heart Rate Variability (ms) - from Apple Watch

  @HiveField(8)
  final List<String> muscleGroupsWorked; // ["Chest", "Triceps", "Shoulders"]

  @HiveField(9)
  final int perceivedExertion; // RPE scale 1–10 (user-rated)

  @HiveField(10)
  final double? vo2Max; // from Apple Watch if available

  @HiveField(11)
  final String source; // "apple_watch" | "manual" | "healthkit"

  WorkoutSession({
    required this.id,
    required this.timestamp,
    required this.workoutType,
    required this.durationMinutes,
    required this.averageHeartRate,
    required this.maxHeartRate,
    required this.caloriesBurned,
    this.hrv,
    required this.muscleGroupsWorked,
    required this.perceivedExertion,
    this.vo2Max,
    this.source = 'apple_watch',
  });

  /// Fatigue Score 0–100 calculated from workout intensity markers
  double get fatigueScore {
    double score = 0;

    // Heart rate intensity factor
    final hrIntensity = (averageHeartRate / 200).clamp(0.0, 1.0);
    score += hrIntensity * 30;

    // Duration factor (diminishing returns after 60 min)
    final durationFactor = (durationMinutes / 90).clamp(0.0, 1.0);
    score += durationFactor * 25;

    // RPE factor
    score += (perceivedExertion / 10) * 30;

    // HRV penalty (low HRV = high fatigue)
    if (hrv != null && hrv! < 50) {
      score += ((50 - hrv!) / 50) * 15;
    }

    return score.clamp(0.0, 100.0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'workoutType': workoutType,
        'durationMinutes': durationMinutes,
        'averageHeartRate': averageHeartRate,
        'maxHeartRate': maxHeartRate,
        'caloriesBurned': caloriesBurned,
        'hrv': hrv,
        'muscleGroupsWorked': muscleGroupsWorked,
        'perceivedExertion': perceivedExertion,
        'vo2Max': vo2Max,
        'fatigueScore': fatigueScore,
        'source': source,
      };
}
