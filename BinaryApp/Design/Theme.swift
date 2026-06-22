import UIKit

enum Theme {

    // MARK: - Colors

    enum Color {

        static let background = UIColor.systemBackground

        static let surface = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.11, alpha: 1)
                : UIColor(white: 1.0, alpha: 1)
        }

        static let surfaceElevated = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 0.16, alpha: 1)
                : UIColor(red: 0.95, green: 0.96, blue: 0.99, alpha: 1)
        }

        static let primary = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.42, green: 0.46, blue: 0.98, alpha: 1)
                : UIColor(red: 0.30, green: 0.34, blue: 0.91, alpha: 1)
        }

        static let primaryGradientEnd = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.62, green: 0.36, blue: 0.92, alpha: 1)
                : UIColor(red: 0.51, green: 0.27, blue: 0.86, alpha: 1)
        }

        static let accent = UIColor.systemTeal

        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let textTertiary = UIColor.tertiaryLabel
        static let textOnPrimary = UIColor.white

        static let separator = UIColor.separator
        static let error = UIColor.systemRed
        static let success = UIColor.systemGreen

        static let bitOne = primary
        static let bitZeroInsideGap = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.95, green: 0.55, blue: 0.30, alpha: 1)
                : UIColor(red: 0.95, green: 0.45, blue: 0.20, alpha: 1)
        }
        static let bitZero = UIColor.tertiaryLabel
    }

    // MARK: - Spacing

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
    }

    // MARK: - Radius

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 14
        static let large: CGFloat = 20
        static let pill: CGFloat = 999
    }

    // MARK: - Typography

    enum Font {
        static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let title = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title2 = UIFont.systemFont(ofSize: 22, weight: .semibold)
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let callout = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let monoLarge = UIFont.monospacedSystemFont(ofSize: 28, weight: .bold)
        static let monoMedium = UIFont.monospacedSystemFont(ofSize: 18, weight: .semibold)
        static let monoSmall = UIFont.monospacedSystemFont(ofSize: 14, weight: .medium)

        static func scaled(_ font: UIFont, textStyle: UIFont.TextStyle) -> UIFont {
            UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
    }

    // MARK: - Animation

    enum Animation {
        static let quick: TimeInterval = 0.18
        static let standard: TimeInterval = 0.32
        static let emphasized: TimeInterval = 0.55
    }
}
