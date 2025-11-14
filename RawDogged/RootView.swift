//
//  RootView.swift
//  RawDogged
//

import SwiftUI

struct RootView: View {
    @State private var showSplash = true
    @State private var showLanguageSelection = !UserDefaults.standard.bool(forKey: "hasSelectedLanguage")
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @State private var showAuth = !UserDefaults.standard.bool(forKey: "hasCompletedAuth")
    @State private var showPaywall = !UserDefaults.standard.bool(forKey: "hasSeenInitialPaywall")
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
            } else if showLanguageSelection {
                LanguageSelectionView(isPresented: $showLanguageSelection, showOnboardingNext: $showOnboarding)
            } else if showOnboarding {
                OnboardingView(isPresented: $showOnboarding, showAuthNext: $showAuth)
            } else if showAuth {
                AuthView(isPresented: $showAuth, showPaywallNext: $showPaywall)
            } else if showPaywall {
                InitialPaywallView(isPresented: $showPaywall)
            } else {
                ContentView()
            }
        }
        .onAppear {
            // Hide splash after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

struct SplashScreenView: View {
    private let accentBlack = Color.black
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(accentBlack)
                
                Text("Be Raw")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}

struct LanguageSelectionView: View {
    @Binding var isPresented: Bool
    @Binding var showOnboardingNext: Bool
    @EnvironmentObject var appState: AppStateManager
    @State private var selectedLanguage: AppLanguage? = nil
    
    private let accentBlack = Color.black
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(accentBlack)
                    
                    Text(selectedLanguage == nil ? "Choose Language" : appState.localized("language_selection_title"))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(selectedLanguage == nil ? "Select your preferred language" : appState.localized("language_selection_subtitle"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Language Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            LanguageCard(
                                language: language,
                                isSelected: selectedLanguage == language
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedLanguage = language
                                    appState.setLanguage(language)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 500)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    if selectedLanguage != nil {
                        UserDefaults.standard.set(true, forKey: "hasSelectedLanguage")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedLanguage != nil ? accentBlack : Color.gray.opacity(0.3))
                        )
                }
                .disabled(selectedLanguage == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct LanguageCard: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void
    
    private let accentBlack = Color.black
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(language.flagEmoji)
                    .font(.system(size: 48))
                
                Text(language.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? accentBlack : Color.gray.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(color: accentBlack.opacity(isSelected ? 0.15 : 0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @Binding var showAuthNext: Bool
    @EnvironmentObject var appState: AppStateManager
    @State private var currentPage = 0
    
    private let accentBlack = Color.black
    
    var pages: [OnboardingPage] {
        [
            OnboardingPage(
                icon: "bolt.fill",
                title: appState.localized("onboarding_welcome_title"),
                description: appState.localized("onboarding_welcome_description")
            ),
            OnboardingPage(
                icon: "timer",
                title: appState.localized("onboarding_track_title"),
                description: appState.localized("onboarding_track_description")
            ),
            OnboardingPage(
                icon: "flag.fill",
                title: appState.localized("onboarding_challenges_title"),
                description: appState.localized("onboarding_challenges_description")
            )
        ]
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Spacer()
                
                // Continue/Get Started button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? appState.localized("continue") : appState.localized("get_started"))
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
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
        
        // Show auth after onboarding if user hasn't completed it
        if !UserDefaults.standard.bool(forKey: "hasCompletedAuth") {
            showAuthNext = true
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    private let accentBlack = Color.black
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            ZStack {
                Circle()
                    .fill(accentBlack.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(accentBlack)
            }
            
            // Title and Description
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct AuthView: View {
    @Binding var isPresented: Bool
    @Binding var showPaywallNext: Bool
    @EnvironmentObject var appState: AppStateManager
    
    private let accentBlack = Color.black
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(accentBlack)
                    
                    Text(appState.localized("auth_title"))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(appState.localized("auth_subtitle"))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                
                Spacer()
                
                // Auth Buttons
                VStack(spacing: 16) {
                    // Apple Sign In
                    Button(action: {
                        // Action: Apple Sign In
                        completeAuth()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20, weight: .semibold))
                            Text(appState.localized("auth_apple"))
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black)
                        )
                    }
                    
                    // Google Sign In
                    Button(action: {
                        // Action: Google Sign In
                        completeAuth()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text(appState.localized("auth_google"))
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Terms
                VStack(spacing: 8) {
                    Text(appState.localized("auth_terms_prefix"))
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
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeAuth() {
        UserDefaults.standard.set(true, forKey: "hasCompletedAuth")
        withAnimation {
            isPresented = false
        }
        
        // Show paywall after auth if user hasn't seen it
        if !UserDefaults.standard.bool(forKey: "hasSeenInitialPaywall") {
            showPaywallNext = true
        }
    }
}

struct InitialPaywallView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppStateManager
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var showCloseButton = false
    
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
                // Close button (X) or Loading spinner
                HStack {
                    Spacer()
                    
                    if showCloseButton {
                        Button(action: {
                            completePaywall()
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
                        .transition(.opacity)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
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
                            PaywallFeatureRow(icon: "infinity", title: appState.localized("paywall_feature_unlimited"), appState: appState)
                            PaywallFeatureRow(icon: "chart.line.uptrend.xyaxis", title: appState.localized("paywall_feature_leaderboard"), appState: appState)
                            PaywallFeatureRow(icon: "trophy.fill", title: appState.localized("paywall_feature_challenges"), appState: appState)
                            PaywallFeatureRow(icon: "sparkles", title: appState.localized("paywall_feature_support"), appState: appState)
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
                            completePaywall()
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
        .onAppear {
            // Show close button after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCloseButton = true
                }
            }
        }
    }
    
    private func completePaywall() {
        UserDefaults.standard.set(true, forKey: "hasSeenInitialPaywall")
        withAnimation {
            isPresented = false
        }
    }
}

struct PaywallFeatureRow: View {
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
    RootView()
        .environmentObject(AppStateManager())
}

