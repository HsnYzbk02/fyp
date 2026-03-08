import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_recovery_fyp/models/workout_session.dart';

void main() {
  test('fatigueScore stays in valid range and increases with intensity', () {
    final lowIntensity = WorkoutSession(
      id: '1',
      timestamp: DateTime(2026, 1, 1),
      workoutType: 'Yoga',
      durationMinutes: 20,
      averageHeartRate: 90,
      maxHeartRate: 110,
      caloriesBurned: 120,
      muscleGroupsWorked: const ['Core'],
      perceivedExertion: 2,
      source: 'manual',
    );

    final highIntensity = WorkoutSession(
      id: '2',
      timestamp: DateTime(2026, 1, 1),
      workoutType: 'HIIT',
      durationMinutes: 75,
      averageHeartRate: 180,
      maxHeartRate: 195,
      caloriesBurned: 900,
      hrv: 30,
      muscleGroupsWorked: const ['Full Body'],
      perceivedExertion: 9,
      source: 'manual',
    );

    expect(lowIntensity.fatigueScore, inInclusiveRange(0, 100));
    expect(highIntensity.fatigueScore, inInclusiveRange(0, 100));
    expect(highIntensity.fatigueScore, greaterThan(lowIntensity.fatigueScore));
  });
}
