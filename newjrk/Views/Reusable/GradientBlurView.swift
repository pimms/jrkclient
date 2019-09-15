import UIKit

@IBDesignable
class GradientBlurView: UIView {

    // MARK: - Private properties

    private let blurEffect = UIBlurEffect(style: .systemThickMaterial)

    private lazy var effectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        return layer
    }()

    // MARK: - Setup

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    private func setup() {
        addGradientLayer()
        updateGradientEndpoint()

        backgroundColor = .clear
        super.addSubview(effectView)
        effectView.fillInSuperview()
    }

    private func addGradientLayer() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [NSNumber(value: 0), NSNumber(value: 0.5), NSNumber(value: 1.0)]
        effectView.layer.mask = gradientLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientEndpoint()
    }

    // MARK: - Private methods

    private func updateGradientEndpoint() {
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
}
