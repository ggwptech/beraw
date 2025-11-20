//
//  DeleteAccountView.swift
//  RawDogged
//
//  Account deletion confirmation screen
//

import SwiftUI
import FirebaseAuth

struct DeleteAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppStateManager
    
    @State private var confirmationText = ""
    @State private var showFinalConfirmation = false
    @State private var isDeleting = false
    @State private var errorMessage: String?
    
    private let accentBlack = Color.black
    private let requiredText = "DELETE"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Warning Icon
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .padding(.top, 40)
                    
                    // Title
                    Text("Delete Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    // Warning Message
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This action cannot be undone")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.red)
                        
                        Text("The following data will be permanently deleted:")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            DeletedDataItem(text: "All your challenges")
                            DeletedDataItem(text: "All journal entries")
                            DeletedDataItem(text: "All session history")
                            DeletedDataItem(text: "Your statistics and progress")
                            DeletedDataItem(text: "Your leaderboard position")
                            DeletedDataItem(text: "Your account and profile")
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    
                    // Error Message
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    
                    // Delete Button
                    Button(action: {
                        showFinalConfirmation = true
                    }) {
                        if isDeleting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text("Delete My Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red)
                    )
                    .disabled(isDeleting)
                    
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(accentBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(accentBlack, lineWidth: 2)
                    )
                }
                .padding(20)
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
            .alert("Final Confirmation", isPresented: $showFinalConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Forever", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you absolutely sure? This cannot be undone.")
            }
        }
    }
    
    private func deleteAccount() {
        isDeleting = true
        errorMessage = nil
        
        Task {
            do {
                try await appState.deleteAccount()
                
                // Success - dismiss and return to auth screen
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isDeleting = false
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct DeletedDataItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.red)
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    DeleteAccountView()
        .environmentObject(AppStateManager())
}
