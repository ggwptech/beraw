//
//  ChallengeTimerView.swift
//  RawDogged
//

import SwiftUI

struct ChallengeTimerView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    let challenge: RawChallenge
    let targetDuration: TimeInterval
    
    @State private var currentMotivationIndex = 0
    @State private var motivationTimer: Timer?
    @State private var hasCompleted = false
    @State private var showCelebration = false
    
    private let accentBlack = Color.black
    
    private let motivationalTextKeys = [
        "timer_motivation_focus",
        "timer_motivation_amazing",
        "timer_motivation_keep_strong",
        "timer_motivation_almost_there",
        "timer_motivation_got_this",
        "timer_motivation_embrace",
        "timer_motivation_every_second",
        "timer_motivation_discipline",
        "timer_motivation_stay_present",
        "timer_motivation_stronger",
        "timer_motivation_push",
        "timer_motivation_excellence"
    ]
    
    private var motivationalTexts: [String] {
        motivationalTextKeys.map { appState.localized($0) }
    }
    
    private var currentMotivationalText: String {
        guard !motivationalTexts.isEmpty else { return "" }
        let index = min(currentMotivationIndex, motivationalTexts.count - 1)
        return motivationalTexts[index]
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // App Logo and Name at top
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(appState.localized("app_brand"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Challenge Title
                Text(challenge.title)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
                
                // Timer Display
                Text(remainingTimeString)
                    .font(.system(size: 80, weight: .ultraLight))
                    .foregroundColor(.green)
                    .monospacedDigit()
                
                Spacer()
                
                // Motivational Text
                VStack(spacing: 40) {
                    Text(currentMotivationalText)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: currentMotivationIndex)
                    
                    // Stop Button
                    Button(action: {
                        stopChallenge()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "stop.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startMotivationTimer()
            checkCompletion()
        }
        .onDisappear {
            motivationTimer?.invalidate()
        }
        .fullScreenCover(isPresented: $showCelebration) {
            ChallengeCelebrationView(challenge: challenge, duration: challenge.durationMinutes)
                .onDisappear {
                    dismiss()
                }
        }
    }
    
    private var remainingTimeString: String {
        guard let session = appState.currentSession else { return "00:00" }
        let elapsed = session.duration
        let remaining = max(targetDuration - elapsed, 0)
        
        return appState.formatTime(remaining)
    }
    
    private var timeColor: Color {
        guard let session = appState.currentSession else { return .white }
        let elapsed = session.duration
        let remaining = targetDuration - elapsed
        
        if remaining <= 0 {
            return Color.green
        } else if remaining <= 60 {
            return Color.yellow
        } else {
            return .white
        }
    }
    
    private var progress: CGFloat {
        guard let session = appState.currentSession else { return 0 }
        let elapsed = session.duration
        return min(CGFloat(elapsed / targetDuration), 1.0)
    }
    
    private func checkCompletion() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard let session = appState.currentSession else {
                timer.invalidate()
                return
            }
            
            if session.duration >= targetDuration && !hasCompleted {
                hasCompleted = true
                completeChallenge()
            }
        }
    }
    
    private func completeChallenge() {
        // Vibration feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        appState.completeChallenge(challenge)
        appState.markChallengeAsCompleted(challenge)
        appState.stopSession()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showCelebration = true
        }
    }
    
    private func stopChallenge() {
        appState.stopSession()
        dismiss()
    }
    
    private func startMotivationTimer() {
        guard !motivationalTextKeys.isEmpty else { return }
        motivationTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            withAnimation {
                let count = motivationalTextKeys.count
                currentMotivationIndex = count > 0 ? (currentMotivationIndex + 1) % count : 0
            }
        }
    }
}

#Preview {
    ChallengeTimerView(
        challenge: RawChallenge(title: "Deep Thought", durationMinutes: 30),
        targetDuration: 1800
    )
    .environmentObject(AppStateManager())
}
