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
    
    @IBOutlet weak var chartColumnView: ChartColumnView!
    @IBOutlet weak var label: UILabel!
    
    override func prepareForReuse() {
        wasSeen = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        chartColumnView.frame = frameForChartColumView()
        label.frame = frameForLabel()
    }
    
    private func frameForChartColumView() -> CGRect {
        let width = bounds.width * Constants.scaleFactorWidthOfCharColumnViewToCellWidth
        let height = bounds.height * Constants.scaleFactorHeightOfCharColumnViewToCellHeight
        let originX = (bounds.width - width)/2.0
        let originY = bounds.midY * Constants.scaleFactorMidXOfCharColumnViewToCellMidX - height/2.0
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    private func frameForLabel() -> CGRect {
        let width = bounds.width
        let height = max(label.frame.height, Constants.labelDefaultHeight)
        let originX = CGFloat(0.0)
        let originY = bounds.maxY - height
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private struct Constants {
        static let scaleFactorHeightOfCharColumnViewToCellHeight: CGFloat = 0.75
        static let scaleFactorWidthOfCharColumnViewToCellWidth: CGFloat = 0.6
        static let scaleFactorMidXOfCharColumnViewToCellMidX: CGFloat = 0.9
        static let labelDefaultHeight: CGFloat = 21.0
    }
}
