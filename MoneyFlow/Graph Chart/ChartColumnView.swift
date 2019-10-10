//
//  ChartColumnView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit


@IBDesignable
class ChartColumnView: UIView {
    
    @IBInspectable
    var mainColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) { didSet { mainValueProgressView.backgroundColor = mainColor } }
    @IBInspectable
    var secondColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.2) { didSet { updateUI() } }
    @IBInspectable
    var secondOverlapColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.2) { didSet { updateUI() } }
    @IBInspectable
    var mainValue: CGFloat = 0.0 { didSet { updateUI() } }
    @IBInspectable
    var secondValue: CGFloat = 0.0 { didSet { updateUI() } }
    

    private var mainValueProgressView: UIView! { didSet { updateUI() } }
    private var secondValueProgressUnderView: UIView! { didSet { updateUI() } }
    
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
        
        backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }

    private func updateUI() {
        if mainValueProgressView != nil && secondValueProgressUnderView != nil {
            mainValueProgressView.removeLinedLayer()
            secondValueProgressUnderView.removeLinedLayer()
            
            if secondValue > mainValue || secondValue == 0 {
                mainValueProgressView.frame = frameForValue(mainValue)
                secondValueProgressUnderView.isHidden = false
                secondValueProgressUnderView.frame = frameForValue(secondValue)
                secondValueProgressUnderView.backgroundColor = secondColor
                
                mainValueProgressView.backgroundColor = mainColor
                secondValueProgressUnderView.backgroundColor = .clear
                secondValueProgressUnderView.addLinedLayer()
            } else {
                mainValueProgressView.frame = frameForValue(secondValue)
                secondValueProgressUnderView.isHidden = false
                secondValueProgressUnderView.frame = frameForValue(mainValue)
                secondValueProgressUnderView.backgroundColor = secondOverlapColor
            }
        }
    }
    
    func set(mainValue: CGFloat, secondValue: CGFloat, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                self.mainValue = mainValue
                self.secondValue = secondValue
            })
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

private extension UIView {
    
    private struct Constants {
        static let lineWidth: CGFloat = 1.0
        static let lineSpacing: CGFloat = 5.0
        static let lineColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(1.0)
        static let lineAngleInDegrees: Double = 45.0
        static let linedShapeLayerName = "LinedLayer"
    }
    
    func addLinedLayer(rect: CGRect? = nil, lineColor color: UIColor? = nil) {
        let boundsToDraw = rect ?? bounds
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let fWidth: CGFloat! = boundsToDraw.width
        let fHeight: CGFloat! = boundsToDraw.height
       
        shapeLayer.bounds = boundsToDraw
        shapeLayer.position = CGPoint(x: fWidth/2, y: fHeight/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = (color ?? Constants.lineColor).cgColor
        shapeLayer.lineWidth = Constants.lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.name = Constants.linedShapeLayerName
        shapeLayer.masksToBounds = true
        
        let path = UIBezierPath()
        // max possinble for lines is a diogonal length
        let length = sqrt(pow(boundsToDraw.width, 2) + pow(boundsToDraw.height, 2.0))
        var x: CGFloat = -length/2
        while x <= length/2 {
            path.move(to: CGPoint(x: x, y: -length/2))
            path.addLine(to: CGPoint(x: x, y: length/2))
            x += path.lineWidth + Constants.lineSpacing
        }
        let radians = CGFloat(Constants.lineAngleInDegrees * Double.pi / 180)
        path.apply(CGAffineTransform(rotationAngle: radians))
        path.apply(CGAffineTransform(translationX: boundsToDraw.midX, y: boundsToDraw.height/2))
        
        shapeLayer.path = path.cgPath
//        self.layer.insertSublayer(shapeLayer, at: 0)
        layer.addSublayer(shapeLayer)
    }
    
    func removeLinedLayer() {
        self.layer.sublayers?.forEach {
            if $0.name == "LinedLayer" {
                $0.removeFromSuperlayer()
            }
        }
    }
}
