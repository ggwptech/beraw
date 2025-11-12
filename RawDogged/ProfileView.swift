//
//  ProfileView.swift
//  RawDogged
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showGoalSetting = false
    
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
                            Text("My Dog")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Settings Section
                    VStack(spacing: 12) {
                        SettingsCard(icon: "bell.fill", title: "App Notifications", showChevron: true) {
                            // Action
                        }
                        
                        SettingsCard(icon: "info.circle.fill", title: "About & Privacy", showChevron: true) {
                            // Action
                        }
                        
                        SettingsCard(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", isDestructive: true, showChevron: false) {
                            // Action
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
        }
        .accentColor(accentBlack)
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

#Preview {
    ProfileView()
        .environmentObject(AppStateManager())
}
