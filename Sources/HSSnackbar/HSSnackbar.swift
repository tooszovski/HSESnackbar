//
//  HSSnackbar.swift
//
//
//  Created by Aleksander Tooszovsky on 27.02.2020.
//

import UIKit

extension NSObjectProtocol {

  func with(_ closure: (Self) -> Void) -> Self {
    closure(self)
    return self
  }

}

public extension UIColor {
  enum SnackBarColors {
    static var defaultText: UIColor {
      if #available(iOS 13, *) {
        return UIColor.label.withAlphaComponent(0.8)
      } else {
        return UIColor(white: 0, alpha: 0.8)
      }
    }

    static var toastBackground : UIColor {
      if #available(iOS 13, *) {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
          if UITraitCollection.userInterfaceStyle == .dark {
            return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
          } else {
            return .white
          }
        }
      } else {
        return .white
      }
    }
    static var defaultShadow : UIColor {
      if #available(iOS 13, *) {
        return .label
      } else {
        return .black
      }
    }
  }
}

extension UIView {
  func addSubviews(_ views: [UIView]) {
    views.forEach {
      addSubview($0)
    }
  }
}

open class HSSnackbar: UIView {
  // MARK: - Subviews
  fileprivate let contentView = UIView().with {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.backgroundColor = UIColor.clear
  }
  fileprivate let iconImageView = UIImageView().with {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.backgroundColor = UIColor.clear
    $0.contentMode = .scaleAspectFill
  }
  fileprivate let messageLabel = UILabel().with {
    $0.accessibilityIdentifier = "messageLabel"
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.textColor = UIColor.SnackBarColors.defaultText
    $0.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    $0.backgroundColor = UIColor.clear
    $0.lineBreakMode = .byTruncatingTail
    $0.numberOfLines = 0;
    $0.textAlignment = .left
  }

  // MARK: - Class property.

  /// Snackbar min height
  public static var snackbarMinHeight: CGFloat = 48

  // MARK: - Typealias.
  /// Dismiss callback closure definition.
  public typealias DismissClosure = (_ snackbar: HSSnackbar) -> Void

  // MARK: - Public property.

  /// Dismiss callback.
  let dismissClosure: DismissClosure?
  var animationDuration: TimeInterval = 0.5
  let margins: UIEdgeInsets
  let contentInset: UIEdgeInsets
  var animationSpringWithDamping: CGFloat
  var animationInitialSpringVelocity: CGFloat
  var messageDuration: TimeInterval

  // MARK: - Private property

  /// Timer to dismiss the snackbar.
  fileprivate var dismissTimer: Timer? = nil

  // Constraints.
  fileprivate var bottomMarginConstraint: NSLayoutConstraint? = nil

  // MARK: - Deinit
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Init
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public init(message: String, icon: UIImage, dismiss: DismissClosure? = nil,
              margins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 16, right: 12),
              contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
              animationSpringWithDamping: CGFloat = 0.7,
              animationInitialSpringVelocity: CGFloat = 5,
              messageDuration: TimeInterval = 1.5) {
    self.animationSpringWithDamping = animationSpringWithDamping
    self.animationInitialSpringVelocity = animationInitialSpringVelocity
    self.contentInset = contentInset
    self.margins = margins
    self.messageDuration = messageDuration
    dismissClosure = dismiss
    super.init(frame: .zero)
    messageLabel.text = message
    iconImageView.image = icon
    addSubviews()
  }

  // Override
  open override func layoutSubviews() {
    super.layoutSubviews()
    if messageLabel.preferredMaxLayoutWidth != messageLabel.frame.size.width {
      messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
      setNeedsLayout()
    }
    super.layoutSubviews()
  }
  //MARK: - Private methods
  fileprivate func addSubviews() {
    for subView in subviews {
      subView.removeFromSuperview()
    }

    contentView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(contentView)

    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = UIColor.SnackBarColors.toastBackground
    layer.cornerRadius = 6
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    layer.shadowOpacity = 0.14
    layer.shadowRadius = 6
    layer.shadowColor = UIColor.SnackBarColors.defaultShadow.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 2)

    contentView.addSubviews([iconImageView,
                             messageLabel])

    let views = ["iconImageView": iconImageView,
                 "messageLabel": messageLabel]

    let layout = ["H:|[iconImageView(==20)]-4-[messageLabel]-(>=10)-|",
                  "V:|-14-[iconImageView(==20)]-14-|",
                  "V:|-14-[messageLabel]-14-|"]
    var constraints = [NSLayoutConstraint]()
    layout.forEach {
      constraints += NSLayoutConstraint.constraints(withVisualFormat: $0,
                                                    options: [],
                                                    metrics: nil,
                                                    views: views)
    }
    NSLayoutConstraint.activate(constraints)
    isUserInteractionEnabled = true
  }
}

