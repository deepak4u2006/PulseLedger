import PulseCore
import UIKit

public final class CategoryBarChartView: UIView {
    private let backgroundPlate = UIView()
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private static let longLabelAbbreviations: [String: String] = [
        "Entertainment": "Entertain.",
        "Transportation": "Transport",
    ]

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        clipsToBounds = false

        backgroundPlate.backgroundColor = UIColor(white: 1, alpha: 0.06)
        backgroundPlate.layer.cornerRadius = 12
        backgroundPlate.clipsToBounds = true
        backgroundPlate.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundPlate)
        NSLayoutConstraint.activate([
            backgroundPlate.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundPlate.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundPlate.topAnchor.constraint(equalTo: topAnchor),
            backgroundPlate.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        titleLabel.text = "Spend by category"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = UIColor(white: 1, alpha: 0.65)

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
        ])

        let column = UIStackView(arrangedSubviews: [titleLabel, scrollView])
        column.axis = .vertical
        column.spacing = 12
        column.translatesAutoresizingMaskIntoConstraints = false
        addSubview(column)
        NSLayoutConstraint.activate([
            column.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            column.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            column.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            column.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 148),
        ])
    }

    private func displayLabel(for category: String) -> String {
        if category.count <= 14 {
            return category
        }
        return Self.longLabelAbbreviations[category] ?? category
    }

    public func update(categories: [CategorySpend], currencyCode: String) {
        let apply = { [weak self] in
            guard let self else { return }
            let maxAmount = categories.map { NSDecimalNumber(decimal: $0.amount).doubleValue }.max() ?? 1
            self.stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for item in categories {
                let value = CGFloat(NSDecimalNumber(decimal: item.amount).doubleValue / max(maxAmount, 0.01))
                self.stack.addArrangedSubview(
                    self.makeBar(label: self.displayLabel(for: item.category), normalized: value)
                )
            }
        }
        if Thread.isMainThread {
            apply()
        } else {
            DispatchQueue.main.async(execute: apply)
        }
    }

    private func makeBar(label: String, normalized: CGFloat) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 6
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(greaterThanOrEqualToConstant: 68).isActive = true

        let bar = UIView()
        bar.backgroundColor = UIColor(red: 0.2, green: 0.85, blue: 0.55, alpha: 1)
        bar.layer.cornerRadius = 4
        bar.translatesAutoresizingMaskIntoConstraints = false
        let height = max(8, 64 * normalized)
        NSLayoutConstraint.activate([
            bar.widthAnchor.constraint(equalToConstant: 32),
            bar.heightAnchor.constraint(equalToConstant: height),
        ])

        let name = UILabel()
        name.text = label
        name.font = .systemFont(ofSize: 9, weight: .medium)
        name.textColor = UIColor(white: 1, alpha: 0.55)
        name.textAlignment = .center
        name.numberOfLines = 2
        name.lineBreakMode = .byWordWrapping
        name.setContentCompressionResistancePriority(.required, for: .vertical)
        name.setContentHuggingPriority(.required, for: .vertical)
        name.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            name.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            name.heightAnchor.constraint(greaterThanOrEqualToConstant: 28),
        ])

        container.addArrangedSubview(bar)
        container.addArrangedSubview(name)
        return container
    }
}
