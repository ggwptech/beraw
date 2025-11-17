//
//  ProfileView.swift
//  RawDogged
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showGoalSetting = false
    @State private var showEditProfile = false
    @State private var showPaywall = false
    
    private let accentBlack = Color.black
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(accentBlack)
                            Text(appState.localized("profile_title"))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // User Profile Card
                    VStack(spacing: 20) {
                        // User Info
                        VStack(spacing: 8) {
                            Text(appState.userName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            // Show email if available
                            if let email = appState.userEmail, !email.isEmpty {
                                Text(email)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 4)
                        
                        // Stats Row
                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("\(appState.userStats.dailyStreak)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                Text(appState.localized("home_streak"))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1, height: 35)
                            
                            VStack(spacing: 4) {
                                Text(appState.formatTotalTime(appState.userStats.totalRawTime))
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                Text(appState.localized("home_total_time"))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1, height: 35)
                            
                            VStack(spacing: 4) {
                                Text("\(appState.journalEntries.count)")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                Text(appState.localized("home_journal_entries"))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Edit Profile Button
                        Button(action: {
                            showEditProfile = true
                        }) {
                            Text(appState.localized("profile_edit_profile"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1.5)
                                )
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Premium Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.orange)
                                    
                                    Text(appState.localized("profile_premium"))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                
                                Text(appState.localized("profile_unlock_features"))
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showPaywall = true
                            }) {
                                Text(appState.localized("profile_upgrade"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(accentBlack)
                                    )
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
                    
                    // Personal Stats Section
                    VStack(spacing: 16) {
                        HStack {
                            Text(appState.localized("profile_your_stats"))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            // Total Time
                            HStack {
                                HStack(spacing: 12) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(accentBlack)
                                        .frame(width: 30)
                                    
                                    Text(appState.localized("profile_total_meditation_time"))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Text(appState.formatTotalTime(appState.userStats.totalRawTime))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(accentBlack)
                            }
                            
                            Divider()
                            
                            // Personal Challenges
                            HStack {
                                HStack(spacing: 12) {
                                    Image(systemName: "target")
                                        .font(.system(size: 18))
                                        .foregroundColor(accentBlack)
                                        .frame(width: 30)
                                    
                                    Text(appState.localized("profile_personal_challenges"))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Text("\(appState.challenges.count)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(accentBlack)
                            }
                            
                            Divider()
                            
                            // Completed Challenges
                            HStack {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.green)
                                        .frame(width: 30)
                                    
                                    Text(appState.localized("profile_completed_challenges"))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Text("\(appState.challenges.filter { $0.isCompleted }.count)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            
                            Divider()
                            
                            // Journal Entries
                            HStack {
                                HStack(spacing: 12) {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(accentBlack)
                                        .frame(width: 30)
                                    
                                    Text(appState.localized("profile_journal_entries"))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Text("\(appState.journalEntries.count)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(accentBlack)
                            }
                            
                            Divider()
                            
                            // Total Points
                            HStack {
                                HStack(spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.orange)
                                        .frame(width: 30)
                                    
                                    Text(appState.localized("profile_total_points"))
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Text("\(appState.userStats.totalPoints)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Settings Section
                    VStack(spacing: 12) {
                        SettingsCard(icon: "questionmark.circle.fill", title: appState.localized("profile_support"), showChevron: true) {
                            // Action: Contact support
                        }
                        
                        SettingsCard(icon: "doc.text.fill", title: appState.localized("profile_terms"), showChevron: true) {
                            // Action: Show terms
                        }
                        
                        SettingsCard(icon: "info.circle.fill", title: appState.localized("profile_about_privacy"), showChevron: true) {
                            // Action
                        }
                        
                        SettingsCard(icon: "rectangle.portrait.and.arrow.right", title: appState.localized("profile_logout"), isDestructive: true, showChevron: false) {
                            logoutUser()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationBarHidden(true)
            .sheet(isPresented: $showGoalSetting) {
                GoalSettingView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .accentColor(accentBlack)
    }
    
    private func logoutUser() {
        // Clear UserDefaults
        UserDefaults.standard.set(false, forKey: "hasCompletedAuth")
        
        // Sign out from Firebase
        do {
            try Auth.auth().signOut()
            
            // Reset app state
            appState.currentUserId = nil
            appState.userName = "Raw Dog"
            appState.userEmail = nil
            appState.challenges = []
            appState.journalEntries = []
            appState.userStats = UserStats(dailyStreak: 0, totalRawTime: 0, dailyGoalMinutes: 60, dailyHistory: [])
            
            // Force app restart by exiting
            exit(0)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct SettingsCard: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    var showChevron: Bool
    let action: () -> Void
    
    private let accentBlack = Color.black
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isDestructive ? .red : accentBlack)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDestructive ? .red : .black)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(accentBlack.opacity(0.4))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LineChartView: View {
    let data: [Int]
    
    private let accentBlack = Color.black // #2f00ff
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let width = geometry.size.width
            let height = geometry.size.height
            let stepX = width / CGFloat(max(data.count - 1, 1))
            
            ZStack(alignment: .bottomLeading) {
                // Line Path
                Path { path in
                    guard data.count > 0 else { return }
                    
                    let firstPoint = CGPoint(
                        x: 0,
                        y: height - (CGFloat(data[0]) / CGFloat(maxValue)) * height
                    )
                    path.move(to: firstPoint)
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(value) / CGFloat(maxValue)) * height
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(accentBlack, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

struct GoalSettingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    
    @State private var goalMinutes = ""
    
    private let accentBlack = Color.black // #2f00ff
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Current Goal Card
                    VStack(spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "target")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Current Goal")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(appState.userStats.dailyGoalMinutes)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.black)
                            Text("min")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // New Goal Input Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("New Daily Goal (minutes)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("e.g., 60", text: $goalMinutes)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .keyboardType(.numberPad)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: {
                        if let minutes = Int(goalMinutes) {
                            appState.userStats.dailyGoalMinutes = minutes
                            dismiss()
                        }
                    }) {
                        Text("Save Goal")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(accentBlack)
                            )
                    }
                    .disabled(goalMinutes.isEmpty)
                    .opacity(goalMinutes.isEmpty ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Set Daily Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(accentBlack)
                }
            }
            .onAppear {
                goalMinutes = String(appState.userStats.dailyGoalMinutes)
            }
        }
        .accentColor(accentBlack)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    
    @State private var userName = ""
    
    private let accentBlack = Color.black
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // User Name Input Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(appState.localized("profile_username"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .leading) {
                            if userName.isEmpty {
                                Text(appState.localized("profile_enter_username"))
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.leading, 16)
                            }
                            
                            TextField("", text: $userName)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .tint(accentBlack)
                                .padding(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: {
                        if !userName.isEmpty {
                            appState.updateUserName(userName)
                            dismiss()
                        }
                    }) {
                        Text(appState.localized("common_save"))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(accentBlack)
                            )
                    }
                    .disabled(userName.isEmpty)
                    .opacity(userName.isEmpty ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
            .navigationTitle(appState.localized("profile_edit_profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(appState.localized("common_cancel")) {
                        dismiss()
                    }
                    .foregroundColor(accentBlack)
                }
            }
            .onAppear {
                userName = appState.userName
            }
        }
        .accentColor(accentBlack)
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    @State private var selectedPlan: SubscriptionPlan = .yearly
    
    private let accentBlack = Color.black
    
    enum SubscriptionPlan {
        case weekly
        case yearly
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color.white)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Premium Icon and Title
                        VStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.orange)
                            
                            Text(appState.localized("paywall_title"))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(appState.localized("paywall_subtitle"))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        // Features List
                        VStack(spacing: 16) {
                            FeatureRow(icon: "infinity", title: appState.localized("paywall_feature_unlimited"), appState: appState)
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: appState.localized("paywall_feature_leaderboard"), appState: appState)
                            FeatureRow(icon: "trophy.fill", title: appState.localized("paywall_feature_challenges"), appState: appState)
                            FeatureRow(icon: "sparkles", title: appState.localized("paywall_feature_support"), appState: appState)
                        }
                        .padding(.horizontal, 20)
                        
                        // Subscription Plans
                        VStack(spacing: 12) {
                            // Yearly Plan (with discount badge)
                            Button(action: {
                                selectedPlan = .yearly
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(appState.localized("paywall_yearly"))
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
                                            
                                            Text(appState.localized("paywall_save"))
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .fill(Color.orange)
                                                )
                                        }
                                        
                                        Text(appState.localized("paywall_price_yearly"))
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(selectedPlan == .yearly ? accentBlack : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if selectedPlan == .yearly {
                                            Circle()
                                                .fill(accentBlack)
                                                .frame(width: 16, height: 16)
                                        }
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedPlan == .yearly ? accentBlack : Color.clear, lineWidth: 2)
                                        )
                                        .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Weekly Plan
                            Button(action: {
                                selectedPlan = .weekly
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(appState.localized("paywall_weekly"))
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                        
                                        Text(appState.localized("paywall_price_weekly"))
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(selectedPlan == .weekly ? accentBlack : Color.gray.opacity(0.3), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if selectedPlan == .weekly {
                                            Circle()
                                                .fill(accentBlack)
                                                .frame(width: 16, height: 16)
                                        }
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(selectedPlan == .weekly ? accentBlack : Color.clear, lineWidth: 2)
                                        )
                                        .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        
                        // Subscribe Button
                        Button(action: {
                            // Action: Process subscription
                            appState.unlockPremium()
                            dismiss()
                        }) {
                            Text(appState.localized("continue"))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(accentBlack)
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        // Terms
                        VStack(spacing: 8) {
                            Text(appState.localized("paywall_terms_prefix"))
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 4) {
                                Button(action: {
                                    // Action: Show terms
                                }) {
                                    Text(appState.localized("auth_terms"))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(accentBlack)
                                        .underline()
                                }
                                
                                Text(appState.localized("auth_and"))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                                
                                Button(action: {
                                    // Action: Show privacy
                                }) {
                                    Text(appState.localized("auth_privacy"))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(accentBlack)
                                        .underline()
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let appState: AppStateManager
    
    private let accentBlack = Color.black
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(accentBlack)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(accentBlack.opacity(0.1))
                )
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.green)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppStateManager())
}

