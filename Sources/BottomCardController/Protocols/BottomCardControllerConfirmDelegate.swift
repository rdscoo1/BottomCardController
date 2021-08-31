//
//  BottomCardControllerConfirmDelegate.swift
//  BottomCardController
//
//  Created by Roman Khodukin on 30.08.2021.
//  Copyright (c) 2021 rdscoo1. All rights reserved.
//

import UIKit

@objc public protocol BottomCardControllerConfirmDelegate: AnyObject {
    var needConfirm: Bool { get }
    func confirm(_ completion: @escaping (_ isConfirmed: Bool)->())
}
