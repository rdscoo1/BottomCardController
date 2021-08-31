//
//  BottomCardViewControllerExtension.swift
//  BottomCardController
//
//  Created by Roman Khodukin on 30.08.2021.
//  Copyright (c) 2021 rdscoo1. All rights reserved.
//

import UIKit

extension UIViewController {

    public var isPresentedAsBottomCard: Bool {
        return transitioningDelegate is BottomCardTransitioningDelegate
            && modalPresentationStyle == .custom
            && presentingViewController != nil
    }

    public func presentBottomCard(_ controller: UIViewController, height: CGFloat? = nil) {
        let transitionDelegate = BottomCardTransitioningDelegate()
        transitionDelegate.customHeight = height
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        self.present(controller, animated: true, completion: nil)
    }

    public func presentBottomCard(_ controller: UIViewController,
                                  height: CGFloat?,
                                  showIndicator: Bool,
                                  showCloseButton: Bool,
                                  completion: (() -> Void)? = nil) {
        let transitionDelegate = BottomCardTransitioningDelegate()
        transitionDelegate.customHeight = height
        transitionDelegate.showCloseButton = showCloseButton
        transitionDelegate.showIndicator = showIndicator
        controller.transitioningDelegate = transitionDelegate
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        self.present(controller, animated: true, completion: completion)
    }
    
}
