//
//  ManagingTableViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 05/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit


extension OperationsViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operationsByDays[section].ops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let operation = operationsByDays[indexPath.section].ops[indexPath.row]
        let operationPresenter = OperationPresenter(operation)
        let cell = tableView.dequeueReusableCell(withIdentifier: operationTableViewCellIdentifier, for: indexPath) as! OperationTableViewCell
        
        cell.valueLabel.text = operationPresenter.valueString
        cell.emojiLabel.text = operationPresenter.categoryEmoji ?? operationPresenter.contactEmoji
        cell.mainLabel.text = operationPresenter.categoryString ?? operationPresenter.contactString
        cell.accountLabel.text = operationPresenter.accountString
        cell.commentLabel.text = operationPresenter.commentString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return operationsByDays.count
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return operationsByDays[section].formattedPeriod
    //    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: operationsHeaderTableViewCellIdentifier) as! OperationsHeaderTableViewCell
        header.periodLabel.text = operationsByDays[section].formattedPeriod
        let sum = operationsByDays[section].ops.valuesSum(mainCurrency)
        header.sumLabel.text = (sum > 0 ? "+" : "") + sum.currencyFormattedDescription(mainCurrency)
        
        return header.contentView
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //            let idOfOperationsToRemove = presenter.all()[indexPath.row].id
            //            presenter.removeOperationWith(identifier: idOfOperationsToRemove)
            //            presenter.syncronize()
            //            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}
