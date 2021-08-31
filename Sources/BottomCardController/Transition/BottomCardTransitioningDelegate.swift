//
//  BottomCardTransitioningDelegate.swift
//  BottomCardController
//
//  Created by Roman Khodukin on 30.08.2021.
//  Copyright (c) 2021 rdscoo1. All rights reserved.
//

import UIKit

public final class BottomCardTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    // MARK: - Public properties

    public var swipeToDismissEnabled: Bool = true
    public var tapAroundToDismissEnabled: Bool = true
    public var showCloseButton: Bool = false
    public var showIndicator: Bool = true
    public var indicatorColor: UIColor = UIColor.init(red: 202/255, green: 201/255, blue: 207/255, alpha: 1)
    public var hideIndicatorWhenScroll: Bool = false
    public var customHeight: CGFloat? = nil
    public var translateForDismiss: CGFloat = 200
    public var cornerRadius: CGFloat = 10
    public var hapticMoments: [BottomCardHapticMoments] = [.willDismissIfRelease]
    public weak var storkDelegate: BottomCardControllerDelegate? = nil
    public weak var confirmDelegate: BottomCardControllerConfirmDelegate? = nil

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        presented.modalPresentationStyle = .overCurrentContext
        let controller = BottomCardPresentationController(presentedViewController: presented, presenting: presenting)
        controller.swipeToDismissEnabled = self.swipeToDismissEnabled
        controller.tapAroundToDismissEnabled = self.tapAroundToDismissEnabled
        controller.showCloseButton = self.showCloseButton
        controller.showIndicator = self.showIndicator
        controller.indicatorColor = self.indicatorColor
        controller.hideIndicatorWhenScroll = self.hideIndicatorWhenScroll
        controller.customHeight = self.customHeight
        controller.translateForDismiss = self.translateForDismiss
        controller.cornerRadius = self.cornerRadius
        controller.hapticMoments = self.hapticMoments
        controller.transitioningDelegate = self
        controller.storkDelegate = self.storkDelegate
        controller.confirmDelegate = self.confirmDelegate
        return controller
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomCardPresentationAnimationController()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BottomCardDismissAnimationController()
    }

}
