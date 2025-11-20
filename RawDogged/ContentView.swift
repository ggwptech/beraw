//
//  ContentView.swift
//  RawDogged
//
//  Created by TestApple on 10.11.2025.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var dynamicLinksManager: DynamicLinksManager
    @State private var hasRequestedReview = false
    @State private var showPaywall = false
    @State private var selectedChallenge: RawChallenge?
    @State private var challengeToStart: RawChallenge?
    
    private let accentBlack = Color.black // #2f00ff
    
    var body: some View {
        ZStack {
            TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "timer")
                    Text(appState.localized("tab_home"))
                }
                .environmentObject(appState)
            
            Group {
                if appState.isPremium {
                    ChallengeView()
                } else {
                    PremiumLockedView(feature: appState.localized("tab_challenge"))
                        .onTapGesture {
                            showPaywall = true
                        }
                }
            }
            .tabItem {
                Image(systemName: "target")
                Text(appState.localized("tab_challenge"))
            }
            .environmentObject(appState)
            
            Group {
                if appState.isPremium {
                    LeaderboardView()
                } else {
                    PremiumLockedView(feature: appState.localized("tab_leaderboard"))
                        .onTapGesture {
                            showPaywall = true
                        }
                }
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text(appState.localized("tab_leaderboard"))
            }
            .environmentObject(appState)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text(appState.localized("tab_profile"))
                }
                .environmentObject(appState)
        }
        .accentColor(accentBlack)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
        .sheet(item: $selectedChallenge) { challenge in
            ChallengeDetailSheet(challenge: challenge, onStartChallenge: { challengeToStart in
                selectedChallenge = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.challengeToStart = challengeToStart
                }
            })
            .environmentObject(appState)
        }
        .fullScreenCover(item: $challengeToStart) { challenge in
            ChallengeTimerView(
                challenge: challenge,
                targetDuration: TimeInterval(challenge.durationMinutes * 60)
            )
            .environmentObject(appState)
        }
        .onAppear {
            // Request review after 5 seconds, only once per session
            if !hasRequestedReview {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    requestReview()
                }
            }
            
            // Handle pending deep link if exists
            if let challengeId = dynamicLinksManager.pendingChallengeId {
                handleDeepLink(challengeId: challengeId)
            }
        }
        .onChange(of: dynamicLinksManager.pendingChallengeId) { _, newChallengeId in
            if let challengeId = newChallengeId {
                handleDeepLink(challengeId: challengeId)
            }
        }
        .onOpenURL { url in
            print("🌐 ContentView: onOpenURL called with: \(url)")
            if dynamicLinksManager.handleIncomingLink(url) {
                print("✅ ContentView: URL handled successfully")
            } else {
                print("❌ ContentView: Failed to handle URL")
            }
        }
            
            // Loading overlay
            if appState.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Syncing with server...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.8))
                )
            }
        }
    }
    
    private func requestReview() {
        // Check if user has completed onboarding and auth
        guard UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"),
              UserDefaults.standard.bool(forKey: "hasCompletedAuth") else {
            return
        }
        
        // Request review only once per session
        hasRequestedReview = true
        
        // Request review using new iOS 18+ API
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 18.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    private func handleDeepLink(challengeId: String) {
        print("🔗 ContentView: handleDeepLink called with ID: \(challengeId)")
        
        guard let uuid = UUID(uuidString: challengeId) else {
            print("❌ Invalid UUID format")
            dynamicLinksManager.pendingChallengeId = nil
            return
        }
        
        // Find challenge in public challenges cache
        if let challenge = appState.publicChallenges.first(where: { $0.id == uuid }) {
            print("✅ Found challenge in cache: \(challenge.title)")
            selectedChallenge = challenge
            dynamicLinksManager.pendingChallengeId = nil
        } else {
            print("⏳ Challenge not in cache, fetching from Firestore...")
            // Challenge not found in cache, fetch from Firestore
            Task {
                do {
                    if let challenge = try await appState.firestoreManager.fetchChallengeById(challengeId) {
                        print("✅ Fetched challenge from Firestore: \(challenge.title)")
                        await MainActor.run {
                            selectedChallenge = challenge
                            dynamicLinksManager.pendingChallengeId = nil
                        }
                    } else {
                        print("❌ Challenge not found in Firestore")
                        await MainActor.run {
                            dynamicLinksManager.pendingChallengeId = nil
                        }
                    }
                } catch {
                    print("❌ Failed to fetch challenge: \(error)")
                    await MainActor.run {
                        dynamicLinksManager.pendingChallengeId = nil
                    }
                }
            }
        }
    }
}

struct PremiumLockedView: View {
    let feature: String
    @EnvironmentObject var appState: AppStateManager
    
    private let accentBlack = Color.black
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Lock Icon
                ZStack {
                    Circle()
                        .fill(accentBlack.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(accentBlack)
                }
                
                // Text
                VStack(spacing: 12) {
                    Text(appState.localized("premium_locked_title"))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(feature == appState.localized("tab_challenge") 
                         ? appState.localized("premium_unlock_challenges")
                         : appState.localized("premium_unlock_leaderboard"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Unlock Button
                VStack(spacing: 8) {
                    Text(appState.localized("premium_tap_to_unlock"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 24))
                        .foregroundColor(accentBlack.opacity(0.6))
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Challenge Detail Sheet
struct ChallengeDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    let challenge: RawChallenge
    let onStartChallenge: (RawChallenge) -> Void
    
    private let accentBlack = Color.black
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Challenge Icon
                ZStack {
                    Circle()
                        .fill(accentBlack)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "target")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Challenge Info
                VStack(spacing: 12) {
                    Text(challenge.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16))
                        Text("\(challenge.durationMinutes) minutes")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(.gray)
                    
                    if challenge.usersCompletedCount > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 14))
                            Text("\(challenge.usersCompletedCount) completed")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.green)
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                // Start Button
                Button(action: {
                    appState.startChallenge(challenge)
                    onStartChallenge(challenge)
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Start Challenge")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(accentBlack)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStateManager())
}

