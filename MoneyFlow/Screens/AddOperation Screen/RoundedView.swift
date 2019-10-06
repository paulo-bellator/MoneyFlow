//
//  RoundedView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 06/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {
    
    @IBInspectable private var cornerRadius: CGFloat = 10.0 { didSet{ setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
    }
}
