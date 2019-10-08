//
//  ChartColumnCollectionViewCell.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class ChartColumnCollectionViewCell: UICollectionViewCell {
    
    var wasSeen = false
    
    lazy var chartColumnView: ChartColumnView! = {
        let view = ChartColumnView(frame: CGRect.zero)
        addSubview(view)
        return view
    }()
    lazy var label: UILabel! = {
       let label = UILabel(frame: CGRect.zero)
        label.textAlignment = NSTextAlignment.center
        addSubview(label)
        return label
    }()
    
    override func prepareForReuse() {
        wasSeen = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        chartColumnView.frame = frameForChartColumnView()
        label.frame = frameForLabel()
    }
    
    func frameForChartColumnView() -> CGRect {
        let width = bounds.width * Constants.scaleFactorWidthOfCharColumnViewToCellWidth
        let height = bounds.height * Constants.scaleFactorHeightOfCharColumnViewToCellHeight
        let originX = (bounds.width - width)/2.0
        let originY = bounds.midY * Constants.scaleFactorMidXOfCharColumnViewToCellMidX - height/2.0
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    private func frameForLabel() -> CGRect {
        let chartColumnViewFrame = frameForChartColumnView()
        let width = bounds.width
        let height = max(label.frame.height, Constants.labelDefaultHeight)
        let originX = CGFloat(0.0)
//        let originY = bounds.maxY - height
        var originY = chartColumnViewFrame.maxY + Constants.labelChartColumnViewSpacing
        if bounds.maxY < originY + height {
            originY = bounds.maxY - height
        }
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private struct Constants {
        static let scaleFactorHeightOfCharColumnViewToCellHeight: CGFloat = 0.8
        static let scaleFactorWidthOfCharColumnViewToCellWidth: CGFloat = 0.7
        static let scaleFactorMidXOfCharColumnViewToCellMidX: CGFloat = 0.9
        static let labelDefaultHeight: CGFloat = 21.0
        static let labelChartColumnViewSpacing: CGFloat = 20
    }
}

extension ChartColumnCollectionViewCell {
    
}
