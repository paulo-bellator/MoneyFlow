//
//  SummaryGraphTableViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 18/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SummaryGraphTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var graph1: CircleGraphView!
    @IBOutlet weak var graph2: CircleGraphView!
    @IBOutlet weak var graph3: CircleGraphView!
    @IBOutlet weak var graph4: CircleGraphView!
    
    var isItFirtsLine = false
    var isItLastLine = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if graph1 != nil, graph2 != nil, graph3 != nil, graph4 != nil {
            removeDashedLines()
            let graph1Frame = graph1.convert(graph1.bounds, to: self)
            let graph2Frame = graph2.convert(graph2.bounds, to: self)
            let graph3Frame = graph3.convert(graph3.bounds, to: self)
            let graph4Frame = graph4.convert(graph4.bounds, to: self)
            
            let graph1Down = CGPoint(x: graph1Frame.midX, y: bounds.maxY)
            let graph1Center = CGPoint(x: graph1Frame.midX, y: bounds.midY)
            let graph1Up = CGPoint(x: graph1Frame.midX, y: bounds.minY)
            
            let graph2Down = CGPoint(x: graph2Frame.midX, y: bounds.maxY)
            let graph2Center = CGPoint(x: graph2Frame.midX, y: bounds.midY)
            let graph2Up = CGPoint(x: graph2Frame.midX, y: bounds.minY)
            
            let graph3Down = CGPoint(x: graph3Frame.midX, y: bounds.maxY)
            let graph3Center = CGPoint(x: graph3Frame.midX, y: bounds.midY)
            let graph3Up = CGPoint(x: graph3Frame.midX, y: bounds.minY)
            
            let graph4Down = CGPoint(x: graph4Frame.midX, y: bounds.maxY)
            let graph4Center = CGPoint(x: graph4Frame.midX, y: bounds.midY)
            let graph4Up = CGPoint(x: graph4Frame.midX, y: bounds.minY)
            
            let points = [
                (isItLastLine ? graph1Center : graph1Down , isItFirtsLine ? graph1Center : graph1Up),
                (isItLastLine ? graph2Center : graph2Down , isItFirtsLine ? graph2Center : graph2Up),
                (isItLastLine ? graph3Center : graph3Down , isItFirtsLine ? graph3Center : graph3Up),
                (isItLastLine ? graph4Center : graph4Down , isItFirtsLine ? graph4Center : graph4Up),
                (graph1Center, graph4Center)]
            addDashedLines(with: points)
        }
    }
    
    private func addDashedLines(with points: [(CGPoint, CGPoint)], pattern: [NSNumber]? = nil, color: UIColor? = nil ) {
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let fWidth: CGFloat! = bounds.width
        let fHeight: CGFloat! = bounds.height
        
        shapeLayer.bounds = self.bounds
        shapeLayer.position = CGPoint(x: fWidth/2, y: fHeight/2)
        shapeLayer.fillColor = Constants.dashedLinesFillColor.cgColor
        shapeLayer.strokeColor = (color ?? Constants.dashedLinesStrokeColor).cgColor
        shapeLayer.lineWidth = Constants.dashedLinesWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = pattern ?? Constants.lineDashPattern
        shapeLayer.name = Constants.lineDashLayerName
        
        let path = UIBezierPath()
        for (point1, point2) in points {
            path.move(to: point1)
            path.addLine(to: point2)
        }
        shapeLayer.path = path.cgPath
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    private func removeDashedLines() {
        self.layer.sublayers?.forEach {
            if $0.name == Constants.lineDashLayerName {
                $0.removeFromSuperlayer()
            }
        }
    }
    
    private struct Constants {
        static let dashedLinesFillColor: UIColor = UIColor.clear
        static let dashedLinesStrokeColor: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        static let dashedLinesWidth: CGFloat = 1.0
        static let lineDashPattern: [NSNumber] = [1,5]
        static let lineDashLayerName: String = "kShapeDashed"
        static let leftOffset: CGFloat = 10
    }

    

}
