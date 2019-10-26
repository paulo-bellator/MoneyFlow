//
//  ManagingAccountsTableViewExtenstion.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 26/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {

    private var accountsListIsEmpty: Bool {
        return moneyAmountByAccounts.isEmpty
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moneyAmountByAccounts.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !accountsListIsEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: accountTableViewCellIdentifier, for: indexPath) as! AccountTableViewCell
            cell.accountLabel.text = moneyAmountByAccounts[indexPath.row].account
            cell.moneyAmountLabel.text = moneyAmountByAccounts[indexPath.row].amount
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyAccountsListTableViewCellIdentifier)!
            return cell
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        let bottomColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let contentHeight = scrollView.contentSize.height
        let centerOfContentHeight = contentHeight / 2
        let offset = scrollView.contentOffset.y + scrollView.bounds.height / 2
        if offset < centerOfContentHeight {
            if tableView.backgroundColor != topColor { tableView.backgroundColor = topColor }
        } else {
            if tableView.backgroundColor != bottomColor { tableView.backgroundColor = bottomColor }
        }
    }
}
