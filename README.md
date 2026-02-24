# 💪 MuscleRecovery AI
### Final Year Project — Université Antonine
**Students:** Amjad Issmail (202111989) · Hasanmahdi Yazbeck (202111233)  
**Supervisors:** Youssef Bou Issa · Youssef Keryakos  
**Major:** Software Engineering · Academic Year 2021–2022

---

## 📱 Project Overview

An AI-powered muscle recovery recommendation system that reads biometric data from **Apple Watch** via **HealthKit** and delivers personalized, actionable recovery strategies through an **iPhone app** built with **Flutter**.

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter 3.x (Dart) |
| iOS Platform | iOS 16+ |
| Watch Platform | watchOS 9+ (native Swift companion) |
| Health Data | Apple HealthKit (`health` package) |
| Watch Communication | WatchConnectivity (via `wearable_communicator`) |
| AI Engine | OpenAI GPT-4o-mini |
| State Management | Provider |
| Local Storage | Hive (offline-first) |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |

---

## 📊 Key Apple Watch Metrics Used

| Metric | Source | Role |
|--------|--------|------|
| HRV (SDNN) | Apple Watch | Primary fatigue indicator |
| Resting Heart Rate | Apple Watch | Cardiovascular recovery |
| Sleep Duration & Quality | Apple Watch | Overnight recovery |
| Workout History | Apple Watch + Manual | Fatigue load calculation |
| VO₂ Max | Apple Watch | Fitness baseline |
| Blood Oxygen | Apple Watch | Supplemental recovery signal |
| Steps | Apple Watch | Activity level |

---

## 🗂️ Project Structure

```
lib/
├── main.dart                    # App entry, Hive init, providers
├── theme/
│   └── app_theme.dart           # Light/dark theme, colors
├── models/
│   ├── workout_session.dart     # Workout + fatigue score model
│   ├── recovery_record.dart     # Daily recovery record
│   └── user_profile.dart        # Athlete profile
├── services/
│   ├── health_service.dart      # HealthKit wrapper
│   ├── ai_recommendation_service.dart  # GPT-4o-mini AI engine
│   ├── watch_service.dart       # WatchConnectivity bridge
│   └── notification_service.dart
├── viewmodels/
│   ├── dashboard_viewmodel.dart
│   ├── recovery_viewmodel.dart
│   ├── workout_viewmodel.dart
│   └── profile_viewmodel.dart
├── views/
│   ├── home/main_nav_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── recovery/recovery_screen.dart
│   ├── workout/workout_screen.dart
│   ├── profile/profile_screen.dart
│   └── onboarding/onboarding_screen.dart
└── widgets/
    ├── recovery_score_ring.dart  # Animated score ring
    ├── metric_card.dart          # Biometric metric card
    ├── recommendation_card.dart  # AI recommendation card
    └── muscle_heatmap.dart       # Muscle group recovery bars

watch_companion/
└── README.md                    # Swift watchOS extension guide
ios/
└── Runner/Info.plist            # HealthKit permissions
```

---

## 🚀 Getting Started

### Prerequisites
- macOS with Xcode 15+
- Flutter 3.x installed (`flutter doctor` should be clean)
- iPhone with iOS 16+
- Apple Watch Series 4+ with watchOS 9+
- Apple Developer account (for device testing + HealthKit entitlements)

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure HealthKit in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target → Signing & Capabilities
3. Add **HealthKit** capability
4. Check: Clinical Health Records (optional), Background Delivery

### 3. Add OpenAI API Key
In `lib/services/ai_recommendation_service.dart`, replace:
```dart
static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
```
> ⚠️ In production, use flutter_dotenv or secure storage — never hardcode!

### 4. Run on iPhone
```bash
flutter run --release
```

### 5. Set up Apple Watch Companion
See `watch_companion/README.md` for Xcode watchOS target setup.

---

## 🤖 AI Recovery Engine

The system sends the following to GPT-4o-mini:
- Current HRV, resting HR, sleep data
- Last 3 workout sessions + fatigue scores
- Athlete fitness level and goals

It returns:
- Recovery score interpretation
- Prioritized recommendations (Sleep / Hydration / Stretching / Nutrition / Training)
- Per-muscle-group recovery estimates
- Apple Watch complication tip

---

## 📈 Recovery Score Formula

```
Recovery Score = (HRV × 0.40) + (Sleep Quality × 0.40) + (Low RHR × 0.20)
```

- **HRV:** Apple Watch SDNN measurement (ms) — higher = better
- **Sleep Quality:** Composite of duration + deep sleep % + REM %
- **Resting HR:** Lower values indicate better cardiovascular recovery

---

## 🔬 Research Methodology

1. **Data Collection:** HealthKit + Apple Watch sensors (passive, continuous)
2. **Feature Engineering:** Fatigue scores from HR, HRV, duration, RPE, muscle groups
3. **AI Model:** Prompt-engineered LLM (GPT-4o-mini) with structured JSON output
4. **Validation:** User feedback loop via "How do you feel?" feature on Watch
5. **Evaluation:** Recovery score accuracy vs. subjective athlete RPE ratings

---

## 🛡️ Privacy

- All health data stays on-device (HealthKit sandbox)
- OpenAI API receives only numeric biometrics (no personal identifiers)
- Local-first architecture — works offline with rule-based fallback AI

---

## 📄 License
Academic project — Université Antonine, 2021–2022. All rights reserved.
