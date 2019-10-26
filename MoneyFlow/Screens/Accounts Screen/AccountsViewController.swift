//
//  AccountsViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 26/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController, UpdatableViewController {

    @IBOutlet weak var availableMoneyLabel: UILabel!
    @IBOutlet weak var allMoneyLabel: UILabel!
    @IBOutlet weak var iOweLabel: UILabel!
    @IBOutlet weak var oweMeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var presenter = AccountsPresenter()
    lazy var mainCurrency: Currency = presenter.currencies.first ?? .rub
    lazy var moneyAmountByAccounts = presenter.formattedMoneyAmountByAccounts(in: mainCurrency)
    
    let accountTableViewCellIdentifier = "accountCell"
    let currencyCollectionViewCellIdentifier = "currencyCell"
    let emptyAccountsListTableViewCellIdentifier = "emptyAccountsListCell"
    let tableViewRowHeight: CGFloat = 80
    
    var isDataReady = false
    var needToUpdate: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        view.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needToUpdate { updateData() }
    }
    
    
    func updateData() {
//        mainCurrency = presenter.currencies.first ?? .rub
        moneyAmountByAccounts = presenter.formattedMoneyAmountByAccounts(in: mainCurrency)
        availableMoneyLabel.text = presenter.availableMoneyString(in: mainCurrency)
        allMoneyLabel.text = presenter.totalMoneyString(in: mainCurrency)
        iOweLabel.text = presenter.iOweString(in: mainCurrency)
        oweMeLabel.text = presenter.oweMeString(in: mainCurrency)
        needToUpdate = false
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}


