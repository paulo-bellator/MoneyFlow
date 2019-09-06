//
//  ViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class OperationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var talbeViewTopSafeAreaTopConstrain: NSLayoutConstraint!
    
    let operationTableViewCellIdentifier = "OperationCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let filterCollectionViewCellIdentifier = "filterCell"
    let mainCurrency: Currency = .rub
    
    let presenter = Presenter()
    lazy var operationsByDays = presenter.operationsSorted(by: .days)
    var appliedFilterCells = [IndexPath(row: 0, section: 0)]
    var tableViewScrollOffset: CGFloat = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 35
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7)
        
        tableView.refreshControl?.isUserInteractionEnabled = false
    }
    

}

