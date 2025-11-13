//
//  RawDoggedApp.swift
//  RawDogged
//
//  Created by TestApple on 10.11.2025.
//

import SwiftUI

@main
struct RawDoggedApp: App {
    @StateObject private var appState = AppStateManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
