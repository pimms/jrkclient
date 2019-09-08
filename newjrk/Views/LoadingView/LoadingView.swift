import UIKit

class LoadingView: UIView {
    @IBOutlet private var contentView: UIView?
    @IBOutlet private var label: UILabel?
    @IBOutlet private var activityIndicator: UIActivityIndicatorView?

    private var message: String {
        get { return label?.text ?? "" }
        set { label?.text = newValue }
    }

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        contentView?.layer.cornerRadius = 32
        contentView?.layer.shadowColor = UIColor.systemGray.cgColor
        contentView?.layer.shadowRadius = 16
        contentView?.clipsToBounds = true
        contentView?.layer.masksToBounds = true
        activityIndicator?.startAnimating()
    }

    // MARK: - Internal methods

    func remove() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}

extension LoadingView {
    static func show(in viewController: UIViewController, withMessage message: String) -> LoadingView? {
        let loaded = Bundle.main.loadNibNamed("LoadingView", owner: nil, options: nil)
        guard let loadingView = loaded?.first as? LoadingView else { return nil }
        loadingView.message = message
        loadingView.alpha = 0

        viewController.view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            loadingView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            loadingView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
        ])

        UIView.animate(withDuration: 0.3) {
            loadingView.alpha = 1.0
        }

        return loadingView
    }
}
