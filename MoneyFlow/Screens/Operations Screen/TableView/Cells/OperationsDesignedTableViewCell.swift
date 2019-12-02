//
//  OperationsDesignedTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 27/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

@IBDesignable class OperationsDesignedTableViewCell: UITableViewCell {

    @IBOutlet weak var leadingConstraintMeasureViewAndSuperView: NSLayoutConstraint!
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var measureView: UIView! { didSet { measureView.addRoundedRectMask() } }
    
    
    var measureValue: CGFloat = 0.0 {
        didSet {
            measureValue = max(min(1.0, measureValue), 0.0)
            let width = (maxMesureWidth - minMesureWidth) * measureValue + minMesureWidth
            leadingConstraintMeasureViewAndSuperView.constant = maxMesureWidth - width
            measureView.superview!.layoutIfNeeded()
        }
    }
    var measureColor: UIColor = UIColor.red {
        didSet {
            measureView.backgroundColor = measureColor
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        measureView?.addRoundedRectMask()
    }
    
    private var minMesureWidth: CGFloat {
        return measureView.superview!.bounds.width*0.45
    }
    private var maxMesureWidth: CGFloat {
        return measureView.superview!.bounds.width
    }
}

private extension UIView {
    func addRoundedRectMask() {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 15.0, height: bounds.height/2))
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        layer.mask = shape
    }
}
