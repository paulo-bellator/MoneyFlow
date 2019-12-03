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
        
        var resultCell = UITableViewCell()
        
        switch operation {
        case is FlowOperation:
            let cell = tableView.dequeueReusableCell(withIdentifier: operationTableViewCellIdentifier, for: indexPath) as! AddedOperationTableViewCell
            cell.valueLabel.text = operationPresenter.valueString
            cell.accountLabel.text = operationPresenter.accountString
            cell.commentLabel.text = operationPresenter.commentString
            cell.mainLabel.text = operationPresenter.categoryString
            cell.typeIndicatorColor = (operation.value >= 0.0) ? #colorLiteral(red: 0.7725490196, green: 0.8784313725, blue: 0.7058823529, alpha: 1) : #colorLiteral(red: 0.9568627451, green: 0.6941176471, blue: 0.5137254902, alpha: 1)
            cell.timeLabel.text = operation.date.formatted(in: "HH:mm")
            resultCell = cell
            
        case is DebtOperation:
            let cell = tableView.dequeueReusableCell(withIdentifier: operationTableViewCellIdentifier, for: indexPath) as! AddedOperationTableViewCell
            cell.valueLabel.text = operationPresenter.valueString
            cell.accountLabel.text = operationPresenter.accountString
            cell.commentLabel.text = operationPresenter.commentString
            cell.mainLabel.text = operationPresenter.contactString
            cell.typeIndicatorColor = #colorLiteral(red: 0.4, green: 0.462745098, blue: 0.9490196078, alpha: 1)
            cell.timeLabel.text = operation.date.formatted(in: "HH:mm")
            resultCell = cell
            
        case is TransferOperation:
            let cell = tableView.dequeueReusableCell(withIdentifier: operationTransferTableViewCellIdentifier, for: indexPath) as! AddedTransferOperationTableViewCell
            cell.valueLabel.text = operationPresenter.valueString
            cell.fromAccountLabel.text = operationPresenter.accountString
            cell.toAccountLabel.text = operationPresenter.destinationAccountString
            cell.typeIndicatorColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
            cell.timeLabel.text = operation.date.formatted(in: "HH:mm")
            resultCell = cell
        default:
            break
        }
        
        return resultCell
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !operationListIsEmpty else { return nil }
        let edit = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, nil) in
            if self != nil {
                self!.performSegue(withIdentifier: self!.addOperationSegueIdentifier, sender: indexPath)
                self!.indexPathToScroll = indexPath
                tableView.setEditing(false, animated: true)
            }
        }
        edit.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        edit.image = #imageLiteral(resourceName: "edit_icon")
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !operationListIsEmpty else { return nil }
        let delete = UIContextualAction(style: .destructive, title: "") { [unowned self] (action, view, nil) in
            let idOfOperationsToRemove = self.operationsByDays[indexPath.section].ops.remove(at: indexPath.row).id
            self.deleteOperation(with: idOfOperationsToRemove)
            
            if self.operationsByDays[indexPath.section].ops.isEmpty {
                self.operationsByDays.remove(at: indexPath.section)
                
                // If dataSource is empty (we deleted last of out sections(=days))
                // then we just reload tableView to show emptyCell
                // Else we deleteSection with tableView's native method
                if self.operationsByDays.isEmpty {
                    tableView.reloadData()
                } else {
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                }
                
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
        }
        delete.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        delete.image = #imageLiteral(resourceName: "delete_icon")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
}
