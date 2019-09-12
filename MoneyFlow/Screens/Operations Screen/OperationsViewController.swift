//
//  ViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import Firebase

class OperationsViewController: UIViewController, AddOperationViewControllerDelegate, CloudDataSourceDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var tableViewTopSafeAreaTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var activityWheel: UIActivityIndicatorView!
    
    let addOperationSegueIdentifier = "ShowAddOperation"
    let operationTableViewCellIdentifier = "OperationCell"
    let empryListTableViewCellIdentifier = "emptyOperationsListCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let filterCollectionViewCellIdentifier = "filterCell"
    let tableViewSectionHeaderHeight: CGFloat = 35
    let tableViewRowHeight: CGFloat = 100
    
    var downloadProgress = 0.0 {
        didSet {
            var progress = (100*downloadProgress).rounded()
            if progress.isNaN { progress = 100.0 }
            print("Download operations: \(Int(progress)) %")
        }
    }
    
    var uploadProgress = 0.0
    
    func uploadComplete(with error: Error?) {
        //
    }
    func downloadComplete(with error: Error?) {
        // reset and reload Data
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.applyFilter()
            self?.activityWheel.stopAnimating()
            self?.tableView.isHidden = false
        }
    }
    
    
    let presenter = Presenter()
    let settingsPresenter = SettingsPresenter.shared
    lazy var operationsByDays = presenter.operationsSorted(by: .days)
    var tableViewScrollOffset: CGFloat = 0 {
        willSet { lastButOneTableViewScrollOffset = tableViewScrollOffset }
    }
    var lastButOneTableViewScrollOffset: CGFloat = 0
    var mainCurrency: Currency = Currency.all.first!
    
    var appliedFilterCells = [IndexPath(row: 0, section: 0)] {
        didSet { applyFilter()  }
    }
    
    lazy var arrayOfAllFilterUnits: [FilterUnit] = {
        var result = [FilterUnit]()
        
        result.append(FilterUnit.all("Все"))
        for currency in settingsPresenter.currenciesSignes { result.append(FilterUnit.currency(currency)) }
        for account in settingsPresenter.accounts { result.append(FilterUnit.account(account)) }
        for category in settingsPresenter.allCategories { result.append(FilterUnit.category(category)) }
        for contact in settingsPresenter.contacts { result.append(FilterUnit.contact(contact)) }
        
        return result
    }()

    
    
    private func applyFilter() {
        if appliedFilterCells.count == 1 {
            let filterUnit = arrayOfAllFilterUnits[appliedFilterCells.first!.row]
            switch filterUnit {
            case .all:
                operationsByDays = presenter.operationsSorted(by: .days)
                mainCurrency = Currency.all.first!
                reloadTableView()
                return
            default: break
            }
        }
        var requiredCurrencies = [Currency]()
        var requiredAccounts = [String]()
        var requiredCategories = [String]()
        var requiredContacts = [String]()
        
        for indexPath in appliedFilterCells {
            let filterUnit = arrayOfAllFilterUnits[indexPath.row]
            switch filterUnit {
            case .all: break
            case .account(let value): requiredAccounts.append(value)
            case .category(let value): requiredCategories.append(value)
            case .currency(let value): requiredCurrencies.append(Currency(rawValue: value)!)
            case .contact(let value): requiredContacts.append(value)
            }
        }
        
        let filteredOperation = presenter.filter(currencies: requiredCurrencies, categories: requiredCategories, contacts: requiredContacts, accounts: requiredAccounts)
        operationsByDays = presenter.operationsSorted(by: .days, operations: filteredOperation)
        
        switch requiredCurrencies.count {
        case 1: mainCurrency = requiredCurrencies.first!
        case 2: for currency in Currency.all { if requiredCurrencies.contains(currency) { mainCurrency = currency; break } }
        default: mainCurrency = Currency.all.first!
        }
        
        reloadTableView()
    }
    
    private func reloadTableView() {
        tableView.reloadData()
        tableView.contentOffset.y = 0.0
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        tableViewScrollOffset = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if MainData.source is CloudOperationDataSource {
//            MainData.source.delegate = self
//            if !MainData.source.isDownloadComplete {
//                activityWheel.startAnimating()
//                tableView.isHidden = true
//            }
//        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = tableViewSectionHeaderHeight
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7)
        
        for op in MainData.source.operations {
            FirebaseDataSource.shared.add(operation: op)
        }
        FirebaseDataSource.shared.save()
    }
    
    
    @IBAction func addOperation(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = true
        self.overlayBlurredBackgroundView()
    }
    
    func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        blurredBackgroundView.alpha = 0.0
        view.addSubview(blurredBackgroundView)
        
        UIView.animate(withDuration: 0.35) {
            blurredBackgroundView.alpha = 1
        }
    }
    
    func removeBlurredBackgroundView() {
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                UIView.animate(
                    withDuration: 0.3,
                    animations: { subview.alpha = 0.0 },
                    completion: {
                        [weak self] ended in
                        if ended { subview.removeFromSuperview()
                            self?.tabBarController?.tabBar.isHidden = false
                        }
                    }
                )
            }
        }
    }
    
    func updateData() {
//        presenter.syncronize()
        applyFilter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == addOperationSegueIdentifier {
                if let viewController = segue.destination as? AddOperationViewController {
                    viewController.delegate = self
                }
            }
        }
    }
    
    

}

enum FilterUnit {
    case all(String)
    case currency(String)
    case category(String)
    case contact(String)
    case account(String)
    
    var value: String {
        switch self {
        case .all(let value): return value
        case .account(let value): return value
        case .category(let value): return value
        case .currency(let value): return value
        case .contact(let value): return value
        }
    }
}

