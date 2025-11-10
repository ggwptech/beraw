//
//  FullScreenTimerView.swift
//  RawDogged
//

import SwiftUI

struct FullScreenTimerView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    @State private var currentMotivationIndex = 0
    @State private var motivationTimer: Timer?
    
    private let accentBlue = Color(red: 47/255, green: 0, blue: 1)
    
    private let motivationalTexts = [
        "Embrace the silence...",
        "Your mind is clearing...",
        "Creativity blooms in stillness...",
        "You're building mental strength...",
        "Deep focus is forming...",
        "Let your thoughts flow freely...",
        "Every second counts...",
        "You're doing great...",
        "Stay present in this moment...",
        "Inner peace is growing...",
        "Your creativity is awakening...",
        "Boredom is the gateway to innovation..."
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Timer Display
                VStack(spacing: 20) {
                    Text(currentTimeString)
                        .font(.system(size: 80, weight: .ultraLight))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    Text("Raw Dogging")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
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
                        appState.stopSession()
                        dismiss()
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
        }
        .onDisappear {
            motivationTimer?.invalidate()
        }
    }
    
    private var currentTimeString: String {
        if let session = appState.currentSession {
            return appState.formatTime(session.duration)
        }
        return "00:00"
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
    FullScreenTimerView()
        .environmentObject(AppStateManager())
}
