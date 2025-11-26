//
//  Models.swift
//  RawDogged
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

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
    var isCompleted: Bool
    var isPublic: Bool
    var createdAt: Date
    var usersCompletedCount: Int
    
    init(id: UUID = UUID(), title: String, durationMinutes: Int, isCompleted: Bool = false, isPublic: Bool = false, createdAt: Date = Date(), usersCompletedCount: Int = 0) {
        self.id = id
        self.title = title
        self.durationMinutes = durationMinutes
        self.isCompleted = isCompleted
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.usersCompletedCount = usersCompletedCount
    }
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let userId: String // Firebase userId
    let nickname: String
    let totalRawTime: TimeInterval
    let totalPoints: Int
    var rank: Int
    
    init(id: UUID = UUID(), userId: String = "", nickname: String, totalRawTime: TimeInterval, totalPoints: Int = 0, rank: Int) {
        self.id = id
        self.userId = userId
        self.nickname = nickname
        self.totalRawTime = totalRawTime
        self.totalPoints = totalPoints
        self.rank = rank
    }
}

// MARK: - User Stats
struct UserStats: Codable {
    var dailyStreak: Int
    var totalRawTime: TimeInterval
    var totalPoints: Int
    var dailyGoalMinutes: Int
    var dailyHistory: [DailyRecord]
    
    init(dailyStreak: Int = 0, totalRawTime: TimeInterval = 0, totalPoints: Int = 0, dailyGoalMinutes: Int = 60, dailyHistory: [DailyRecord] = []) {
        self.dailyStreak = dailyStreak
        self.totalRawTime = totalRawTime
        self.totalPoints = totalPoints
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
    let duration: TimeInterval
    let thoughts: String
    
    init(id: UUID = UUID(), date: Date = Date(), duration: TimeInterval, thoughts: String) {
        self.id = id
        self.date = date
        self.duration = duration
        self.thoughts = thoughts
    }
    
    // Compatibility property
    var sessionDuration: TimeInterval { duration }
}

// MARK: - Language Support
enum AppLanguage: String, Codable, CaseIterable {
    case german = "de"
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case italian = "it"
    case polish = "pl"
    case portuguese = "pt"
    case russian = "ru"
    case turkish = "tr"
    case ukrainian = "uk"
    
    var displayName: String {
        switch self {
        case .german: return "Deutsch"
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .italian: return "Italiano"
        case .polish: return "Polski"
        case .portuguese: return "Português"
        case .russian: return "Русский"
        case .turkish: return "Türkçe"
        case .ukrainian: return "Українська"
        }
    }
    
    var flagEmoji: String {
        switch self {
        case .german: return "🇩🇪"
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .italian: return "🇮🇹"
        case .polish: return "🇵🇱"
        case .portuguese: return "🇵🇹"
        case .russian: return "🇷🇺"
        case .turkish: return "🇹🇷"
        case .ukrainian: return "🇺🇦"
        }
    }
}

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    @Published var currentSession: RawSession?
    @Published var userStats: UserStats
    @Published var challenges: [RawChallenge]
    @Published var publicChallenges: [RawChallenge]
    @Published var leaderboard: [LeaderboardEntry]
    @Published var currentUser: String
    @Published var userName: String
    @Published var userEmail: String?
    @Published var journalEntries: [JournalEntry]
    @Published var completedSessionDuration: TimeInterval?
    @Published var selectedLanguage: AppLanguage
    @Published var isLoading: Bool = false
    
    private var timer: Timer?
    let firestoreManager = FirestoreManager()
    var currentUserId: String?
    
    // Store reference - will be set from RootView
    weak var storeManager: StoreManager?
    
    init() {
        // Load selected language from UserDefaults
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.selectedLanguage = language
        } else {
            self.selectedLanguage = .english
        }
        
        // Initialize with empty data - will be loaded from Firebase after login
        self.userStats = UserStats(
            dailyStreak: 0,
            totalRawTime: 0,
            dailyGoalMinutes: 60,
            dailyHistory: []
        )
        
