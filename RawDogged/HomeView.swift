//
//  HomeView.swift
//  RawDogged
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showFullScreenTimer = false
    @State private var showJournalEntry = false
    @State private var selectedEntry: JournalEntry?
    @State private var showFullJournal = false
    @State private var showMotivation = true
    @State private var showPointsInfo = false
    
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
                            Text(appState.localized("app_brand"))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Activity Card (First)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 12, weight: .medium))
                                Text(appState.localized("home_activity"))
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            Spacer()
                            Text(appState.localized("home_last_7_days"))
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
                    
                    // Day Streak Card (Second)
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Text(appState.localized("home_day_streak"))
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
                            ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                                VStack(spacing: 6) {
                                    Text(day)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    Circle()
                                        .fill(getStreakColor(for: index))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: isStreakActive(for: index) ? "checkmark" : "")
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
                    
                    // Stats Grid (Third - Two small blocks)
                    HStack(spacing: 12) {
                        
                        // Raw Time Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 11, weight: .medium))
                                Text(appState.localized("home_total"))
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            
                            Text(appState.formatTotalTime(appState.userStats.totalRawTime))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(appState.localized("home_raw_time"))
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
                                Text(appState.localized("home_total"))
                                
                                Spacer()
                                
                                Button(action: {
                                    showPointsInfo = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            
                            Text("\(appState.userStats.totalPoints)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.orange)
                            
                            Text(appState.localized("home_points"))
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
                    
                    // Latest Journal Entry Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 12, weight: .medium))
                                Text(appState.localized("home_latest_session"))
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        if appState.journalEntries.isEmpty {
                            Text(appState.localized("home_no_entries"))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else if let latestEntry = appState.journalEntries.first {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(accentBlack)
                                    
                                    Text(formatDate(latestEntry.date))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text(formatDuration(latestEntry.sessionDuration))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(accentBlack)
                                        )
                                }
                                
                                Text(latestEntry.thoughts.isEmpty ? appState.localized("home_no_thoughts") : latestEntry.thoughts)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.black.opacity(0.8))
                                    .lineLimit(3)
                                    .padding(.top, 4)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: accentBlack.opacity(0.06), radius: 8, x: 0, y: 2)
                            )
                            .onTapGesture {
                                showFullJournal = true
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
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
                        HStack(spacing: 8) {
                            if appState.currentSession == nil {
                                if showMotivation {
                                    Text(appState.localized("home_start_motivation"))
                                        .font(.system(size: 16, weight: .semibold))
                                        .transition(.opacity)
                                } else {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(appState.localized("home_do_it"))
                                        .font(.system(size: 16, weight: .semibold))
                                        .transition(.opacity)
                                }
                            } else {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(appState.localized("home_stop"))
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(appState.currentSession == nil ? accentBlack : Color.red)
                        )
                    }
                    .onAppear {
                        startButtonTextTimer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .accentColor(accentBlack)
        .sheet(isPresented: Binding(
            get: { selectedEntry != nil },
            set: { if !$0 { selectedEntry = nil } }
        )) {
            if let entry = selectedEntry {
                JournalEntryDetailView(entry: entry)
            }
        }
        .sheet(isPresented: $showFullJournal) {
            JournalView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showPointsInfo) {
            PointsInfoSheet()
        }
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
                .presentationDetents([.height(500)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
    
    private var currentTimeString: String {
        if let session = appState.currentSession {
            return appState.formatTime(session.duration)
        } else {
            return "00:00"
        }
    }
    
    private func startButtonTextTimer() {
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                showMotivation.toggle()
            }
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
    
    private func getStreakColor(for dayIndex: Int) -> Color {
        return isStreakActive(for: dayIndex) ? .orange : Color.gray.opacity(0.2)
    }
    
    private func isStreakActive(for dayIndex: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate the date for this day (0 = Sunday, 6 = Saturday in the week)
        // dayIndex: 0=S, 1=M, 2=T, 3=W, 4=T, 5=F, 6=S
        let todayWeekday = calendar.component(.weekday, from: today) - 1 // 0 = Sunday
        let daysBack = (todayWeekday - dayIndex + 7) % 7
        
        guard let checkDate = calendar.date(byAdding: .day, value: -daysBack, to: today) else {
            return false
        }
        
        // Check if this date exists in dailyHistory
        return appState.userStats.dailyHistory.contains { record in
            calendar.isDate(record.date, inSameDayAs: checkDate)
        }
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

// Compact Journal Card for horizontal scroll
struct CompactJournalCard: View {
    let entry: JournalEntry
    private let accentBlack = Color.black
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 9))
                    .foregroundColor(accentBlack)
                
                Text(formattedDate)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Text(entry.thoughts.isEmpty ? "No thoughts recorded" : entry.thoughts)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(2)
                .frame(height: 32)
            
            Text(formattedDuration)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(accentBlack)
                )
        }
        .padding(10)
        .frame(width: 150)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: accentBlack.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: entry.date)
    }
    
    private var formattedDuration: String {
        let totalSeconds = Int(entry.sessionDuration)
        let minutes = totalSeconds / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(totalSeconds)s"
        }
    }
}

// Journal Entry Detail View
struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @Environment(\.dismiss) var dismiss
    
    private let accentBlack = Color.black
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Info
                    VStack(spacing: 12) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 40))
                            .foregroundColor(accentBlack)
                        
                        Text(formattedDate)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text(formattedDuration)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(accentBlack)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Thoughts Content
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "text.quote")
                                .font(.system(size: 12, weight: .medium))
                            Text("Your Thoughts")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        
                        Text(entry.thoughts)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .lineSpacing(6)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentBlack)
                }
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy • HH:mm"
        return formatter.string(from: entry.date)
    }
    
    private var formattedDuration: String {
        let totalSeconds = Int(entry.sessionDuration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if minutes > 0 {
            return "\(minutes) minutes"
        } else {
            return "\(seconds) seconds"
        }
    }
}

// Points Info Sheet
struct PointsInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    private let accentBlack = Color.black
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("How Points Work")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(20)
                .background(Color.white)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Regular Sessions
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(accentBlack)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Regular Sessions")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Focus time tracking")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("•")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.orange)
                                    Text("1 point per minute")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.black)
                                }
                                
                                Text("Track your focus sessions and earn 1 point for every minute you stay present.")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 20)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        }
                        
                        // Challenge Completion
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "target")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Challenge Bonus")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Extra rewards")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("•")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.orange)
                                    Text("2x points for challenge duration")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.black)
                                }
                                
                                Text("Complete a challenge to earn bonus points: 2 points per minute of the challenge duration.")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 20)
                                
                                HStack(spacing: 8) {
                                    Text("Example:")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("30-min challenge = 60 bonus points")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 20)
                                .padding(.top, 4)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        }
                        
                        // Summary
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.orange)
                                Text("Pro Tip")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            
                            Text("Combine regular sessions with challenges to maximize your points and climb the leaderboard!")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(20)
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStateManager())
}
