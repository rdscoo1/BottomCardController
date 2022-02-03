//
//  BottomCardPresentationController.swift
//  BottomCardController
//
//  Created by Roman Khodukin on 30.08.2021.
//  Copyright (c) 2021 rdscoo1. All rights reserved.
//

import UIKit

public class BottomCardPresentationController: UIPresentationController, UIGestureRecognizerDelegate {

    // MARK: - UI

    public private(set) var closeButton = BottomCardCloseButton()
    public private(set) lazy var homeIndicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.00)
        return view
    }()
    public private(set) var gradeView: UIView = UIView()
    public let snapshotViewContainer = UIView()
    public private(set) var snapshotView: UIVisualEffectView?
    public let backgroundView = UIView()

    // MARK: - Properties

    /** Включено ли сворачивание карточки при помощи свайпа */
    var swipeToDismissEnabled: Bool = true

    /** Включено ли сворачивание карточки при нажатии вне карточки */
    var tapAroundToDismissEnabled: Bool = true

    /** Показывается ли кнопка закрытия карточки */
    public var showCloseButton: Bool = false

    /** Показывается ли home индикатор */
    public var showIndicator: Bool = true

    /** Цвет home индикатора */
    public var indicatorColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.00)

    /** Прятать ли home индикатор при скролле */
    var hideIndicatorWhenScroll: Bool = false

    /** Высота кастомной карточки */
    public var customHeight: CGFloat? = nil {
        didSet {
            presentedViewController.view?.frame = frameOfPresentedViewInContainerView
        }
    }

    /** Минимальная высота для сворачивания карточки при свайпе */
    public var translateForDismiss: CGFloat = 200

    /** Тактильная отдача при сворачивании */
    var hapticMoments: [BottomCardHapticMoments] = [.willDismissIfRelease]
    
    /** Vibration haptic */
    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    // MARK: Delegates

    public var transitioningDelegate: BottomCardTransitioningDelegate?
    weak var storkDelegate: BottomCardControllerDelegate?
    weak var confirmDelegate: BottomCardControllerConfirmDelegate?

    // MARK: Gestures

    var pan: UIPanGestureRecognizer?
    var tap: UITapGestureRecognizer?

    // MARK: Constraints

    private var snapshotViewTopConstraint: NSLayoutConstraint?
    private var snapshotViewWidthConstraint: NSLayoutConstraint?
    private var snapshotViewAspectRatioConstraint: NSLayoutConstraint?

    // MARK: Local properties

    var workConfirmation: Bool = false
    private var workGester: Bool = false
    private var startDismissing: Bool = false
    private var afterReleaseDismissing: Bool = false
    private var initialPresentedViewY: CGFloat = 0.0

    private var topSpace: CGFloat {
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        return (statusBarHeight < 25) ? 30 : statusBarHeight
    }

    private var keyboardOffset: CGFloat = 0
    private let alpha: CGFloat =  0.51
    /** Corner radius for bottom card */
    public var cornerRadius: CGFloat = 24

    private var scaleForPresentingView: CGFloat {
        guard let containerView = containerView else { return 0 }
        let factor = 1 - ((self.cornerRadius + 3) * 2 / containerView.frame.width)
        return factor
    }

    public override var presentedView: UIView? {
        let view = self.presentedViewController.view
        if view?.frame.origin == CGPoint.zero {
            view?.frame = self.frameOfPresentedViewInContainerView
        }
        return view
    }

    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let baseY: CGFloat = self.topSpace + 13
        let maxHeight: CGFloat = containerView.bounds.height - baseY
        var height: CGFloat = maxHeight

        if let customHeight = self.customHeight {
            if customHeight < maxHeight {
                height = customHeight
            } else {
                print("BottomCardController - Custom height change to default value. Your height more maximum value")
            }
        }
        initialPresentedViewY = containerView.bounds.height - height - keyboardOffset
        return CGRect(
            x: 0,
            y: containerView.bounds.height - height - keyboardOffset,
            width: containerView.bounds.width,
            height: height == maxHeight ? height : containerView.bounds.height
        )
    }

    // MARK: - Public methods

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        if !self.hapticMoments.isEmpty {
            self.feedbackGenerator.prepare()
        }

        guard
            let containerView = self.containerView,
            let presentedView = self.presentedView,
            let window = containerView.window
        else { return }

        let closeTitle = NSLocalizedString("Close", comment: "Close")

        if self.showIndicator {
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapIndicator))
            tap.cancelsTouchesInView = false
            self.homeIndicatorView.addGestureRecognizer(tap)
            self.homeIndicatorView.accessibilityLabel = closeTitle
            presentedView.addSubview(self.homeIndicatorView)
            self.homeIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            self.homeIndicatorView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            self.homeIndicatorView.heightAnchor.constraint(equalToConstant: 4).isActive = true
            self.homeIndicatorView.centerXAnchor.constraint(equalTo: presentedView.centerXAnchor).isActive = true
            self.homeIndicatorView.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: 16).isActive = true

            if UIAccessibility.isVoiceOverRunning {
                let accessibleIndicatorOverlayButton = UIButton(type: .custom)
                accessibleIndicatorOverlayButton.addTarget(self, action: #selector(self.tapIndicator), for: .touchUpInside)
                accessibleIndicatorOverlayButton.accessibilityLabel = closeTitle
                presentedView.addSubview(accessibleIndicatorOverlayButton)
                accessibleIndicatorOverlayButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    accessibleIndicatorOverlayButton.leadingAnchor.constraint(equalTo: presentedView.leadingAnchor),
                    accessibleIndicatorOverlayButton.trailingAnchor.constraint(equalTo: presentedView.trailingAnchor),
                    accessibleIndicatorOverlayButton.topAnchor.constraint(equalTo: presentedView.topAnchor),
                    accessibleIndicatorOverlayButton.bottomAnchor.constraint(equalTo: self.homeIndicatorView.bottomAnchor),
                ])
            }
        }
        self.gradeView.alpha = 0

        self.closeButton.accessibilityLabel = closeTitle
        if self.showCloseButton {
            self.closeButton.addTarget(self, action: #selector(self.tapCloseButton), for: .touchUpInside)
            presentedView.addSubview(self.closeButton)
        }
        self.updateLayoutCloseButton()

        let initialFrame: CGRect = presentingViewController.isPresentedAsBottomCard ? presentingViewController.view.frame : containerView.bounds

        containerView.insertSubview(self.snapshotViewContainer, belowSubview: presentedViewController.view)
        self.snapshotViewContainer.frame = initialFrame
        self.updateSnapshot()
        self.snapshotView?.layer.cornerRadius = 0
        self.backgroundView.alpha = 0
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.insertSubview(self.backgroundView, belowSubview: self.snapshotViewContainer)
        NSLayoutConstraint.activate([
            self.backgroundView.topAnchor.constraint(equalTo: window.topAnchor),
            self.backgroundView.leftAnchor.constraint(equalTo: window.leftAnchor),
            self.backgroundView.rightAnchor.constraint(equalTo: window.rightAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])

        let transformForSnapshotView = CGAffineTransform.identity

        self.snapshotView?.layer.masksToBounds = true
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.cornerRadius = self.cornerRadius
        presentedView.layer.masksToBounds = true

        var rootSnapshotView: UIView?
        var rootSnapshotRoundedView: UIView?

        if presentingViewController.isPresentedAsBottomCard {
            guard let rootController = presentingViewController.presentingViewController, let snapshotView = rootController.view.snapshotView(afterScreenUpdates: false) else { return }

            containerView.insertSubview(snapshotView, aboveSubview: self.backgroundView)
            backgroundView.alpha = self.alpha
            rootSnapshotView = snapshotView

            let snapshotRoundedView = UIView()
            snapshotRoundedView.layer.masksToBounds = true
            containerView.insertSubview(snapshotRoundedView, aboveSubview: snapshotView)
            snapshotRoundedView.frame = initialFrame
            snapshotRoundedView.transform = transformForSnapshotView
            rootSnapshotRoundedView = snapshotRoundedView
        }

        presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { [weak self] context in
                guard let `self` = self else { return }
                self.snapshotView?.transform = transformForSnapshotView
                self.backgroundView.alpha = self.alpha
            }, completion: { _ in
                self.snapshotView?.transform = .identity
                rootSnapshotView?.removeFromSuperview()
                rootSnapshotRoundedView?.removeFromSuperview()
            })

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Keyboard handling

    @objc func keyboardWillShow(notification: NSNotification) {
        guard
            let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            keyboardOffset != keyboardSize.height
        else { return }

        keyboardOffset = keyboardSize.height
        presentedViewController.view?.frame = frameOfPresentedViewInContainerView
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard keyboardOffset != 0 else { return }

        keyboardOffset = 0
        presentedViewController.view?.frame = frameOfPresentedViewInContainerView
    }

    public override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        guard let containerView = containerView else { return }
        self.updateSnapshot()
        self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        self.snapshotViewContainer.transform = .identity
        self.snapshotViewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.snapshotViewContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        self.updateSnapshotAspectRatio()

        if self.tapAroundToDismissEnabled {
            self.tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapArround))
            self.tap?.cancelsTouchesInView = false
            self.snapshotViewContainer.addGestureRecognizer(self.tap!)
        }

        if self.swipeToDismissEnabled {
            self.pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
            self.pan!.delegate = self
            self.pan!.maximumNumberOfTouches = 1
            self.pan!.cancelsTouchesInView = false
            self.presentedViewController.view.addGestureRecognizer(self.pan!)
        }

        if self.hapticMoments.contains(.willDismiss) {
            self.feedbackGenerator.impactOccurred()
        }
    }

    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        guard let containerView = containerView else { return }
        self.startDismissing = true

        let initialFrame: CGRect = presentingViewController.isPresentedAsBottomCard ? presentingViewController.view.frame : containerView.bounds

        let initialTransform = CGAffineTransform.identity

        self.snapshotViewTopConstraint?.isActive = false
        self.snapshotViewWidthConstraint?.isActive = false
        self.snapshotViewAspectRatioConstraint?.isActive = false
        self.snapshotViewContainer.translatesAutoresizingMaskIntoConstraints = true
        self.snapshotViewContainer.frame = initialFrame
        self.snapshotViewContainer.transform = initialTransform

        let finalTransform: CGAffineTransform = .identity

        var rootSnapshotView: UIView?
        var rootSnapshotRoundedView: UIView?

        if presentingViewController.isPresentedAsBottomCard {
            guard let rootController = presentingViewController.presentingViewController, let snapshotView = rootController.view.snapshotView(afterScreenUpdates: false) else { return }

            containerView.insertSubview(snapshotView, aboveSubview: backgroundView)
            snapshotView.frame = initialFrame
            snapshotView.transform = initialTransform
            snapshotView.contentMode = .top
            rootSnapshotView = snapshotView
            snapshotView.layer.masksToBounds = true

            let snapshotRoundedView = UIView()
            snapshotRoundedView.layer.masksToBounds = true
            snapshotRoundedView.backgroundColor = UIColor.black.withAlphaComponent(self.alpha)
            containerView.insertSubview(snapshotRoundedView, aboveSubview: snapshotView)
            snapshotRoundedView.frame = initialFrame
            snapshotRoundedView.transform = initialTransform
            rootSnapshotRoundedView = snapshotRoundedView
        }

        presentedViewController.transitionCoordinator?.animate(
            alongsideTransition: { [weak self] context in
                guard let `self` = self else { return }
                self.snapshotView?.transform = .identity
                self.snapshotViewContainer.transform = finalTransform
                self.backgroundView.alpha = 0
            }, completion: { _ in
                rootSnapshotView?.removeFromSuperview()
                rootSnapshotRoundedView?.removeFromSuperview()
            })
    }

    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        guard let containerView = containerView else { return }

        self.backgroundView.removeFromSuperview()
        self.snapshotView?.removeFromSuperview()
        self.snapshotViewContainer.removeFromSuperview()
        self.homeIndicatorView.removeFromSuperview()
        self.closeButton.removeFromSuperview()

        let offscreenFrame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: containerView.bounds.height)
        presentedViewController.view.frame = offscreenFrame
        presentedViewController.view.transform = .identity
    }
}

