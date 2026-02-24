# Apple Watch Companion App
## MuscleRecovery AI – watchOS Extension

Flutter does not natively compile to watchOS. The Apple Watch integration uses two approaches:

---

## Approach 1: WatchConnectivity (Recommended for FYP)

The iPhone Flutter app communicates with a **native Swift watchOS extension** via WatchConnectivity.

### Setup Steps

1. Open the generated Xcode project (`ios/Runner.xcworkspace`)
2. Add a new **watchOS App target**: File → New → Target → Watch App
3. Name it: `MuscleRecoveryWatch`
4. Enable **WatchConnectivity** capability on both targets

### Watch App Swift Files

#### `WatchSessionManager.swift` (place in watchOS target)
```swift
import WatchConnectivity
import WatchKit

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    
    @Published var recoveryScore: Double = 0
    @Published var recoveryStatus: String = "Loading..."
    @Published var todayTip: String = ""
    @Published var muscleStatus: [String: Double] = [:]
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // Receive messages from iPhone Flutter app
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let type = message["type"] as? String, type == "recovery_update" {
                self.recoveryScore = message["score"] as? Double ?? 0
                self.recoveryStatus = message["status"] as? String ?? ""
                self.todayTip = message["tip"] as? String ?? ""
                self.muscleStatus = message["muscles"] as? [String: Double] ?? [:]
            }
        }
    }
    
    // Send workout data from Watch to iPhone
    func sendWorkoutData(heartRate: Double, hrv: Double) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage([
            "type": "heart_rate_update",
            "bpm": heartRate,
            "hrv_ms": hrv
        ], replyHandler: nil)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
}
```

#### `ContentView.swift` (Watch UI)
```swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var session = WatchSessionManager.shared
    
    var ringColor: Color {
        switch session.recoveryScore {
        case 80...100: return .green
        case 60..<80:  return .blue
        case 40..<60:  return .yellow
        default:       return .red
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Recovery Ring
                ZStack {
                    Circle()
                        .stroke(ringColor.opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: session.recoveryScore / 100)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(Int(session.recoveryScore))")
                            .font(.system(size: 32, weight: .bold))
                        Text(session.recoveryStatus)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 110, height: 110)
                
                // Tip
                if !session.todayTip.isEmpty {
                    Text(session.todayTip)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                }
                
                // Quick feel buttons
                HStack {
                    WatchButton(label: "💪 Good", color: .green) {
                        WatchSessionManager.shared.sendWorkoutData(heartRate: 0, hrv: 0)
                    }
                    WatchButton(label: "😴 Tired", color: .orange) {
                        WatchSessionManager.shared.sendWorkoutData(heartRate: 0, hrv: 0)
                    }
                }
            }
            .padding()
        }
    }
}

struct WatchButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(color.opacity(0.2))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
```

---

## Approach 2: HealthKit Sharing (Simpler)
The Watch writes data to HealthKit automatically. The iPhone app reads it via the `health` Flutter package. No direct messaging needed for basic metrics.

---

## What the Watch Complication Shows
- Recovery Score ring (0–100)
- Status label (Optimal / Good / Moderate / Rest Needed)
- Top recovery tip of the day

---

## Data Flow Architecture

```
Apple Watch (HRV, HR, Sleep, Workouts)
         ↓ HealthKit sync (automatic)
iPhone ← health Flutter package reads HealthKit
         ↓
  AI Recommendation Engine (OpenAI GPT-4o-mini)
         ↓
  Recovery Score + Recommendations
         ↓ WatchConnectivity
Apple Watch Complication + UI update
```
