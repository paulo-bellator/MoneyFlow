//
//  ChartView.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class ChartView: UIView {
    
    var collectionView: UICollectionView!
    private var itFirstLoading = true
    private var collectionViewNeedToUpdate = false
    weak var delegate: ChartViewDelegate?
    
    var allowsSelection = false { didSet { collectionView?.allowsSelection = allowsSelection } }
    var labelsColor = UIColor.white.withAlphaComponent(0.7) {
        didSet {
            minValueLabel.textColor = labelsColor
            midValueLabel.textColor = labelsColor
            collectionViewNeedToUpdate = true
        }
    }
    var labelsFont: UIFont! { didSet { collectionViewNeedToUpdate = true } }
    var mainValueColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) { didSet { collectionViewNeedToUpdate = true } }
    var secondValueColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.2) { didSet { collectionViewNeedToUpdate = true } }
    var secondOverlapValueColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.9) { didSet { collectionViewNeedToUpdate = true } }
    var measureLinesColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.2)

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
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    private func initialization() {
        let collectionViewFrame = frameForCollectionView()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 70, height: collectionViewFrame.height)
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ChartColumnCollectionViewCell.self, forCellWithReuseIdentifier: Constants.chartColumnCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        collectionViewNeedToUpdate = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialization()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }
    
    
    private func updateUI() {
        if collectionViewNeedToUpdate { collectionView.reloadData(); collectionViewNeedToUpdate.toggle() }
        
        let frameForCell = CGRect(origin: collectionView.frame.origin,
                              size: CGSize(width: 30.0, height: collectionView.bounds.height))
        let cell = ChartColumnCollectionViewCell(frame: frameForCell)
        cell.isHidden = true
        cell.layoutIfNeeded()
        addSubview(cell)
        let chartColumnView = cell.chartColumnView
        let chartColumnViewFrame = cell.convert(chartColumnView!.frame, to: self)
        cell.removeFromSuperview()
        
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
    
    private func frameForCollectionView() -> CGRect {
        let width = bounds.width * Constants.scaleFactorCollectionViewWidthToViewChartViewWidth
        let height = bounds.height * Constants.scaleFactorCollectionViewHeightToViewChartViewHeight
        let originX = bounds.maxX - width
        let originY = bounds.midY - height/2.0
        return CGRect(x: originX, y: originY, width: width, height: height)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        print("layouts")
        let frameForCV = frameForCollectionView()
        if collectionView.frame != frameForCV {
            collectionView.frame = frameForCV
            collectionViewNeedToUpdate = true
        }
        updateUI()
    }
    
    private struct Constants {
        static let dashedLinesFillColor: UIColor = UIColor.clear
        static let dashedLinesStrokeColor: UIColor = UIColor.white.withAlphaComponent(0.2)
        static let dashedLinesWidth: CGFloat = 1.0
        static let lineDashPattern: [NSNumber] = [1,5]
        static let lineDashLayerName: String = "kShapeDashed"
        static let chartColumnCellReuseIdentifier = "chartColumn"
        static let scaleFactorCollectionViewWidthToViewChartViewWidth: CGFloat = 0.8
        static let scaleFactorCollectionViewHeightToViewChartViewHeight: CGFloat = 0.8
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
        cell.bounds.size.height = collectionView.bounds.height
        
        cell.label.text = delegate?.chartView(labelForColumnAt: indexPath.row)
        cell.label.textColor = labelsColor
        if let font = labelsFont { cell.label.font = font }
        
        let mainValue = delegate?.chartView(mainValueForColumnAt: indexPath.row) ?? 0.0
        let secondValue = delegate?.chartView(secondValueForColumnAt: indexPath.row) ?? 0.0
        
        cell.chartColumnView.mainColor = mainValueColor
        cell.chartColumnView.secondColor = secondValueColor
        cell.chartColumnView.secondOverlapColor = secondOverlapValueColor
        cell.chartColumnView.set(mainValue: mainValue, secondValue: secondValue, animated: !cell.wasSeen)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.chartView(didSelectColumnAt: indexPath.row)
        let cell = collectionView.cellForItem(at: indexPath)
//        UIView.animate(withDuration: 0.2) {
//            cell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
//        UIView.animate(withDuration: 0.2) {
//            cell?.transform = .identity
//        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            let distance = cell.frame.midX - scrollView.contentOffset.x
            cell.alpha = max(min(distance / 25.0, 1.0), 0)
        }
    }
}

