import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

/// HealthService wraps Apple HealthKit via the `health` package.
/// On iOS this reads real Apple Watch data: HRV, heart rate, sleep, steps, etc.
class HealthService {
  final Health _health = Health();

  static final List<HealthDataType> _readTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN, // Key metric from Apple Watch
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.WATER,
    HealthDataType.RESPIRATORY_RATE,
  ];

  bool _authorized = false;
  bool get isAuthorized => _authorized;

  Future<bool> requestAuthorization() async {
    try {
      _authorized = await _health.requestAuthorization(_readTypes);
      debugPrint('[HealthService] Authorization: $_authorized');
      return _authorized;
    } catch (e) {
      debugPrint('[HealthService] Authorization error: $e');
      return false;
    }
  }

  // ── Heart Rate ──────────────────────────────────────────────────────────────

  Future<double?> getLatestHeartRate() async {
    return _getLatestDoubleValue(HealthDataType.HEART_RATE);
  }

  Future<double?> getRestingHeartRate() async {
    return _getLatestDoubleValue(HealthDataType.RESTING_HEART_RATE);
  }

  Future<List<HealthDataPoint>> getHeartRateHistory({int days = 7}) async {
    return _getHistory(HealthDataType.HEART_RATE, days: days);
  }

  // ── HRV (Heart Rate Variability) ────────────────────────────────────────────
  // Apple Watch measures SDNN in milliseconds — higher = better recovery

  Future<double?> getLatestHRV() async {
    return _getLatestDoubleValue(HealthDataType.HEART_RATE_VARIABILITY_SDNN);
  }

  Future<List<HealthDataPoint>> getHRVHistory({int days = 14}) async {
    return _getHistory(HealthDataType.HEART_RATE_VARIABILITY_SDNN, days: days);
  }

  // ── Sleep ───────────────────────────────────────────────────────────────────

  Future<Map<String, double>> getLastNightSleep() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    final data = await _health.getHealthDataFromTypes(
      startTime: yesterday,
      endTime: now,
      types: [
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
      ],
    );

    double totalMinutes = 0;
    double deepMinutes = 0;
    double remMinutes = 0;

    for (final point in data) {
      final minutes =
          point.dateTo.difference(point.dateFrom).inMinutes.toDouble();
      if (point.type == HealthDataType.SLEEP_ASLEEP) totalMinutes += minutes;
      if (point.type == HealthDataType.SLEEP_DEEP) deepMinutes += minutes;
      if (point.type == HealthDataType.SLEEP_REM) remMinutes += minutes;
    }

    final quality = _calculateSleepQuality(
      totalMinutes: totalMinutes,
      deepMinutes: deepMinutes,
      remMinutes: remMinutes,
    );

    return {
      'totalHours': totalMinutes / 60,
      'deepMinutes': deepMinutes,
      'remMinutes': remMinutes,
      'qualityScore': quality,
    };
  }

  double _calculateSleepQuality({
    required double totalMinutes,
    required double deepMinutes,
    required double remMinutes,
  }) {
    double score = 0;
    // Duration score (target 8h = 480 min)
    score += (totalMinutes / 480).clamp(0.0, 1.0) * 40;
    // Deep sleep (target 90 min = 20% of sleep)
    score += (deepMinutes / 90).clamp(0.0, 1.0) * 30;
    // REM sleep (target 90–120 min)
    score += (remMinutes / 100).clamp(0.0, 1.0) * 30;
    return score.clamp(0.0, 100.0);
  }

  // ── Steps & Activity ────────────────────────────────────────────────────────

  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final steps = await _health.getTotalStepsInInterval(midnight, now);
    return steps ?? 0;
  }

  Future<double?> getBloodOxygen() async {
    return _getLatestDoubleValue(HealthDataType.BLOOD_OXYGEN);
  }

  // ── Recent Workouts ─────────────────────────────────────────────────────────

  Future<List<HealthDataPoint>> getRecentWorkouts({int days = 7}) async {
    return _getHistory(HealthDataType.WORKOUT, days: days);
  }

  // ── Recovery Score Calculation ──────────────────────────────────────────────
  /// Combines HRV, sleep, and resting HR into a 0–100 recovery score.
  Future<double> calculateRecoveryScore() async {
    double score = 0;

    // HRV contribution (40%)
    final hrv = await getLatestHRV();
    if (hrv != null) {
      // Healthy HRV range: 20–80ms; >60 is very good
      final hrvScore = (hrv / 80).clamp(0.0, 1.0);
      score += hrvScore * 40;
    } else {
      score += 20; // neutral if no data
    }

    // Sleep contribution (40%)
    final sleep = await getLastNightSleep();
    score += (sleep['qualityScore'] ?? 0) * 0.40;

    // Resting HR contribution (20%) — lower is better (45–60 is athletic)
    final rhr = await getRestingHeartRate();
    if (rhr != null) {
      final rhrScore = rhr <= 60
          ? 1.0
          : rhr <= 80
              ? (80 - rhr) / 20
              : 0.0;
      score += rhrScore * 20;
    } else {
      score += 10;
    }

    return score.clamp(0.0, 100.0);
  }

  // ── Private Helpers ─────────────────────────────────────────────────────────

  Future<double?> _getLatestDoubleValue(HealthDataType type) async {
    final now = DateTime.now();
    final from = now.subtract(const Duration(hours: 24));
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: from,
        endTime: now,
        types: [type],
      );
      if (data.isEmpty) return null;
      data.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final val = data.first.value;
      if (val is NumericHealthValue) return val.numericValue.toDouble();
      return null;
    } catch (e) {
      debugPrint('[HealthService] Error fetching $type: $e');
      return null;
    }
  }

  Future<List<HealthDataPoint>> _getHistory(
    HealthDataType type, {
    int days = 7,
  }) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days));
    try {
      return await _health.getHealthDataFromTypes(
        startTime: from,
        endTime: now,
        types: [type],
      );
    } catch (e) {
      debugPrint('[HealthService] Error fetching history $type: $e');
      return [];
    }
  }
}
