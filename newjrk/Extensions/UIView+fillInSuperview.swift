import UIKit

extension UIView {
    func fillInSuperview(padding: CGFloat = 0) {
        guard let superview = superview else { return }

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: padding),
            topAnchor.constraint(equalTo: superview.topAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding)
        ])
    }
}
