//
//  ChallengeView.swift
//  RawDogged
//

import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showAddChallenge = false
    
    private let accentBlue = Color(red: 47/255, green: 0, blue: 1) // #2f00ff
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "target")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(accentBlue)
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
                                    .fill(accentBlue)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Progress Summary Card
                    VStack(spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Progress")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(completedCount)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                                Text("Completed")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(appState.challenges.count)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.gray)
                                Text("Total")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Challenges List
                    VStack(spacing: 12) {
                        ForEach(appState.challenges) { challenge in
                            ChallengeCard(challenge: challenge)
                                .environmentObject(appState)
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
        }
        .accentColor(accentBlue)
    }
    
    private var completedCount: Int {
        appState.challenges.filter { $0.isCompleted }.count
    }
}

struct ChallengeCard: View {
    let challenge: RawChallenge
    @EnvironmentObject var appState: AppStateManager
    
    private let accentBlue = Color(red: 47/255, green: 0, blue: 1) // #2f00ff
    
    var body: some View {
        Button(action: {
            appState.toggleChallenge(challenge)
        }) {
            HStack(spacing: 16) {
                // Status Indicator
                ZStack {
                    if challenge.isCompleted {
                        ZStack {
                            Circle()
                                .fill(accentBlue)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    } else {
                        Circle()
                            .stroke(accentBlue.opacity(0.3), lineWidth: 2)
                            .frame(width: 32, height: 32)
                    }
                }
                
                // Challenge Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text("\(challenge.durationMinutes) minutes")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Duration Badge
                Text("\(challenge.durationMinutes)m")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(challenge.isCompleted ? .white : accentBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(challenge.isCompleted ? accentBlue : accentBlue.opacity(0.1))
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddChallengeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    
    @State private var title = ""
    @State private var duration = ""
    
    private let accentBlue = Color(red: 47/255, green: 0, blue: 1) // #2f00ff
    
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
                            .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
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
                            .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
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
                                    .fill(accentBlue)
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
                    .foregroundColor(accentBlue)
                }
            }
        }
        .accentColor(accentBlue)
    }
}

#Preview {
    ChallengeView()
        .environmentObject(AppStateManager())
}
