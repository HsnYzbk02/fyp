import 'dart:convert';
import 'package:flutter/foundation.dart';

/// WatchService handles bi-directional communication between the iPhone app
/// and the Apple Watch companion app via WatchConnectivity / wearable_communicator.
///
/// iPhone → Watch: Sends recovery status, today's recommendations
/// Watch → iPhone: Sends real-time HR, workout start/stop events
class WatchService {
  // In production, use wearable_communicator package which wraps WatchConnectivity
  // import 'package:wearable_communicator/wearable_communicator.dart';

  bool _isWatchReachable = false;
  bool get isWatchReachable => _isWatchReachable;

  final List<Function(Map<String, dynamic>)> _messageListeners = [];

  WatchService() {
    _initializeWatchConnection();
  }

  void _initializeWatchConnection() {
    // WearableCommunicator.listenToMessages((msg) {
    //   _handleIncomingMessage(msg);
    // });
    debugPrint('[WatchService] Initialized — WatchConnectivity ready');
  }

  // ── Send to Watch ────────────────────────────────────────────────────────────

  /// Sends today's recovery score + top recommendation to the Watch face
  Future<void> sendRecoveryStatusToWatch({
    required double recoveryScore,
    required String statusLabel,
    required String topRecommendation,
    required Map<String, double> muscleStatus,
  }) async {
    final message = {
      'type': 'recovery_update',
      'score': recoveryScore,
      'status': statusLabel,
      'tip': topRecommendation,
      'muscles': muscleStatus,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _sendMessage(message);
    debugPrint('[WatchService] Sent recovery update: $message');
  }

  /// Sends a haptic + notification to Watch when recovery drops critically
  Future<void> sendFatigueAlert({required String message}) async {
    await _sendMessage({
      'type': 'fatigue_alert',
      'message': message,
      'haptic': 'notification',
    });
  }

  /// Pushes workout recommendation to Watch
  Future<void> sendWorkoutSuggestion({
    required String workoutName,
    required String intensity,
    required int durationMinutes,
  }) async {
    await _sendMessage({
      'type': 'workout_suggestion',
      'name': workoutName,
      'intensity': intensity,
      'duration': durationMinutes,
    });
  }

  // ── Receive from Watch ───────────────────────────────────────────────────────

  void addMessageListener(Function(Map<String, dynamic>) listener) {
    _messageListeners.add(listener);
  }

  void removeMessageListener(Function(Map<String, dynamic>) listener) {
    _messageListeners.remove(listener);
  }

  void _handleIncomingMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    debugPrint('[WatchService] Received from Watch: $type');

    switch (type) {
      case 'workout_started':
        _onWorkoutStarted(message);
        break;
      case 'workout_ended':
        _onWorkoutEnded(message);
        break;
      case 'heart_rate_update':
        _onHeartRateUpdate(message);
        break;
      case 'hrv_reading':
        _onHRVReading(message);
        break;
      case 'user_feeling':
        _onUserFeeling(message);
        break;
    }

    for (final listener in _messageListeners) {
      listener(message);
    }
  }

  void _onWorkoutStarted(Map<String, dynamic> msg) {
    debugPrint('[WatchService] Workout started: ${msg['workout_type']}');
  }

  void _onWorkoutEnded(Map<String, dynamic> msg) {
    debugPrint('[WatchService] Workout ended. Duration: ${msg['duration']} min');
  }

  void _onHeartRateUpdate(Map<String, dynamic> msg) {
    debugPrint('[WatchService] Live HR: ${msg['bpm']} bpm');
  }

  void _onHRVReading(Map<String, dynamic> msg) {
    debugPrint('[WatchService] HRV reading: ${msg['hrv_ms']} ms');
  }

  void _onUserFeeling(Map<String, dynamic> msg) {
    // User tapped a feeling on Watch (e.g. "Tired" / "Good" / "Sore")
    debugPrint('[WatchService] User feeling: ${msg['feeling']}');
  }

  // ── Private ──────────────────────────────────────────────────────────────────

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    try {
      // Real implementation:
      // await WearableCommunicator.sendMessage(message);
      final encoded = jsonEncode(message);
      debugPrint('[WatchService] → Watch: $encoded');
    } catch (e) {
      debugPrint('[WatchService] Send error: $e');
    }
  }
}