extension BottomCardPresentationController {

    // MARK: - Actions

    @objc func tapIndicator() {
        self.storkDelegate?.willDismissCardByTap?()
        self.dismissWithConfirmation(prepare: nil, completion: {
            self.storkDelegate?.didDismissCardByTap?()
        })
    }

    @objc func tapArround() {
        self.storkDelegate?.willDismissCardByTap?()
        self.dismissWithConfirmation(prepare: nil, completion: {
            self.storkDelegate?.didDismissCardByTap?()
        })
    }

    @objc func tapCloseButton() {
        self.storkDelegate?.willDismissCardByTap?()
        self.dismissWithConfirmation(prepare: nil, completion: {
            self.storkDelegate?.didDismissCardByTap?()
        })
    }

    public func dismissTapStyle() {
        self.storkDelegate?.willDismissCardByTap?()
        self.dismissWithConfirmation(prepare: nil, completion: {
            self.storkDelegate?.didDismissCardByTap?()
        })
    }

    public func dismissWithConfirmation(prepare: (()->())?, completion: (()->())?) {

        let dismiss = {
            self.presentingViewController.view.endEditing(true)
            self.presentedViewController.view.endEditing(true)
            self.presentedViewController.dismiss(animated: true, completion: {
                completion?()
            })
        }

        guard let confirmDelegate = self.confirmDelegate else {
            dismiss()
            return
        }

        if self.workConfirmation { return }

        if confirmDelegate.needConfirm {
            prepare?()
            self.workConfirmation = true
            confirmDelegate.confirm({ (isConfirmed) in
                self.workConfirmation = false
                self.afterReleaseDismissing = false
                if isConfirmed {
                    dismiss()
                }
            })
        } else {
            dismiss()
        }
    }

    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.isEqual(self.pan), self.swipeToDismissEnabled else { return }

