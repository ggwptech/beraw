//
//  JournalEntryView.swift
//  RawDogged
//

import SwiftUI

struct JournalEntryView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    @State private var thoughts = ""
    @FocusState private var isTextFieldFocused: Bool
    
    private let accentBlue = Color(red: 47/255, green: 0, blue: 1)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Session Complete Card
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(accentBlue)
                        
                        Text("Session Complete!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        if let duration = appState.completedSessionDuration {
                            Text(appState.formatTime(duration))
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(accentBlue)
                                .monospacedDigit()
                        }
                        
                        Text("How do you feel?")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlue.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Thoughts Input Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.line")
                                .font(.system(size: 12, weight: .medium))
                            Text("Your Thoughts")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        
                        TextEditor(text: $thoughts)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .frame(height: 180)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .focused($isTextFieldFocused)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isTextFieldFocused ? accentBlue : Color.clear, lineWidth: 2)
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
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            if !thoughts.isEmpty {
                                appState.saveJournalEntry(thoughts: thoughts)
                            }
                            dismiss()
                        }) {
                            Text("Save Thoughts")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(thoughts.isEmpty ? accentBlue.opacity(0.5) : accentBlue)
                                )
                        }
                        
                        Button(action: {
                            appState.skipJournalEntry()
                            dismiss()
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    JournalEntryView()
        .environmentObject(AppStateManager())
}
