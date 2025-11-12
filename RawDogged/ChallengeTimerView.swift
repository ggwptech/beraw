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
    
    private let motivationalTexts = [
        "Stay focused...",
        "You're doing amazing...",
        "Keep going strong...",
        "Almost there...",
        "You've got this...",
        "Embrace the challenge...",
        "Every second matters...",
        "Building discipline...",
        "Stay present...",
        "You're stronger than you think...",
        "Push through...",
        "Excellence is forming..."
    ]
    
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
                    
                    Text("Be Raw")
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
                VStack(spacing: 20) {
                    Text(remainingTimeString)
                        .font(.system(size: 80, weight: .ultraLight))
                        .foregroundColor(timeColor)
                        .monospacedDigit()
                    
                    // Progress Ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(accentBlack, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Motivational Text
                VStack(spacing: 40) {
                    Text(motivationalTexts[currentMotivationIndex])
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
        motivationTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            withAnimation {
                currentMotivationIndex = (currentMotivationIndex + 1) % motivationalTexts.count
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
