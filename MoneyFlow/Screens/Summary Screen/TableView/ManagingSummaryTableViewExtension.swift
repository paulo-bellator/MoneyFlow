//
//  ManagingSummaryTableViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 25/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension SummaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return presenter.settings.incomeCategories.count + 1
        case 1: return presenter.settings.outcomeCategories.count + 1
        case 2: return 2 + 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: summaryHeaderCellIdentifier) as! SummaryHeaderTableViewCell
            header.layoutIfNeeded()
            return header
        } else {
            let cellIdentifier = isCircleChartPresentationType ? summaryGraphCellIdentifier : summaryCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case _ where cell is SummaryHeaderTableViewCell:
            let header = cell as! SummaryHeaderTableViewCell
            switch indexPath.section {
            case 0:
                header.leftLabel.text = "Доходы"
                header.rightLabel.text = monthData.incomesAmount
            case 1:
                header.leftLabel!.text = "Расходы"
                header.rightLabel.text = monthData.outcomesAmount
            case 2:
                header.leftLabel!.text = "Долги"
                header.rightLabel.text = monthData.debtsBalance
            default: break
            }
        
        case _ where cell is  SummaryTableViewCell:
            let cell = cell as! SummaryTableViewCell
            switch indexPath.section {
            case 0:
                cell.titleLabel.text = monthData.incomesByWeeks[indexPath.row-1].categoryName
                for (index, valueLabel) in cell.valueLabels.enumerated() {
                    valueLabel.text = monthData.incomesByWeeks[indexPath.row-1].values[index]
                }
            case 1:
                cell.titleLabel.text = monthData.outcomesByWeeks[indexPath.row-1].categoryName
                for (index, valueLabel) in cell.valueLabels.enumerated() {
                    valueLabel.text = monthData.outcomesByWeeks[indexPath.row-1].values[index]
                }
            case 2:
                cell.titleLabel.text = monthData.debtsByWeeks[indexPath.row-1].direction
                for (index, valueLabel) in cell.valueLabels.enumerated() {
                    valueLabel.text = monthData.debtsByWeeks[indexPath.row-1].values[index]
                }
            default: break
            }
       
        // color is for difference from other periods but same category
        // size is for difference from same period by different categories
        case _ where cell is  SummaryGraphTableViewCell:
            let cell = cell as! SummaryGraphTableViewCell
            switch indexPath.section {
            case 0:
                cell.titleLabel.text = monthData.incomesByWeeksForChart[indexPath.row-1].categoryName
                for (index, graph) in cell.graphs.enumerated() {
                    graph.value = monthData.incomesByWeeksForChart[indexPath.row-1].chartSets[index].value
                    graph.backgroundColor = monthData.incomesByWeeksForChart[indexPath.row-1].chartSets[index].color
                }
            case 1:
                cell.titleLabel.text = monthData.outcomesByWeeksForChart[indexPath.row-1].categoryName
                for (index, graph) in cell.graphs.enumerated() {
                    graph.value = monthData.outcomesByWeeksForChart[indexPath.row-1].chartSets[index].value
                    graph.backgroundColor = monthData.outcomesByWeeksForChart[indexPath.row-1].chartSets[index].color
                }
            case 2:
                cell.titleLabel.text = monthData.debtsByWeeksForChart[indexPath.row-1].direction
                for (index, graph) in cell.graphs.enumerated() {
                    graph.value = monthData.debtsByWeeksForChart[indexPath.row-1].chartSets[index].value
                    graph.backgroundColor = monthData.debtsByWeeksForChart[indexPath.row-1].chartSets[index].color
                }
            default: break
            }
            
            cell.isItFirtsLine = indexPath.row-1 == 0
            cell.isItLastLine = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            cell.layoutIfNeeded()
        default: break
        }
    }
    
}

