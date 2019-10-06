//
//  RoundedSoaringView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 09/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

//@IBDesignable
class RoundedSoaringView: UIView {

    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
    }
    
    private var shadowLayer: CAShapeLayer!
    @IBInspectable private var cornerRadius: CGFloat = 10.0 { didSet{ layer.cornerRadius = cornerRadius; setNeedsLayout(); setNeedsDisplay() } }
    @IBInspectable var fillColor: UIColor = .white { didSet { setNeedsLayout(); setNeedsDisplay(); layoutSubviews() } }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowLayer?.removeFromSuperlayer()
        
        shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect:bounds, byRoundingCorners:[.topLeft, .topRight, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius)).cgPath
        
        shadowLayer.fillColor = fillColor.cgColor
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowRadius = cornerRadius
        
        layer.insertSublayer(shadowLayer, at: 0)
    }

}
