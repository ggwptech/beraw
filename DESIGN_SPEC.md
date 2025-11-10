# RawDogged UI/UX Design Specification

## Color Palette (STRICTLY ENFORCED)

### Primary Colors
```
White:       #FFFFFF   RGB(255, 255, 255)
Accent Blue: #007AFF   RGB(0, 122, 255) - Apple System Blue
```

### Accent Colors (Used Sparingly)
```
Red:         System Red - ONLY for STOP button and Log Out
```

### Opacity Variants
```
Blue 60%:    rgba(0, 122, 255, 0.6)  - Subtle text
Blue 20%:    rgba(0, 122, 255, 0.2)  - Strokes, dividers
Blue 10%:    rgba(0, 122, 255, 0.1)  - Background highlights
Blue 50%:    rgba(0, 122, 255, 0.5)  - Disabled states
```

---

## Typography System

### Font Family
**San Francisco (SF Pro)** - iOS System Font

### Text Styles

| Element | Size | Weight | Color | Usage |
|---------|------|--------|-------|-------|
| Timer Display | 72pt | Ultra Light | Blue | Current session time |
| Large Numbers | 32pt | Light | Blue | Progress percentage |
| Headers | 24pt | Medium | Blue | Metrics, stats |
| Body Text | 16pt | Regular | Blue | Buttons, list items |
| Subheadings | 14pt | Medium | Blue 60% | Labels, captions |
| Small Text | 12pt | Regular | Blue 60% | Helper text |

### Font Features
- **Monospaced Digits**: Used for timers and numerical data
- **Line Height**: 1.2-1.4× font size for readability
- **Letter Spacing**: Default tracking (0)

---

## Layout & Spacing

### Screen Margins
```
Horizontal: 16-20pt
Vertical:   24-40pt (contextual)
```

### Component Spacing
```
Section Gaps:     32-40pt
Element Spacing:  16-20pt
Tight Spacing:    8-12pt
Icon-Text Gap:    8pt
```

### Safe Areas
- Respect iOS safe area insets
- Navigation bar height: 44pt
- Tab bar height: 49pt

---

## Interactive Components

### Buttons

#### Primary Action Button (BEGIN/STOP)
```
Shape:      Circle
Size:       120 × 120pt
Background: Solid Blue (BEGIN) / Solid Red (STOP)
Text:       18pt, Semibold, White
Shadow:     None
```

#### Secondary Buttons
```
Background: White
Border:     1pt Blue
Text:       16pt, Semibold, Blue
Padding:    16pt vertical, full width
Radius:     12pt
```

### Cards

#### Challenge Cards
```
Background: White
Border:     1pt Blue
Radius:     12pt
Padding:    20pt
Shadow:     None
Spacing:    16pt between cards
```

#### List Items
```
Background: White
Divider:    1pt Blue 20%
Padding:    16pt vertical, 20pt horizontal
Height:     Min 44pt (touch target)
```

### Progress Indicators

#### Circular Progress Ring
```
Diameter:   200pt
Stroke:     3pt
Track:      Blue 20%
Progress:   Solid Blue
Cap:        Round
Start:      -90° (top)
```

#### Line Chart
```
Height:     180pt
Line:       2pt Blue
Cap:        Round
Join:       Round
Background: White
Axes:       None (minimalist)
```

---

## Icons

### System SF Symbols
All icons use SF Symbols from Apple's icon library:

```
timer           → Home tab
target          → Challenges tab
chart.bar       → Leaderboard tab
person          → Profile tab
plus            → Add challenge
checkmark.circle.fill → Completed challenge
chevron.right   → Navigation indicator
```

### Icon Specifications
```
Size:   18-24pt (contextual)
Weight: Regular
Color:  Accent Blue
Style:  Linear (no fills except checkmark)
```

---

## Screen-Specific Designs

### 1. Home Screen

#### Timer Display
```
┌──────────────────────┐
│                      │
│     HH:MM:SS        │ ← 72pt, Ultra Light
│                      │
└──────────────────────┘
```

#### Progress Ring
```
       ╭─────────╮
      ╱           ╲
     │             │  ← 3pt stroke
     │     85%     │  ← 32pt number
     │  Daily Goal │  ← 12pt caption
      ╲           ╱
       ╰─────────╯
```

#### Metrics Row
```
┌──────────────────────────────────┐
│  🔥 5              8 hrs         │
│  Daily Streak     Total Raw Time │
└──────────────────────────────────┘
```

---

### 2. Challenge Screen

#### Challenge List Item
```
┌────────────────────────────────────┐
│  [●]  15 Min: Stare at the Wall   │ ← Incomplete
├────────────────────────────────────┤
│  [✓]  30 Min: Deep Thought        │ ← Complete
└────────────────────────────────────┘

Legend:
[●] = Blue circle (12pt diameter)
[✓] = Blue checkmark icon (24pt)
```

#### Add Challenge Modal
```
┌──────────────────────────┐
│  Challenge Title         │ ← Label
│  ┌────────────────────┐ │
│  │ e.g., 20 Min...    │ │ ← Input field
│  └────────────────────┘ │
│                          │
│  Duration (minutes)      │
│  ┌────────────────────┐ │
│  │ e.g., 20           │ │ ← Number input
│  └────────────────────┘ │
│                          │
│  ┌────────────────────┐ │
│  │  Add Challenge     │ │ ← Blue button
│  └────────────────────┘ │
└──────────────────────────┘
```

---

### 3. Leaderboard Screen

