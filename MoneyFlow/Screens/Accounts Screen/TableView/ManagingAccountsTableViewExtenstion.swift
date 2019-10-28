//
//  ManagingAccountsTableViewExtenstion.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 26/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {

    private var dataSource: [(String, String)] {
        switch listType {
        case .accounts: return moneyAmountByAccounts
        case .lenders: return moneyByLenders
        case .debtors: return moneyByDebtors
        }
    }
    
    private var dataSourceIsEmpty: Bool {
        return dataSource.isEmpty
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceIsEmpty ? 1 : dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSourceIsEmpty ? tableViewEmptyCellRowHeight : tableViewRowHeight 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !dataSourceIsEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: accountTableViewCellIdentifier, for: indexPath) as! AccountTableViewCell
            cell.accountLabel.text = dataSource[indexPath.row].0
            cell.moneyAmountLabel.text = dataSource[indexPath.row].1
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyAccountsListTableViewCellIdentifier)!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if dataSourceIsEmpty {
            tableView.isScrollEnabled = false
            return
        }
        if indexPath.row == tableView.indexPathsForVisibleRows!.last!.row {
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
                if tableView.contentSize.height <= tableView.bounds.height {
                    tableView.isScrollEnabled = false
                    tableView.backgroundColor = BackColors.bottomColor
                } else {
                    tableView.isScrollEnabled = true
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topColor = BackColors.topColor
        let bottomColor = BackColors.bottomColor
        let contentHeight = scrollView.contentSize.height
        let centerOfContentHeight = contentHeight / 2
        let offset = scrollView.contentOffset.y + scrollView.bounds.height / 2
        if offset < centerOfContentHeight {
            if tableView.backgroundColor != topColor { tableView.backgroundColor = topColor }
        } else {
            if tableView.backgroundColor != bottomColor { tableView.backgroundColor = bottomColor }
        }
    }
    
    private struct BackColors {
        static let topColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        static let bottomColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}
