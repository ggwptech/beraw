//
//  ContentView.swift
//  RawDogged
//
//  Created by TestApple on 10.11.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppStateManager()
    
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
    }
}

#Preview {
    ContentView()
}
