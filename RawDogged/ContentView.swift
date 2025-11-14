//
//  ContentView.swift
//  RawDogged
//
//  Created by TestApple on 10.11.2025.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @StateObject private var appState = AppStateManager()
    @State private var hasRequestedReview = false
    @State private var showPaywall = false
    
    private let accentBlack = Color.black // #2f00ff
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Home")
                }
                .environmentObject(appState)
            
            Group {
                if appState.isPremiumUser {
                    ChallengeView()
                } else {
                    PremiumLockedView(feature: "Challenges")
                        .onTapGesture {
                            showPaywall = true
                        }
                }
            }
            .tabItem {
                Image(systemName: "target")
                Text("Challenges")
            }
            .environmentObject(appState)
            
            Group {
                if appState.isPremiumUser {
                    LeaderboardView()
                } else {
                    PremiumLockedView(feature: "Leaderboard")
                        .onTapGesture {
                            showPaywall = true
                        }
                }
            }
            .tabItem {
                Image(systemName: "chart.bar")
                Text("Leaderboard")
            }
            .environmentObject(appState)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .environmentObject(appState)
        }
        .accentColor(accentBlack)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
        .onAppear {
            // Request review after 5 seconds, only once per session
            if !hasRequestedReview {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    requestReview()
                }
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
}

struct PremiumLockedView: View {
    let feature: String
    
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
                    Text("Premium Feature")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Unlock \(feature) with Premium")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Unlock Button
                VStack(spacing: 8) {
                    Text("Tap anywhere to unlock")
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

#Preview {
    ContentView()
}

