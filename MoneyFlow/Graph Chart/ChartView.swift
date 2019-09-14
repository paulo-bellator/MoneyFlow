//
//  ChartView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class ChartView: UIView {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = UIColor.clear
            collectionView.allowsMultipleSelection = false
            Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { _ in
                self.updateUI()
            }
        }
    }
    
    var heightForColumn: CGFloat = 257.0 { didSet { collectionView.reloadData(); updateUI() } }
    var labelsColor = UIColor.white.withAlphaComponent(0.7) {
        didSet {
            minValueLabel.textColor = labelsColor
            midValueLabel.textColor = labelsColor
            collectionView.reloadData()
        }
    }
    var mainValueColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) { didSet { collectionView.reloadData() } }
    var secondValueColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.2) { didSet { collectionView.reloadData() } }
    var secondOverlapValueColor = #colorLiteral(red: 0.9459742453, green: 0.9459742453, blue: 0.9459742453, alpha: 1) { didSet { collectionView.reloadData() } }
    var measureLinesColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.2) { didSet { updateUI() } }

    lazy var minValueLabel: UILabel =  {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = labelsColor
        self.addSubview(label)
        return label
    }()
    lazy var midValueLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = labelsColor
        self.addSubview(label)
        return label
    }()
    
    weak var delegate: ChartViewDelegate?
    
   
    
    private func updateUI() {
        print("update")
        let cell = (collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ChartColumnCollectionViewCell)
        if let cell = cell {
            let chartColumnView = cell.chartColumnView
            let chartColumnViewFrame = collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!.convert(chartColumnView!.frame, to: self)
            let minY = chartColumnViewFrame.midY
            let maxY = chartColumnViewFrame.maxY
        
            let point1 = CGPoint(x: bounds.maxX*0.05, y: minY+1)
            let point2 = CGPoint(x: bounds.maxX, y: minY+1)
            let point3 = CGPoint(x: bounds.maxX*0.05, y: maxY-0.5)
            let point4 = CGPoint(x: bounds.maxX, y: maxY-0.5)
            
            removeDashedLines()
            addDashedLines(with: [(point1, point2)], color: measureLinesColor)
            let colorForSecondLine = measureLinesColor.withAlphaComponent(measureLinesColor.cgColor.alpha - 0.1)
            addDashedLines(with: [(point3, point4)], pattern: [1,0], color: colorForSecondLine)
            
            if midValueLabel.text != nil {
                midValueLabel.sizeToFit()
                midValueLabel.frame.origin = CGPoint(x: bounds.maxX*0.05 , y: minY+1 - (midValueLabel.bounds.height + 5))
            }
            if minValueLabel.text != nil {
                minValueLabel.sizeToFit()
                minValueLabel.frame.origin = CGPoint(x: bounds.maxX*0.05 , y: maxY+1 - (minValueLabel.bounds.height + 5))
            }
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
        static let dashedLinesStrokeColor: UIColor = UIColor.white.withAlphaComponent(0.2)
        static let dashedLinesWidth: CGFloat = 1.0
        static let lineDashPattern: [NSNumber] = [1,5]
        static let lineDashLayerName: String = "kShapeDashed"
        static let chartColumnCellReuseIdentifier = "chartColumn"
    }

}

protocol ChartViewDelegate: class {
    func chartView(didSelectColumnAt index: Int)
    func chartViewNumberOfColumns() -> Int
    func chartView(labelForColumnAt index: Int) -> String
    func chartView(mainValueForColumnAt index: Int) -> CGFloat
    func chartView(secondValueForColumnAt index: Int) -> CGFloat?
}


extension ChartView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.chartViewNumberOfColumns() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.chartColumnCellReuseIdentifier, for: indexPath) as! ChartColumnCollectionViewCell
        cell.label.text = delegate?.chartView(labelForColumnAt: indexPath.row)
        cell.label.textColor = labelsColor
        let mainValue = delegate?.chartView(mainValueForColumnAt: indexPath.row) ?? 0.0
        let secondValue = delegate?.chartView(secondValueForColumnAt: indexPath.row) ?? 0.0
        cell.chartColumnView.mainColor = mainValueColor
        cell.chartColumnView.secondColor = secondValueColor
        cell.chartColumnView.secondOverlapColor = secondOverlapValueColor
        cell.chartColumnView.set(mainValue: mainValue, secondValue: secondValue, animated: !cell.wasSeen)
//        cell.layer.borderWidth = cell.isSelected ? 1.0 : 0.0
        cell.bounds.size.height = heightForColumn
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.chartView(didSelectColumnAt: indexPath.row)
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.layer.borderWidth = 1.0
//        cell?.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        print(cell?.isSelected)
//        cell?.layer.borderWidth = 0.0
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            let distance = cell.frame.midX - scrollView.contentOffset.x
            cell.alpha = max(min(distance / 25.0, 1.0), 0)
        }
    }
}



//@IBOutlet weak var collectionView: UICollectionView! {
//    didSet {
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.backgroundColor = UIColor.clear
//
//        Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { _ in
//            self.updateLayoutsOfSubviews()
//        }
//
//
//        let mask = CAGradientLayer()
//        mask.startPoint = CGPoint(x: 0.0, y: 0.5)
//        mask.endPoint = CGPoint(x: 1.0, y: 0.5)
//        let mainColor = self.backgroundColor ?? UIColor.white
//        mask.colors = [mainColor.withAlphaComponent(0.0).cgColor,
//                       mainColor.withAlphaComponent(0.2).cgColor,
//                       mainColor.withAlphaComponent(1.0).cgColor]
//        mask.locations = [0.25, 0.3, 0.35]
//        mask.frame = collectionView.superview?.bounds ?? CGRect.zero
//        mask.frame = collectionView.frame ?? CGRect.zero
//        collectionView.backgroundColor = UIColor.clear
//    }
//}