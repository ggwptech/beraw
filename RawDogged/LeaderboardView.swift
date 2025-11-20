//
//  LeaderboardView.swift
//  RawDogged
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var appState: AppStateManager
    
    private let accentBlack = Color.black // #2f00ff
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(accentBlack)
                                Text(appState.localized("leaderboard_top_raw"))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Text(appState.localized("leaderboard_all_time"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, AdaptivePadding.horizontal(for: geometry.size.width))
                        .padding(.top, 10)
                        
                        // Your Rank Card
                        if let userId = appState.currentUserId,
                           let yourEntry = appState.leaderboard.first(where: { $0.userId == userId }) {
                            VStack(spacing: 12) {
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "chart.bar.fill")
                                            .font(.system(size: 12, weight: .medium))
                                        Text(appState.localized("leaderboard_your_rank"))
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                    Spacer()
                                }
                                
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("#\(yourEntry.rank)")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.black)
                                        Text(appState.localized("leaderboard_position"))
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 8) {
                                        // Time
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(appState.formatTotalTime(yourEntry.totalRawTime))
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.black)
                                            Text(appState.localized("leaderboard_total_time"))
                                                .font(.system(size: 11, weight: .regular))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        // Points
                                        HStack(spacing: 4) {
                                            Image(systemName: "bolt.fill")
                                                .font(.system(size: 12, weight: .medium))
                                            Text("\(yourEntry.totalPoints) pts")
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                        .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                            )
                            .padding(.horizontal, AdaptivePadding.horizontal(for: geometry.size.width))
                        }
                        
                        // Leaderboard List
                        VStack(spacing: 8) {
                            ForEach(appState.leaderboard) { entry in
                                LeaderboardRow(entry: entry, isCurrentUser: appState.currentUserId == entry.userId)
                                    .environmentObject(appState)
                            }
                        }
                        .padding(.horizontal, AdaptivePadding.horizontal(for: geometry.size.width))
                        .padding(.bottom, 20)
                    }
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .accentColor(accentBlack)
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    @EnvironmentObject var appState: AppStateManager
    
    private let accentBlack = Color.black // #2f00ff
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                if entry.rank <= 3 {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 40, height: 40)
                    
                    Text("\(entry.rank)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .stroke(accentBlack.opacity(0.3), lineWidth: 2)
                        .frame(width: 40, height: 40)
                    
                    Text("\(entry.rank)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.nickname)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    Text(appState.formatTotalTime(entry.totalRawTime))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                        Text("\(entry.totalPoints) \(appState.localized("leaderboard_points"))")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // Medal for top 3
            if entry.rank <= 3 {
                Image(systemName: "medal.fill")
                    .font(.system(size: 24))
                    .foregroundColor(medalColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isCurrentUser ? accentBlack.opacity(0.1) : Color.white)
                .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
    
    private var rankColor: Color {
        switch entry.rank {
        case 1: return Color.black // Purple for first
        case 2: return accentBlack.opacity(0.7)
        case 3: return accentBlack.opacity(0.5)
        default: return accentBlack.opacity(0.3)
        }
    }
    
    private var medalColor: Color {
        switch entry.rank {
        case 1: return Color(red: 1, green: 0.84, blue: 0) // Gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return accentBlack
        }
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(AppStateManager())
}
