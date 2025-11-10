//
//  Models.swift
//  RawDogged
//

import Foundation
import SwiftUI
import Combine

// MARK: - Session Model
struct RawSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    var duration: TimeInterval {
        if let end = endTime {
            return end.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
}

// MARK: - Challenge Model
struct RawChallenge: Identifiable, Codable {
    let id: UUID
    let title: String
    let durationMinutes: Int
    var completedCount: Int
    
    init(id: UUID = UUID(), title: String, durationMinutes: Int, completedCount: Int = 0) {
        self.id = id
        self.title = title
        self.durationMinutes = durationMinutes
        self.completedCount = completedCount
    }
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let nickname: String
    let totalRawTime: TimeInterval
    var rank: Int = 0
    
    init(id: UUID = UUID(), nickname: String, totalRawTime: TimeInterval, rank: Int = 0) {
        self.id = id
        self.nickname = nickname
        self.totalRawTime = totalRawTime
        self.rank = rank
    }
}

// MARK: - User Stats
struct UserStats: Codable {
    var dailyStreak: Int
    var totalRawTime: TimeInterval
    var dailyGoalMinutes: Int
    var dailyHistory: [DailyRecord]
    
    init(dailyStreak: Int = 0, totalRawTime: TimeInterval = 0, dailyGoalMinutes: Int = 60, dailyHistory: [DailyRecord] = []) {
        self.dailyStreak = dailyStreak
        self.totalRawTime = totalRawTime
        self.dailyGoalMinutes = dailyGoalMinutes
        self.dailyHistory = dailyHistory
    }
}

struct DailyRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let totalMinutes: Int
    
    init(id: UUID = UUID(), date: Date, totalMinutes: Int) {
        self.id = id
        self.date = date
        self.totalMinutes = totalMinutes
    }
}

// MARK: - Journal Entry
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let sessionDuration: TimeInterval
    let thoughts: String
    
    init(id: UUID = UUID(), date: Date = Date(), sessionDuration: TimeInterval, thoughts: String) {
        self.id = id
        self.date = date
        self.sessionDuration = sessionDuration
        self.thoughts = thoughts
    }
}

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    @Published var currentSession: RawSession?
    @Published var userStats: UserStats
    @Published var challenges: [RawChallenge]
    @Published var leaderboard: [LeaderboardEntry]
    @Published var currentUser: String
    @Published var journalEntries: [JournalEntry]
    @Published var completedSessionDuration: TimeInterval?
    
    private var timer: Timer?
    
    init() {
        // Initialize with default data
        self.userStats = UserStats(
            dailyStreak: 5,
            totalRawTime: 28800, // 8 hours
            dailyGoalMinutes: 60,
            dailyHistory: AppStateManager.generateDummyHistory()
        )
        
        self.challenges = [
            RawChallenge(title: "Stare at the Wall", durationMinutes: 15, completedCount: 3),
            RawChallenge(title: "Silent Walk", durationMinutes: 45, completedCount: 0),
            RawChallenge(title: "No Phone Dinner", durationMinutes: 180, completedCount: 0),
            RawChallenge(title: "Deep Thought", durationMinutes: 30, completedCount: 2),
            RawChallenge(title: "Complete Disconnect", durationMinutes: 120, completedCount: 0)
        ]
        
        self.currentUser = "You"
        
        self.leaderboard = [
            LeaderboardEntry(nickname: "ZenMaster", totalRawTime: 144000, rank: 1), // 40 hours
            LeaderboardEntry(nickname: "MindfulNinja", totalRawTime: 108000, rank: 2), // 30 hours
            LeaderboardEntry(nickname: "SilentWarrior", totalRawTime: 86400, rank: 3), // 24 hours
            LeaderboardEntry(nickname: "You", totalRawTime: 28800, rank: 4), // 8 hours
            LeaderboardEntry(nickname: "DeepThinker", totalRawTime: 21600, rank: 5), // 6 hours
            LeaderboardEntry(nickname: "Minimalist", totalRawTime: 18000, rank: 6), // 5 hours
        ]
        
        self.journalEntries = []
    }
    
    // MARK: - Session Management
    func startSession() {
        currentSession = RawSession()
        startTimer()
    }
    
    func stopSession() {
        guard let session = currentSession else { return }
        let completedSession = RawSession(
            id: session.id,
            startTime: session.startTime,
            endTime: Date()
        )
        
        // Store duration for journal entry
        completedSessionDuration = completedSession.duration
        
        // Update stats
        userStats.totalRawTime += completedSession.duration
        updateDailyHistory(duration: completedSession.duration)
        
        currentSession = nil
        stopTimer()
    }
    
    func saveJournalEntry(thoughts: String) {
        guard let duration = completedSessionDuration else { return }
        let entry = JournalEntry(sessionDuration: duration, thoughts: thoughts)
        journalEntries.insert(entry, at: 0) // Add at beginning for newest first
        completedSessionDuration = nil
    }
    
    func skipJournalEntry() {
        completedSessionDuration = nil
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateDailyHistory(duration: TimeInterval) {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = userStats.dailyHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            userStats.dailyHistory[index] = DailyRecord(
                id: userStats.dailyHistory[index].id,
                date: today,
                totalMinutes: userStats.dailyHistory[index].totalMinutes + Int(duration / 60)
            )
        } else {
            userStats.dailyHistory.append(DailyRecord(
                date: today,
                totalMinutes: Int(duration / 60)
            ))
        }
    }
    
    // MARK: - Challenge Management
    func startChallenge(_ challenge: RawChallenge) {
        currentSession = RawSession()
        startTimer()
    }
    
    func completeChallenge(_ challenge: RawChallenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].completedCount += 1
        }
    }
    
    func addChallenge(title: String, durationMinutes: Int) {
        let newChallenge = RawChallenge(title: title, durationMinutes: durationMinutes)
        challenges.append(newChallenge)
    }
    
    // MARK: - Helper Methods
    static func generateDummyHistory() -> [DailyRecord] {
        var history: [DailyRecord] = []
        let calendar = Calendar.current
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let minutes = Int.random(in: 0...120)
                history.append(DailyRecord(date: date, totalMinutes: minutes))
            }
        }
        
        return history.reversed()
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) / 60 % 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    func formatTotalTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        if hours > 0 {
            return "\(hours) hrs"
        } else {
            let minutes = Int(seconds) / 60
            return "\(minutes) min"
        }
    }
}
