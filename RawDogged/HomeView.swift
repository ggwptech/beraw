//
//  HomeView.swift
//  RawDogged
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showFullScreenTimer = false
    @State private var showJournalEntry = false
    
    private let accentBlack = Color.black
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Title
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(accentBlack)
                            Text("Be Raw")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Today")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Main Timer Card
                    VStack(spacing: 16) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "timer")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Current Session")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        Text(currentTimeString)
                            .font(.system(size: 56, weight: .bold))
                            .foregroundColor(.black)
                            .monospacedDigit()
                        
                        // Action Button
                        Button(action: {
                            if appState.currentSession == nil {
                                appState.startSession()
                                showFullScreenTimer = true
                            } else {
                                appState.stopSession()
                                showJournalEntry = true
                            }
                        }) {
                            HStack {
                                Image(systemName: appState.currentSession == nil ? "play.fill" : "stop.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(appState.currentSession == nil ? "Do it" : "STOP")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(appState.currentSession == nil ? accentBlack : Color.red)
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Day Streak Card
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Text("Day Streak")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "flame.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.orange)
                            
                            Text("\(appState.userStats.dailyStreak)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        
                        // Week Days Calendar
                        HStack(spacing: 8) {
                            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                VStack(spacing: 6) {
                                    Text(day)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Circle()
                                        .fill(getStreakColor(for: day))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: isStreakActive(for: day) ? "checkmark" : "")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Stats Grid
                    HStack(spacing: 12) {
                        
                        // Raw Time Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 11, weight: .medium))
                                Text("Total")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            
                            Text(appState.formatTotalTime(appState.userStats.totalRawTime))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Raw Time")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Total Points Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 11, weight: .medium))
                                Text("Total")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            
                            Text("\(appState.userStats.totalPoints)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.orange)
                            
                            Text("Points")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Activity Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Activity")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            Spacer()
                            Text("Last 7 Days")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        MiniBarChart(data: getLast7Days())
                            .frame(height: 80)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationBarHidden(true)
        }
        .accentColor(accentBlack)
        .fullScreenCover(isPresented: $showFullScreenTimer) {
            FullScreenTimerView()
                .environmentObject(appState)
                .onDisappear {
                    if appState.completedSessionDuration != nil {
                        showJournalEntry = true
                    }
                }
        }
        .sheet(isPresented: $showJournalEntry) {
            JournalEntryView()
                .environmentObject(appState)
        }
    }
    
    private var currentTimeString: String {
        if let session = appState.currentSession {
            return appState.formatTime(session.duration)
        } else {
            return "00:00"
        }
    }
    
    private var dailyProgress: CGFloat {
        let todayMinutes = getTodayMinutes()
        let goalMinutes = CGFloat(appState.userStats.dailyGoalMinutes)
        return min(CGFloat(todayMinutes) / goalMinutes, 1.0)
    }
    
    private func getTodayMinutes() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        var totalMinutes = 0
        
        if let todayRecord = appState.userStats.dailyHistory.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            totalMinutes = todayRecord.totalMinutes
        }
        
        // Add current session time if active
        if let session = appState.currentSession {
            totalMinutes += Int(session.duration / 60)
        }
        
        return totalMinutes
    }
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private func getLast7Days() -> [Int] {
        let last7 = Array(appState.userStats.dailyHistory.suffix(7))
        return last7.map { $0.totalMinutes }
    }
    
    private func getStreakColor(for day: String) -> Color {
        // For demo: first 2 days are active
        let activeDays = ["S", "M"]
        return activeDays.contains(day) ? .orange : Color.gray.opacity(0.2)
    }
    
    private func isStreakActive(for day: String) -> Bool {
        let activeDays = ["S", "M"]
        return activeDays.contains(day)
    }
}

// MARK: - Mini Bar Chart Component
struct MiniBarChart: View {
    let data: [Int]
    private let accentBlack = Color.black
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let barWidth = (geometry.size.width - CGFloat(data.count - 1) * 8) / CGFloat(data.count)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<data.count, id: \.self) { index in
                    VStack(spacing: 4) {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(accentBlack)
                            .frame(
                                width: barWidth,
                                height: max(CGFloat(data[index]) / CGFloat(maxValue) * geometry.size.height * 0.8, 4)
                            )
                        
                        Text(dayLabel(for: index))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private func dayLabel(for index: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let today = Calendar.current.component(.weekday, from: Date())
        let adjustedIndex = (today - 2 + index) % 7
        return days[max(0, min(adjustedIndex, 6))]
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStateManager())
}
