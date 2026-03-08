import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final double weightKg;

  @HiveField(3)
  final double heightCm;

  @HiveField(4)
  final String
      fitnessLevel; // "Beginner" | "Intermediate" | "Advanced" | "Athlete"

  @HiveField(5)
  final List<String>
      primaryGoals; // ["Build Muscle", "Lose Weight", "Improve Endurance"]

  @HiveField(6)
  final List<String> favoriteWorkouts;

  @HiveField(7)
  final int targetSleepHours;

  @HiveField(8)
  final bool hasAppleWatch;

  @HiveField(9)
  final String? appleWatchModel; // e.g. "Apple Watch Series 9"

  @HiveField(10)
  final bool notificationsEnabled;

  @HiveField(11)
  final int dailyWaterTargetMl;

  UserProfile({
    required this.name,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.fitnessLevel,
    required this.primaryGoals,
    required this.favoriteWorkouts,
    this.targetSleepHours = 8,
    this.hasAppleWatch = true,
    this.appleWatchModel,
    this.notificationsEnabled = true,
    this.dailyWaterTargetMl = 2500,
  });

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? weightKg,
    double? heightCm,
    String? fitnessLevel,
    List<String>? primaryGoals,
    List<String>? favoriteWorkouts,
    int? targetSleepHours,
    bool? hasAppleWatch,
    String? appleWatchModel,
    bool? notificationsEnabled,
    int? dailyWaterTargetMl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      primaryGoals: primaryGoals ?? this.primaryGoals,
      favoriteWorkouts: favoriteWorkouts ?? this.favoriteWorkouts,
      targetSleepHours: targetSleepHours ?? this.targetSleepHours,
      hasAppleWatch: hasAppleWatch ?? this.hasAppleWatch,
      appleWatchModel: appleWatchModel ?? this.appleWatchModel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyWaterTargetMl: dailyWaterTargetMl ?? this.dailyWaterTargetMl,
    );
  }
}