        self.challenges = []
        self.publicChallenges = []
        self.currentUser = "You"
        self.userName = "Raw Dog"
        self.userEmail = nil
        self.leaderboard = []
        self.journalEntries = []
    }
    
    // MARK: - Firebase Sync
    func setUser(userId: String, userName: String, email: String?) {
        self.currentUserId = userId
        self.userName = userName
        self.userEmail = email
        
        Task {
            await syncWithFirebase(userId: userId, userName: userName, email: email)
        }
    }
    
    func syncWithFirebase(userId: String, userName: String, email: String?) async {
        isLoading = true
        
        do {
            // Load user profile first (might have been updated)
            if let profileData = try await firestoreManager.fetchUserProfile(userId: userId) {
                DispatchQueue.main.async {
                    // Update userName from Firebase if it exists
                    if let savedUserName = profileData["userName"] as? String, !savedUserName.isEmpty {
                        self.userName = savedUserName
                    }
                    if let savedEmail = profileData["email"] as? String {
                        self.userEmail = savedEmail
                    }
                }
            } else {
                // If profile doesn't exist, create it
                try await firestoreManager.saveUserProfile(userId: userId, userName: userName, email: email)
            }
            
            // Load user data
            if let stats = try await firestoreManager.fetchUserStats(userId: userId) {
                DispatchQueue.main.async {
                    // Load stats but ignore dailyStreak from Firebase
                    self.userStats.totalRawTime = stats.totalRawTime
                    self.userStats.totalPoints = stats.totalPoints
                    self.userStats.dailyGoalMinutes = stats.dailyGoalMinutes
                }
            }
            
            let challenges = try await firestoreManager.fetchChallenges(userId: userId)
            DispatchQueue.main.async {
                self.challenges = challenges
            }
            
            let entries = try await firestoreManager.fetchJournalEntries(userId: userId)
            DispatchQueue.main.async {
                self.journalEntries = entries
            }
            
            let history = try await firestoreManager.fetchDailyHistory(userId: userId, days: 30)
            DispatchQueue.main.async {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                
                // Get current week start (Monday)
                var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
                components.weekday = 2 // Monday
                guard let monday = calendar.date(from: components) else {
                    self.userStats.dailyHistory = []
                    self.userStats.dailyStreak = 0
                    return
                }
                
                // Keep only records from current week (Monday onwards)
                // This ensures old week data is completely removed
                let cleanedHistory = history.filter { record in
                    let recordDate = calendar.startOfDay(for: record.date)
                    return recordDate >= monday && recordDate <= today
                }
                
                self.userStats.dailyHistory = cleanedHistory
                
                // Always save cleaned data back to Firebase to remove old records
                Task {
                    try? await self.firestoreManager.saveDailyHistory(userId: userId, history: cleanedHistory)
                }
                
                // Always recalculate streak based on cleaned history
                self.updateStreak()
            }
            
            // Start listening to public challenges in real-time
            firestoreManager.listenToPublicChallenges { [weak self] challenges in
                DispatchQueue.main.async {
                    self?.publicChallenges = challenges
                }
            }
            
            // Load leaderboard
            let leaderboard = try await firestoreManager.fetchLeaderboard(limit: 50)
            DispatchQueue.main.async {
                self.leaderboard = leaderboard
            }
            
        } catch {
            print("Error syncing with Firebase: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func saveToFirebase() {
        guard let userId = currentUserId else { return }
        
        Task {
            do {
                try await firestoreManager.saveUserStats(userId: userId, stats: userStats)
                try await firestoreManager.saveChallenges(userId: userId, challenges: challenges)
                try await firestoreManager.saveJournalEntries(userId: userId, entries: journalEntries)
                try await firestoreManager.saveDailyHistory(userId: userId, history: userStats.dailyHistory)
                try await firestoreManager.updateLeaderboard(
                    userId: userId,
                    userName: userName,
                    totalRawTime: userStats.totalRawTime,
                    totalPoints: userStats.totalPoints
                )
            } catch {
                print("Error saving to Firebase: \(error)")
            }
        }
    }
    
    // MARK: - User Management
    func updateUserName(_ newName: String) {
        userName = newName
        
        // Update in Firebase
        guard let userId = currentUserId else { return }
        
        Task {
            do {
                try await firestoreManager.saveUserProfile(userId: userId, userName: newName, email: userEmail)
                
                // Update in leaderboard as well
                try await firestoreManager.updateLeaderboard(
                    userId: userId,
                    userName: newName,
                    totalRawTime: userStats.totalRawTime,
                    totalPoints: userStats.totalPoints
                )
            } catch {
                print("Error updating user name: \(error)")
            }
        }
    }
    
    // MARK: - Premium Management
    var isPremium: Bool {
        #if DEBUG
        return true  // Always premium in debug mode for testing
        #else
        return storeManager?.isPremium ?? false
        #endif
    }
    
    func updatePremiumStatus() {
        // Trigger UI update by refreshing published properties
        objectWillChange.send()
    }
    
    // MARK: - Language Management
    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
    }
    
    func localized(_ key: String) -> String {
        return LocalizationManager.translate(key, language: selectedLanguage)
    }
    
    // MARK: - Session Management
    func startSession() {
        currentSession = RawSession()
        startTimer()
    }
    
    func stopSession(shouldShowJournal: Bool = true) {
        guard let session = currentSession else { return }
        let completedSession = RawSession(
            id: session.id,
            startTime: session.startTime,
            endTime: Date()
        )
        
        // Store duration for journal entry only if session was completed successfully
        if shouldShowJournal {
            completedSessionDuration = completedSession.duration
        }
        
        // Update stats
        userStats.totalRawTime += completedSession.duration
        updateDailyHistory(duration: completedSession.duration)
        
        // Award points: 1 point per minute
        let pointsEarned = Int(completedSession.duration / 60)
        userStats.totalPoints += pointsEarned
        
        currentSession = nil
        stopTimer()
        
        // Save session to Firebase
        if let userId = currentUserId {
            Task {
                do {
                    try await firestoreManager.saveSession(userId: userId, session: completedSession)
                } catch {
                    print("Error saving session: \(error)")
                }
            }
        }
        
        // Auto-save to Firebase
        saveToFirebase()
    }
    
    func saveJournalEntry(thoughts: String) {
        guard let duration = completedSessionDuration else { return }
        let entry = JournalEntry(duration: duration, thoughts: thoughts)
        journalEntries.insert(entry, at: 0) // Add at beginning for newest first
        completedSessionDuration = nil
        
        // Save to Firebase
        saveToFirebase()
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
        
        // Update streak
        updateStreak()
    }
    
    private func updateStreak() {
        // Always recalculate streak based on dailyHistory
        // This ensures old/incorrect streak data from Firebase is ignored
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get current week start (Monday)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        guard let monday = calendar.date(from: components) else {
            userStats.dailyStreak = 0
            return
        }
        
        // Clean up old records - keep only last 30 days to avoid clutter
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        userStats.dailyHistory.removeAll { record in
            calendar.startOfDay(for: record.date) < thirtyDaysAgo
        }
        
        // Count unique days with activity in current week (Monday to today)
        var activeDaysThisWeek = Set<Date>()
        
        for record in userStats.dailyHistory {
            let recordDate = calendar.startOfDay(for: record.date)
            
            // Only count if: in current week, from Monday onwards, and not in future
            if recordDate >= monday && recordDate <= today {
                activeDaysThisWeek.insert(recordDate)
            }
        }
        
        // Set streak to number of active days this week
        userStats.dailyStreak = activeDaysThisWeek.count
    }
    
    // MARK: - Challenge Management
    func startChallenge(_ challenge: RawChallenge) {
        currentSession = RawSession()
        startTimer()
    }
    
    func completeChallenge(_ challenge: RawChallenge) {
        guard challenges.contains(where: { $0.id == challenge.id }) else { return }
        
        // Award bonus points for completing challenge: 2x the duration in minutes
        let bonusPoints = challenge.durationMinutes * 2
        userStats.totalPoints += bonusPoints
        
        // If this is a public challenge, check if user completed it before
        if challenge.isPublic, let userId = currentUserId {
            Task {
                do {
                    // Check if user has already completed this challenge
                    let hasCompleted = try await firestoreManager.hasUserCompletedChallenge(userId: userId, challengeId: challenge.id.uuidString)
                    
                    if !hasCompleted {
                        // First time completing - increment counter
                        try await firestoreManager.incrementChallengeCompletionCount(challengeId: challenge.id.uuidString)
                        
                        // Mark as completed for this user
                        try await firestoreManager.markChallengeAsCompleted(userId: userId, challengeId: challenge.id.uuidString)
                        
                        print("✅ First completion - counter incremented")
                    } else {
                        print("ℹ️ Already completed this challenge before - counter not incremented")
                    }
                    
                    // Update local publicChallenges array
                    if let index = publicChallenges.firstIndex(where: { $0.id == challenge.id }) {
                        await MainActor.run {
                            if !hasCompleted {
                                publicChallenges[index].usersCompletedCount += 1
                            }
                        }
                    }
                } catch {
                    print("Error handling challenge completion: \(error)")
                }
            }
        }
        
        // Save to Firebase
        saveToFirebase()
    }
    
    func toggleChallengeCompletion(_ challenge: RawChallenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].isCompleted.toggle()
            saveToFirebase()
        }
    }
    
    func markChallengeAsCompleted(_ challenge: RawChallenge) {
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].isCompleted = true
            saveToFirebase()
        }
    }
    
    func addChallenge(title: String, durationMinutes: Int) {
        let newChallenge = RawChallenge(title: title, durationMinutes: durationMinutes)
        challenges.append(newChallenge)
        saveToFirebase()
    }
    
    func deleteChallenge(_ challenge: RawChallenge) {
        print("🗑️ Deleting challenge: \(challenge.title), isCompleted: \(challenge.isCompleted), isPublic: \(challenge.isPublic)")
        
        // Remove from local challenges (works for completed and uncompleted)
        challenges.removeAll { $0.id == challenge.id }
        
        // If challenge was public, also remove from public challenges
        if challenge.isPublic {
            publicChallenges.removeAll { $0.id == challenge.id }
        }
        
        // Delete from Firebase
        guard let userId = currentUserId else {
            print("❌ No userId for deletion")
            return
        }
        
        Task {
            do {
                // Delete from user's challenges
                try await firestoreManager.deleteChallenge(userId: userId, challengeId: challenge.id.uuidString)
                print("✅ Deleted from user challenges")
                
                // If it was public, delete from public challenges too
                if challenge.isPublic {
                    try await firestoreManager.deletePublicChallenge(challengeId: challenge.id.uuidString)
                    print("✅ Deleted from public challenges")
                }
            } catch {
                print("❌ Error deleting challenge: \(error)")
            }
        }
    }
    
    func shareChallengeToPublic(_ challenge: RawChallenge) {
        guard let userId = currentUserId else { return }
        
        // Mark the challenge as public in user's own challenges
        if let index = challenges.firstIndex(where: { $0.id == challenge.id }) {
            challenges[index].isPublic = true
        }
        
        // Add to public challenges if not already there
        if !publicChallenges.contains(where: { $0.id == challenge.id }) {
            var publicChallenge = challenge
            publicChallenge.isPublic = true
            publicChallenge.usersCompletedCount = 1
            
            // Save to Firebase - real-time listener will update all users automatically
            Task {
                do {
                    try await firestoreManager.savePublicChallenge(challenge: publicChallenge, creatorId: userId)
                    print("✅ Public challenge saved - will appear for all users via listener")
                } catch {
                    print("Error saving public challenge: \(error)")
                }
            }
        }
        
        saveToFirebase()
    }
    
    // MARK: - Data Management
    func resetStreakData() {
        // Clear all daily history
        userStats.dailyHistory.removeAll()
        // Reset streak to 0
        userStats.dailyStreak = 0
        
        // Save to Firebase
        saveToFirebase()
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
    
    // MARK: - Account Deletion
    func deleteAccount() async throws {
        guard let userId = currentUserId else {
            throw NSError(domain: "AppStateManager", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        isLoading = true
        defer { 
            Task { @MainActor in
                self.isLoading = false
            }
        }
        
        do {
            // 1. Reauthenticate user (required by Firebase for account deletion)
            guard let currentUser = Auth.auth().currentUser else {
                throw NSError(domain: "AppStateManager", code: -2,
                             userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
            }
            
            // Check if user needs reauthentication
            // Firebase requires recent authentication for sensitive operations
            let metadata = currentUser.metadata
            if let lastSignIn = metadata.lastSignInDate,
               Date().timeIntervalSince(lastSignIn) > 300 { // 5 minutes
                // User needs to reauthenticate - throw specific error
                throw NSError(domain: "AppStateManager", code: -3,
                             userInfo: [NSLocalizedDescriptionKey: "Please sign in again to delete your account"])
            }
            
            // 2. Delete all Firestore data
            try await firestoreManager.deleteUserAccount(userId: userId)
            
            // 3. Delete Firebase Auth account
            try await currentUser.delete()
            
            // 4. Clear local data
            await MainActor.run {
                // Reset all app state
                self.currentUserId = nil
                self.userName = "Raw Dog"
                self.userEmail = nil
                self.userStats = UserStats(
                    dailyStreak: 0,
                    totalRawTime: 0,
                    totalPoints: 0,
                    dailyGoalMinutes: 60,
                    dailyHistory: []
                )
                self.challenges = []
                self.publicChallenges = []
                self.journalEntries = []
                self.leaderboard = []
                self.currentSession = nil
                
                // Clear UserDefaults
                UserDefaults.standard.set(false, forKey: "hasCompletedAuth")
                UserDefaults.standard.removeObject(forKey: "userId")
                
                // Force app restart to ensure clean state
                exit(0)
            }
            
        } catch {
            throw error
        }
    }
}

// MARK: - Localization Manager
struct LocalizationManager {
    static func translate(_ key: String, language: AppLanguage) -> String {
        guard let translation = translations[key]?[language.rawValue] else {
            return key // Return key if translation not found
        }
        return translation
    }
    
    private static let translations: [String: [String: String]] = [
        // MARK: - Tab Names
        "tab_home": [
            "de": "Start",
            "en": "Home",
            "es": "Inicio",
            "fr": "Accueil",
            "it": "Home",
            "pl": "Główna",
            "pt": "Início",
            "ru": "Главная",
            "tr": "Ana Sayfa",
            "uk": "Головна"
        ],
        "tab_challenge": [
            "de": "Herausforderung",
            "en": "Challenge",
            "es": "Desafío",
            "fr": "Défi",
            "it": "Sfida",
            "pl": "Wyzwanie",
            "pt": "Desafio",
            "ru": "Челлендж",
            "tr": "Meydan Okuma",
            "uk": "Виклик"
        ],
        "tab_journal": [
            "de": "Tagebuch",
            "en": "Journal",
            "es": "Diario",
            "fr": "Journal",
            "it": "Diario",
            "pl": "Dziennik",
            "pt": "Diário",
            "ru": "Дневник",
            "tr": "Günlük",
            "uk": "Щоденник"
        ],
        "tab_leaderboard": [
            "de": "Bestenliste",
            "en": "Leaderboard",
            "es": "Clasificación",
            "fr": "Classement",
            "it": "Classifica",
            "pl": "Ranking",
            "pt": "Classificação",
            "ru": "Лидерборд",
            "tr": "Sıralama",
            "uk": "Лідерборд"
        ],
        "tab_profile": [
            "de": "Profil",
            "en": "Profile",
            "es": "Perfil",
            "fr": "Profil",
            "it": "Profilo",
            "pl": "Profil",
            "pt": "Perfil",
            "ru": "Профиль",
            "tr": "Profil",
            "uk": "Профіль"
        ],
        
        // MARK: - Common UI Elements
        "continue": [
            "de": "Weiter",
            "en": "Continue",
            "es": "Continuar",
            "fr": "Continuer",
            "it": "Continua",
            "pl": "Kontynuuj",
            "pt": "Continuar",
            "ru": "Продолжить",
            "tr": "Devam Et",
            "uk": "Продовжити"
        ],
        "get_started": [
            "de": "Loslegen",
            "en": "Get Started",
            "es": "Comenzar",
            "fr": "Commencer",
            "it": "Inizia",
            "pl": "Rozpocznij",
            "pt": "Começar",
            "ru": "Начать",
            "tr": "Başla",
            "uk": "Почати"
        ],
        "start": [
            "de": "Start",
            "en": "Start",
            "es": "Iniciar",
            "fr": "Démarrer",
            "it": "Avvia",
            "pl": "Start",
            "pt": "Iniciar",
            "ru": "Старт",
            "tr": "Başlat",
            "uk": "Старт"
        ],
        "share": [
            "de": "Teilen",
            "en": "Share",
            "es": "Compartir",
            "fr": "Partager",
            "it": "Condividi",
            "pl": "Udostępnij",
            "pt": "Compartilhar",
            "ru": "Поделиться",
            "tr": "Paylaş",
            "uk": "Поділитися"
        ],
        "delete": [
            "de": "Löschen",
            "en": "Delete",
            "es": "Eliminar",
            "fr": "Supprimer",
            "it": "Elimina",
            "pl": "Usuń",
            "pt": "Excluir",
            "ru": "Удалить",
            "tr": "Sil",
            "uk": "Видалити"
        ],
        
        // MARK: - Language Selection Screen
        "language_selection_title": [
            "de": "Sprache wählen",
            "en": "Choose Language",
            "es": "Elegir idioma",
            "fr": "Choisir la langue",
            "it": "Scegli la lingua",
            "pl": "Wybierz język",
            "pt": "Escolher idioma",
            "ru": "Выберите язык",
            "tr": "Dil seçin",
            "uk": "Оберіть мову"
        ],
        "language_selection_subtitle": [
            "de": "Wählen Sie Ihre bevorzugte Sprache",
            "en": "Select your preferred language",
            "es": "Seleccione su idioma preferido",
            "fr": "Sélectionnez votre langue préférée",
            "it": "Seleziona la tua lingua preferita",
            "pl": "Wybierz preferowany język",
            "pt": "Selecione seu idioma preferido",
            "ru": "Выберите предпочитаемый язык",
            "tr": "Tercih ettiğiniz dili seçin",
            "uk": "Оберіть бажану мову"
        ],
        
        // MARK: - Onboarding
        "onboarding_welcome_title": [
            "de": "Willkommen bei Be Raw",
            "en": "Welcome to Be Raw",
            "es": "Bienvenido a Be Raw",
            "fr": "Bienvenue sur Be Raw",
            "it": "Benvenuto su Be Raw",
            "pl": "Witaj w Be Raw",
            "pt": "Bem-vindo ao Be Raw",
            "ru": "Добро пожаловать в Be Raw",
            "tr": "Be Raw'a Hoş Geldiniz",
            "uk": "Ласкаво просимо до Be Raw"
        ],
        "onboarding_welcome_description": [
            "de": "Erleben Sie das Leben ohne Ablenkungen. Seien Sie präsent im Moment.",
            "en": "Experience life without distractions. Be present in the moment.",
            "es": "Experimenta la vida sin distracciones. Vive el momento presente.",
            "fr": "Vivez sans distractions. Soyez présent dans l'instant.",
            "it": "Vivi la vita senza distrazioni. Sii presente nel momento.",
            "pl": "Doświadcz życia bez rozpraszaczy. Bądź obecny w chwili.",
            "pt": "Viva sem distrações. Esteja presente no momento.",
            "ru": "Почувствуй жизнь без отвлечений. Будь здесь и сейчас.",
            "tr": "Hayatı dikkat dağıtıcılardan uzak yaşayın. Anın içinde olun.",
            "uk": "Відчуй життя без відволікань. Будь у моменті."
        ],
        "onboarding_track_title": [
            "de": "Verfolgen Sie Ihre Reise",
            "en": "Track Your Journey",
            "es": "Rastrea tu camino",
            "fr": "Suivez votre parcours",
            "it": "Traccia il tuo percorso",
            "pl": "Śledź swoją podróż",
            "pt": "Acompanhe sua jornada",
            "ru": "Отслеживай свой путь",
            "tr": "Yolculuğunuzu Takip Edin",
            "uk": "Відстежуй свій шлях"
        ],
        "onboarding_track_description": [
            "de": "Sehen Sie Ihren Fortschritt mit detaillierten Statistiken und Strähnen.",
            "en": "Monitor your progress with detailed stats and streaks.",
            "es": "Monitorea tu progreso con estadísticas detalladas y rachas.",
            "fr": "Suivez vos progrès avec des statistiques détaillées.",
            "it": "Monitora i tuoi progressi con statistiche dettagliate.",
            "pl": "Śledź swoje postępy dzięki szczegółowym statystykom.",
            "pt": "Monitore seu progresso com estatísticas detalhadas.",
            "ru": "Следи за прогрессом с детальной статистикой.",
            "tr": "Detaylı istatistiklerle ilerlemenizi izleyin.",
            "uk": "Відстежуй прогрес з детальною статистикою."
        ],
        "onboarding_challenges_title": [
            "de": "Nehmen Sie Herausforderungen an",
            "en": "Take on Challenges",
            "es": "Acepta desafíos",
            "fr": "Relevez des défis",
            "it": "Affronta le sfide",
            "pl": "Podejmuj wyzwania",
            "pt": "Aceite desafios",
            "ru": "Принимай челленджи",
            "tr": "Meydan Okumaları Kabul Edin",
            "uk": "Приймай виклики"
        ],
        "onboarding_challenges_description": [
            "de": "Fordern Sie sich selbst heraus und werden Sie Teil einer Gemeinschaft von Menschen.",
            "en": "Push yourself and join a community of like-minded individuals.",
            "es": "Desafíate y únete a una comunidad de personas afines.",
            "fr": "Dépassez-vous et rejoignez une communauté de personnes motivées.",
            "it": "Mettiti alla prova e unisciti a una comunità di persone simili.",
            "pl": "Rzuć sobie wyzwanie i dołącz do społeczności podobnie myślących osób.",
            "pt": "Desafie-se e junte-se a uma comunidade de pessoas.",
            "ru": "Испытай себя и присоединись к сообществу единомышленников.",
            "tr": "Kendinize meydan okuyun ve benzer düşünen insanlarla tanışın.",
            "uk": "Випробуй себе і приєднайся до спільноти однодумців."
        ],
        
        // MARK: - Auth Screen
        "auth_title": [
            "de": "Be Raw",
            "en": "Be Raw",
            "es": "Be Raw",
            "fr": "Be Raw",
            "it": "Be Raw",
            "pl": "Be Raw",
            "pt": "Be Raw",
            "ru": "Be Raw",
            "tr": "Be Raw",
            "uk": "Be Raw"
        ],
        "auth_subtitle": [
            "de": "Anmelden, um fortzufahren",
            "en": "Sign in to continue",
            "es": "Inicia sesión para continuar",
            "fr": "Connectez-vous pour continuer",
            "it": "Accedi per continuare",
            "pl": "Zaloguj się, aby kontynuować",
            "pt": "Entre para continuar",
            "ru": "Войдите, чтобы продолжить",
            "tr": "Devam etmek için giriş yapın",
            "uk": "Увійдіть, щоб продовжити"
        ],
        "auth_apple": [
            "de": "Mit Apple fortfahren",
            "en": "Continue with Apple",
            "es": "Continuar con Apple",
            "fr": "Continuer avec Apple",
            "it": "Continua con Apple",
            "pl": "Kontynuuj z Apple",
            "pt": "Continuar com Apple",
            "ru": "Продолжить с Apple",
            "tr": "Apple ile Devam Et",
            "uk": "Продовжити з Apple"
        ],
        "auth_google": [
            "de": "Mit Google fortfahren",
            "en": "Continue with Google",
            "es": "Continuar con Google",
            "fr": "Continuer avec Google",
            "it": "Continua con Google",
            "pl": "Kontynuuj z Google",
            "pt": "Continuar com Google",
            "ru": "Продолжить с Google",
            "tr": "Google ile Devam Et",
            "uk": "Продовжити з Google"
        ],
        "auth_terms_prefix": [
            "de": "Mit der Fortsetzung stimmen Sie unseren",
            "en": "By continuing, you agree to our",
            "es": "Al continuar, aceptas nuestros",
            "fr": "En continuant, vous acceptez nos",
            "it": "Continuando, accetti i nostri",
            "pl": "Kontynuując, akceptujesz nasze",
            "pt": "Ao continuar, você concorda com nossos",
            "ru": "Продолжая, вы соглашаетесь с нашими",
            "tr": "Devam ederek şunları kabul ediyorsunuz:",
            "uk": "Продовжуючи, ви погоджуєтесь з нашими"
        ],
        "auth_terms": [
            "de": "Nutzungsbedingungen",
            "en": "Terms of Service",
            "es": "Términos de servicio",
            "fr": "Conditions d'utilisation",
            "it": "Termini di servizio",
            "pl": "Warunki korzystania",
            "pt": "Termos de serviço",
            "ru": "Условиями использования",
            "tr": "Hizmet Şartları",
            "uk": "Умовами використання"
        ],
        "auth_and": [
            "de": "und",
            "en": "and",
            "es": "y",
            "fr": "et",
            "it": "e",
            "pl": "i",
            "pt": "e",
            "ru": "и",
            "tr": "ve",
            "uk": "та"
        ],
        "auth_privacy": [
            "de": "Datenschutzrichtlinie",
            "en": "Privacy Policy",
            "es": "Política de privacidad",
            "fr": "Politique de confidentialité",
            "it": "Informativa sulla privacy",
            "pl": "Polityka prywatności",
            "pt": "Política de privacidade",
            "ru": "Политикой конфиденциальности",
            "tr": "Gizlilik Politikası",
            "uk": "Політикою конфіденційності"
        ],
        
        // MARK: - Paywall
        "paywall_title": [
            "de": "Be Raw Premium",
            "en": "Be Raw Premium",
            "es": "Be Raw Premium",
            "fr": "Be Raw Premium",
            "it": "Be Raw Premium",
            "pl": "Be Raw Premium",
            "pt": "Be Raw Premium",
            "ru": "Be Raw Premium",
            "tr": "Be Raw Premium",
            "uk": "Be Raw Premium"
        ],
        "paywall_subtitle": [
            "de": "Erleben Sie das volle Potenzial",
            "en": "Unlock the full experience",
            "es": "Desbloquea la experiencia completa",
            "fr": "Débloquez l'expérience complète",
            "it": "Sblocca l'esperienza completa",
            "pl": "Odblokuj pełne doświadczenie",
            "pt": "Desbloqueie a experiência completa",
            "ru": "Открой полный потенциал",
            "tr": "Tam deneyimin kilidini açın",
            "uk": "Розблокуй повний досвід"
        ],
        "paywall_feature_unlimited": [
            "de": "Unbegrenzte Sitzungen",
            "en": "Unlimited Sessions",
            "es": "Sesiones ilimitadas",
            "fr": "Sessions illimitées",
            "it": "Sessioni illimitate",
            "pl": "Nieograniczone sesje",
            "pt": "Sessões ilimitadas",
            "ru": "Неограниченные сессии",
            "tr": "Sınırsız Oturum",
            "uk": "Необмежені сесії"
        ],
        "paywall_feature_leaderboard": [
            "de": "Zugang zur Bestenliste",
            "en": "Access to Leaderboard",
            "es": "Acceso a la clasificación",
            "fr": "Accès au classement",
            "it": "Accesso alla classifica",
            "pl": "Dostęp do rankingu",
            "pt": "Acesso à classificação",
            "ru": "Доступ к лидерборду",
            "tr": "Sıralamaya Erişim",
            "uk": "Доступ до лідерборду"
        ],
        "paywall_feature_challenges": [
            "de": "Exklusive Herausforderungen",
            "en": "Exclusive Challenges",
            "es": "Desafíos exclusivos",
            "fr": "Défis exclusifs",
            "it": "Sfide esclusive",
            "pl": "Ekskluzywne wyzwania",
            "pt": "Desafios exclusivos",
            "ru": "Эксклюзивные челленджи",
            "tr": "Özel Meydan Okumalar",
            "uk": "Ексклюзивні виклики"
        ],
        "paywall_feature_support": [
            "de": "Vorrangiger Support",
            "en": "Priority Support",
            "es": "Soporte prioritario",
            "fr": "Support prioritaire",
            "it": "Supporto prioritario",
            "pl": "Wsparcie priorytetowe",
            "pt": "Suporte prioritário",
            "ru": "Приоритетная поддержка",
            "tr": "Öncelikli Destek",
            "uk": "Пріоритетна підтримка"
        ],
        "paywall_yearly": [
            "de": "Jährlich",
            "en": "Yearly",
            "es": "Anual",
            "fr": "Annuel",
            "it": "Annuale",
            "pl": "Rocznie",
            "pt": "Anual",
            "ru": "Годовая",
            "tr": "Yıllık",
            "uk": "Річна"
        ],
        "paywall_weekly": [
            "de": "Wöchentlich",
            "en": "Weekly",
            "es": "Semanal",
            "fr": "Hebdomadaire",
            "it": "Settimanale",
            "pl": "Tygodniowo",
            "pt": "Semanal",
            "ru": "Недельная",
            "tr": "Haftalık",
            "uk": "Тижнева"
        ],
        "paywall_save": [
            "de": "SPARE 40%",
            "en": "SAVE 40%",
            "es": "AHORRA 40%",
            "fr": "ÉCONOMISEZ 40%",
            "it": "RISPARMIA 40%",
            "pl": "OSZCZĘDŹ 40%",
            "pt": "ECONOMIZE 40%",
            "ru": "СКИДКА 40%",
            "tr": "%40 TASARRUf",
            "uk": "ЗНИЖКА 40%"
        ],
        "paywall_price_yearly": [
            "de": "49,99 €/Jahr",
            "en": "$49.99/year",
            "es": "49,99 €/año",
            "fr": "49,99 €/an",
            "it": "49,99 €/anno",
            "pl": "49,99 zł/rok",
            "pt": "49,99 €/ano",
            "ru": "49,99 ₽/год",
            "tr": "49,99 ₺/yıl",
            "uk": "49,99 ₴/рік"
        ],
        "paywall_price_weekly": [
            "de": "1,99 €/Woche",
            "en": "$1.99/week",
            "es": "1,99 €/semana",
            "fr": "1,99 €/semaine",
            "it": "1,99 €/settimana",
            "pl": "1,99 zł/tydzień",
            "pt": "1,99 €/semana",
            "ru": "1,99 ₽/неделя",
            "tr": "1,99 ₺/hafta",
            "uk": "1,99 ₴/тиждень"
        ],
        "paywall_terms_prefix": [
            "de": "Durch Fortsetzen stimmen Sie unseren",
            "en": "By continuing, you agree to our",
            "es": "Al continuar, aceptas nuestros",
            "fr": "En continuant, vous acceptez nos",
            "it": "Continuando, accetti i nostri",
            "pl": "Kontynuując, akceptujesz nasze",
            "pt": "Ao continuar, você concorda com nossos",
            "ru": "Продолжая, вы соглашаетесь с",
            "tr": "Devam ederek şunları kabul ediyorsunuz:",
            "uk": "Продовжуючи, ви погоджуєтесь з"
        ],
        
        // MARK: - Home Screen
        "home_title": [
            "de": "Startseite",
            "en": "Home",
            "es": "Inicio",
            "fr": "Accueil",
            "it": "Home",
            "pl": "Główna",
            "pt": "Início",
            "ru": "Главная",
            "tr": "Ana Sayfa",
            "uk": "Головна"
        ],
        "home_daily_goal": [
            "de": "Tägliches Ziel",
            "en": "Daily Goal",
            "es": "Objetivo diario",
            "fr": "Objectif quotidien",
            "it": "Obiettivo giornaliero",
            "pl": "Codzienny cel",
            "pt": "Meta diária",
            "ru": "Дневная цель",
            "tr": "Günlük Hedef",
            "uk": "Щоденна ціль"
        ],
        "home_streak": [
            "de": "Serie",
            "en": "Streak",
            "es": "Racha",
            "fr": "Série",
            "it": "Serie",
            "pl": "Passa",
            "pt": "Sequência",
            "ru": "Серия",
            "tr": "Seri",
            "uk": "Серія"
        ],
        "home_total_time": [
            "de": "Gesamtzeit",
            "en": "Total Time",
            "es": "Tiempo total",
            "fr": "Temps total",
            "it": "Tempo totale",
            "pl": "Całkowity czas",
            "pt": "Tempo total",
            "ru": "Всего времени",
            "tr": "Toplam Süre",
            "uk": "Загальний час"
        ],
        "home_start_session": [
            "de": "Sitzung starten",
            "en": "Start Session",
            "es": "Iniciar sesión",
            "fr": "Démarrer une session",
            "it": "Avvia sessione",
            "pl": "Rozpocznij sesję",
            "pt": "Iniciar sessão",
            "ru": "Начать сессию",
            "tr": "Oturumu Başlat",
            "uk": "Почати сесію"
        ],
        
        // MARK: - Challenge Screen
        "challenge_title": [
            "de": "Herausforderungen",
            "en": "Challenges",
            "es": "Desafíos",
            "fr": "Défis",
            "it": "Sfide",
            "pl": "Wyzwania",
            "pt": "Desafios",
            "ru": "Челленджи",
            "tr": "Meydan Okumalar",
            "uk": "Виклики"
        ],
        "challenge_create": [
            "de": "Herausforderung erstellen",
            "en": "Create Challenge",
            "es": "Crear desafío",
            "fr": "Créer un défi",
            "it": "Crea sfida",
            "pl": "Utwórz wyzwanie",
            "pt": "Criar desafio",
            "ru": "Создать челлендж",
            "tr": "Meydan Okuma Oluştur",
            "uk": "Створити виклик"
        ],
        "challenge_my": [
            "de": "Meine Herausforderungen",
            "en": "My Challenges",
            "es": "Mis desafíos",
            "fr": "Mes défis",
            "it": "Le mie sfide",
            "pl": "Moje wyzwania",
            "pt": "Meus desafios",
            "ru": "Мои челленджи",
            "tr": "Meydan Okumalarım",
            "uk": "Мої виклики"
        ],
        "challenge_public": [
            "de": "Öffentliche Herausforderungen",
            "en": "Public Challenges",
            "es": "Desafíos públicos",
            "fr": "Défis publics",
            "it": "Sfide pubbliche",
            "pl": "Wyzwania publiczne",
            "pt": "Desafios públicos",
            "ru": "Публичные челленджи",
            "tr": "Genel Meydan Okumalar",
            "uk": "Публічні виклики"
        ],
        "challenge_minutes": [
            "de": "Minuten",
            "en": "minutes",
            "es": "minutos",
            "fr": "minutes",
            "it": "minuti",
            "pl": "minut",
            "pt": "minutos",
            "ru": "минут",
            "tr": "dakika",
            "uk": "хвилин"
        ],
        
        // MARK: - Premium Locked
        "premium_locked_title": [
            "de": "Premium-Funktion",
            "en": "Premium Feature",
            "es": "Función Premium",
            "fr": "Fonctionnalité Premium",
            "it": "Funzione Premium",
            "pl": "Funkcja Premium",
            "pt": "Recurso Premium",
            "ru": "Премиум функция",
            "tr": "Premium Özellik",
            "uk": "Преміум функція"
        ],
        "premium_unlock_challenges": [
            "de": "Entsperren Sie Herausforderungen mit Premium",
            "en": "Unlock Challenges with Premium",
            "es": "Desbloquea Desafíos con Premium",
            "fr": "Débloquez les Défis avec Premium",
            "it": "Sblocca le Sfide con Premium",
            "pl": "Odblokuj Wyzwania z Premium",
            "pt": "Desbloqueie Desafios com Premium",
            "ru": "Открой Челленджи с Premium",
            "tr": "Premium ile Meydan Okumaların Kilidini Açın",
            "uk": "Розблокуй Виклики з Premium"
        ],
        "premium_unlock_leaderboard": [
            "de": "Entsperren Sie die Bestenliste mit Premium",
            "en": "Unlock Leaderboard with Premium",
            "es": "Desbloquea la Clasificación con Premium",
            "fr": "Débloquez le Classement avec Premium",
            "it": "Sblocca la Classifica con Premium",
            "pl": "Odblokuj Ranking z Premium",
            "pt": "Desbloqueie a Classificação com Premium",
            "ru": "Открой Лидерборд с Premium",
            "tr": "Premium ile Sıralama Kilidini Açın",
            "uk": "Розблокуй Лідерборд з Premium"
        ],
        "premium_tap_to_unlock": [
            "de": "Tippen Sie irgendwo, um Premium freizuschalten",
            "en": "Tap anywhere to unlock with Premium",
            "es": "Toca en cualquier lugar para desbloquear con Premium",
            "fr": "Appuyez n'importe où pour débloquer avec Premium",
            "it": "Tocca ovunque per sbloccare con Premium",
            "pl": "Dotknij w dowolnym miejscu, aby odblokować Premium",
            "pt": "Toque em qualquer lugar para desbloquear com Premium",
            "ru": "Нажмите в любом месте, чтобы разблокировать Premium",
            "tr": "Premium ile kilidi açmak için herhangi bir yere dokunun",
            "uk": "Натисніть будь-де, щоб розблокувати Premium"
        ],
        
        // MARK: - Home Screen Extended
        "home_days": [
            "de": "Tage",
            "en": "days",
            "es": "días",
            "fr": "jours",
            "it": "giorni",
            "pl": "dni",
            "pt": "dias",
            "ru": "дней",
            "tr": "gün",
            "uk": "днів"
        ],
        "home_hrs": [
            "de": "Std",
            "en": "hrs",
            "es": "hrs",
            "fr": "hrs",
            "it": "ore",
            "pl": "godz",
            "pt": "hrs",
            "ru": "ч",
            "tr": "saat",
            "uk": "год"
        ],
        "home_min": [
            "de": "Min",
            "en": "min",
            "es": "min",
            "fr": "min",
            "it": "min",
            "pl": "min",
            "pt": "min",
            "ru": "мин",
            "tr": "dk",
            "uk": "хв"
        ],
        "home_today": [
            "de": "Heute",
            "en": "Today",
            "es": "Hoy",
            "fr": "Aujourd'hui",
            "it": "Oggi",
            "pl": "Dzisiaj",
            "pt": "Hoje",
            "ru": "Сегодня",
            "tr": "Bugün",
            "uk": "Сьогодні"
        ],
        "home_this_week": [
            "de": "Diese Woche",
            "en": "This Week",
            "es": "Esta semana",
            "fr": "Cette semaine",
            "it": "Questa settimana",
            "pl": "Ten tydzień",
            "pt": "Esta semana",
            "ru": "На этой неделе",
            "tr": "Bu Hafta",
            "uk": "Цього тижня"
        ],
        "home_stop_session": [
            "de": "Sitzung beenden",
            "en": "Stop Session",
            "es": "Detener sesión",
            "fr": "Arrêter la session",
            "it": "Ferma sessione",
            "pl": "Zatrzymaj sesję",
            "pt": "Parar sessão",
            "ru": "Остановить сессию",
            "tr": "Oturumu Durdur",
            "uk": "Зупинити сесію"
        ],
        
        // MARK: - Challenge Screen Extended
        "challenge_enter_title": [
            "de": "Titel eingeben",
            "en": "Enter title",
            "es": "Ingrese el título",
            "fr": "Entrez le titre",
            "it": "Inserisci il titolo",
            "pl": "Wprowadź tytuł",
            "pt": "Digite o título",
            "ru": "Введите название",
            "tr": "Başlık girin",
            "uk": "Введіть назву"
        ],
        "challenge_duration": [
            "de": "Dauer (Minuten)",
            "en": "Duration (minutes)",
            "es": "Duración (minutos)",
            "fr": "Durée (minutes)",
            "it": "Durata (minuti)",
            "pl": "Czas trwania (minuty)",
            "pt": "Duração (minutos)",
            "ru": "Длительность (минуты)",
            "tr": "Süre (dakika)",
            "uk": "Тривалість (хвилини)"
        ],
        "challenge_make_public": [
            "de": "Öffentlich machen",
            "en": "Make Public",
            "es": "Hacer público",
            "fr": "Rendre public",
            "it": "Rendi pubblico",
            "pl": "Upublicznij",
            "pt": "Tornar público",
            "ru": "Сделать публичным",
            "tr": "Herkese Açık Yap",
            "uk": "Зробити публічним"
        ],
        "challenge_create_new": [
            "de": "Neue Herausforderung erstellen",
            "en": "Create New Challenge",
            "es": "Crear nuevo desafío",
            "fr": "Créer un nouveau défi",
            "it": "Crea nuova sfida",
            "pl": "Utwórz nowe wyzwanie",
            "pt": "Criar novo desafio",
            "ru": "Создать новый челлендж",
            "tr": "Yeni Meydan Okuma Oluştur",
            "uk": "Створити новий виклик"
        ],
        "challenge_cancel": [
            "de": "Abbrechen",
            "en": "Cancel",
            "es": "Cancelar",
            "fr": "Annuler",
            "it": "Annulla",
            "pl": "Anuluj",
            "pt": "Cancelar",
            "ru": "Отмена",
            "tr": "İptal",
            "uk": "Скасувати"
        ],
        "challenge_create_button": [
            "de": "Erstellen",
            "en": "Create",
            "es": "Crear",
            "fr": "Créer",
            "it": "Crea",
            "pl": "Utwórz",
            "pt": "Criar",
            "ru": "Создать",
            "tr": "Oluştur",
            "uk": "Створити"
        ],
        "challenge_completed": [
            "de": "Abgeschlossen",
            "en": "Completed",
            "es": "Completado",
            "fr": "Terminé",
            "it": "Completato",
            "pl": "Ukończono",
            "pt": "Concluído",
            "ru": "Завершено",
            "tr": "Tamamlandı",
            "uk": "Завершено"
        ],
        "challenge_users_completed": [
            "de": "Benutzer abgeschlossen",
            "en": "users completed",
            "es": "usuarios completados",
            "fr": "utilisateurs terminés",
            "it": "utenti completati",
            "pl": "użytkowników ukończyło",
            "pt": "usuários concluídos",
            "ru": "пользователей завершили",
            "tr": "kullanıcı tamamladı",
            "uk": "користувачів завершили"
        ],
        "challenge_done": [
            "de": "Fertig",
            "en": "Done",
            "es": "Listo",
            "fr": "Terminé",
            "it": "Fatto",
            "pl": "Gotowe",
            "pt": "Concluído",
            "ru": "Готово",
            "tr": "Bitti",
            "uk": "Готово"
        ],
        "challenge_failed_title": [
            "de": "Du hast verloren!",
            "en": "You Lost!",
            "es": "¡Perdiste!",
            "fr": "Tu as perdu !",
            "it": "Hai perso!",
            "pl": "Przegrałeś!",
            "pt": "Você perdeu!",
            "ru": "Ты проиграл!",
            "tr": "Kaybettin!",
            "uk": "Ти програв!"
        ],
        "challenge_failed_message": [
            "de": "Du hast die App während der Challenge verlassen. Der Timer wurde gestoppt.",
            "en": "You left the app during the challenge. The timer has been stopped.",
            "es": "Saliste de la app durante el desafío. El temporizador se ha detenido.",
            "fr": "Tu as quitté l'app pendant le défi. Le chronomètre a été arrêté.",
            "it": "Hai lasciato l'app durante la sfida. Il timer è stato fermato.",
            "pl": "Opuściłeś aplikację podczas wyzwania. Timer został zatrzymany.",
            "pt": "Você saiu do app durante o desafio. O cronômetro foi parado.",
            "ru": "Ты вышел из приложения во время челленджа. Таймер остановлен.",
            "tr": "Meydan okuma sırasında uygulamadan çıktın. Zamanlayıcı durduruldu.",
            "uk": "Ти вийшов з додатку під час виклику. Таймер зупинено."
        ],
        
        // MARK: - Journal Screen
        "journal_title": [
            "de": "Tagebuch",
            "en": "Journal",
            "es": "Diario",
            "fr": "Journal",
            "it": "Diario",
            "pl": "Dziennik",
            "pt": "Diário",
            "ru": "Дневник",
            "tr": "Günlük",
            "uk": "Щоденник"
        ],
        "journal_add_entry": [
            "de": "Eintrag hinzufügen",
            "en": "Add Entry",
            "es": "Agregar entrada",
            "fr": "Ajouter une entrée",
            "it": "Aggiungi voce",
            "pl": "Dodaj wpis",
            "pt": "Adicionar entrada",
            "ru": "Добавить запись",
            "tr": "Giriş Ekle",
            "uk": "Додати запис"
        ],
        "journal_entry_title": [
            "de": "Tagebucheintrag",
            "en": "Journal Entry",
            "es": "Entrada de diario",
            "fr": "Entrée de journal",
            "it": "Voce del diario",
            "pl": "Wpis dziennika",
            "pt": "Entrada de diário",
            "ru": "Запись в дневнике",
            "tr": "Günlük Girişi",
            "uk": "Запис щоденника"
        ],
        "journal_write_thoughts": [
            "de": "Schreiben Sie Ihre Gedanken...",
            "en": "Write your thoughts...",
            "es": "Escribe tus pensamientos...",
            "fr": "Écrivez vos pensées...",
            "it": "Scrivi i tuoi pensieri...",
            "pl": "Napisz swoje myśli...",
            "pt": "Escreva seus pensamentos...",
            "ru": "Напишите свои мысли...",
            "tr": "Düşüncelerinizi yazın...",
            "uk": "Напишіть свої думки..."
        ],
        "journal_save": [
            "de": "Speichern",
            "en": "Save",
            "es": "Guardar",
            "fr": "Enregistrer",
            "it": "Salva",
            "pl": "Zapisz",
            "pt": "Salvar",
            "ru": "Сохранить",
            "tr": "Kaydet",
            "uk": "Зберегти"
        ],
        "journal_session_duration": [
            "de": "Sitzungsdauer",
            "en": "Session Duration",
            "es": "Duración de la sesión",
            "fr": "Durée de la session",
            "it": "Durata della sessione",
            "pl": "Czas trwania sesji",
            "pt": "Duração da sessão",
            "ru": "Длительность сессии",
            "tr": "Oturum Süresi",
            "uk": "Тривалість сесії"
        ],
        
        // MARK: - Leaderboard Screen
        "leaderboard_title": [
            "de": "Bestenliste",
            "en": "Leaderboard",
            "es": "Clasificación",
            "fr": "Classement",
            "it": "Classifica",
            "pl": "Ranking",
            "pt": "Classificação",
            "ru": "Лидерборд",
            "tr": "Sıralama",
            "uk": "Лідерборд"
        ],
        "leaderboard_rank": [
            "de": "Rang",
            "en": "Rank",
            "es": "Rango",
            "fr": "Rang",
            "it": "Rango",
            "pl": "Ranga",
            "pt": "Classificação",
            "ru": "Ранг",
            "tr": "Sıra",
            "uk": "Ранг"
        ],
        "leaderboard_points": [
            "de": "Punkte",
            "en": "points",
            "es": "puntos",
            "fr": "points",
            "it": "punti",
            "pl": "punkty",
            "pt": "pontos",
            "ru": "очков",
            "tr": "puan",
            "uk": "очок"
        ],
        
        // MARK: - Profile Screen
        "profile_settings": [
            "de": "Einstellungen",
            "en": "Settings",
            "es": "Configuración",
            "fr": "Paramètres",
            "it": "Impostazioni",
            "pl": "Ustawienia",
            "pt": "Configurações",
            "ru": "Настройки",
            "tr": "Ayarlar",
            "uk": "Налаштування"
        ],
        "profile_upgrade_premium": [
            "de": "Auf Premium upgraden",
            "en": "Upgrade to Premium",
            "es": "Actualizar a Premium",
            "fr": "Passer à Premium",
            "it": "Passa a Premium",
            "pl": "Przejdź na Premium",
            "pt": "Atualizar para Premium",
            "ru": "Перейти на Premium",
            "tr": "Premium'a Yükselt",
            "uk": "Перейти на Premium"
        ],
        "profile_restore_purchases": [
            "de": "Käufe wiederherstellen",
            "en": "Restore Purchases",
            "es": "Restaurar compras",
            "fr": "Restaurer les achats",
            "it": "Ripristina acquisti",
            "pl": "Przywróć zakupy",
            "pt": "Restaurar compras",
            "ru": "Восстановить покупки",
            "tr": "Satın Almaları Geri Yükle",
            "uk": "Відновити покупки"
        ],
        "profile_edit": [
            "de": "Bearbeiten",
            "en": "Edit",
            "es": "Editar",
            "fr": "Modifier",
            "it": "Modifica",
            "pl": "Edytuj",
            "pt": "Editar",
            "ru": "Редактировать",
            "tr": "Düzenle",
            "uk": "Редагувати"
        ],
        
        // MARK: - Share Challenge Sheet
        "share_challenge_title": [
            "de": "Herausforderung teilen",
            "en": "Share Challenge",
            "es": "Compartir desafío",
            "fr": "Partager le défi",
            "it": "Condividi sfida",
            "pl": "Udostępnij wyzwanie",
            "pt": "Compartilhar desafio",
            "ru": "Поделиться челленджем",
            "tr": "Meydan Okumayı Paylaş",
            "uk": "Поділитися викликом"
        ],
        "share_published_public": [
            "de": "Öffentlich veröffentlicht",
            "en": "Published to Public",
            "es": "Publicado públicamente",
            "fr": "Publié publiquement",
            "it": "Pubblicato pubblicamente",
            "pl": "Opublikowano publicznie",
            "pt": "Publicado publicamente",
            "ru": "Опубликовано публично",
            "tr": "Herkese Açık Yayınlandı",
            "uk": "Опубліковано публічно"
        ],
        "share_challenge_link": [
            "de": "Herausforderungslink",
            "en": "Challenge Link",
            "es": "Enlace del desafío",
            "fr": "Lien du défi",
            "it": "Link della sfida",
            "pl": "Link do wyzwania",
            "pt": "Link do desafio",
            "ru": "Ссылка на челлендж",
            "tr": "Meydan Okuma Bağlantısı",
            "uk": "Посилання на виклик"
        ],
        "share_copy_link": [
            "de": "Link kopieren",
            "en": "Copy Link",
            "es": "Copiar enlace",
            "fr": "Copier le lien",
            "it": "Copia link",
            "pl": "Kopiuj link",
            "pt": "Copiar link",
            "ru": "Скопировать ссылку",
            "tr": "Bağlantıyı Kopyala",
            "uk": "Скопіювати посилання"
        ],
        "share_link_copied": [
            "de": "Link kopiert!",
            "en": "Link Copied!",
            "es": "¡Enlace copiado!",
            "fr": "Lien copié!",
            "it": "Link copiato!",
            "pl": "Link skopiowany!",
            "pt": "Link copiado!",
            "ru": "Ссылка скопирована!",
            "tr": "Bağlantı Kopyalandı!",
            "uk": "Посилання скопійовано!"
        ],
        "share_done": [
            "de": "Fertig",
            "en": "Done",
            "es": "Listo",
            "fr": "Terminé",
            "it": "Fatto",
            "pl": "Gotowe",
            "pt": "Concluído",
            "ru": "Готово",
            "tr": "Tamam",
            "uk": "Готово"
        ],
        "share_with_friends": [
            "de": "Mit Freunden teilen",
            "en": "Share with Friends",
            "es": "Compartir con amigos",
            "fr": "Partager avec des amis",
            "it": "Condividi con gli amici",
            "pl": "Udostępnij znajomym",
            "pt": "Compartilhar com amigos",
            "ru": "Поделиться с друзьями",
            "tr": "Arkadaşlarla Paylaş",
            "uk": "Поділитися з друзями"
        ],
        
        // MARK: - Home Screen Blocks
        "home_activity": [
            "de": "Aktivität",
            "en": "Activity",
            "es": "Actividad",
            "fr": "Activité",
            "it": "Attività",
            "pl": "Aktywność",
            "pt": "Atividade",
            "ru": "Активность",
            "tr": "Etkinlik",
            "uk": "Активність"
        ],
        "home_last_7_days": [
            "de": "Letzte 7 Tage",
            "en": "Last 7 Days",
            "es": "Últimos 7 días",
            "fr": "7 derniers jours",
            "it": "Ultimi 7 giorni",
            "pl": "Ostatnie 7 dni",
            "pt": "Últimos 7 dias",
            "ru": "Последние 7 дней",
            "tr": "Son 7 Gün",
            "uk": "Останні 7 днів"
        ],
        "home_day_streak": [
            "de": "Tagessträhne",
            "en": "Day Streak",
            "es": "Racha de días",
            "fr": "Série de jours",
            "it": "Serie di giorni",
            "pl": "Passa dni",
            "pt": "Sequência de dias",
            "ru": "Дневная серия",
            "tr": "Günlük Seri",
            "uk": "Денна серія"
        ],
        "home_completed_challenges": [
            "de": "Abgeschlossene Herausforderungen",
            "en": "Completed Challenges",
            "es": "Desafíos completados",
            "fr": "Défis terminés",
            "it": "Sfide completate",
            "pl": "Ukończone wyzwania",
            "pt": "Desafios concluídos",
            "ru": "Завершённые челленджи",
            "tr": "Tamamlanan Meydan Okumalar",
            "uk": "Завершені виклики"
        ],
        "home_total_points": [
            "de": "Gesamtpunkte",
            "en": "Total Points",
            "es": "Puntos totales",
            "fr": "Points totaux",
            "it": "Punti totali",
            "pl": "Łączne punkty",
            "pt": "Pontos totais",
            "ru": "Всего очков",
            "tr": "Toplam Puan",
            "uk": "Всього очок"
        ],
        "home_journal_entries": [
            "de": "Tagebucheinträge",
            "en": "Journal Entries",
            "es": "Entradas de diario",
            "fr": "Entrées de journal",
            "it": "Voci del diario",
            "pl": "Wpisy dziennika",
            "pt": "Entradas de diário",
            "ru": "Записи в дневнике",
            "tr": "Günlük Girişleri",
            "uk": "Записи щоденника"
        ],
        "home_recent_entries": [
            "de": "Neueste Einträge",
            "en": "Recent Entries",
            "es": "Entradas recientes",
            "fr": "Entrées récentes",
            "it": "Voci recenti",
            "pl": "Ostatnie wpisy",
            "pt": "Entradas recentes",
            "ru": "Недавние записи",
            "tr": "Son Girişler",
            "uk": "Останні записи"
        ],
        "home_view_all": [
            "de": "Alle anzeigen",
            "en": "View All",
            "es": "Ver todo",
            "fr": "Tout voir",
            "it": "Vedi tutto",
            "pl": "Zobacz wszystko",
            "pt": "Ver tudo",
            "ru": "Посмотреть все",
            "tr": "Tümünü Gör",
            "uk": "Переглянути все"
        ],
        
        // MARK: - Profile Screen Extended
        "profile_title": [
            "de": "Profil",
            "en": "Profile",
            "es": "Perfil",
            "fr": "Profil",
            "it": "Profilo",
            "pl": "Profil",
            "pt": "Perfil",
            "ru": "Профиль",
            "tr": "Profil",
            "uk": "Профіль"
        ],
        "profile_username": [
            "de": "Benutzername",
            "en": "Username",
            "es": "Nombre de usuario",
            "fr": "Nom d'utilisateur",
            "it": "Nome utente",
            "pl": "Nazwa użytkownika",
            "pt": "Nome de usuário",
            "ru": "Имя пользователя",
            "tr": "Kullanıcı Adı",
            "uk": "Ім'я користувача"
        ],
        "profile_edit_profile": [
            "de": "Profil bearbeiten",
            "en": "Edit Profile",
            "es": "Editar perfil",
            "fr": "Modifier le profil",
            "it": "Modifica profilo",
            "pl": "Edytuj profil",
            "pt": "Editar perfil",
            "ru": "Редактировать профиль",
            "tr": "Profili Düzenle",
            "uk": "Редагувати профіль"
        ],
        "profile_enter_username": [
            "de": "Benutzername eingeben",
            "en": "Enter username",
            "es": "Ingrese nombre de usuario",
            "fr": "Entrez le nom d'utilisateur",
            "it": "Inserisci nome utente",
            "pl": "Wprowadź nazwę użytkownika",
            "pt": "Digite o nome de usuário",
            "ru": "Введите имя пользователя",
            "tr": "Kullanıcı adını girin",
            "uk": "Введіть ім'я користувача"
        ],
        "profile_statistics": [
            "de": "Statistiken",
            "en": "Statistics",
            "es": "Estadísticas",
            "fr": "Statistiques",
            "it": "Statistiche",
            "pl": "Statystyki",
            "pt": "Estatísticas",
            "ru": "Статистика",
            "tr": "İstatistikler",
            "uk": "Статистика"
        ],
        "profile_premium": [
            "de": "Premium",
            "en": "Premium",
            "es": "Premium",
            "fr": "Premium",
            "it": "Premium",
            "pl": "Premium",
            "pt": "Premium",
            "ru": "Premium",
            "tr": "Premium",
            "uk": "Premium"
        ],
        "profile_unlock_features": [
            "de": "Alle Funktionen freischalten",
            "en": "Unlock all features",
            "es": "Desbloquear todas las funciones",
            "fr": "Débloquer toutes les fonctionnalités",
            "it": "Sblocca tutte le funzionalità",
            "pl": "Odblokuj wszystkie funkcje",
            "pt": "Desbloquear todos os recursos",
            "ru": "Разблокировать все функции",
            "tr": "Tüm özelliklerin kilidini aç",
            "uk": "Розблокувати всі функції"
        ],
        "profile_upgrade": [
            "de": "Upgraden",
            "en": "Upgrade",
            "es": "Mejorar",
            "fr": "Mettre à niveau",
            "it": "Aggiorna",
            "pl": "Ulepsz",
            "pt": "Atualizar",
            "ru": "Обновить",
            "tr": "Yükselt",
            "uk": "Оновити"
        ],
        "profile_support": [
            "de": "Support",
            "en": "Support",
            "es": "Soporte",
            "fr": "Assistance",
            "it": "Supporto",
            "pl": "Wsparcie",
            "pt": "Suporte",
            "ru": "Поддержка",
            "tr": "Destek",
            "uk": "Підтримка"
        ],
        "profile_terms": [
            "de": "Nutzungsbedingungen",
            "en": "Terms of Service",
            "es": "Términos de servicio",
            "fr": "Conditions d'utilisation",
            "it": "Termini di servizio",
            "pl": "Warunki korzystania z usługi",
            "pt": "Termos de serviço",
            "ru": "Условия использования",
            "tr": "Hizmet şartları",
            "uk": "Умови використання"
        ],
        "profile_about_privacy": [
            "de": "Über & Datenschutz",
            "en": "About & Privacy",
            "es": "Acerca de y privacidad",
            "fr": "À propos et confidentialité",
            "it": "Informazioni e privacy",
            "pl": "O aplikacji i prywatność",
            "pt": "Sobre e privacidade",
            "ru": "О приложении и конфиденциальность",
            "tr": "Hakkında ve gizlilik",
            "uk": "Про додаток і конфіденційність"
        ],
        "profile_logout": [
            "de": "Abmelden",
            "en": "Log Out",
            "es": "Cerrar sesión",
            "fr": "Se déconnecter",
            "it": "Esci",
            "pl": "Wyloguj się",
            "pt": "Sair",
            "ru": "Выйти",
            "tr": "Çıkış yap",
            "uk": "Вийти"
        ],
        "profile_your_stats": [
            "de": "Deine Statistiken",
            "en": "Your Statistics",
            "es": "Tus estadísticas",
            "fr": "Tes statistiques",
            "it": "Le tue statistiche",
            "pl": "Twoje statystyki",
            "pt": "Suas estatísticas",
            "ru": "Твоя статистика",
            "tr": "Senin istatistiklerin",
            "uk": "Твоя статистика"
        ],
        "profile_total_meditation_time": [
            "de": "Gesamte Meditationszeit",
            "en": "Total Meditation Time",
            "es": "Tiempo total de meditación",
            "fr": "Temps total de méditation",
            "it": "Tempo totale di meditazione",
            "pl": "Całkowity czas medytacji",
            "pt": "Tempo total de meditação",
            "ru": "Общее время медитации",
            "tr": "Toplam meditasyon süresi",
            "uk": "Загальний час медитації"
        ],
        "profile_personal_challenges": [
            "de": "Persönliche Herausforderungen",
            "en": "Personal Challenges",
            "es": "Desafíos personales",
            "fr": "Défis personnels",
            "it": "Sfide personali",
            "pl": "Osobiste wyzwania",
            "pt": "Desafios pessoais",
            "ru": "Личные челленджи",
            "tr": "Kişisel meydan okumalar",
            "uk": "Особисті челенджі"
        ],
        "profile_completed_challenges": [
            "de": "Abgeschlossene Herausforderungen",
            "en": "Completed Challenges",
            "es": "Desafíos completados",
            "fr": "Défis complétés",
            "it": "Sfide completate",
            "pl": "Ukończone wyzwania",
            "pt": "Desafios concluídos",
            "ru": "Завершённые челленджи",
            "tr": "Tamamlanan meydan okumalar",
            "uk": "Завершені челенджі"
        ],
        "profile_journal_entries": [
            "de": "Tagebucheinträge",
            "en": "Journal Entries",
            "es": "Entradas del diario",
            "fr": "Entrées de journal",
            "it": "Voci del diario",
            "pl": "Wpisy dziennika",
            "pt": "Entradas do diário",
            "ru": "Записи в журнале",
            "tr": "Günlük girişleri",
            "uk": "Записи в журналі"
        ],
        "profile_total_points": [
            "de": "Gesamtpunkte",
            "en": "Total Points",
            "es": "Puntos totales",
            "fr": "Points totaux",
            "it": "Punti totali",
            "pl": "Łączne punkty",
            "pt": "Pontos totais",
            "ru": "Всего баллов",
            "tr": "Toplam puan",
            "uk": "Всього балів"
        ],
        "home_total": [
            "de": "Gesamt",
            "en": "Total",
            "es": "Total",
            "fr": "Total",
            "it": "Totale",
            "pl": "Suma",
            "pt": "Total",
            "ru": "Всего",
            "tr": "Toplam",
            "uk": "Всього"
        ],
        "home_raw_time": [
            "de": "Raw Zeit",
            "en": "Raw Time",
            "es": "Tiempo Raw",
            "fr": "Temps Raw",
            "it": "Tempo Raw",
            "pl": "Czas Raw",
            "pt": "Tempo Raw",
            "ru": "Время Raw",
            "tr": "Raw Süresi",
            "uk": "Час Raw"
        ],
        "home_points": [
            "de": "Punkte",
            "en": "Points",
            "es": "Puntos",
            "fr": "Points",
            "it": "Punti",
            "pl": "Punkty",
            "pt": "Pontos",
            "ru": "Баллы",
            "tr": "Puan",
            "uk": "Бали"
        ],
        "home_latest_session": [
            "de": "Letzte Sitzung",
            "en": "Latest Session",
            "es": "Última sesión",
            "fr": "Dernière session",
            "it": "Ultima sessione",
            "pl": "Ostatnia sesja",
            "pt": "Última sessão",
            "ru": "Последняя сессия",
            "tr": "Son oturum",
            "uk": "Остання сесія"
        ],
        "home_no_entries": [
            "de": "Noch keine Einträge",
            "en": "No journal entries yet",
            "es": "Aún no hay entradas",
            "fr": "Aucune entrée pour le moment",
            "it": "Nessuna voce ancora",
            "pl": "Brak wpisów",
            "pt": "Ainda não há entradas",
            "ru": "Пока нет записей",
            "tr": "Henüz kayıt yok",
            "uk": "Поки немає записів"
        ],
        "home_no_thoughts": [
            "de": "Keine Gedanken aufgezeichnet",
            "en": "No thoughts recorded",
            "es": "Sin pensamientos registrados",
            "fr": "Aucune pensée enregistrée",
            "it": "Nessun pensiero registrato",
            "pl": "Brak zapisanych myśli",
            "pt": "Nenhum pensamento registrado",
            "ru": "Мысли не записаны",
            "tr": "Düşünce kaydedilmedi",
            "uk": "Думки не записані"
        ],
        "home_start_motivation": [
            "de": "Keine Eile. Nur echte Zeit",
            "en": "No rush. Just real time",
            "es": "Sin prisa. Solo tiempo real",
            "fr": "Pas de précipitation. Juste du temps réel",
            "it": "Nessuna fretta. Solo tempo reale",
            "pl": "Bez pośpiechu. Po prostu prawdziwy czas",
            "pt": "Sem pressa. Apenas tempo real",
            "ru": "Без спешки. Только реальное время",
            "tr": "Acele yok. Sadece gerçek zaman",
            "uk": "Без поспіху. Лише реальний час"
        ],
        "home_do_it": [
            "de": "Los geht's",
            "en": "Do it",
            "es": "Hazlo",
            "fr": "Fais-le",
            "it": "Fallo",
            "pl": "Zrób to",
            "pt": "Faça isso",
            "ru": "Начать",
            "tr": "Yap",
            "uk": "Зробити"
        ],
        "home_stop": [
            "de": "STOPP",
            "en": "STOP",
            "es": "DETENER",
            "fr": "ARRÊTER",
            "it": "FERMA",
            "pl": "STOP",
            "pt": "PARAR",
            "ru": "СТОП",
            "tr": "DUR",
            "uk": "СТОП"
        ],
        
        // MARK: - Common
        "app_brand": [
            "de": "Be Raw",
            "en": "Be Raw",
            "es": "Be Raw",
            "fr": "Be Raw",
            "it": "Be Raw",
            "pl": "Be Raw",
            "pt": "Be Raw",
            "ru": "Be Raw",
            "tr": "Be Raw",
            "uk": "Be Raw"
        ],
        "timer_raw_dogging": [
            "de": "Raw Dogging",
            "en": "Raw Dogging",
            "es": "Raw Dogging",
            "fr": "Raw Dogging",
            "it": "Raw Dogging",
            "pl": "Raw Dogging",
            "pt": "Raw Dogging",
            "ru": "Raw Dogging",
            "tr": "Raw Dogging",
            "uk": "Raw Dogging"
        ],
        "common_continue": [
            "de": "Weiter",
            "en": "Continue",
            "es": "Continuar",
            "fr": "Continuer",
            "it": "Continua",
            "pl": "Kontynuuj",
            "pt": "Continuar",
            "ru": "Продолжить",
            "tr": "Devam et",
            "uk": "Продовжити"
        ],
        "common_cancel": [
            "de": "Abbrechen",
            "en": "Cancel",
            "es": "Cancelar",
            "fr": "Annuler",
            "it": "Annulla",
            "pl": "Anuluj",
            "pt": "Cancelar",
            "ru": "Отменить",
            "tr": "İptal",
            "uk": "Скасувати"
        ],
        "common_save": [
            "de": "Speichern",
            "en": "Save",
            "es": "Guardar",
            "fr": "Enregistrer",
            "it": "Salva",
            "pl": "Zapisz",
            "pt": "Salvar",
            "ru": "Сохранить",
            "tr": "Kaydet",
            "uk": "Зберегти"
        ],
        "common_ok": [
            "de": "OK",
            "en": "OK",
            "es": "OK",
            "fr": "OK",
            "it": "OK",
            "pl": "OK",
            "pt": "OK",
            "ru": "ОК",
            "tr": "Tamam",
            "uk": "OK"
        ],
        "common_skip": [
            "de": "Überspringen",
            "en": "Skip",
            "es": "Omitir",
            "fr": "Ignorer",
            "it": "Salta",
            "pl": "Pomiń",
            "pt": "Pular",
            "ru": "Пропустить",
            "tr": "Atla",
            "uk": "Пропустити"
        ],
        "common_hour_short": [
            "de": "Std",
            "en": "hr",
            "es": "h",
            "fr": "h",
            "it": "h",
            "pl": "godz",
            "pt": "h",
            "ru": "ч",
            "tr": "sa",
            "uk": "год"
        ],
        "common_minute_short": [
            "de": "min",
            "en": "min",
            "es": "min",
            "fr": "min",
            "it": "min",
            "pl": "min",
            "pt": "min",
            "ru": "мин",
            "tr": "dk",
            "uk": "хв"
        ],
        
        // MARK: - Challenge Timer Motivations
        "timer_motivation_focus": [
            "de": "Bleib fokussiert...",
            "en": "Stay focused...",
            "es": "Mantente enfocado...",
            "fr": "Reste concentré...",
            "it": "Resta concentrato...",
            "pl": "Skup się...",
            "pt": "Mantenha o foco...",
            "ru": "Сохраняй фокус...",
            "tr": "Odaklanmış kal...",
            "uk": "Залишайся зосередженим..."
        ],
        "timer_motivation_amazing": [
            "de": "Du machst das großartig...",
            "en": "You're doing amazing...",
            "es": "Lo estás haciendo increíble...",
            "fr": "Tu gères ça à merveille...",
            "it": "Stai andando alla grande...",
            "pl": "Świetnie ci idzie...",
            "pt": "Você está mandando muito bem...",
            "ru": "Ты делаешь это потрясающе...",
            "tr": "Harika gidiyorsun...",
            "uk": "Ти робиш це неймовірно..."
        ],
        "timer_motivation_keep_strong": [
            "de": "Mach stark weiter...",
            "en": "Keep going strong...",
            "es": "Sigue con fuerza...",
            "fr": "Continue sur ta lancée...",
            "it": "Continua con forza...",
            "pl": "Jedź dalej z mocą...",
            "pt": "Continue firme...",
            "ru": "Продолжай в том же духе...",
            "tr": "Güçlü kalmaya devam et...",
            "uk": "Продовжуй потужно..."
        ],
        "timer_motivation_almost_there": [
            "de": "Fast geschafft...",
            "en": "Almost there...",
            "es": "Ya casi llegas...",
            "fr": "Tu y es presque...",
            "it": "Ci sei quasi...",
            "pl": "Już prawie...",
            "pt": "Quase lá...",
            "ru": "Почти готово...",
            "tr": "Neredeyse oldu...",
            "uk": "Майже готово..."
        ],
        "timer_motivation_got_this": [
            "de": "Du schaffst das...",
            "en": "You've got this...",
            "es": "Lo tienes...",
            "fr": "Tu maîtrises...",
            "it": "Ce la fai...",
            "pl": "Masz to...",
            "pt": "Você consegue...",
            "ru": "Ты справишься...",
            "tr": "Bunu başaracaksın...",
            "uk": "У тебе вийде..."
        ],
        "timer_motivation_embrace": [
            "de": "Umarme die Herausforderung...",
            "en": "Embrace the challenge...",
            "es": "Abraza el desafío...",
            "fr": "Embrasse le défi...",
            "it": "Accogli la sfida...",
            "pl": "Przyjmij wyzwanie...",
            "pt": "Abra o desafio...",
            "ru": "Прими вызов...",
            "tr": "Meydan okumayı kucakla...",
            "uk": "Прийми виклик..."
        ],
        "timer_motivation_every_second": [
            "de": "Jede Sekunde zählt...",
            "en": "Every second matters...",
            "es": "Cada segundo cuenta...",
            "fr": "Chaque seconde compte...",
            "it": "Ogni secondo conta...",
            "pl": "Każda sekunda się liczy...",
            "pt": "Cada segundo importa...",
            "ru": "Каждая секунда важна...",
            "tr": "Her saniye önemli...",
            "uk": "Кожна секунда має значення..."
        ],
        "timer_motivation_discipline": [
            "de": "Disziplin entsteht...",
            "en": "Building discipline...",
            "es": "Construyendo disciplina...",
            "fr": "Tu construis ta discipline...",
            "it": "Stai costruendo disciplina...",
            "pl": "Budujesz dyscyplinę...",
            "pt": "Construindo disciplina...",
            "ru": "Формируешь дисциплину...",
            "tr": "Disiplin inşa ediyorsun...",
            "uk": "Ти вибудовуєш дисципліну..."
        ],
        "timer_motivation_stay_present": [
            "de": "Bleib im Moment...",
            "en": "Stay present...",
            "es": "Permanece presente...",
            "fr": "Reste présent...",
            "it": "Rimani presente...",
            "pl": "Bądź tu i teraz...",
            "pt": "Permaneça presente...",
            "ru": "Оставайся в моменте...",
            "tr": "Anda kal...",
            "uk": "Залишайся в моменті..."
        ],
        "timer_motivation_stronger": [
            "de": "Du bist stärker als du denkst...",
            "en": "You're stronger than you think...",
            "es": "Eres más fuerte de lo que crees...",
            "fr": "Tu es plus fort que tu ne le crois...",
            "it": "Sei più forte di quanto pensi...",
            "pl": "Jesteś silniejszy, niż myślisz...",
            "pt": "Você é mais forte do que imagina...",
            "ru": "Ты сильнее, чем думаешь...",
            "tr": "Düşündüğünden daha güçlüsün...",
            "uk": "Ти сильніший, ніж думаєш..."
        ],
        "timer_motivation_push": [
            "de": "Zieh es durch...",
            "en": "Push through...",
            "es": "Impulsa hasta el final...",
            "fr": "Pousse jusqu'au bout...",
            "it": "Resisti...",
            "pl": "Przebrnij przez to...",
            "pt": "Atravesse isso...",
            "ru": "Прорывайся...",
            "tr": "Devam et...",
            "uk": "Пройди крізь це..."
        ],
        "timer_motivation_excellence": [
            "de": "Exzellenz entsteht...",
            "en": "Excellence is forming...",
            "es": "La excelencia se está formando...",
            "fr": "L'excellence prend forme...",
            "it": "L'eccellenza sta prendendo forma...",
            "pl": "Doskonalenie się kształtuje...",
            "pt": "A excelência está se formando...",
            "ru": "Формируется превосходство...",
            "tr": "Mükemmellik oluşuyor...",
            "uk": "Формується досконалість..."
        ],
        
        // MARK: - Full Screen Timer Motivations
        "timer_fs_silence": [
            "de": "Umarme die Stille...",
            "en": "Embrace the silence...",
            "es": "Abraza el silencio...",
            "fr": "Embrasse le silence...",
            "it": "Abbraccia il silenzio...",
            "pl": "Przyjmij ciszę...",
            "pt": "Abrace o silêncio...",
            "ru": "Обними тишину...",
            "tr": "Sessizliği kucakla...",
            "uk": "Обійми тишу..."
        ],
        "timer_fs_mind_clearing": [
            "de": "Dein Geist klärt sich...",
            "en": "Your mind is clearing...",
            "es": "Tu mente se está despejando...",
            "fr": "Ton esprit s'éclaircit...",
            "it": "La tua mente si sta schiarendo...",
            "pl": "Twój umysł się oczyszcza...",
            "pt": "Sua mente está clareando...",
            "ru": "Твой разум проясняется...",
            "tr": "Zihnin berraklaşıyor...",
            "uk": "Твій розум прояснюється..."
        ],
        "timer_fs_creativity_stillness": [
            "de": "Kreativität blüht in der Stille...",
            "en": "Creativity blooms in stillness...",
            "es": "La creatividad florece en la quietud...",
            "fr": "La créativité fleurit dans le calme...",
            "it": "La creatività sboccia nella quiete...",
            "pl": "Kreatywność rozkwita w ciszy...",
            "pt": "A criatividade floresce na quietude...",
            "ru": "Креатив расцветает в тишине...",
            "tr": "Yaratıcılık dinginlikte filizlenir...",
            "uk": "Креативність розквітає в тиші..."
        ],
        "timer_fs_mental_strength": [
            "de": "Du baust mentale Stärke auf...",
            "en": "You're building mental strength...",
            "es": "Estás construyendo fortaleza mental...",
            "fr": "Tu renforces ton mental...",
            "it": "Stai costruendo forza mentale...",
            "pl": "Budujesz siłę mentalną...",
            "pt": "Você está construindo força mental...",
            "ru": "Ты развиваешь ментальную силу...",
            "tr": "Zihinsel güç inşa ediyorsun...",
            "uk": "Ти будуєш ментальну силу..."
        ],
        "timer_fs_deep_focus": [
            "de": "Tiefe Konzentration entsteht...",
            "en": "Deep focus is forming...",
            "es": "Se está formando una concentración profunda...",
            "fr": "Une profonde concentration se forme...",
            "it": "Si sta formando una profonda concentrazione...",
            "pl": "Tworzy się głęboka koncentracja...",
            "pt": "Um foco profundo está se formando...",
            "ru": "Формируется глубокий фокус...",
            "tr": "Derin odak oluşuyor...",
            "uk": "Формується глибока зосередженість..."
        ],
        "timer_fs_flow_freely": [
            "de": "Lass deine Gedanken frei fließen...",
            "en": "Let your thoughts flow freely...",
            "es": "Deja que tus pensamientos fluyan libres...",
            "fr": "Laisse tes pensées circuler librement...",
            "it": "Lascia fluire liberamente i pensieri...",
            "pl": "Pozwól myślom płynąć swobodnie...",
            "pt": "Deixe seus pensamentos fluírem livremente...",
            "ru": "Пусть мысли текут свободно...",
            "tr": "Düşüncelerin özgürce aksın...",
            "uk": "Нехай думки течуть вільно..."
        ],
        "timer_fs_every_second_counts": [
            "de": "Jede Sekunde zählt...",
            "en": "Every second counts...",
            "es": "Cada segundo cuenta...",
            "fr": "Chaque seconde compte...",
            "it": "Ogni secondo conta...",
            "pl": "Każda sekunda się liczy...",
            "pt": "Cada segundo conta...",
            "ru": "Каждая секунда на счету...",
            "tr": "Her saniye önemli...",
            "uk": "Кожна секунда важлива..."
        ],
        "timer_fs_doing_great": [
            "de": "Du machst das super...",
            "en": "You're doing great...",
            "es": "Lo estás haciendo genial...",
            "fr": "Tu t'en sors très bien...",
            "it": "Stai andando benissimo...",
            "pl": "Świetnie ci idzie...",
            "pt": "Você está indo muito bem...",
            "ru": "У тебя отлично получается...",
            "tr": "Harika gidiyorsun...",
            "uk": "Ти чудово справляєшся..."
        ],
        "timer_fs_stay_present": [
            "de": "Bleib in diesem Moment...",
            "en": "Stay present in this moment...",
            "es": "Permanece presente en este momento...",
            "fr": "Reste présent dans l'instant...",
            "it": "Rimani presente in questo momento...",
            "pl": "Bądź obecny w tej chwili...",
            "pt": "Permaneça presente neste momento...",
            "ru": "Оставайся в этом моменте...",
            "tr": "Bu anda kal...",
            "uk": "Залишайся в цю мить..."
        ],
        "timer_fs_inner_peace": [
            "de": "Innerer Frieden wächst...",
            "en": "Inner peace is growing...",
            "es": "La paz interior está creciendo...",
            "fr": "La paix intérieure grandit...",
            "it": "La pace interiore sta crescendo...",
            "pl": "Wewnętrzny spokój rośnie...",
            "pt": "A paz interior está crescendo...",
            "ru": "Внутренний покой растёт...",
            "tr": "İç huzur büyüyor...",
            "uk": "Внутрішній спокій зростає..."
        ],
        "timer_fs_creativity_awakening": [
            "de": "Deine Kreativität erwacht...",
            "en": "Your creativity is awakening...",
            "es": "Tu creatividad está despertando...",
            "fr": "Ta créativité s'éveille...",
            "it": "La tua creatività si sta risvegliando...",
            "pl": "Twoja kreatywność się budzi...",
            "pt": "Sua criatividade está despertando...",
            "ru": "Твоё творчество просыпается...",
            "tr": "Yaratıcılığın uyanıyor...",
            "uk": "Твоя креативність прокидається..."
        ],
        "timer_fs_boredom_innovation": [
            "de": "Langeweile ist das Tor zur Innovation...",
            "en": "Boredom is the gateway to innovation...",
            "es": "El aburrimiento es la puerta a la innovación...",
            "fr": "L'ennui est la porte de l'innovation...",
            "it": "La noia è la porta dell'innovazione...",
            "pl": "Nuda jest bramą do innowacji...",
            "pt": "O tédio é o portal para a inovação...",
            "ru": "Скука — путь к инновациям...",
            "tr": "Can sıkıntısı inovasyona açılan kapıdır...",
            "uk": "Нудьга — шлях до інновацій..."
        ],
        
        // MARK: - Journal
        "journal_session_complete": [
            "de": "Session abgeschlossen!",
            "en": "Session Complete!",
            "es": "¡Sesión completa!",
            "fr": "Session terminée !",
            "it": "Sessione completata!",
            "pl": "Sesja zakończona!",
            "pt": "Sessão concluída!",
            "ru": "Сессия завершена!",
            "tr": "Seans tamamlandı!",
            "uk": "Сесію завершено!"
        ],
        "journal_feel_question": [
            "de": "Wie fühlst du dich?",
            "en": "How do you feel?",
            "es": "¿Cómo te sientes?",
            "fr": "Comment te sens-tu ?",
            "it": "Come ti senti?",
            "pl": "Jak się czujesz?",
            "pt": "Como você se sente?",
            "ru": "Как ты себя чувствуешь?",
            "tr": "Nasıl hissediyorsun?",
            "uk": "Як ти почуваєшся?"
        ],
        "journal_your_thoughts": [
            "de": "Deine Gedanken",
            "en": "Your Thoughts",
            "es": "Tus pensamientos",
            "fr": "Tes pensées",
            "it": "I tuoi pensieri",
            "pl": "Twoje myśli",
            "pt": "Seus pensamentos",
            "ru": "Твои мысли",
            "tr": "Düşüncelerin",
            "uk": "Твої думки"
        ],
        "journal_thoughts_placeholder": [
            "de": "Schreib deine Gedanken hier...",
            "en": "Write your thoughts here...",
            "es": "Escribe tus pensamientos aquí...",
            "fr": "Écris tes pensées ici...",
            "it": "Scrivi qui i tuoi pensieri...",
            "pl": "Zapisz tu swoje myśli...",
            "pt": "Escreva seus pensamentos aqui...",
            "ru": "Запиши здесь свои мысли...",
            "tr": "Düşüncelerini buraya yaz...",
            "uk": "Запиши тут свої думки..."
        ],
        "journal_save_thoughts": [
            "de": "Gedanken speichern",
            "en": "Save Thoughts",
            "es": "Guardar pensamientos",
            "fr": "Enregistrer les pensées",
            "it": "Salva i pensieri",
            "pl": "Zapisz myśli",
            "pt": "Salvar pensamentos",
            "ru": "Сохранить мысли",
            "tr": "Düşünceleri kaydet",
            "uk": "Зберегти думки"
        ],
        "journal_skip": [
            "de": "Überspringen",
            "en": "Skip",
            "es": "Omitir",
            "fr": "Ignorer",
            "it": "Salta",
            "pl": "Pomiń",
            "pt": "Pular",
            "ru": "Пропустить",
            "tr": "Atla",
            "uk": "Пропустити"
        ],
        
        // MARK: - Leaderboard Extended
        "leaderboard_top_raw": [
            "de": "Top Raw",
            "en": "Top Raw",
            "es": "Top Raw",
            "fr": "Top Raw",
            "it": "Top Raw",
            "pl": "Top Raw",
            "pt": "Top Raw",
            "ru": "Top Raw",
            "tr": "Top Raw",
            "uk": "Top Raw"
        ],
        "leaderboard_all_time": [
            "de": "Alle Zeiten",
            "en": "All-Time",
            "es": "Histórico",
            "fr": "Tout le temps",
            "it": "Di sempre",
            "pl": "Wszech czasów",
            "pt": "Todo o tempo",
            "ru": "За всё время",
            "tr": "Tüm zamanlar",
            "uk": "За весь час"
        ],
        "leaderboard_your_rank": [
            "de": "Dein Rang",
            "en": "Your Rank",
            "es": "Tu rango",
            "fr": "Ton rang",
            "it": "Il tuo rango",
            "pl": "Twój ranking",
            "pt": "Sua posição",
            "ru": "Твой ранг",
            "tr": "Senin sıran",
            "uk": "Твій ранг"
        ],
        "leaderboard_position": [
            "de": "Position",
            "en": "Position",
            "es": "Posición",
            "fr": "Position",
            "it": "Posizione",
            "pl": "Pozycja",
            "pt": "Posição",
            "ru": "Позиция",
            "tr": "Pozisyon",
            "uk": "Позиція"
        ],
        "leaderboard_total_time": [
            "de": "Gesamtzeit",
            "en": "Total Time",
            "es": "Tiempo total",
            "fr": "Temps total",
            "it": "Tempo totale",
            "pl": "Łączny czas",
            "pt": "Tempo total",
            "ru": "Общее время",
            "tr": "Toplam süre",
            "uk": "Загальний час"
        ],
        
        // MARK: - Celebration
        "celebration_message_1": [
            "de": "Du bist raw gegangen und hast gewonnen",
            "en": "You went raw and won",
            "es": "Te fuiste al modo raw y ganaste",
            "fr": "Tu es allé full raw et tu as gagné",
            "it": "Sei andato raw e hai vinto",
            "pl": "Poszedłeś na surowo i wygrałeś",
            "pt": "Você foi raw e venceu",
            "ru": "Ты был raw и победил",
            "tr": "Raw gittin ve kazandın",
            "uk": "Ти пішов raw і переміг"
        ],
        "celebration_message_2": [
            "de": "Alles gegeben. Keine Filter. Geschafft",
            "en": "All in. No filters. You did it",
            "es": "A todo o nada. Sin filtros. Lo lograste",
            "fr": "Tout donné. Aucun filtre. Tu l'as fait",
            "it": "Tutto dentro. Nessun filtro. Ce l'hai fatta",
            "pl": "Wszystko na stół. Zero filtrów. Udało się",
            "pt": "Tudo ou nada. Sem filtros. Você conseguiu",
            "ru": "На всю. Без фильтров. Ты сделал это",
            "tr": "Tam gaz. Filtre yok. Başardın",
            "uk": "На повну. Без фільтрів. Ти зробив це"
        ],
        "celebration_message_3": [
            "de": "Rohe Energie. Echte Ergebnisse",
            "en": "Raw energy. Real results",
            "es": "Energía raw. Resultados reales",
            "fr": "Énergie brute. Résultats réels",
            "it": "Energia raw. Risultati reali",
            "pl": "Surowa energia. Prawdziwe wyniki",
            "pt": "Energia raw. Resultados reais",
            "ru": "Raw энергия. Реальные результаты",
            "tr": "Ham enerji. Gerçek sonuçlar",
            "uk": "Raw енергія. Справжні результати"
        ],
        "celebration_message_4": [
            "de": "So macht man das – roh und echt",
            "en": "That's how it's done - raw and real",
            "es": "Así se hace: raw y real",
            "fr": "Voilà comment on fait – brut et réel",
            "it": "Così si fa: raw e reale",
            "pl": "Tak to się robi – surowo i prawdziwie",
            "pt": "É assim que se faz – raw e real",
            "ru": "Вот как это делается — raw и по-настоящему",
            "tr": "İşte böyle yapılır – ham ve gerçek",
            "uk": "Ось як це робиться — raw і по-справжньому"
        ],
        "celebration_message_5": [
            "de": "Du warst großartig!",
            "en": "You did awesome!",
            "es": "¡Lo hiciste increíble!",
            "fr": "Tu as assuré !",
            "it": "Sei stato fantastico!",
            "pl": "Było świetnie!",
            "pt": "Você mandou muito bem!",
            "ru": "Ты был потрясающим!",
            "tr": "Harikaydın!",
            "uk": "Ти був неймовірним!"
        ],
    "celebration_share_text": [
            "de": "Ich habe gerade '%@' für %d Minuten auf Be Raw abgeschlossen! 💪",
            "en": "I just completed '%@' for %d minutes on Be Raw! 💪",
            "es": "¡Acabo de completar '%@' por %d minutos en Be Raw! 💪",
            "fr": "Je viens de terminer '%@' pendant %d minutes sur Be Raw ! 💪",
            "it": "Ho appena completato '%@' per %d minuti su Be Raw! 💪",
            "pl": "Właśnie ukończyłem '%@' przez %d minut w Be Raw! 💪",
            "pt": "Acabei de completar '%@' por %d minutos no Be Raw! 💪",
            "ru": "Я только что прошёл '%@' за %d минут в Be Raw! 💪",
            "tr": "Az önce Be Raw'da '%@' meydan okumasını %d dakika tamamladım! 💪",
            "uk": "Я щойно пройшов '%@' за %d хвилин у Be Raw! 💪"
        ]
    ]
}
