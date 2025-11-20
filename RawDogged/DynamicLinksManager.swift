//
//  DynamicLinksManager.swift
//  RawDogged
//
//  Handles Custom URL Scheme deep linking for challenge sharing
//

import Foundation
import Combine

@MainActor
class DynamicLinksManager: ObservableObject {
    @Published var pendingChallengeId: String?
    
    // MARK: - Configuration
    
    private let universalLinkDomain = "beraw.info"
    
    // MARK: - Create Challenge Link
    
    func createChallengeLink(for challenge: RawChallenge) -> String {
        // Returns a Universal Link that works for both installed and non-installed users
        return "https://\(universalLinkDomain)/challenge/\(challenge.id.uuidString)"
    }
    
    func createCustomSchemeLink(for challenge: RawChallenge) -> String {
        // Fallback custom URL scheme (only works if app is installed)
        return "beraw://challenge/\(challenge.id.uuidString)"
    }
    
    // MARK: - Handle Incoming Links
    
    func handleIncomingLink(_ url: URL) -> Bool {
        print("🔗 DynamicLinksManager: handleIncomingLink called with URL: \(url)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("❌ Failed to parse URL components")
            return false
        }
        
        // Handle Universal Link (https://beraw.app/challenge/123)
        if components.scheme == "https" && components.host == universalLinkDomain {
            print("✅ Valid Universal Link detected")
            extractChallengeId(from: url)
            return true
        }
        
        // Handle custom URL scheme (beraw://challenge/123)
        if components.scheme == "beraw" && components.host == "challenge" {
            print("✅ Valid beraw URL scheme detected")
            extractChallengeId(from: url)
            return true
        }
        
        print("❌ Invalid URL scheme or host")
        return false
    }
    
    // MARK: - Private Helpers
    
    private func extractChallengeId(from url: URL) {
        // Extract from path
        // For Universal Link: https://beraw.app/challenge/123-456-789
        // For Custom Scheme: beraw://challenge/123-456-789
        let pathComponents = url.pathComponents
        print("📍 Path components: \(pathComponents)")
        
        // Find "challenge" in path and get the next component
        if let challengeIndex = pathComponents.firstIndex(of: "challenge"),
           challengeIndex + 1 < pathComponents.count {
            let challengeId = pathComponents[challengeIndex + 1]
            print("✅ Extracted challenge ID: \(challengeId)")
            pendingChallengeId = challengeId
        } else if pathComponents.count >= 2 {
            // Fallback: second component
            let challengeId = pathComponents[1]
            print("✅ Extracted challenge ID (fallback): \(challengeId)")
            pendingChallengeId = challengeId
        } else {
            print("❌ Invalid path components count: \(pathComponents.count)")
        }
    }
}
