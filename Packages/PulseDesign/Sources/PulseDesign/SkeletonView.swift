import SwiftUI

public struct SkeletonView: View {
    private let height: CGFloat
    private let cornerRadius: CGFloat
    @State private var phase: CGFloat = 0

    public init(height: CGFloat = 16, cornerRadius: CGFloat = 8) {
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.18),
                        Color.white.opacity(0.08),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: height)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.25), .clear],
                            startPoint: UnitPoint(x: phase - 0.3, y: 0.5),
                            endPoint: UnitPoint(x: phase + 0.3, y: 0.5)
                        )
                    )
            }
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
            .accessibilityHidden(true)
    }
}

public struct BalanceCardSkeleton: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView(height: 14, cornerRadius: 6).frame(width: 100)
            SkeletonView(height: 40, cornerRadius: 10).frame(maxWidth: .infinity)
            SkeletonView(height: 12, cornerRadius: 6).frame(width: 160)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FintechTheme.cardGradient(index: 0))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

public struct WeeklyCardSkeleton: View {
    public init() {}

    public var body: some View {
        FintechCard {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    SkeletonView(height: 14, cornerRadius: 6).frame(width: 80)
                    SkeletonView(height: 28, cornerRadius: 8).frame(width: 120)
                }
                Spacer()
                SkeletonView(height: 32, cornerRadius: 8).frame(width: 32)
            }
        }
    }
}

public struct TransactionRowSkeleton: View {
    public init() {}

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                SkeletonView(height: 16, cornerRadius: 6).frame(width: 140)
                SkeletonView(height: 12, cornerRadius: 4).frame(width: 70)
            }
            Spacer()
            SkeletonView(height: 16, cornerRadius: 6).frame(width: 72)
        }
        .padding(.vertical, 8)
    }
}

public struct ChartCardSkeleton: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView(height: 14, cornerRadius: 6).frame(width: 140)
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(0 ..< 4, id: \.self) { index in
                    SkeletonView(
                        height: CGFloat([48, 72, 36, 60][index]),
                        cornerRadius: 6
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
        .background(FintechTheme.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
