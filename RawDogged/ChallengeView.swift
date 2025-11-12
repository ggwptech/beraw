//
//  ChallengeView.swift
//  RawDogged
//

import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showAddChallenge = false
    @State private var selectedChallenge: RawChallenge?
    @State private var showChallengeTimer = false
    @State private var showChallengeActions = false
    @State private var selectedTab: ChallengeTab = .myChalllenges
    
    private let accentBlack = Color.black // #2f00ff
    
    enum ChallengeTab {
        case myChalllenges
        case publicChallenges
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "target")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(accentBlack)
                            Text("Raw Challenges")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showAddChallenge = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(accentBlack)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Tab Switcher
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                selectedTab = .myChalllenges
                            }
                        }) {
                            VStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Personal")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(selectedTab == .myChalllenges ? accentBlack : .gray)
                                
                                Rectangle()
                                    .fill(selectedTab == .myChalllenges ? accentBlack : Color.clear)
                                    .frame(height: 2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        
                        Button(action: {
                            withAnimation {
                                selectedTab = .publicChallenges
                            }
                        }) {
                            VStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Public")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(selectedTab == .publicChallenges ? accentBlack : .gray)
                                
                                Rectangle()
                                    .fill(selectedTab == .publicChallenges ? accentBlack : Color.clear)
                                    .frame(height: 2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    
                    // Statistics Card
                    VStack(spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Statistics")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(completedChallengesCount)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.green)
                                Text("Completed")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(activeChallengesCount)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                                Text("Active")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Challenges List based on selected tab
                    if selectedTab == .publicChallenges {
                        // Public Challenges Section
                        VStack(spacing: 12) {
                            ForEach(appState.publicChallenges) { challenge in
                                PublicChallengeCard(challenge: challenge)
                                    .environmentObject(appState)
                                    .onTapGesture {
                                        // Tap directly starts public challenge
                                        selectedChallenge = challenge
                                        appState.startChallenge(challenge)
                                        showChallengeTimer = true
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    } else {
                        // My Challenges Section
                        VStack(spacing: 12) {
                            ForEach(appState.challenges) { challenge in
                                ChallengeCard(challenge: challenge, isPublic: challenge.isPublic)
                                    .environmentObject(appState)
                                    .onTapGesture {
                                        if !challenge.isCompleted {
                                            selectedChallenge = challenge
                                            showChallengeActions = true
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddChallenge) {
                AddChallengeView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showChallengeActions) {
                if let challenge = selectedChallenge {
                    ChallengeActionsSheet(
                        challenge: challenge,
                        onStart: {
                            showChallengeActions = false
                            appState.startChallenge(challenge)
                            showChallengeTimer = true
                        },
                        onShare: {
                            appState.shareChallengeToPublic(challenge)
                            showChallengeActions = false
                        }
                    )
                    .presentationDetents([.height(200)])
                }
            }
            .fullScreenCover(isPresented: $showChallengeTimer) {
                if let challenge = selectedChallenge {
                    ChallengeTimerView(
                        challenge: challenge,
                        targetDuration: TimeInterval(challenge.durationMinutes * 60)
                    )
                    .environmentObject(appState)
                }
            }
        }
        .accentColor(accentBlack)
    }
    
    private var completedChallengesCount: Int {
        appState.challenges.filter { $0.isCompleted }.count
    }
    
    private var activeChallengesCount: Int {
        appState.challenges.filter { !$0.isCompleted }.count
    }
}

struct ChallengeCard: View {
    let challenge: RawChallenge
    let isPublic: Bool
    @EnvironmentObject var appState: AppStateManager
    
    private let accentBlack = Color.black // #2f00ff
    
    var body: some View {
        HStack(spacing: 16) {
            // Target Icon
            ZStack {
                Circle()
                    .fill(challenge.isCompleted ? Color.gray.opacity(0.3) : accentBlack)
                    .frame(width: 48, height: 48)
                
                Image(systemName: challenge.isCompleted ? "checkmark" : "target")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(challenge.isCompleted ? .gray : .white)
            }
            
            // Challenge Info
            VStack(alignment: .leading, spacing: 6) {
                Text(challenge.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(challenge.isCompleted ? .gray : .black)
                    .strikethrough(challenge.isCompleted, color: .gray)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text("\(challenge.durationMinutes) min")
                    }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    
                    if challenge.completedCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text("\(challenge.completedCount)×")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(challenge.isCompleted ? .gray : accentBlack)
                    }
                    
                    if isPublic {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.system(size: 10))
                            Text("Public")
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Arrow or Completed
            if challenge.isCompleted {
                Text("Done")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .opacity(challenge.isCompleted ? 0.6 : 1.0)
    }
}

struct AddChallengeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    
    @State private var title = ""
    @State private var selectedHours = 0
    @State private var selectedMinutes = 20
    
    private let accentBlack = Color.black // #2f00ff
    
    private var totalDuration: Int {
        selectedHours * 60 + selectedMinutes
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Title Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Challenge Title")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("e.g., 20 Min: Meditate", text: $title)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
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
                    
                    // Duration Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Duration")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        // Time picker using hours and minutes
                        HStack(spacing: 0) {
                            // Hours
                            Picker("Hours", selection: $selectedHours) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Text("hr")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                            
                            // Minutes
                            Picker("Minutes", selection: $selectedMinutes) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Text("min")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                        }
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Add Button
                    Button(action: {
                        if totalDuration > 0 && !title.isEmpty {
                            appState.addChallenge(title: title, durationMinutes: totalDuration)
                            dismiss()
                        }
                    }) {
                        Text("Add Challenge")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(accentBlack)
                            )
                    }
                    .disabled(title.isEmpty || totalDuration == 0)
                    .opacity(title.isEmpty || totalDuration == 0 ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(accentBlack)
                }
            }
        }
        .accentColor(accentBlack)
    }
}

// Public Challenge Card with user count
struct PublicChallengeCard: View {
    let challenge: RawChallenge
    @EnvironmentObject var appState: AppStateManager
    
    private let accentBlack = Color.black
    
    var body: some View {
        HStack(spacing: 16) {
            // Globe Icon
            ZStack {
                Circle()
                    .fill(accentBlack)
                    .frame(width: 48, height: 48)
                
                Image(systemName: "globe")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Challenge Info
            VStack(alignment: .leading, spacing: 6) {
                Text(challenge.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text("\(challenge.durationMinutes) min")
                    }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                        Text("\(challenge.usersCompletedCount) users")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Play Icon
            Image(systemName: "play.circle.fill")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(accentBlack)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }
}

// Bottom sheet for challenge actions
struct ChallengeActionsSheet: View {
    let challenge: RawChallenge
    let onStart: () -> Void
    let onShare: () -> Void
    
    private let accentBlack = Color.black
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Challenge title
            Text(challenge.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 20)
            
            // Actions
            HStack(spacing: 20) {
                // Share button
                Button(action: onShare) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        Text("Share")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Start button
                Button(action: onStart) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(accentBlack)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Text("Start")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 60)
            .padding(.bottom, 20)
            
            Spacer()
        }
    }
}

#Preview {
    ChallengeView()
        .environmentObject(AppStateManager())
}
