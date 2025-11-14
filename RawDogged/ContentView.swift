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
    
    private let accentBlack = Color.black // #2f00ff
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Home")
                }
                .environmentObject(appState)
            
            ChallengeView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Challenges")
                }
                .environmentObject(appState)
            
            LeaderboardView()
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
        
        // Request review using StoreKit
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    ContentView()
}
