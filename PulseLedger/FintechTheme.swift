import SwiftUI

enum FintechTheme {
    static let background = Color(red: 0.06, green: 0.07, blue: 0.10)
    static let surface = Color(red: 0.11, green: 0.12, blue: 0.16)
    static let accent = Color(red: 0.20, green: 0.85, blue: 0.55)
    static let accentSecondary = Color(red: 0.35, green: 0.55, blue: 1.0)
    static let danger = Color(red: 1.0, green: 0.35, blue: 0.35)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)

    static func cardGradient(index: Int) -> LinearGradient {
        let palettes: [(Color, Color)] = [
            (Color(red: 0.15, green: 0.45, blue: 0.95), Color(red: 0.05, green: 0.15, blue: 0.45)),
            (Color(red: 0.55, green: 0.20, blue: 0.85), Color(red: 0.20, green: 0.05, blue: 0.35)),
            (Color(red: 0.10, green: 0.70, blue: 0.55), Color(red: 0.02, green: 0.25, blue: 0.20)),
        ]
        let pair = palettes[index % palettes.count]
        return LinearGradient(colors: [pair.0, pair.1], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct FintechCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding()
            .background(FintechTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
