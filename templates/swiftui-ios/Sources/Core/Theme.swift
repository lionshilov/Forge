import SwiftUI

enum Theme {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
    }

    enum Palette {
        static let background = Color(.systemBackground)
        static let secondary = Color(.secondarySystemBackground)
        static let accent = Color.blue
    }
}