// MARK: - Show methods.

public extension HSSnackbar {

  @objc func show(on view: UIView) {
    // Only show once
    guard superview == nil else { return }

    // Create dismiss timer
    dismissTimer = Timer(timeInterval: messageDuration,
                         target: self,
                         selector: #selector(dismiss),
                         userInfo: nil,
                         repeats: false)
    RunLoop.main.add(dismissTimer!, forMode: .common)

    NSLayoutConstraint
      .activate([contentView.leftAnchor.constraint(equalTo: self.leftAnchor,
                                                   constant: contentInset.left),
                 contentView.rightAnchor.constraint(equalTo: self.rightAnchor,
                                                    constant: contentInset.right)])
    NSLayoutConstraint(item: contentView,
                       attribute: .bottom,
                       relatedBy: .equal,
                       toItem: self,
                       attribute: .bottom,
                       multiplier: 1,
                       constant: -contentInset.bottom).isActive = true

    // Get super view to show
    view.addSubview(self)

    let toItem: Any?
    if #available(iOS 11.0, *) {
      toItem = view.safeAreaLayoutGuide
    } else  {
      toItem = view
    }
    bottomMarginConstraint = NSLayoutConstraint(
      item: self, attribute: .bottom, relatedBy: .equal,
      toItem: toItem, attribute: .bottom, multiplier: 1, constant: -margins.bottom)

    NSLayoutConstraint(
      item: self, attribute: .leading, relatedBy: .equal,
      toItem: toItem, attribute: .leading, multiplier: 1, constant: margins.left).isActive = true
    NSLayoutConstraint(
      item: self, attribute: .trailing, relatedBy: .equal,
      toItem: toItem, attribute: .trailing, multiplier: 1, constant: -margins.right).isActive = true
    NSLayoutConstraint(
      item: self, attribute: .centerX, relatedBy: .equal,
      toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true

    NSLayoutConstraint(
      item: self, attribute: .height, relatedBy: .greaterThanOrEqual,
      toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: HSSnackbar.snackbarMinHeight).isActive = true

    view.addConstraint(bottomMarginConstraint!)

    showWithAnimation()

    // Accessibility announcement.
    if UIAccessibility.isVoiceOverRunning {
      UIAccessibility.post(notification: .announcement, argument: messageLabel.text)
    }
  }

  fileprivate func showWithAnimation() {
    let superViewWidth = (superview?.frame)!.width
    let snackbarHeight = systemLayoutSizeFitting(.init(width: superViewWidth - margins.left - margins.right, height: HSSnackbar.snackbarMinHeight)).height

    bottomMarginConstraint?.constant = snackbarHeight

    superview?.layoutIfNeeded()

    // Final state
    bottomMarginConstraint?.constant = -margins.bottom

    UIView.animate(withDuration: animationDuration, delay: 0,
                   usingSpringWithDamping: animationSpringWithDamping,
                   initialSpringVelocity: animationInitialSpringVelocity, options: .allowUserInteraction,
                   animations: {
                    () -> Void in
                    self.superview?.layoutIfNeeded()
    })
  }
  // MARK: - Dismiss methods
  @objc func dismiss() {
    // On main thread
    DispatchQueue.main.async { [weak self] in
      self?.dismissAnimated(true)
    }
  }

  fileprivate func dismissAnimated(_ animated: Bool) {
    guard dismissTimer != nil else { return }
    
    invalidDismissTimer()
    let snackbarHeight = frame.size.height
    var safeAreaInsets = UIEdgeInsets.zero

    if #available(iOS 11.0, *) {
      safeAreaInsets = superview?.safeAreaInsets ?? .zero;
    }

    guard animated else {
      dismissClosure?(self)
      removeFromSuperview()
      return
    }

    bottomMarginConstraint?.constant = snackbarHeight + safeAreaInsets.bottom

    setNeedsLayout()

    UIView
      .animate(withDuration: animationDuration,
               delay: 0,
               usingSpringWithDamping: animationSpringWithDamping,
               initialSpringVelocity: animationInitialSpringVelocity,
               options: .curveEaseIn,
               animations: { [weak self] in
                self?.superview?.layoutIfNeeded()
        },
               completion: { [weak self] (finished) -> Void in
                guard let `self` = self else { return }
                self.dismissClosure?(self)
                self.removeFromSuperview()

      })
  }

  fileprivate func invalidDismissTimer() {
    dismissTimer?.invalidate()
    dismissTimer = nil
  }
}
