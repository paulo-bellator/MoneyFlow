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
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var tableViewTopSafeAreaTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: Properties
    
    let addOperationSegueIdentifier = "ShowAddOperation"
    let addSomeOperationsSegueIdentidier = "addSomeOperations"
    let operationTableViewCellIdentifier = "OperationCell"
    let operationTableViewDesignCellIdentifier = "OperationDesignCell"
    let operationTableViewCleanDesignCellIdentifier = "OperationCleanDesignCell"
    let emptyListTableViewCellIdentifier = "emptyOperationsListCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let filterCollectionViewCellIdentifier = "filterCell"
    let tableViewSectionHeaderHeight: CGFloat = 55
    let tableViewRowHeight: CGFloat = 100
    let filterPeriod: Presenter.DateFilterUnit = .days
    var upperBound: Double = 0.0
    private var buttonSelector: ButtonSelectorView!
    private weak var timer: Timer?
    var loadingView: LoadingView?
    
    let presenter = Presenter()
    lazy var operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod)
    var tableViewScrollOffset: CGFloat = 0 {
        willSet { lastButOneTableViewScrollOffset = tableViewScrollOffset }
    }
    var lastButOneTableViewScrollOffset: CGFloat = 0
    lazy var mainCurrency: Currency = presenter.settings.currencies.first ?? .rub
    
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

    // MARK: Working with data functions
    
    private func applyFilter() {
        if appliedFilterCells.count == 1 {
            let filterUnit = arrayOfAllFilterUnits[appliedFilterCells.first!.row]
            switch filterUnit {
            case .all:
                operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod)
                mainCurrency = presenter.settings.currencies.first ?? .rub
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
        if ops.isEmpty { return }
        let upperBoundConstant = 0.15
        let index = Int(Double(ops.count - 1) * (1.0 - upperBoundConstant))
        upperBound = ops[index]
    }
    
    func updateData() {
        presenter.syncronize()
        countUpperBound()
        applyFilter()
    }
    
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonSelector()
        
        if var cloudSource = MainData.source as? CloudOperationDataSource {
            cloudSource.delegate = self
            if !cloudSource.isDownloadComplete {
//                tableView.isHidden = true
                showLoadingView(withProcessName: "Загрузка", animated: false)
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
    
    // MARK: Button selector
    
    @objc func addOperation() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        performSegue(withIdentifier: addOperationSegueIdentifier, sender: self)
        buttonSelector.close(animated: false)
    }
    @objc func addSomeOperations() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        performSegue(withIdentifier: addSomeOperationsSegueIdentidier, sender: self)
        buttonSelector.close(animated: false)
    }
    
    private func addButtonSelector() {
        let button1 = UIButton(frame: CGRect.zero)
        let button2 = UIButton(frame: CGRect.zero)
        let button3 = UIButton(frame: CGRect.zero)
        button1.addTarget(self, action: #selector(addOperation), for: .touchUpInside)
        button2.addTarget(self, action: #selector(addSomeOperations), for: .touchUpInside)
        button1.backgroundColor = .clear
        button2.backgroundColor = .clear
        button3.backgroundColor = .clear
        if let image = UIImage(named: "plus_icon.png") { button1.setImage(image, for: .normal) }
        if let image = UIImage(named: "camera_icon.png") { button2.setImage(image, for: .normal) }
        if let image = UIImage(named: "list_icon.png") { button3.setImage(image, for: .normal) }
        
        let size = CGSize(width: view.bounds.width/6, height: view.bounds.width/5)
        let origin = CGPoint(x: view.bounds.maxX - size.width - 20, y: view.bounds.maxY - size.height - 70)
        let frameForView = CGRect(origin: origin, size: size)
        
        let buttonSelector = ButtonSelectorView(frame: frameForView, buttons: [button3, button2, button1])
        buttonSelector.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        buttonSelector.direction = .left
        buttonSelector.mainButton.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
        if let image = UIImage(named: "plus_icon_white.png") {
            buttonSelector.mainButton.setImage(image, for: .normal)
        }
        
        buttonSelector.delegate = self
        self.buttonSelector = buttonSelector
        view.addSubview(buttonSelector)
    }
    
   // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == addOperationSegueIdentifier {
                if let navVC = segue.destination as? UINavigationController {
                    if let vc = navVC.viewControllers[0] as? AddOperationViewController {
                        vc.delegate = self
                    }
                }
            }
        }
    }
}

// MARK: ButtonSelector delegate

extension OperationsViewController: ButtonSelectorViewDelegate {
    func buttonSelectorOpened(sender: ButtonSelectorView, animated: Bool) {
        if animated {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
                self?.buttonSelector.close(animated: true)
            }
        }
    }
    
    func buttonSelectorClosed(sender: ButtonSelectorView, animated: Bool) {
        if animated {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        timer?.invalidate()
    }
}

// MARK: Handling cloud data sources

extension OperationsViewController: CloudDataSourceDelegate {
    
    var downloadProgress: Double {
        get { return 0 }
        set {
            if loadingView == nil { showLoadingView(withProcessName: "Загрузка", animated: true) }
            var progress = (100*newValue).rounded()
            if progress.isNaN { progress = 100.0 }
            print("Download operations: \(Int(progress)) %")
            loadingView?.mainLabel.text = "Загрузка  \(Int(progress))%"
//            progressView.isHidden = false
//            progressView.progress = Float(newValue)
        }
    }
    var uploadProgress: Double {
        get { return 0 }
        set {
            if loadingView == nil { showLoadingView(withProcessName: "Сохранение", animated: true) }
            var progress = (100*newValue).rounded()
            if progress.isNaN { progress = 100.0 }
            print("Upload operations: \(Int(progress)) %")
            loadingView?.mainLabel.text = "Cохранение  \(Int(progress))%"
//            progressView.isHidden = false
//            progressView.progress = Float(newValue)
        }
    }
    
    func uploadComplete(with error: Error?) {
//        progressView.isHidden = true
        removeLoadingView()
    }
    func downloadComplete(with error: Error?) {
        // reset and reload Data
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.countUpperBound()
            self?.applyFilter()
//            self?.progressView.isHidden = trueы
            self?.tableView.isHidden = false
            self?.removeLoadingView()
        }
    }
    
    private func showLoadingView(withProcessName name: String, animated: Bool = true) {
        loadingView = LoadingView(superview: self.view)
        tabBarController?.tabBar.isHidden = true
        loadingView!.mainLabel.text = name
        loadingView!.breakButton.setTitle("Прервать", for: .normal)
        loadingView!.breakAction = { [weak self] in
            (MainData.source as? CloudOperationDataSource)?.cancelLoading()
            (MainData.settings as? CloudSettingsDataSource)?.cancelLoading()
            (MainGenerator.generator as? CloudIDGenerator)?.cancelLoading()
            self?.removeLoadingView()
        }
        loadingView!.appear(animated: animated)
    }
    private func removeLoadingView(animated: Bool = true) {
        tabBarController?.tabBar.isHidden = false
        loadingView?.remove(animated: animated, duration: 0.4)
        loadingView = nil
    }
}

// MARK: Service entities

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

