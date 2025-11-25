


A highly minimalist iOS application designed to track and encourage periods of "raw dogging boredom"—intentionally spending time without digital distractions to foster creativity and mental resilience.

## 🎨 Design Philosophy

**Extreme Minimalism**: The app adheres to strict design constraints focused on clarity, white space, and high contrast.

### Color Palette
- **White**: `#FFFFFF` (Primary background)
- **Accent Blue**: `#007AFF` (Apple's system blue)
- **Red**: Used only for the STOP button and destructive actions

### Design Rules
✅ **Solid, flat colors only**  
❌ **NO gradients anywhere**  
✅ **San Francisco system font**  
✅ **Simple, linear icons**  
✅ **High contrast, clean spacing**

---

## 📱 Screen Breakdown

### 1. Home Screen (Dashboard)
**Purpose**: Track current raw dogging session and display key metrics

**Key Elements**:
- **Large Timer Display**: Shows current session time (00:00 format) in light blue
- **Circular Progress Indicator**: Thin blue circle showing progress toward daily goal
- **BEGIN/STOP Button**: Large circular button that changes from blue (BEGIN) to red (STOP)
- **Daily Streak**: Fire emoji with number of consecutive days
- **Total Raw Time**: Cumulative hours spent "raw dogging"

**User Flow**:
1. Tap BEGIN to start tracking
2. Timer counts up in real-time
3. Progress ring fills as you approach daily goal
4. Tap STOP to end session and save progress

---

### 2. Challenge Screen
**Purpose**: Provide and track predefined challenges for building discipline

**Key Elements**:
- **Scrollable Challenge List**: White cards with blue borders
- **Challenge Format**: "Duration: Activity Name" (e.g., "15 Min: Stare at the Wall")
- **Status Indicators**:
  - Blue filled dot for incomplete
  - Blue checkmark for completed
- **Add Button**: Plus icon in navigation bar to create custom challenges

**Included Challenges**:
- 15 Min: Stare at the Wall
- 45 Min: Silent Walk
- 3 Hour: No Phone Dinner
- 30 Min: Deep Thought
- 2 Hour: Complete Disconnect

**User Flow**:
1. Browse available challenges
2. Tap to mark as complete/incomplete
3. Create custom challenges via + button

---

### 3. Leaderboard Screen
**Purpose**: Compare raw time with other users and foster competition

**Key Elements**:
- **Period Toggles**: Daily / Weekly / All-Time (segmented control)
- **Ranked List**: Showing rank, nickname, and total time
- **#1 Highlight**: Top user has blue background with white text
- **Current User Highlight**: Light blue (10% opacity) background
- **Clean Typography**: Focus on numbers and names, no avatars

**Ranking Display**:
```
1  ZenMaster        40 hrs
2  MindfulNinja     30 hrs
3  SilentWarrior    24 hrs
4  You               8 hrs ← Highlighted
```

**User Flow**:
1. View rankings by different time periods
2. Compare your progress with others
3. Get motivated by top performers

---

### 4. Profile Screen
**Purpose**: View personal statistics, history, and manage settings

**Key Elements**:

#### A. History Visualization
- **Line Chart**: Clean blue line on white background
- **Time Range**: Last 30 days of raw time per day
- **Minimalist Design**: No axis labels, just the data shape

#### B. Settings List
Flat white cells with blue accents:
- **Set Daily Goal** → Opens modal to customize minutes
- **App Notifications** → Toggle and configure alerts
- **About & Privacy** → App info and privacy policy
- **Log Out** → Red text for visual separation

**User Flow**:
1. Review 30-day history at a glance
2. Adjust daily goal target
3. Configure notification preferences
4. Access app information

---

## 🛠️ Technical Implementation

### Platform
- **iOS 26** (Latest)
- **SwiftUI** framework
- **Language**: Swift

### Architecture
```
Models.swift              → Data structures and app state management
HomeView.swift           → Dashboard with timer and progress
ChallengeView.swift      → Challenge list and creation
LeaderboardView.swift    → Rankings and period toggles
ProfileView.swift        → History chart and settings
ContentView.swift        → Main TabView navigation
```

### Key Components

#### AppStateManager (Observable Object)
- Manages current session state
- Tracks user statistics (streak, total time, daily history)
- Handles challenge completion
- Provides leaderboard data
- Real-time timer updates

#### Data Models
- `RawSession`: Individual tracking sessions
- `RawChallenge`: Challenge definitions and completion status
- `LeaderboardEntry`: User rankings and times
- `UserStats`: Personal metrics and goals
- `DailyRecord`: Historical time tracking

---

## 🎯 User Experience Goals

1. **Friction-Free Tracking**: One tap to start, one tap to stop
2. **Visual Motivation**: Progress rings, streaks, and leaderboards
3. **Guided Practice**: Curated challenges for different durations
4. **Personal Insights**: Historical trends via clean line chart
5. **Social Competition**: Leaderboard to encourage consistency

---

## 🚀 How to Build & Run

### Prerequisites
- macOS with Xcode 16+ installed
- iOS Simulator or physical iOS device

### Steps
1. Open `RawDogged.xcodeproj` in Xcode
2. Select a target device (iOS Simulator or physical device)
3. Press `⌘ + R` to build and run
4. The app will launch with sample data

### Adding Files to Xcode Project
If files aren't showing in Xcode:
1. Right-click on the `RawDogged` group in the Project Navigator
2. Select "Add Files to RawDogged..."
3. Select all `.swift` files in the RawDogged folder
4. Ensure "Copy items if needed" is checked
5. Click "Add"

---

## 📐 Design Specifications

### Typography
- **Large Timer**: 72pt, Ultra Light weight
- **Titles**: 18-24pt, Medium/Semibold weight
- **Body Text**: 14-16pt, Regular weight
- **Caption**: 12-14pt, Regular weight, 60% opacity

### Spacing
- **Screen Padding**: 16-20pt horizontal, 24-40pt vertical
- **Card Spacing**: 16pt between elements
- **Component Padding**: 12-20pt internal padding

### Interactive Elements
- **Primary Button**: 120x120pt circle (BEGIN/STOP)
- **Cards**: 12pt corner radius, 1pt border
- **List Items**: 16pt vertical padding
- **Progress Ring**: 200x200pt, 3pt stroke width

### Colors (Exact Values)
```swift
White: Color.white (#FFFFFF)
Accent Blue: Color(red: 0, green: 122/255, blue: 1) (#007AFF)
Red: Color.red (System red for destructive actions)
Light Blue BG: accentBlue.opacity(0.1) (Current user highlight)
Disabled: accentBlue.opacity(0.5) (Inactive states)
```

---

## 🎨 Visual Design Preview

### Home Screen Layout
```
┌─────────────────────────┐
│    November 10, 2025    │ ← Navigation title
├─────────────────────────┤
│                         │
│       00:00:00         │ ← Large timer (72pt)
│                         │
│     ╭─────────╮        │
│     │         │        │ ← Progress ring
│     │   45%   │        │   (thin blue stroke)
│     │ Daily   │        │
│     ╰─────────╯        │
│                         │
│  🔥 5        8 hrs     │ ← Key metrics
│  Daily      Total      │
│  Streak     Raw Time   │
│                         │
│         ●              │ ← BEGIN button
│      BEGIN             │   (blue circle)
│                         │
└─────────────────────────┘
```

### Challenge Card Design
```
┌─────────────────────────────┐
│  ● 15 Min: Stare at Wall   │ ← Incomplete (blue dot)
└─────────────────────────────┘

┌─────────────────────────────┐
│  ✓ 30 Min: Deep Thought    │ ← Complete (checkmark)
└─────────────────────────────┘
```

### Leaderboard Entry
```
┌─────────────────────────────┐
│  1  ZenMaster      40 hrs  │ ← #1 (blue background)
├─────────────────────────────┤
│  2  MindfulNinja   30 hrs  │
├─────────────────────────────┤
│  4  You             8 hrs  │ ← Current user (light blue)
└─────────────────────────────┘
```

---

## 🔄 App State Flow

```
Launch App
    ↓
Tab Navigation (Home/Challenges/Leaderboard/Profile)
    ↓
Home: BEGIN → Timer Running → STOP → Session Saved
    ↓
Stats Updated (Total Time, Daily History, Streak)
    ↓
Leaderboard Refreshes
    ↓
Profile Shows New Data Point in Chart
```

---

## ✨ Future Enhancements (Optional)

While maintaining strict minimalism:
- **Haptic Feedback**: Subtle vibration on button taps
- **Widgets**: Home screen widget showing today's progress
- **Notifications**: Gentle reminders to start a session
- **Export Data**: CSV export of historical data
- **Dark Mode**: Inverted palette (Black background, blue accents)

---

## 📝 Notes

- **No Network Required**: All data stored locally
- **No User Authentication**: Simple nickname-based system
- **Privacy First**: No tracking, no analytics
- **Offline First**: Works completely without internet
- **Battery Efficient**: Minimal background processing

---

## 🎓 Design Principles Applied

1. **Constraint-Driven Design**: Limited color palette forces creative clarity
2. **Gestalt Principles**: Proximity, similarity, and continuity in layouts
3. **Fitts's Law**: Large, accessible touch targets
4. **Progressive Disclosure**: Core function (timer) front and center
5. **Visual Hierarchy**: Size, weight, and color guide attention

---

## 📄 License

This is a design concept and implementation example.
Feel free to use, modify, and build upon it.

---

**Created**: November 2025  
**Platform**: iOS 26  
**Framework**: SwiftUI  
**Design**: Extreme Minimalism  
**Philosophy**: Less is more. Focus is power.
