//
//  AdaptiveLayout.swift
//  RawDogged
//
//  Adaptive layout utilities for responsive iPad/iPhone layouts
//

import SwiftUI

// MARK: - Device Type Detection
enum DeviceType {
    case iPhone
    case iPad
    case iPadPro
    
    static var current: DeviceType {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let screenWidth = max(width, height) // Use larger dimension
        
        if screenWidth >= 1024 {
            return .iPadPro
        } else if screenWidth >= 768 {
            return .iPad
        } else {
            return .iPhone
        }
    }
    
    var isIPad: Bool {
        return self == .iPad || self == .iPadPro
    }
}

// MARK: - Grid Columns Calculator
struct GridColumns {
    static func columns(for width: CGFloat, minColumnWidth: CGFloat = 300) -> Int {
        if width < 768 {
            return 1 // iPhone
        } else if width < 1024 {
            return 2 // iPad
        } else if width < 1366 {
            return 2 // iPad Pro 11"
        } else {
            return 3 // iPad Pro 12.9"
        }
    }
    
    static func challengeColumns(for width: CGFloat) -> Int {
        if width < 768 {
            return 1 // iPhone
        } else if width < 1024 {
            return 2 // iPad
        } else {
            return 3 // iPad Pro
        }
    }
    
    static func statsColumns(for width: CGFloat) -> Int {
        if width < 768 {
            return 2 // iPhone - 2 small cards
        } else if width < 1024 {
            return 2 // iPad
        } else {
            return 3 // iPad Pro
        }
    }
}

// MARK: - Adaptive Padding
struct AdaptivePadding {
    static func horizontal(for width: CGFloat) -> CGFloat {
        if width < 768 {
            return 20 // iPhone
        } else if width < 1024 {
            return 32 // iPad
        } else {
            return 40 // iPad Pro
        }
    }
    
    static func cardSpacing(for width: CGFloat) -> CGFloat {
        if width < 768 {
            return 12 // iPhone
        } else {
            return 16 // iPad
        }
    }
}

// MARK: - Adaptive Grid View
struct AdaptiveGrid<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    let content: Content
    
    init(columns: Int, spacing: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
            spacing: spacing
        ) {
            content
        }
    }
}

// MARK: - Responsive Container
struct ResponsiveContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                content
                    .padding(.horizontal, AdaptivePadding.horizontal(for: geometry.size.width))
            }
        }
    }
}

// MARK: - Adaptive Stack (HStack on iPad, VStack on iPhone)
struct AdaptiveStack<Content: View>: View {
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat
    let content: Content
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .center,
        spacing: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad - use HStack
            HStack(alignment: verticalAlignment, spacing: spacing) {
                content
            }
        } else {
            // iPhone - use VStack
            VStack(alignment: horizontalAlignment, spacing: spacing) {
                content
            }
        }
    }
}
