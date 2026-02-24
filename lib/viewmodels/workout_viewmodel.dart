import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_session.dart';

class WorkoutViewModel extends ChangeNotifier {
  final _uuid = const Uuid();
  List<WorkoutSession> sessions = [];
  bool isLoading = false;

  WorkoutViewModel() {
    loadWorkouts();
  }

  void loadWorkouts() {
    final box = Hive.box<WorkoutSession>('workouts');
    sessions = box.values.toList().reversed.toList().cast<WorkoutSession>();
    notifyListeners();
  }

  Future<void> logManualWorkout({
    required String workoutType,
    required int durationMinutes,
    required double avgHeartRate,
    required double maxHeartRate,
    required double calories,
    required List<String> muscleGroups,
    required int perceivedExertion,
    double? hrv,
  }) async {
    final session = WorkoutSession(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      workoutType: workoutType,
      durationMinutes: durationMinutes,
      averageHeartRate: avgHeartRate,
      maxHeartRate: maxHeartRate,
      caloriesBurned: calories,
      hrv: hrv,
      muscleGroupsWorked: muscleGroups,
      perceivedExertion: perceivedExertion,
      source: 'manual',
    );

    final box = Hive.box<WorkoutSession>('workouts');
    await box.add(session);
    loadWorkouts();
  }

  static const List<String> workoutTypes = [
    'Running', 'Cycling', 'Swimming', 'Weightlifting', 'HIIT',
    'CrossFit', 'Yoga', 'Pilates', 'Basketball', 'Football',
    'Tennis', 'Boxing', 'Rock Climbing', 'Rowing', 'Jump Rope',
  ];

  static const List<String> muscleGroups = [
    'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps',
    'Forearms', 'Core', 'Quads', 'Hamstrings', 'Glutes',
    'Calves', 'Hip Flexors', 'Full Body',
  ];
}
