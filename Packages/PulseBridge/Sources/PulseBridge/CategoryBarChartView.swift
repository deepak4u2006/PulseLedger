import PulseCore
import UIKit

public final class CategoryBarChartView: UIView {
    private var bars: [(label: String, value: CGFloat)] = []
    private let stack = UIStackView()
    private let titleLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = UIColor(white: 1, alpha: 0.06)
        layer.cornerRadius = 12
        clipsToBounds = true

        titleLabel.text = "Spend by category"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = UIColor(white: 1, alpha: 0.65)

        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.distribution = .fillEqually
        stack.spacing = 8

        let column = UIStackView(arrangedSubviews: [titleLabel, stack])
        column.axis = .vertical
        column.spacing = 12
        column.translatesAutoresizingMaskIntoConstraints = false
        addSubview(column)
        NSLayoutConstraint.activate([
            column.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            column.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            column.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            column.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
        ])
    }

    public func update(categories: [CategorySpend], currencyCode: String) {
        let maxAmount = categories.map { NSDecimalNumber(decimal: $0.amount).doubleValue }.max() ?? 1
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in categories {
            let value = CGFloat(NSDecimalNumber(decimal: item.amount).doubleValue / max(maxAmount, 0.01))
            stack.addArrangedSubview(makeBar(label: item.category, normalized: value))
        }
    }

    private func makeBar(label: String, normalized: CGFloat) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 4

        let bar = UIView()
        bar.backgroundColor = UIColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 1)
        bar.layer.cornerRadius = 4
        bar.translatesAutoresizingMaskIntoConstraints = false
        let height = max(8, 72 * normalized)
        NSLayoutConstraint.activate([bar.widthAnchor.constraint(equalToConstant: 28), bar.heightAnchor.constraint(equalToConstant: height)])

        let name = UILabel()
        name.text = String(label.prefix(6))
        name.font = .systemFont(ofSize: 9, weight: .medium)
        name.textColor = UIColor(white: 1, alpha: 0.55)
        name.textAlignment = .center

        container.addArrangedSubview(bar)
        container.addArrangedSubview(name)
        return container
    }
}
