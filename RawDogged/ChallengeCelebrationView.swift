//
//  ChallengeCelebrationView.swift
//  RawDogged
//

import SwiftUI

struct ChallengeCelebrationView: View {
    @Environment(\.dismiss) var dismiss
    let challenge: RawChallenge
    let duration: Int // in minutes
    
    @State private var showConfetti = false
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var selectedMessage: String = ""
    
    private let congratulationMessages = [
        "You went raw and won",
        "All in. No filters. You did it",
        "Raw energy. Real results",
        "That's how it's done - raw and real",
        "You did awesome!"
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Confetti
            ForEach(confettiPieces) { piece in
                ConfettiView(piece: piece)
            }
            
            VStack(spacing: 40) {
                // App Logo and Name at top
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Be Raw")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .opacity(showConfetti ? 1.0 : 0.0)
                .offset(y: showConfetti ? 0 : -20)
                .animation(.easeOut(duration: 0.6).delay(0.1), value: showConfetti)
                .padding(.top, 60)
                
                Spacer()
                
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(showConfetti ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: showConfetti)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.green)
                        .scaleEffect(showConfetti ? 1.0 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5), value: showConfetti)
                }
                .frame(width: 120, height: 120)
                
                VStack(spacing: 16) {
                    Text(selectedMessage)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showConfetti ? 1.0 : 0.0)
                        .offset(y: showConfetti ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: showConfetti)
                }
                
                // Challenge info
                VStack(spacing: 12) {
                    Text(challenge.title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16))
                        Text("\(duration) min")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .opacity(showConfetti ? 1.0 : 0.0)
                .offset(y: showConfetti ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showConfetti)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 40)
                .opacity(showConfetti ? 1.0 : 0.0)
                .offset(y: showConfetti ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: showConfetti)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            selectedMessage = congratulationMessages.randomElement() ?? "You did awesome!"
            startCelebration()
        }
    }
    
    private func startCelebration() {
        showConfetti = true
        generateConfetti()
    }
    
    private func generateConfetti() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
        let screenHeight = UIScreen.main.bounds.height
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                color: colors.randomElement() ?? .blue,
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: screenHeight + 50,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5)
            )
            confettiPieces.append(piece)
        }
    }
}

// MARK: - Confetti Piece Model
struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let rotation: Double
    let scale: CGFloat
}

// MARK: - Confetti View
struct ConfettiView: View {
    let piece: ConfettiPiece
    
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(piece.color)
            .frame(width: 10 * piece.scale, height: 10 * piece.scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(x: piece.x + xOffset, y: piece.y + yOffset)
            .onAppear {
                let duration = Double.random(in: 1.5...2.5)
                let maxHeight = -CGFloat.random(in: 200...400)
                
                withAnimation(.easeOut(duration: duration)) {
                    yOffset = maxHeight
                    opacity = 0.0
                }
                
                withAnimation(.easeInOut(duration: duration * 0.5).repeatCount(3, autoreverses: true)) {
                    xOffset = CGFloat.random(in: -40...40)
                }
                
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

#Preview {
    ChallengeCelebrationView(
        challenge: RawChallenge(title: "Медитация", durationMinutes: 20),
        duration: 20
    )
}
