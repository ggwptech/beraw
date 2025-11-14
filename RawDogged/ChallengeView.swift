//
//  ChallengeView.swift
//  RawDogged
//

import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showAddChallenge = false
    @State private var challengeForActions: RawChallenge?
    @State private var challengeForTimer: RawChallenge?
    @State private var challengeForShare: RawChallenge?
    @State private var pendingChallengeStart: RawChallenge?
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
                            Text(appState.localized("challenge_title"))
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
                                    Text(appState.localized("challenge_my"))
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
                                    Text(appState.localized("challenge_public"))
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
                                        let storedChallenge = appState.publicChallenges.first(where: { $0.id == challenge.id }) ?? challenge
                                        appState.startChallenge(storedChallenge)
                                        challengeForTimer = storedChallenge
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
                                        guard !challenge.isCompleted else { return }
                                        let storedChallenge = appState.challenges.first(where: { $0.id == challenge.id }) ?? challenge
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                            challengeForActions = storedChallenge
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
            .sheet(item: $challengeForActions) { challenge in
                ChallengeActionsSheet(
                    challenge: challenge,
                    onStart: {
                        pendingChallengeStart = challenge
                        challengeForActions = nil
                    },
                    onShare: {
                        let challengeId = challenge.id
                        challengeForActions = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let storedChallenge = appState.challenges.first(where: { $0.id == challengeId }) {
                                challengeForShare = storedChallenge
                            } else {
                                challengeForShare = challenge
                            }
                        }
                    },
                    onDelete: {
                        appState.deleteChallenge(challenge)
                        challengeForActions = nil
                    }
                )
                .environmentObject(appState)
                .presentationDetents([.height(225)])
                .presentationBackground(Color.white)
                .onDisappear {
                    if let pendingStart = pendingChallengeStart {
                        pendingChallengeStart = nil
                        let challengeToStart = appState.challenges.first(where: { $0.id == pendingStart.id }) ?? pendingStart
                        appState.startChallenge(challengeToStart)
                        challengeForTimer = challengeToStart
                    }
                }
            }
            .sheet(item: $challengeForShare) { challenge in
                ShareChallengeSheet(challenge: challenge)
                    .environmentObject(appState)
                    .presentationDetents([.height(380)])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.white)
                    .onAppear {
                        appState.shareChallengeToPublic(challenge)
                    }
            }
            .fullScreenCover(item: $challengeForTimer) { challenge in
                ChallengeTimerView(
                    challenge: challenge,
                    targetDuration: TimeInterval(challenge.durationMinutes * 60)
                )
                .environmentObject(appState)
                .onDisappear {
                    challengeForTimer = nil
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
                        Text(appState.localized("challenge_title"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .leading) {
                            if title.isEmpty {
                                Text(appState.localized("challenge_enter_title"))
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.leading, 16)
                            }
                            
                            TextField("", text: $title)
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
                    
                    // Duration Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(appState.localized("challenge_duration"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        // Time picker using hours and minutes
                        HStack(spacing: 0) {
                            // Hours
                            Picker("Hours", selection: $selectedHours) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour)")
                                        .foregroundColor(.black)
                                        .tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Text(appState.localized("common_hour_short"))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                            
                            // Minutes
                            Picker("Minutes", selection: $selectedMinutes) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)")
                                        .foregroundColor(.black)
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            
                            Text(appState.localized("common_minute_short"))
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
                        Text(appState.localized("challenge_create_button"))
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
            .navigationTitle(appState.localized("challenge_create_new"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(appState.localized("challenge_cancel")) {
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
    let onDelete: () -> Void
    @EnvironmentObject var appState: AppStateManager
    
    private let accentBlack = Color.black
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)
            
            // Challenge title
            Text(challenge.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 16)
            
            // Horizontal buttons
            HStack(spacing: 12) {
                // Share button - white with black border
                Button(action: onShare) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 20)
                        Text(appState.localized("share"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    )
                }
                
                // Start button - black
                Button(action: onStart) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 20)
                        Text(appState.localized("start"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentBlack)
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // Delete button - red
            Button(action: onDelete) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 20)
                    Text(appState.localized("delete"))
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}

// Share Challenge Sheet
struct ShareChallengeSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    let challenge: RawChallenge
    
    @State private var linkCopied = false
    
    private let accentBlack = Color.black
    
    private var challengeLink: String {
        "beraw://challenge/\(challenge.id.uuidString)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.localized("share_challenge_title"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                    Text(appState.localized("share_published_public"))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.gray)
                }
            }
            .padding(20)
            .background(Color.white)
            
            VStack(spacing: 20) {
                // Challenge Preview
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(accentBlack)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "target")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                            Text("\(challenge.durationMinutes) min")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                )
                
                // Link Section
                VStack(alignment: .leading, spacing: 10) {
                    Text(appState.localized("share_challenge_link"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 10) {
                        Text(challengeLink)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        
                        Button(action: {
                            UIPasteboard.general.string = challengeLink
                            linkCopied = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                linkCopied = false
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: linkCopied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 13, weight: .semibold))
                                Text(linkCopied ? appState.localized("share_link_copied") : appState.localized("share_copy_link"))
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(linkCopied ? Color.green : accentBlack)
                            )
                        }
                    }
                }
                
                // Share Button
                ShareLink(
                    item: URL(string: challengeLink)!,
                    subject: Text("Join my Raw Challenge"),
                    message: Text("I challenge you to: \(challenge.title) for \(challenge.durationMinutes) minutes. Can you do it?")
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                        Text(appState.localized("share_with_friends"))
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentBlack)
                    )
                }
            }
            .padding(20)
            .background(Color.white)
        }
    }
}

#Preview {
    ChallengeView()
        .environmentObject(AppStateManager())
}
