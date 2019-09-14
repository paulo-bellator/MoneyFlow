//
//  ChartColumnView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit


//@IBDesignable
class ChartColumnView: UIView {
    
    @IBInspectable
    var mainColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) { didSet { mainValueProgressView.backgroundColor = mainColor } }
    @IBInspectable
    var secondColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.2) { didSet { secondValueProgressUnderView.backgroundColor = secondColor } }
    @IBInspectable
    var secondOverlapColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) { didSet { secondValueProgressOverView.backgroundColor = secondOverlapColor } }
    @IBInspectable
    var mainValue: CGFloat = 0.0 { didSet { updateUI() } }
    @IBInspectable
    var secondValue: CGFloat = 0.0 { didSet { updateUI() } }
    

    private var mainValueProgressView: UIView! { didSet { updateUI() } }
    private var secondValueProgressUnderView: UIView! { didSet { updateUI() } }
    private var secondValueProgressOverView: UIView! { didSet { updateUI() } }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        secondValueProgressUnderView = UIView(frame: frameForValue(secondValue))
        secondValueProgressUnderView.backgroundColor = secondColor
        addSubview(secondValueProgressUnderView)
        
        mainValueProgressView = UIView(frame: frameForValue(mainValue))
        mainValueProgressView.backgroundColor = mainColor
        addSubview(mainValueProgressView)
        
        secondValueProgressOverView = UIView(frame: frameForValue(secondValue))
        secondValueProgressOverView.backgroundColor = secondColor
        addSubview(secondValueProgressOverView)
        
        backgroundColor = UIColor.clear
    }

    private func updateUI() {
        if mainValueProgressView != nil && secondValueProgressOverView != nil && secondValueProgressUnderView != nil {
            mainValueProgressView.frame = frameForValue(mainValue)
            if secondValue > mainValue {
                secondValueProgressUnderView.isHidden = false
                secondValueProgressOverView.isHidden = true
                secondValueProgressUnderView.frame = frameForValue(secondValue)
            } else {
                secondValueProgressOverView.isHidden = false
                secondValueProgressUnderView.isHidden = true
                secondValueProgressOverView.frame = frameForValue(secondValue)
            }
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    func set(mainValue: CGFloat, secondValue: CGFloat, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                self.mainValue = mainValue
                self.secondValue = secondValue
            })
//            UIView.animate(withDuration: 0.5) {
//                self.mainValue = mainValue
//                self.secondValue = secondValue
//            }
        } else {
            self.mainValue = mainValue
            self.secondValue = secondValue
        }
    }

    
    private func frameForValue(_ value: CGFloat) -> CGRect {
        let origin = CGPoint(x: bounds.minX, y: bounds.maxY * (1.0 - value))
        let height = bounds.height * value
        let size = CGSize(width: bounds.width, height: height)
        
        return CGRect(origin: origin, size: size)
    }
}
