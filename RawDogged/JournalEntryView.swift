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
    
    private let accentBlack = Color.black
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Session Complete Info (without card background)
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(accentBlack)
                            
                            Text("Session Complete!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        if let duration = appState.completedSessionDuration {
                            Text(appState.formatTime(duration))
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(accentBlack)
                                .monospacedDigit()
                        }
                        
                        Text("How do you feel?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Thoughts Input Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.line")
                                .font(.system(size: 11, weight: .medium))
                            Text("Your Thoughts")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $thoughts)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.black)
                                .frame(height: 140)
                                .padding(8)
                                .background(Color.white)
                                .scrollContentBackground(.hidden)
                                .cornerRadius(8)
                                .focused($isTextFieldFocused)
                            
                            if thoughts.isEmpty {
                                Text("Write your thoughts here...")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: accentBlack.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    // Buttons (removed Spacer to reduce empty space)
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
                                        .fill(thoughts.isEmpty ? accentBlack.opacity(0.5) : accentBlack)
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
