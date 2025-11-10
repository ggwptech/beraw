//
//  HomeView.swift
//  RawDogged
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showFullScreenTimer = false
    @State private var showJournalEntry = false
    
    private let accentBlue = Color(red: 47/255, green: 0, blue: 1) // #2f00ff
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Title
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(accentBlue)
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
                                    .fill(appState.currentSession == nil ? accentBlue : Color.red)
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Daily Goal Card
                    VStack(spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "target")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Daily Goal")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            Spacer()
                            Text("\(getTodayMinutes()) / \(appState.userStats.dailyGoalMinutes) min")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(accentBlue.opacity(0.1))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(accentBlue)
                                    .frame(width: geometry.size.width * dailyProgress, height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        HStack {
                            Spacer()
                            Text("\(Int(dailyProgress * 100))%")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Stats Grid
                    HStack(spacing: 12) {
                        // Streak Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 11, weight: .medium))
                                Text("Streak")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            
                            Text("\(appState.userStats.dailyStreak)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Days")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        
                        // Total Time Card
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
                                .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
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
                            .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationBarHidden(true)
        }
        .accentColor(accentBlue)
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
}

// MARK: - Mini Bar Chart Component
struct MiniBarChart: View {
    let data: [Int]
    private let accentBlue = Color(red: 47/255, green: 0, blue: 1)
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let barWidth = (geometry.size.width - CGFloat(data.count - 1) * 8) / CGFloat(data.count)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<data.count, id: \.self) { index in
                    VStack(spacing: 4) {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(accentBlue)
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
