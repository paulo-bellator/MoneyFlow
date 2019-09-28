//
//  ViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import Firebase

class OperationsViewController: UIViewController, AddOperationViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var tableViewTopSafeAreaTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    
    let addOperationSegueIdentifier = "ShowAddOperation"
    let operationTableViewCellIdentifier = "OperationCell"
    let operationTableViewDesignCellIdentifier = "OperationDesignCell"
    let emptyListTableViewCellIdentifier = "emptyOperationsListCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let filterCollectionViewCellIdentifier = "filterCell"
    let tableViewSectionHeaderHeight: CGFloat = 35
    let tableViewRowHeight: CGFloat = 100
    let filterPeriod: Presenter.DateFilterUnit = .days
    var upperBound: Double = 0.0
    
    let presenter = Presenter()
    lazy var operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod)
    var tableViewScrollOffset: CGFloat = 0 {
        willSet { lastButOneTableViewScrollOffset = tableViewScrollOffset }
    }
    var lastButOneTableViewScrollOffset: CGFloat = 0
    lazy var mainCurrency: Currency = presenter.settings.currencies.first!
    
    var appliedFilterCells = [IndexPath(row: 0, section: 0)] {
        didSet { applyFilter() }
    }
    
    lazy var arrayOfAllFilterUnits: [FilterUnit] = {
        var result = [FilterUnit]()
        
        result.append(FilterUnit.all("Все"))
        for currency in presenter.settings.currenciesSignesSorted { result.append(FilterUnit.currency(currency)) }
        for account in presenter.settings.accountsSorted { result.append(FilterUnit.account(account)) }
        for category in presenter.settings.allCategoriesSorted { result.append(FilterUnit.category(category)) }
        for contact in presenter.settings.contactsSorted { result.append(FilterUnit.contact(contact)) }
        
        return result
    }()

    
    
    private func applyFilter() {
        if appliedFilterCells.count == 1 {
            let filterUnit = arrayOfAllFilterUnits[appliedFilterCells.first!.row]
            switch filterUnit {
            case .all:
                operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod)
                mainCurrency = presenter.settings.currencies.first!
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
        operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod, operations: filteredOperation)
        
        switch requiredCurrencies.count {
        case 1: mainCurrency = requiredCurrencies.first!
        case 2: for currency in Currency.all { if requiredCurrencies.contains(currency) { mainCurrency = currency; break } }
        default: mainCurrency = presenter.settings.currencies.first!
        }
        
        reloadTableView()
    }
    
    private func reloadTableView() {
        tableView.reloadData()
        tableView.contentOffset.y = 0.0
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        tableViewScrollOffset = 0
    }
    
    private func countUpperBound() {
        let ops = presenter.all().map({ abs($0.value) }).sorted(by: <)
        let upperBoundConstant = 0.15
        let index = Int(Double(ops.count - 1) * (1.0 - upperBoundConstant))
        upperBound = ops[index]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if var cloudSource = MainData.source as? CloudOperationDataSource {
            cloudSource.delegate = self
            if !cloudSource.isDownloadComplete {
                tableView.isHidden = true
            }
        } else {
            countUpperBound()
        }
        
        progressView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = tableViewSectionHeaderHeight
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7)
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
        countUpperBound()
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

extension OperationsViewController: CloudDataSourceDelegate {
    var downloadProgress: Double {
        set {
            var progress = (100*newValue).rounded()
            if progress.isNaN { progress = 100.0 }
            print("Download operations: \(Int(progress)) %")
            progressView.isHidden = false
            progressView.progress = Float(newValue)
        }
        get { return 0 }
    }
    var uploadProgress: Double {
        get { return 0 }
        set {
            progressView.isHidden = false
            progressView.progress = Float(newValue)
        }
    }
    
    func uploadComplete(with error: Error?) {
        progressView.isHidden = true
    }
    func downloadComplete(with error: Error?) {
        // reset and reload Data
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.countUpperBound()
            self?.applyFilter()
            self?.progressView.isHidden = true
            self?.tableView.isHidden = false
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

