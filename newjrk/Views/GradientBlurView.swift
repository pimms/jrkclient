import UIKit

@IBDesignable
class GradientBlurView: UIView {

    // MARK: - IBDesignable properties

    @IBInspectable
    var blurHeight: CGFloat = 100 {
        didSet { updateGradientEndpoint() }
    }

    // MARK: - Private properties

    private let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)

    private lazy var effectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()

    private lazy var vibrancyView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        return vibrancyView
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
        effectView.contentView.addSubview(vibrancyView)

        effectView.fillInSuperview()
        vibrancyView.fillInSuperview()
    }

    private func addGradientLayer() {
        gradientLayer.colors = [ UIColor.clear.cgColor, UIColor.white.cgColor ]
        effectView.layer.mask = gradientLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientEndpoint()
    }

    // MARK: - Private func

    private func updateGradientEndpoint() {
        let ratio = blurHeight / bounds.height
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: ratio)
    }
}

// MARK: - Content View overrides
// Simply proxy all subview-related calls to

extension GradientBlurView {
    override func addSubview(_ view: UIView) {
        vibrancyView.contentView.addSubview(view)
    }

    override func willRemoveSubview(_ subview: UIView) {
        vibrancyView.contentView.willRemoveSubview(subview)
    }

    override func insertSubview(_ view: UIView, at index: Int) {
        vibrancyView.contentView.insertSubview(view, at: index)
    }

    override func sendSubviewToBack(_ view: UIView) {
        vibrancyView.contentView.sendSubviewToBack(view)
    }

    override func bringSubviewToFront(_ view: UIView) {
        vibrancyView.contentView.bringSubviewToFront(view)
    }

    override func exchangeSubview(at index1: Int, withSubviewAt index2: Int) {
        vibrancyView.contentView.exchangeSubview(at: index1, withSubviewAt: index2)
    }

    override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
        vibrancyView.contentView.insertSubview(view, aboveSubview: siblingSubview)
    }

    override func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) {
        vibrancyView.contentView.insertSubview(view, belowSubview: siblingSubview)
    }

    override func didAddSubview(_ subview: UIView) {
        vibrancyView.contentView.didAddSubview(subview)
    }
}