        switch gestureRecognizer.state {
        case .began:
            self.workGester = true
            self.presentingViewController.view.layer.removeAllAnimations()
            self.presentingViewController.view.endEditing(true)
            self.presentedViewController.view.endEditing(true)
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: containerView)
        case .changed:
            self.workGester = true
            let translation = gestureRecognizer.translation(in: presentedView)
            if self.swipeToDismissEnabled {
                self.updatePresentedViewForTranslation(inVerticalDirection: translation.y)
            } else {
                gestureRecognizer.setTranslation(.zero, in: presentedView)
            }
        case .ended:
            self.workGester = false
            let translation = gestureRecognizer.translation(in: presentedView).y

            let toDefault = {
                UIView.animate(
                    withDuration: 0.6,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 1,
                    options: [.curveEaseOut, .allowUserInteraction],
                    animations: {
                        self.snapshotView?.transform = .identity
                        self.setPresentedViewTransform()
                        self.backgroundView.alpha = self.alpha
                    })
            }

            if translation >= self.translateForDismiss {
                self.storkDelegate?.willDismissCardBySwipe?()
                self.dismissWithConfirmation(prepare: toDefault, completion: {
                    self.storkDelegate?.didDismissCardBySwipe?()
                })
            } else {
                toDefault()
            }
        default:
            break
        }
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gester = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gester.velocity(in: self.presentedViewController.view)
            return abs(velocity.y) > abs(velocity.x)
        }
        return true
    }

    func scrollViewDidScroll(_ translation: CGFloat) {
        if !self.workGester {
            self.updatePresentedViewForTranslation(inVerticalDirection: translation)
        }
    }

    func updatePresentingController() {
        if self.startDismissing { return }
        self.updateSnapshot()
    }

    func setIndicator(visible: Bool, forse: Bool) {
        guard self.hideIndicatorWhenScroll else { return }
        let newAlpha: CGFloat = visible ? 1 : 0
        if forse {
            self.homeIndicatorView.layer.removeAllAnimations()
            self.homeIndicatorView.alpha = newAlpha
            return
        }
        if self.homeIndicatorView.alpha == newAlpha {
            return
        }
        UIView.animate(withDuration: 0.18, animations: {
            self.homeIndicatorView.alpha = newAlpha
        })
    }

    private func updatePresentedViewForTranslation(inVerticalDirection translation: CGFloat) {
        if self.startDismissing { return }

        let translationFactor: CGFloat = 1 / 2

        if translation >= 0 || containerView?.bounds.height ?? 0 == frameOfPresentedViewInContainerView.height {
            let translationForModal: CGFloat = translation * translationFactor
            setPresentedViewTransform(translationForModal)
            self.snapshotView?.transform = .identity
            let gradeFactor = 1 + (translationForModal / 7000)
            self.backgroundView.alpha = min(0.5, self.alpha - ((gradeFactor - 1) * 15))
        } else {
            setPresentedViewTransform()
        }

        if self.swipeToDismissEnabled {
            let afterRealseDismissing = (translation >= self.translateForDismiss)
            if afterRealseDismissing != self.afterReleaseDismissing {
                self.afterReleaseDismissing = afterRealseDismissing
                if !self.workConfirmation {
                    if self.hapticMoments.contains(.willDismissIfRelease) {
                        self.feedbackGenerator.impactOccurred()
                    }
                }

            }
        }
    }

    private func setPresentedViewTransform(_ y: CGFloat = 0.0) {
        let transform: CGAffineTransform
        if y == 0.0 {
            transform = .identity
        } else {
            transform = CGAffineTransform(translationX: 0, y: y)
        }
        if #available(iOS 14.0, *) {
            if var frame = self.presentedView?.frame.origin {
                frame.y = initialPresentedViewY + y
                self.presentedView?.frame.origin = frame
            } else {
                self.presentedView?.transform = transform
            }
        } else {
            self.presentedView?.transform = transform
        }
    }
}

