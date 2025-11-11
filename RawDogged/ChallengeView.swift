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
    
    private let accentBlack = Color.black // #2f00ff
    
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
                    
                    // Challenges List
                    VStack(spacing: 12) {
                        ForEach(appState.challenges) { challenge in
                            ChallengeCard(challenge: challenge)
                                .environmentObject(appState)
                                .onTapGesture {
                                    if !challenge.isCompleted {
                                        selectedChallenge = challenge
                                        appState.startChallenge(challenge)
                                        showChallengeTimer = true
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddChallenge) {
                AddChallengeView()
                    .environmentObject(appState)
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
    @State private var duration = ""
    
    private let accentBlack = Color.black // #2f00ff
    
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
                        Text("Duration (minutes)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("e.g., 20", text: $duration)
                            .font(.system(size: 16, weight: .regular))
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
                    
                    // Add Button
                    Button(action: {
                        if let durationInt = Int(duration), !title.isEmpty {
                            appState.addChallenge(title: title, durationMinutes: durationInt)
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
                    .disabled(title.isEmpty || duration.isEmpty)
                    .opacity(title.isEmpty || duration.isEmpty ? 0.5 : 1.0)
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

#Preview {
    ChallengeView()
        .environmentObject(AppStateManager())
}
