//
//  ManagingAddingTableViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 22/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension AddingViewController: UITableViewDelegate, UITableViewDataSource  {
    
    private var operationListIsEmpty: Bool {
        return operationsByDays.isEmpty
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return operationListIsEmpty ? 1 : operationsByDays.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operationListIsEmpty ? 1 : operationsByDays[section].ops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if operationListIsEmpty { return tableView.dequeueReusableCell(withIdentifier: emptyListTableViewCellIdentifier)! }
        
        let operation = operationsByDays[indexPath.section].ops[indexPath.row]
        let operationPresenter = OperationPresenter(operation)
        let cell = tableView.dequeueReusableCell(withIdentifier: operationTableViewCellIdentifier, for: indexPath) as! AddedOperationTableViewCell
        
        cell.timeLabel.text = operation.date.formatted(in: "HH:mm")
        cell.valueLabel.text = operationPresenter.valueString
        cell.mainLabel.text = operationPresenter.categoryString ?? operationPresenter.contactString
        cell.accountLabel.text = operationPresenter.accountString
        cell.commentLabel.text = operationPresenter.commentString
        
        switch operation {
        case _ where operation is DebtOperation:
            cell.typeIndicatorColor = #colorLiteral(red: 0.4, green: 0.462745098, blue: 0.9490196078, alpha: 1)
        case _ where operation is FlowOperation && (operation.value >= 0.0):
            cell.typeIndicatorColor = #colorLiteral(red: 0.7725490196, green: 0.8784313725, blue: 0.7058823529, alpha: 1)
        case _ where operation is FlowOperation && (operation.value < 0.0):
            cell.typeIndicatorColor = #colorLiteral(red: 0.9568627451, green: 0.6941176471, blue: 0.5137254902, alpha: 1)
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return operationListIsEmpty ? tableView.bounds.height : tableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return operationListIsEmpty ? 0 : tableViewSectionHeaderHeight
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if operationListIsEmpty { return nil }
        let header = tableView.dequeueReusableCell(withIdentifier: operationsHeaderTableViewCellIdentifier) as! OperationsHeaderTableViewCell
        header.periodLabel.text = operationsByDays[section].formattedPeriod
        let sum = operationsByDays[section].ops.valuesSum(mainCurrency)
        header.sumLabel.text = (sum > 0 ? "+" : "") + sum.currencyFormattedDescription(mainCurrency)
        
        return header.contentView
    }
    
}
