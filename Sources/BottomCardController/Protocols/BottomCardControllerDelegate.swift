//
//  BottomCardControllerDelegate.swift
//  BottomCardController
//
//  Created by Roman Khodukin on 30.08.2021.
//  Copyright (c) 2021 rdscoo1. All rights reserved.
//
import UIKit

@objc public protocol BottomCardControllerDelegate: AnyObject {
    @objc optional func willDismissCardBySwipe()
    @objc optional func didDismissCardBySwipe()
    @objc optional func willDismissCardByTap()
    @objc optional func didDismissCardByTap()
}
