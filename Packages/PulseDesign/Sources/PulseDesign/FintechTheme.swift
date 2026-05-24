import SwiftUI

public enum FintechTheme {
    public static let background = Color(red: 0.06, green: 0.07, blue: 0.10)
    public static let surface = Color(red: 0.11, green: 0.12, blue: 0.16)
    public static let accent = Color(red: 0.20, green: 0.85, blue: 0.55)
    public static let accentSecondary = Color(red: 0.35, green: 0.55, blue: 1.0)
    public static let danger = Color(red: 1.0, green: 0.35, blue: 0.35)
    public static let textPrimary = Color.white
    public static let textSecondary = Color.white.opacity(0.65)

    public static func cardGradient(index: Int) -> LinearGradient {
        let palettes: [(Color, Color)] = [
            (Color(red: 0.15, green: 0.45, blue: 0.95), Color(red: 0.05, green: 0.15, blue: 0.45)),
            (Color(red: 0.55, green: 0.20, blue: 0.85), Color(red: 0.20, green: 0.05, blue: 0.35)),
            (Color(red: 0.10, green: 0.70, blue: 0.55), Color(red: 0.02, green: 0.25, blue: 0.20)),
        ]
        let pair = palettes[index % palettes.count]
        return LinearGradient(colors: [pair.0, pair.1], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

public struct FintechCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding()
            .background(FintechTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

public struct FintechPrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(FintechTheme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(FintechTheme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
