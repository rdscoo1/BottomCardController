//
//  BottomCardCloseButton.swift
//  BottomCardController
//
//  Created by Roman Khodukin on 30.08.2021.
//  Copyright (c) 2021 rdscoo1. All rights reserved.
//

import UIKit

open class BottomCardCloseButton: UIButton {

    let iconView = BottomCardCloseView()

    // MARK: - Properties

    var widthIconFactor: CGFloat = 1
    var heightIconFactor: CGFloat = 1

    var color = UIColor.blue {
        didSet {
            self.iconView.color = self.color
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            self.iconView.color = self.color.withAlphaComponent(self.isHighlighted ? 0.7 : 1)
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        self.commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func commonInit() {
        self.iconView.isUserInteractionEnabled = false
        self.addSubview(self.iconView)
        self.color = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1.00)
        self.widthIconFactor = 0.4
        self.heightIconFactor = 0.4
    }

    // MARK: - Public methods

    func layout(bottomX: CGFloat, y: CGFloat) {
        self.sizeToFit()
        self.frame.origin.x = bottomX - self.frame.width
        self.frame.origin.y = y
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width * self.widthIconFactor, height: self.frame.height * self.heightIconFactor)
        self.iconView.center = CGPoint.init(x: self.frame.width / 2, y: self.frame.height / 2)
    }

    override open func sizeToFit() {
        super.sizeToFit()
        self.frame = CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: 40, height: 40)
    }

}
