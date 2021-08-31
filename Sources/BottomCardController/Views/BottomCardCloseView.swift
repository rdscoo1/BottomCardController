//
//  BottomCardCloseView.swift
//  BottomCardController
//
//  Created by Roman Khodukin on 30.08.2021.
//  Copyright (c) 2021 rdscoo1. All rights reserved.
//

import UIKit

open class BottomCardCloseView: UIView {

    var color = UIColor.blue {
        didSet {
            self.setNeedsDisplay()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        self.commonInit()
    }

    private func commonInit() {
        self.backgroundColor = UIColor.clear
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        BottomCardCodeDraw.drawClose(frame: rect, resizing: .aspectFit, color: self.color)
    }

}
