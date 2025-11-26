import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - User Data
    func saveUserProfile(userId: String, userName: String, email: String?) async throws {
        let userData: [String: Any] = [
            "userName": userName,
            "email": email ?? "",
            "createdAt": Timestamp(date: Date()),
            "lastUpdated": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userId).setData(userData, merge: true)
    }
    
    func fetchUserProfile(userId: String) async throws -> [String: Any]? {
        let document = try await db.collection("users").document(userId).getDocument()
        return document.data()
    }
    
    // MARK: - User Stats
    func saveUserStats(userId: String, stats: UserStats) async throws {
        let statsData: [String: Any] = [
            "dailyStreak": stats.dailyStreak,
            "totalRawTime": stats.totalRawTime,
            "totalPoints": stats.totalPoints,
            "dailyGoalMinutes": stats.dailyGoalMinutes,
            "lastUpdated": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userId).collection("stats").document("current").setData(statsData, merge: true)
    }
    
    func fetchUserStats(userId: String) async throws -> UserStats? {
        let document = try await db.collection("users").document(userId).collection("stats").document("current").getDocument()
        
        guard let data = document.data() else { return nil }
        
        return UserStats(
            dailyStreak: data["dailyStreak"] as? Int ?? 0,
            totalRawTime: data["totalRawTime"] as? TimeInterval ?? 0,
            totalPoints: data["totalPoints"] as? Int ?? 0,
            dailyGoalMinutes: data["dailyGoalMinutes"] as? Int ?? 60,
            dailyHistory: []
        )
    }
    
    // MARK: - Challenges
    func saveChallenges(userId: String, challenges: [RawChallenge]) async throws {
        let batch = db.batch()
        
        for challenge in challenges {
            let challengeRef = db.collection("users").document(userId).collection("challenges").document(challenge.id.uuidString)
            
            let challengeData: [String: Any] = [
                "title": challenge.title,
                "durationMinutes": challenge.durationMinutes,
                "isCompleted": challenge.isCompleted,
                "isPublic": challenge.isPublic,
                "createdAt": Timestamp(date: challenge.createdAt),
                "usersCompletedCount": challenge.usersCompletedCount
            ]
            
            batch.setData(challengeData, forDocument: challengeRef)
        }
        
        try await batch.commit()
    }
    
    func fetchChallenges(userId: String) async throws -> [RawChallenge] {
        let snapshot = try await db.collection("users").document(userId).collection("challenges").getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let title = data["title"] as? String,
                  let durationMinutes = data["durationMinutes"] as? Int else {
                return nil
            }
            
            let isCompleted = data["isCompleted"] as? Bool ?? false
            let isPublic = data["isPublic"] as? Bool ?? false
            let usersCompletedCount = data["usersCompletedCount"] as? Int ?? 0
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            return RawChallenge(
                id: UUID(uuidString: doc.documentID) ?? UUID(),
                title: title,
                durationMinutes: durationMinutes,
                isCompleted: isCompleted,
                isPublic: isPublic,
                createdAt: createdAt,
                usersCompletedCount: usersCompletedCount
            )
        }
    }
    
    // MARK: - Public Challenges
    func savePublicChallenge(challenge: RawChallenge, creatorId: String) async throws {
        let challengeData: [String: Any] = [
            "title": challenge.title,
            "durationMinutes": challenge.durationMinutes,
            "creatorId": creatorId,
            "usersCompletedCount": challenge.usersCompletedCount,
            "createdAt": Timestamp(date: challenge.createdAt)
        ]
        
        try await db.collection("publicChallenges").document(challenge.id.uuidString).setData(challengeData)
    }
    
    func fetchPublicChallenges() async throws -> [RawChallenge] {
        let snapshot = try await db.collection("publicChallenges")
            .order(by: "usersCompletedCount", descending: true)
            .limit(to: 50)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let title = data["title"] as? String,
                  let durationMinutes = data["durationMinutes"] as? Int else {
                return nil
            }
            
            let usersCompletedCount = data["usersCompletedCount"] as? Int ?? 0
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            return RawChallenge(
                id: UUID(uuidString: doc.documentID) ?? UUID(),
                title: title,
                durationMinutes: durationMinutes,
                isCompleted: false,
                isPublic: true,
                createdAt: createdAt,
                usersCompletedCount: usersCompletedCount
            )
        }
    }
    
    func fetchChallengeById(_ challengeId: String) async throws -> RawChallenge? {
        let doc = try await db.collection("publicChallenges").document(challengeId).getDocument()
        
        guard doc.exists, let data = doc.data(),
              let title = data["title"] as? String,
              let durationMinutes = data["durationMinutes"] as? Int else {
            return nil
        }
        
        let usersCompletedCount = data["usersCompletedCount"] as? Int ?? 0
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        
        return RawChallenge(
            id: UUID(uuidString: doc.documentID) ?? UUID(),
            title: title,
            durationMinutes: durationMinutes,
            isCompleted: false,
            isPublic: true,
            createdAt: createdAt,
            usersCompletedCount: usersCompletedCount
        )
    }
    
    func deleteChallenge(userId: String, challengeId: String) async throws {
        try await db.collection("users").document(userId).collection("challenges").document(challengeId).delete()
    }
    
    func deletePublicChallenge(challengeId: String) async throws {
        try await db.collection("publicChallenges").document(challengeId).delete()
    }
    
    // MARK: - Journal Entries
    func saveJournalEntries(userId: String, entries: [JournalEntry]) async throws {
        let batch = db.batch()
        
        for entry in entries {
            let entryRef = db.collection("users").document(userId).collection("journal").document(entry.id.uuidString)
            
            let entryData: [String: Any] = [
                "date": Timestamp(date: entry.date),
                "duration": entry.duration,
                "thoughts": entry.thoughts
            ]
            
            batch.setData(entryData, forDocument: entryRef)
        }
        
        try await batch.commit()
    }
    
    func fetchJournalEntries(userId: String) async throws -> [JournalEntry] {
        let snapshot = try await db.collection("users").document(userId).collection("journal")
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let timestamp = data["date"] as? Timestamp,
                  let duration = data["duration"] as? TimeInterval,
                  let thoughts = data["thoughts"] as? String else {
                return nil
            }
            
            return JournalEntry(
                id: UUID(uuidString: doc.documentID) ?? UUID(),
                date: timestamp.dateValue(),
                duration: duration,
                thoughts: thoughts
            )
        }
    }
    
    // MARK: - Daily History
    func saveDailyHistory(userId: String, history: [DailyRecord]) async throws {
        let batch = db.batch()
        
        for record in history {
            let dateString = ISO8601DateFormatter().string(from: record.date)
            let recordRef = db.collection("users").document(userId).collection("dailyHistory").document(dateString)
            
            let recordData: [String: Any] = [
                "date": Timestamp(date: record.date),
                "totalMinutes": record.totalMinutes
            ]
            
            batch.setData(recordData, forDocument: recordRef)
        }
        
        try await batch.commit()
    }
    
    func fetchDailyHistory(userId: String, days: Int = 30) async throws -> [DailyRecord] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let snapshot = try await db.collection("users").document(userId).collection("dailyHistory")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .order(by: "date", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let timestamp = data["date"] as? Timestamp,
                  let totalMinutes = data["totalMinutes"] as? Int else {
                return nil
            }
            
            return DailyRecord(date: timestamp.dateValue(), totalMinutes: totalMinutes)
        }
    }
    
    // MARK: - Leaderboard
    func updateLeaderboard(userId: String, userName: String, totalRawTime: TimeInterval, totalPoints: Int) async throws {
        let leaderboardData: [String: Any] = [
            "nickname": userName,
            "totalRawTime": totalRawTime,
            "totalPoints": totalPoints,
            "lastUpdated": Timestamp(date: Date())
        ]
        
        try await db.collection("leaderboard").document(userId).setData(leaderboardData, merge: true)
    }
    
    func fetchLeaderboard(limit: Int = 50) async throws -> [LeaderboardEntry] {
        let snapshot = try await db.collection("leaderboard")
            .order(by: "totalPoints", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.enumerated().compactMap { index, doc in
            let data = doc.data()
            guard let nickname = data["nickname"] as? String,
                  let totalRawTime = data["totalRawTime"] as? TimeInterval,
                  let totalPoints = data["totalPoints"] as? Int else {
                return nil
            }
            
            // Use userId as string for ID
            let userId = doc.documentID
            
            return LeaderboardEntry(
                id: UUID(uuidString: userId) ?? UUID(), // Try to parse as UUID, fallback to random
                userId: userId, // Store actual Firebase userId
                nickname: nickname,
                totalRawTime: totalRawTime,
                totalPoints: totalPoints,
                rank: index + 1
            )
        }
    }
    
    // MARK: - Session Tracking
    func saveSession(userId: String, session: RawSession) async throws {
        let sessionData: [String: Any] = [
            "startTime": Timestamp(date: session.startTime),
            "endTime": session.endTime != nil ? Timestamp(date: session.endTime!) : NSNull(),
            "duration": session.duration
        ]
        
        try await db.collection("users").document(userId).collection("sessions").document(session.id.uuidString).setData(sessionData)
    }
    
    // MARK: - Account Deletion
    func deleteUserAccount(userId: String) async throws {
        let batch = db.batch()
        
        // 1. Delete user's public challenges from global collection
        let publicChallengesSnapshot = try await db.collection("publicChallenges")
            .whereField("creatorId", isEqualTo: userId)
            .getDocuments()
        
        for doc in publicChallengesSnapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        
        // 2. Delete user's challenges
        let challengesSnapshot = try await db.collection("users")
            .document(userId)
            .collection("challenges")
            .getDocuments()
        
        for doc in challengesSnapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        
        // 3. Delete user's journal entries
        let journalSnapshot = try await db.collection("users")
            .document(userId)
            .collection("journal")
            .getDocuments()
        
        for doc in journalSnapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        
        // 4. Delete user's sessions
        let sessionsSnapshot = try await db.collection("users")
            .document(userId)
            .collection("sessions")
            .getDocuments()
        
        for doc in sessionsSnapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        
        // 5. Delete user's daily history
        let historySnapshot = try await db.collection("users")
            .document(userId)
            .collection("dailyHistory")
            .getDocuments()
        
        for doc in historySnapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        
        // 6. Delete user's stats
        let statsRef = db.collection("users")
            .document(userId)
            .collection("stats")
            .document("current")
        batch.deleteDocument(statsRef)
        
        // 7. Delete from leaderboard
        let leaderboardRef = db.collection("leaderboard").document(userId)
        batch.deleteDocument(leaderboardRef)
        
        // 8. Delete user profile (main document)
        let userRef = db.collection("users").document(userId)
        batch.deleteDocument(userRef)
        
        // Commit all deletions
        try await batch.commit()
    }
}
