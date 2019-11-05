//
//  ManagingTableViewExtension.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 05/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit


extension OperationsViewController: UITableViewDelegate, UITableViewDataSource  {
    
    private var operationListIsEmpty: Bool {
        return operationsByDays.isEmpty
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operationListIsEmpty ? 1 : operationsByDays[section].ops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if operationListIsEmpty { return tableView.dequeueReusableCell(withIdentifier: emptyListTableViewCellIdentifier)! }
        
        let operation = operationsByDays[indexPath.section].ops[indexPath.row]
        let operationPresenter = OperationPresenter(operation)
        let cell = tableView.dequeueReusableCell(withIdentifier: operationTableViewCleanDesignCellIdentifier, for: indexPath) as! OperationCleanDesignTableViewCell
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return operationListIsEmpty ? 1 : operationsByDays.count
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
            self.presenter.removeOperationWith(identifier: idOfOperationsToRemove)
            self.presenter.syncronize()
            
            if self.operationsByDays[indexPath.section].ops.isEmpty {
                self.operationsByDays.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
            self.sendUpdateRequirementToVCs()
        }
        delete.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        delete.image = #imageLiteral(resourceName: "delete_icon")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UITableView {
            let contentOffset = scrollView.contentOffset.y
            let maxAllowableContentOffset = scrollView.contentSize.height - scrollView.frame.height - tableView.rowHeight/2

//            print("\n")
//            print("maxAllowableContentOffset = \(maxAllowableContentOffset)")
//            print("NEWcontentOffset = \(contentOffset)")
//            print("OLDcontentOffset = \(tableViewScrollOffset)")
//            print("constraint = \(talbeViewTopSafeAreaTopConstrain.constant)")
//            print("collectionsViewHeight = \(collectionView.frame.height)")
//            print("drasticallyChanged: \(isDirectionOfContentOffsetDramaticallyChanged(newOffset: contentOffset))")
            
            if contentOffset >= 0 && contentOffset <= maxAllowableContentOffset && !isDirectionOfContentOffsetDramaticallyChanged(newOffset: contentOffset) {
            // scrolling up
                if contentOffset < tableViewScrollOffset {
                    if tableView.frame.origin.y < collectionView.frame.maxY {
                        let constantValue = tableViewTopSafeAreaTopConstrain.constant + (tableViewScrollOffset - contentOffset)
                        tableViewTopSafeAreaTopConstrain.constant = min(constantValue, collectionView.frame.height)
                    }
            // scrolling down
                } else {
                    if tableView.frame.origin.y > collectionView.frame.origin.y {
                        let constantValue = tableViewTopSafeAreaTopConstrain.constant + (tableViewScrollOffset - contentOffset)
                        tableViewTopSafeAreaTopConstrain.constant = max(constantValue, 0)
                    }
                }
            }
            tableViewScrollOffset = contentOffset
        }
    }
    
    // i don't know why, but tableView for some reason drastically change contentOffset,
    // when i use filter and reloadData in tableView
    // and this is happening a lot of times, when i scroll up
    // i think this may be becouse of reuseing cells
    // and when i reloadData in the middle of the list, and start scrollin up
    // new cells creating and it changes offset
    // so when it happends, i just forbid to change constrain
    private func isDirectionOfContentOffsetDramaticallyChanged(newOffset: CGFloat) -> Bool {
        let isDirectionChanged = lastButOneTableViewScrollOffset >= tableViewScrollOffset && tableViewScrollOffset < newOffset
        if isDirectionChanged {
            return (newOffset - tableViewScrollOffset) > 10.0
        }
        return false
    }
    
}
