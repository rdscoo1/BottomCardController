//
//  BottomCardPresentationAnimationController.swift
//  BottomCardController
//
//  Created by Roman Khodukin on 30.08.2021.
//  Copyright (c) 2021 rdscoo1. All rights reserved.
//

import UIKit

/** Анимация при открытии карточки */
public final class BottomCardPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedViewController = transitionContext.viewController(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        containerView.addSubview(presentedViewController.view)

        let finalFrameForPresentedView = transitionContext.finalFrame(for: presentedViewController)
        presentedViewController.view.frame = finalFrameForPresentedView
        presentedViewController.view.frame.origin.y = containerView.bounds.height

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                presentedViewController.view.frame = finalFrameForPresentedView
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }

}

