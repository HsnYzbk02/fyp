import 'package:hive/hive.dart';

part 'recovery_record.g.dart';

enum RecoveryStatus { optimal, good, moderate, poor }

@HiveType(typeId: 1)
class RecoveryRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double overallScore; // 0–100

  @HiveField(3)
  final double sleepQuality; // 0–100 (from HealthKit sleep data)

  @HiveField(4)
  final double sleepDurationHours;

  @HiveField(5)
  final double hrv; // ms — key Apple Watch metric

  @HiveField(6)
  final double restingHeartRate; // bpm

  @HiveField(7)
  final double hydrationLevel; // 0–100 estimated

  @HiveField(8)
  final List<String> recommendations; // AI-generated

  @HiveField(9)
  final Map<String, double> muscleGroupRecovery;
  // e.g. {"Chest": 75.0, "Legs": 30.0}

  @HiveField(10)
  final String aiSummary; // Short AI-generated text insight

  @HiveField(11)
  final bool notificationSent;

  RecoveryRecord({
    required this.id,
    required this.date,
    required this.overallScore,
    required this.sleepQuality,
    required this.sleepDurationHours,
    required this.hrv,
    required this.restingHeartRate,
    required this.hydrationLevel,
    required this.recommendations,
    required this.muscleGroupRecovery,
    required this.aiSummary,
    this.notificationSent = false,
  });

  RecoveryStatus get status {
    if (overallScore >= 80) return RecoveryStatus.optimal;
    if (overallScore >= 60) return RecoveryStatus.good;
    if (overallScore >= 40) return RecoveryStatus.moderate;
    return RecoveryStatus.poor;
  }

  String get statusLabel {
    switch (status) {
      case RecoveryStatus.optimal:
        return 'Optimal';
      case RecoveryStatus.good:
        return 'Good';
      case RecoveryStatus.moderate:
        return 'Moderate';
      case RecoveryStatus.poor:
        return 'Rest Needed';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'overallScore': overallScore,
        'sleepQuality': sleepQuality,
        'sleepDurationHours': sleepDurationHours,
        'hrv': hrv,
        'restingHeartRate': restingHeartRate,
        'hydrationLevel': hydrationLevel,
        'recommendations': recommendations,
        'muscleGroupRecovery': muscleGroupRecovery,
        'aiSummary': aiSummary,
        'status': statusLabel,
      };
}
