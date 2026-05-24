import PulseCore
import SwiftUI

public struct CategoryBarChartBridge: UIViewRepresentable {
    private let categories: [CategorySpend]
    private let currencyCode: String

    public init(categories: [CategorySpend], currencyCode: String) {
        self.categories = categories
        self.currencyCode = currencyCode
    }

    public func makeUIView(context: Context) -> CategoryBarChartView {
        CategoryBarChartView()
    }

    public func updateUIView(_ uiView: CategoryBarChartView, context: Context) {
        uiView.update(categories: categories, currencyCode: currencyCode)
    }
}
