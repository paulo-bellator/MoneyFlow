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
        if operationListIsEmpty { return tableView.dequeueReusableCell(withIdentifier: empryListTableViewCellIdentifier)! }
        
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
        return tableViewRowHeight
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
                        let constantValue = talbeViewTopSafeAreaTopConstrain.constant + (tableViewScrollOffset - contentOffset)
                        talbeViewTopSafeAreaTopConstrain.constant = min(constantValue, collectionView.frame.height)
                    }
            // scrolling down
                } else {
                    if tableView.frame.origin.y > collectionView.frame.origin.y {
                        let constantValue = talbeViewTopSafeAreaTopConstrain.constant + (tableViewScrollOffset - contentOffset)
                        talbeViewTopSafeAreaTopConstrain.constant = max(constantValue, 0)
                    }
                }
            }
            tableViewScrollOffset = contentOffset
        }
    }
    
    // i don't know why, by tableView for somereson drastically change contentOffset,
    // when i use filter and reloadDate in tableView
    // and this is happening a lot of times, when i scroll up
    // i think this may be becouse of reuseing cells
    // and when i reloadData in the middle of list, and start scrollin up
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
