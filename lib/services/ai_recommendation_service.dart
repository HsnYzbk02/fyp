import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/workout_session.dart';

/// AIRecommendationService generates personalized muscle recovery advice
/// by feeding HealthKit biometrics and workout history to an LLM.
class AIRecommendationService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini'; // Cost-efficient for FYP

  // 🔑 Store in .env or secure storage — never hardcode in production!
  static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';

  /// Generates a full recovery recommendation given sensor data
  Future<RecoveryRecommendation> generateRecommendation({
    required double recoveryScore,
    required double hrv,
    required double restingHR,
    required Map<String, double> sleepData,
    required List<WorkoutSession> recentWorkouts,
    required String fitnessLevel,
    required List<String> goals,
  }) async {
    final prompt = _buildPrompt(
      recoveryScore: recoveryScore,
      hrv: hrv,
      restingHR: restingHR,
      sleepData: sleepData,
      recentWorkouts: recentWorkouts,
      fitnessLevel: fitnessLevel,
      goals: goals,
    );

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert sports science AI specializing in 
muscle recovery. Analyze biometric data from Apple Watch and provide 
personalized, evidence-based recovery recommendations. Always respond in 
valid JSON format with the exact structure requested.''',
            },
            {'role': 'user', 'content': prompt},
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final content = body['choices'][0]['message']['content'];
        return RecoveryRecommendation.fromJson(jsonDecode(content));
      } else {
        debugPrint('[AI] API error ${response.statusCode}: ${response.body}');
        return _fallbackRecommendation(recoveryScore);
      }
    } catch (e) {
      debugPrint('[AI] Error: $e');
      return _fallbackRecommendation(recoveryScore);
    }
  }

  String _buildPrompt({
    required double recoveryScore,
    required double hrv,
    required double restingHR,
    required Map<String, double> sleepData,
    required List<WorkoutSession> recentWorkouts,
    required String fitnessLevel,
    required List<String> goals,
  }) {
    final workoutSummary = recentWorkouts
        .take(3)
        .map((w) => '- ${w.workoutType} (${w.durationMinutes}min, '
            'fatigue: ${w.fatigueScore.toStringAsFixed(0)}/100, '
            'muscles: ${w.muscleGroupsWorked.join(", ")})')
        .join('\n');

    return '''
Analyze this athlete's recovery status and provide personalized recommendations.

BIOMETRIC DATA (from Apple Watch + HealthKit):
- Recovery Score: ${recoveryScore.toStringAsFixed(1)}/100
- HRV (SDNN): ${hrv.toStringAsFixed(1)} ms
- Resting Heart Rate: ${restingHR.toStringAsFixed(0)} bpm
- Sleep Duration: ${sleepData['totalHours']?.toStringAsFixed(1) ?? 'N/A'} hours
- Sleep Quality Score: ${sleepData['qualityScore']?.toStringAsFixed(0) ?? 'N/A'}/100
- Deep Sleep: ${sleepData['deepMinutes']?.toStringAsFixed(0) ?? 'N/A'} min
- REM Sleep: ${sleepData['remMinutes']?.toStringAsFixed(0) ?? 'N/A'} min

RECENT WORKOUTS (last 3):
$workoutSummary

ATHLETE PROFILE:
- Fitness Level: $fitnessLevel
- Goals: ${goals.join(', ')}

Respond ONLY in this exact JSON format:
{
  "summary": "2-sentence insight about current recovery state",
  "recovery_score_interpretation": "what this score means for this athlete",
  "recommendations": [
    {
      "category": "Sleep|Hydration|Stretching|Nutrition|Active Recovery|Rest|Training",
      "title": "short action title",
      "description": "specific actionable advice",
      "priority": "high|medium|low",
      "duration_minutes": 0
    }
  ],
  "muscle_recovery_estimate": {
    "Chest": 85,
    "Back": 70,
    "Legs": 45,
    "Shoulders": 90,
    "Arms": 75,
    "Core": 80
  },
  "next_workout_suggestion": {
    "name": "workout name",
    "intensity": "light|moderate|high|rest",
    "reason": "why this is appropriate today"
  },
  "watch_tip": "one short sentence to show on Apple Watch"
}
''';
  }

  RecoveryRecommendation _fallbackRecommendation(double score) {
    // Rule-based fallback when AI is unavailable
    final List<Map<String, dynamic>> recs = [];

    if (score < 40) {
      recs.addAll([
        {
          'category': 'Rest',
          'title': 'Take a Full Rest Day',
          'description':
              'Your body needs recovery. Avoid intense training today.',
          'priority': 'high',
          'duration_minutes': 0,
        },
        {
          'category': 'Sleep',
          'title': 'Prioritize 8+ Hours Tonight',
          'description':
              'Sleep is your most powerful recovery tool. Aim for 8–9 hours.',
          'priority': 'high',
          'duration_minutes': 480,
        },
      ]);
    } else if (score < 70) {
      recs.addAll([
        {
          'category': 'Active Recovery',
          'title': '20-Min Light Walk or Yoga',
          'description':
              'Gentle movement increases blood flow to fatigued muscles.',
          'priority': 'medium',
          'duration_minutes': 20,
        },
        {
          'category': 'Hydration',
          'title': 'Drink 2.5L of Water Today',
          'description': 'Proper hydration accelerates muscle repair.',
          'priority': 'medium',
          'duration_minutes': 0,
        },
      ]);
    } else {
      recs.add({
        'category': 'Training',
        'title': 'You\'re Ready to Train!',
        'description':
            'Your recovery is excellent. A moderate-to-high intensity session is appropriate.',
        'priority': 'low',
        'duration_minutes': 60,
      });
    }

    return RecoveryRecommendation(
      summary: 'Recovery score: ${score.toStringAsFixed(0)}/100. '
          '${score >= 70 ? "You are well recovered." : score >= 40 ? "Moderate fatigue detected." : "High fatigue — rest is essential."}',
      recommendations: recs,
      muscleRecoveryEstimate: const {
        'Chest': 75,
        'Back': 70,
        'Legs': 65,
        'Shoulders': 80,
        'Arms': 75,
        'Core': 80,
      },
      watchTip:
          score >= 70 ? 'Great recovery! Ready to train.' : 'Rest up today 💤',
    );
  }
}

class RecoveryRecommendation {
  final String summary;
  final List<Map<String, dynamic>> recommendations;
  final Map<String, dynamic> muscleRecoveryEstimate;
  final String watchTip;
  final Map<String, dynamic>? nextWorkoutSuggestion;

  const RecoveryRecommendation({
    required this.summary,
    required this.recommendations,
    required this.muscleRecoveryEstimate,
    required this.watchTip,
    this.nextWorkoutSuggestion,
  });

  factory RecoveryRecommendation.fromJson(Map<String, dynamic> json) {
    return RecoveryRecommendation(
      summary: json['summary'] ?? '',
      recommendations:
          List<Map<String, dynamic>>.from(json['recommendations'] ?? []),
      muscleRecoveryEstimate:
          Map<String, dynamic>.from(json['muscle_recovery_estimate'] ?? {}),
      watchTip: json['watch_tip'] ?? '',
      nextWorkoutSuggestion: json['next_workout_suggestion'],
    );
  }
}
