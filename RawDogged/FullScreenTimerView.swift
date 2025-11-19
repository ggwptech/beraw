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
    @State private var showFailedAlert = false
    @State private var sessionFailed = false
    
    private let accentBlack = Color.black
    
    private let motivationalTextKeys = [
        "timer_fs_silence",
        "timer_fs_mind_clearing",
        "timer_fs_creativity_stillness",
        "timer_fs_mental_strength",
        "timer_fs_deep_focus",
        "timer_fs_flow_freely",
        "timer_fs_every_second_counts",
        "timer_fs_doing_great",
        "timer_fs_stay_present",
        "timer_fs_inner_peace",
        "timer_fs_creativity_awakening",
        "timer_fs_boredom_innovation"
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
                
                // Timer Display
                VStack(spacing: 20) {
                    Text(currentTimeString)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 150 : 80, weight: .ultraLight))
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    Text(appState.localized("timer_raw_dogging"))
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                
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
            setupBackgroundObservers()
        }
        .onDisappear {
            motivationTimer?.invalidate()
            removeBackgroundObservers()
        }
        .alert(appState.localized("challenge_failed_title"), isPresented: $showFailedAlert) {
            Button(appState.localized("common_ok"), role: .cancel) {
                dismiss()
            }
        } message: {
            Text(appState.localized("challenge_failed_message"))
        }
    }
    
    private var currentTimeString: String {
        if let session = appState.currentSession {
            return appState.formatTime(session.duration)
        }
        return "00:00"
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
    
    private func setupBackgroundObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // User is leaving the app
            if appState.currentSession != nil && !sessionFailed {
                sessionFailed = true
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // User returned to the app
            if sessionFailed && appState.currentSession != nil {
                appState.stopSession(shouldShowJournal: false)
                showFailedAlert = true
            }
        }
    }
    
    private func removeBackgroundObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

#Preview {
    FullScreenTimerView()
        .environmentObject(AppStateManager())
}
