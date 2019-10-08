//
//  ManagingSummaryChartViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 25/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension SummaryViewController: ChartViewDelegate {
    
    func chartView(didSelectColumnAt index: Int) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        if currentMonthIndex != index {
            currentMonthIndex = index
            tableView.reloadData()
        }
    }
    
    func chartViewNumberOfColumns() -> Int {
        return summaryByMonth.count
    }
    
    func chartView(labelForColumnAt index: Int) -> String {
        return summaryByMonth[index].period.end.formatted(in: "LLL")
    }
    
    func chartView(mainValueForColumnAt index: Int) -> CGFloat {
        //        let measureUnit = summaryMinMax.max - summaryMinMax.min
        //        let value = summaryByMonth[index].availableMoney - summaryMinMax.min
        let measureUnit = summaryMinMax.max
        let value = max(0, summaryByMonth[index].availableMoney)
        return CGFloat(value/measureUnit)
    }
    
    func chartView(secondValueForColumnAt index: Int) -> CGFloat? {
        //        let measureUnit = summaryMinMax.max - summaryMinMax.min
        //        let value = summaryByMonth[index].totalMoney - summaryMinMax.min
        let measureUnit = summaryMinMax.max
        let value = max(0, summaryByMonth[index].totalMoney)
        return CGFloat(value/measureUnit)
    }
    
}
