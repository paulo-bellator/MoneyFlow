//
//  ViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import Firebase

class OperationsViewController: UIViewController, AddOperationViewControllerDelegate, AddingViewControllerDelegate, UpdatableViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var tableViewTopSafeAreaTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: Properties
    
    let addOperationSegueIdentifier = "ShowAddOperation"
    let recognizeOperationsSegueIdentidier = "addSomeOperations"
    let addSomeOperationsSegueIdentidier = "addingVCSegue"
    let operationTableViewCellIdentifier = "OperationCell"
    let operationTableViewDesignCellIdentifier = "OperationDesignCell"
    let operationTableViewCleanDesignCellIdentifier = "OperationCleanDesignCell"
    let emptyListTableViewCellIdentifier = "emptyOperationsListCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let filterCollectionViewCellIdentifier = "filterCell"
    let operationTransferTableViewCellIdentifier = "OperationTransferCell"
    let tableViewSectionHeaderHeight: CGFloat = 55
    let tableViewRowHeight: CGFloat = 100
    let filterPeriod: Presenter.DateFilterUnit = .days
    var upperBound: Double = 0.0
    private var buttonSelector: ButtonSelectorView!
    private weak var timer: Timer?
    var loadingView: LoadingView?
    fileprivate let loadManager = DataSourceLoadManager.shared
    var indexPathToScroll: IndexPath?
    var needToUpdate: Bool = false
    
    let presenter = Presenter()
    lazy var operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod)
    var tableViewScrollOffset: CGFloat = 0 {
        willSet { lastButOneTableViewScrollOffset = tableViewScrollOffset }
    }
    var lastButOneTableViewScrollOffset: CGFloat = 0
    lazy var mainCurrency: Currency = presenter.settings.enabledCurrencies.first ?? .rub
    
    var appliedFilterCells = [IndexPath(row: 0, section: 0)] {
        didSet { applyFilter() }
    }
    
    lazy var arrayOfAllFilterUnits: [FilterUnit] = {
        var result = [FilterUnit]()
        
        result.append(FilterUnit.all("Все"))
        for currency in presenter.settings.enabledCurrenciesSignesSorted { result.append(FilterUnit.currency(currency)) }
        for account in presenter.settings.enabledAccountsSorted { result.append(FilterUnit.account(account)) }
        for category in presenter.settings.allEnabledCategoriesSorted { result.append(FilterUnit.category(category)) }
        for contact in presenter.settings.enabledContactsSorted { result.append(FilterUnit.contact(contact)) }
        
        return result
    }()

    // MARK: Working with data functions
    
    private func applyFilter() {
        if appliedFilterCells.count == 1 {
            let filterUnit = arrayOfAllFilterUnits[appliedFilterCells.first!.row]
            switch filterUnit {
            case .all:
                operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod)
                mainCurrency = presenter.settings.enabledCurrencies.first ?? .rub
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
        default: mainCurrency = presenter.settings.enabledCurrencies.first!
        }
        
        reloadTableView()
    }
    
    private func reloadTableView() {
        tableView.reloadData()
        tableView.contentOffset.y = 0.0
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        tableViewScrollOffset = 0
    }
    
    fileprivate func reloadFilterCollectionView() {
        var result = [FilterUnit]()
        
        result.append(FilterUnit.all("Все"))
        for currency in presenter.settings.enabledCurrenciesSignesSorted { result.append(FilterUnit.currency(currency)) }
        for account in presenter.settings.enabledAccountsSorted { result.append(FilterUnit.account(account)) }
        for category in presenter.settings.allEnabledCategoriesSorted { result.append(FilterUnit.category(category)) }
        for contact in presenter.settings.enabledContactsSorted { result.append(FilterUnit.contact(contact)) }
        
        arrayOfAllFilterUnits = result
        collectionView.reloadData()
        needToUpdate = false
    }
    
    private func countUpperBound() {
        let ops = presenter.all().map({ abs($0.value) }).sorted(by: <)
        if ops.isEmpty { return }
        let upperBoundConstant = 0.15
        let index = Int(Double(ops.count - 1) * (1.0 - upperBoundConstant))
        upperBound = ops[index]
    }
    
    func addedOperation(_ operation: Operation) {
        presenter.add(operation: operation)
        updateData()
    }
    func addedOperations(_ operations: [Operation]) {
        operations.forEach { presenter.add(operation: $0) }
        updateData()
    }
    func editedOperation(_ operation: Operation) {
        let specialField: String
        switch operation {
        case let flowOp as FlowOperation: specialField = flowOp.category
        case let debtOp as DebtOperation: specialField = debtOp.contact
        case let transferOp as TransferOperation: specialField = transferOp.destinationAccount
        default: specialField = ""
        }
        let comment: String? = (operation as? FlowOperation)?.comment ?? (operation as? DebtOperation)?.comment
        presenter.editOperation(
            with: operation.id,
            date: operation.date,
            value: operation.value,
            currency: operation.currency,
            account: operation.account,
            comment: comment,
            specialField: specialField)
        updateData()
        
        // это крашит приложение когда меняю дату у последнец операции в секции
//        if let indexPath = indexPathToScroll {
//            tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
//            indexPathToScroll = nil
//        }
    }
    
    func updateData() {
        loadManager.newSession()
        presenter.syncronize()
        countUpperBound()
        applyFilter()
        sendUpdateRequirementToVCs() 
    }
    
    func sendUpdateRequirementToVCs() {
        if let tabVC = tabBarController {
            for vc in tabVC.viewControllers ?? [] {
                if var updatableVC = vc as? UpdatableViewController {
                    updatableVC.needToUpdate = true
                }
            }
        }
    }
    
    @IBAction func repeatDownloadButtonTouched(_ sender: UIButton) {
        loadManager.updateData()
        if !loadManager.isDownloadComplete {
            showLoadingView(withProcessName: "Загрузка", animated: true)
        }
    }
    
    
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Operations ViewDidLoad")
        needToUpdate = false
        addButtonSelector()
        
        print(loadManager.isDownloadComplete)
        if loadManager.isCloudDataSource && GlobalConstants.CloudDataSource.isFirstLoad {
//        if !loadManager.isDownloadComplete {
            showLoadingView(withProcessName: "Загрузка", animated: false)
            tableView.isHidden = true
            collectionView.isHidden = true
            buttonSelector.isHidden = true
        }
        
        progressView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = tableViewSectionHeaderHeight
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Operations ViewWillAppear")
        loadManager.delegate = self
        if loadManager.isDownloadComplete {
            removeLoadingView()
            loadManager.newSession()
        }
        if needToUpdate {
            reloadFilterCollectionView()
            appliedFilterCells = [IndexPath(row: 0, section: 0)]
        }
    }
    
    // MARK: Button selector
    
    @objc func addOperation() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        performSegue(withIdentifier: addOperationSegueIdentifier, sender: self)
        buttonSelector.close(animated: false)
    }
    @objc func recognizeOperations() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let mode: AddingViewController.AddingViewControllerMode = .recognize
        performSegue(withIdentifier: addSomeOperationsSegueIdentidier, sender: mode)
        buttonSelector.close(animated: false)
    }
    @objc func addFewOperations() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let mode: AddingViewController.AddingViewControllerMode = .add
        performSegue(withIdentifier: addSomeOperationsSegueIdentidier, sender: mode)
        buttonSelector.close(animated: false)
    }
    
    private func addButtonSelector() {
        let button1 = UIButton(frame: CGRect.zero)
        let button2 = UIButton(frame: CGRect.zero)
        let button3 = UIButton(frame: CGRect.zero)
        button1.addTarget(self, action: #selector(addOperation), for: .touchUpInside)
        button2.addTarget(self, action: #selector(recognizeOperations), for: .touchUpInside)
        button3.addTarget(self, action: #selector(addFewOperations), for: .touchUpInside)
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
                        if let indexPath = sender as? IndexPath {
                            vc.operationToBeEditted = operationsByDays[indexPath.section].ops[indexPath.row]
                        }
                    }
                }
            } else if let vc = segue.destination as? AddingViewController {
                vc.delegate = self
                if let mode = sender as? AddingViewController.AddingViewControllerMode {
                    vc.mode = mode
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

extension OperationsViewController: DataSourceLoadManagerDelegate {
    var downloadProgress: Double {
        get { return 0 }
        set {
            if loadingView == nil {
                showLoadingView(withProcessName: "Загрузка", animated: true)
                tableView.isHidden = true
                collectionView.isHidden = true
                buttonSelector.isHidden = true
            }
            var progress = (100*newValue).rounded()
            if progress.isNaN { progress = 100.0 }
            print("Downloading: \(Int(progress)) %")
            loadingView?.mainLabel.text = "Загрузка  \(Int(progress))%"
        }
    }
    var uploadProgress: Double {
        get { return 0 }
        set {
            if loadingView == nil { showLoadingView(withProcessName: "Сохранение", animated: true) }
            var progress = (100*newValue).rounded()
            if progress.isNaN { progress = 100.0 }
            print("Uploading: \(Int(progress)) %")
            loadingView?.mainLabel.text = "Cохранение  \(Int(progress))%"
        }
    }
    func uploadComplete(with error: Error?) { removeLoadingView() }
    func downloadComplete(with error: Error?) {
        if let error = error, !error.localizedDescription.contains("does not exist.") {
            errorLabel.text = "Loading error occured: \n\(error.localizedDescription)"
            removeLoadingView()
            
        } else {
            showLoadedData()
        }
    }
    
    private func showLoadedData() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.countUpperBound()
            self?.reloadFilterCollectionView()
            self?.applyFilter()
            self?.tableView.isHidden = false
            self?.collectionView.isHidden = false
            self?.buttonSelector.isHidden = false
            self?.sendUpdateRequirementToVCs()
            self?.removeLoadingView()
        }
    }
    private func showLoadingView(withProcessName name: String, animated: Bool = true) {
        loadingView = LoadingView(superview: self.view)
        tabBarController?.tabBar.isHidden = true
        loadingView!.mainLabel.text = name
        loadingView!.breakButton.setTitle("Прервать", for: .normal)
        loadingView!.breakAction = { [weak self] in
            self?.loadManager.cancelLoading()
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