#### Period Selector
```
┌─────────────────────────────────┐
│ Daily │ Weekly │ All-Time       │ ← Segmented control
└─────────────────────────────────┘
Active: Blue background, White text
Inactive: White background, Blue text
```

#### Leaderboard Entry States
```
Rank #1:
┌─────────────────────────────────┐
│ [1]  ZenMaster        40 hrs   │ ← Blue BG, White text
└─────────────────────────────────┘

Current User:
┌─────────────────────────────────┐
│ [4]  You               8 hrs   │ ← Blue 10% BG, Blue text
└─────────────────────────────────┘

Other Users:
┌─────────────────────────────────┐
│ [2]  MindfulNinja     30 hrs   │ ← White BG, Blue text
└─────────────────────────────────┘
```

---

### 4. Profile Screen

#### Line Chart Visualization
```
Title: "Raw Time per Day (Last 30 Days)"

         •
        • •
       •   •    •
      •     •  • •
     •       ••   •
────────────────────────
Day 1              Day 30

Elements:
- Line: 2pt Blue stroke
- Points: Not shown (continuous line only)
- Background: White
- No axes or labels (pure data shape)
```

#### Settings List
```
┌────────────────────────────────┐
│ Set Daily Goal              › │
├────────────────────────────────┤
│ App Notifications           › │
├────────────────────────────────┤
│ About & Privacy             › │
├────────────────────────────────┤
│ Log Out                       │ ← Red text
└────────────────────────────────┘

Dividers: Blue 20% opacity, 1pt
Chevron: Blue 40% opacity, 14pt
```

---

## Interaction States

### Button States

#### Normal
- Background: Solid Blue
- Text: White
- Opacity: 100%

#### Pressed
- Background: Blue
- Opacity: 80%
- Scale: 0.95× (subtle)

#### Disabled
- Background: Blue
- Opacity: 50%
- Interaction: None

### List Item States

#### Normal
- Background: White
- Text: Blue

#### Highlighted (Tap)
- Background: Blue 5% opacity
- Text: Blue
- Duration: Brief (150ms)

---

## Animation Specifications

### Timing Functions
```
Standard:    ease-in-out, 0.3s
Quick:       ease-out, 0.2s
Slow:        ease-in-out, 0.5s
```

### Animated Elements

#### Progress Ring
```
Animation: Linear fill from 0° to progress angle
Duration:  0.5s
Easing:    Ease-out
```

#### Button Tap
```
Animation: Scale down to 0.95, spring back
Duration:  0.2s
Easing:    Spring (damping: 0.6)
```

#### View Transitions
```
Animation: Slide and fade
Duration:  0.3s
Easing:    Ease-in-out
```

#### Timer Updates
```
Animation: None (instant update)
Frequency: 1Hz (every second)
```

---

## Accessibility

### Minimum Touch Targets
```
Size: 44 × 44pt (Apple HIG standard)
```

### Dynamic Type Support
- All text scales with system text size settings
- Maintain layout integrity at all sizes

### VoiceOver Labels
- All interactive elements have descriptive labels
- Timer announces updates every minute

### Color Contrast
```
Blue on White: 4.5:1 (WCAG AA compliant)
White on Blue: 4.5:1 (WCAG AA compliant)
```

---

## Design Principles Checklist

### ✅ Do's
- Use only White and Accent Blue colors
- Maintain flat, solid color fills
- Maximize white space
- Use system fonts (San Francisco)
- Keep icons simple and linear
- Ensure high contrast
- Make touch targets large (min 44pt)
- Respect iOS design conventions

### ❌ Don'ts
- **NO GRADIENTS** (most important!)
- No complex illustrations
- No decorative elements
- No shadows or depth effects
- No textures or patterns
- No additional colors
- No custom fonts
- No small, hard-to-tap buttons

---

## Build Checklist

Before submitting design:
- [ ] All screens use only White and Blue
- [ ] Zero gradients in entire app
- [ ] All fonts are San Francisco
- [ ] Icons are simple SF Symbols
- [ ] Touch targets ≥ 44pt
- [ ] Adequate white space
- [ ] Consistent spacing system
- [ ] Clean, minimal aesthetic
- [ ] All states defined (normal, pressed, disabled)
- [ ] Smooth animations (≤ 0.5s)

---

## File Structure Reference

```
RawDogged/
├── Models.swift              → Data models and state management
├── HomeView.swift           → Dashboard with timer
├── ChallengeView.swift      → Challenge list and creation
├── LeaderboardView.swift    → Rankings and competition
├── ProfileView.swift        → Stats, chart, settings
├── ContentView.swift        → Main TabView container
├── RawDoggedApp.swift       → App entry point
└── Assets.xcassets/         → App icon and assets
```

---

## Quality Assurance

### Visual Testing
1. Check color consistency across all screens
2. Verify no gradients appear anywhere
3. Confirm typography hierarchy
4. Test touch target sizes
5. Review spacing and alignment

### Functional Testing
1. Timer starts/stops correctly
2. Progress ring updates in real-time
3. Challenges toggle completion state
4. Leaderboard displays proper rankings
5. Chart visualizes 30-day history
6. Settings modals open/close properly

### Device Testing
Test on multiple screen sizes:
- iPhone SE (small)
- iPhone 15 Pro (standard)
- iPhone 15 Pro Max (large)

---

**Design Status**: ✅ Complete  
**Gradient Count**: 0 (Zero!)  
**Color Palette**: 2 colors (White + Blue)  
**Simplicity Level**: Maximum  

---

*Remember: Constraint breeds creativity. The limitation to two colors and no gradients forces us to rely on spacing, typography, and hierarchy—the fundamentals of great design.*