extension BottomCardPresentationController {

    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let containerView = containerView else { return }
        self.updateSnapshotAspectRatio()
        if presentedViewController.view.isDescendant(of: containerView) {
            self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
        }
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { contex in
            self.updateLayoutCloseButton()
        }, completion: { [weak self] _ in
            self?.updateSnapshotAspectRatio()
            self?.updateSnapshot()
        })
    }

    private func updateLayoutCloseButton() {
        guard let presentedView = self.presentedView else { return }
        self.closeButton.sizeToFit()
        self.closeButton.layout(bottomX: presentedView.frame.width - 4, y: 32)
    }

    private func updateSnapshot() {
        self.snapshotView?.removeFromSuperview()
        let blurEffectView = UIVisualEffectView(effect: nil)
        blurEffectView.frame = presentingViewController.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.snapshotViewContainer.addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: snapshotViewContainer.topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: snapshotViewContainer.leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: snapshotViewContainer.rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: snapshotViewContainer.bottomAnchor)
        ])
        self.snapshotView = blurEffectView
        self.snapshotView?.layer.masksToBounds = true
        snapshotView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func updateSnapshotAspectRatio() {
        guard let containerView = containerView, snapshotViewContainer.translatesAutoresizingMaskIntoConstraints == false else { return }
        
        self.snapshotViewTopConstraint?.isActive = false
        self.snapshotViewWidthConstraint?.isActive = false
        self.snapshotViewAspectRatioConstraint?.isActive = false

        let snapshotReferenceSize = presentingViewController.view.frame.size
        let aspectRatio = snapshotReferenceSize.width / snapshotReferenceSize.height

        self.snapshotViewTopConstraint = snapshotViewContainer.topAnchor.constraint(equalTo: containerView.topAnchor)
        self.snapshotViewWidthConstraint = snapshotViewContainer.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        self.snapshotViewAspectRatioConstraint = snapshotViewContainer.widthAnchor.constraint(equalTo: snapshotViewContainer.heightAnchor, multiplier: aspectRatio)

        self.snapshotViewTopConstraint?.isActive = true
        self.snapshotViewWidthConstraint?.isActive = true
        self.snapshotViewAspectRatioConstraint?.isActive = true
    }

    private func addCornerRadiusAnimation(for view: UIView?, cornerRadius: CGFloat, duration: CFTimeInterval) {
        guard let view = view else { return }
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fromValue = view.layer.cornerRadius
        animation.toValue = cornerRadius
        animation.duration = duration
        view.layer.add(animation, forKey: "cornerRadius")
        view.layer.cornerRadius = cornerRadius
    }
}
