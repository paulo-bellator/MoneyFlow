//
//  AddingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 22/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

protocol AddingViewControllerDelegate: class {
    func addedOperations(_ operations: [Operation])
}

class AddingViewController: UIViewController, ImagePickerCollectionViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftButtonsSubstrateView: UIView!
    @IBOutlet weak var rightButtonsSubstrateView: UIView!
    @IBOutlet weak var recognizeButton: UIButton!
    @IBOutlet weak var recognizingActivityIndicator: UIActivityIndicatorView!
    
    var loadedPhotos = [UIImage]() {
        didSet {
            startRecognition()
            if !loadedPhotos.isEmpty {
                recognizeButton.isHidden = true
                recognizingActivityIndicator.isHidden = false
                recognizingActivityIndicator.startAnimating()
            }
        }
    }
    
    let addOperationSegueIdentifier = "AddOperation"
    let recognizeOperationsSegueIdentifier = "recognizeOperations"
    let operationTableViewCellIdentifier = "OperationCleanDesignCell"
    let emptyListTableViewCellIdentifier = "emptyOperationsListCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let operationTransferTableViewCellIdentifier = "AddedOperationTransferCell"
    let tableViewSectionHeaderHeight: CGFloat = 55
    let tableViewRowHeight: CGFloat = 100
    let filterPeriod: Presenter.DateFilterUnit = .days
    let mainCurrency = Currency.rub
    var indexPathToScroll: IndexPath?
    var mode: AddingViewControllerMode = .none
    weak var delegate: AddingViewControllerDelegate?
    
    lazy var operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod, operations: operations)
    private let presenter = Presenter()
    private lazy var recognizer = OperationVisionRecognizer()
    private var recognizedOps = [Operation]()
    private var operations = [Operation]()
    private var recognitionCounter = 0
    private var lastUsedDate: Date?
    
    
    @IBAction func backButtonTouched(_ sender: UIButton) { dismiss(animated: true) }
    @IBAction func saveButtonTouched(_ sender: UIButton) { delegate?.addedOperations(operations); dismiss(animated: true) }
    @IBAction func addOperationButtonTouched(_ sender: UIButton) {}
    @IBAction func recognizeOperationsButtonTouched(_ sender: UIButton) {}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizingActivityIndicator.isHidden = true
        let radius = CGSize(width: leftButtonsSubstrateView.bounds.height/2.0, height: leftButtonsSubstrateView.bounds.height/2.0)
        leftButtonsSubstrateView.layer.cornerRadius = leftButtonsSubstrateView.bounds.height/2.0
        rightButtonsSubstrateView.layer.cornerRadius = rightButtonsSubstrateView.bounds.height/2.0
        leftButtonsSubstrateView.addRoundedShadow(corners: .allCorners, radius: radius)
        rightButtonsSubstrateView.addRoundedShadow(corners: .allCorners, radius: radius)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch mode {
        case .none: break
        case .add:
            performSegue(withIdentifier: addOperationSegueIdentifier, sender: nil)
            mode = .none
        case .recognize:
            performSegue(withIdentifier: recognizeOperationsSegueIdentifier, sender: nil)
            mode = .none
        }
    }
    
    private func addAndSave() {
        operations.forEach { presenter.add(operation: $0) }
        presenter.syncronize()
    }
    
    func deleteOperation(with identifier: Int) {
        operations = operations.filter { $0.id != identifier }
    }
    
    private func updateTableView() {
        operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod, operations: operations)
        tableView.reloadData()
    }
    
    private func startRecognition() {
        print("start recognition with \(loadedPhotos.count) photos")
        
        for image in loadedPhotos {
            recognizer.recognize(from: image) { [weak self] operations, error in
                if self != nil {
                    if let ops = operations {
                        self!.recognizedOps = self!.sumWithoutDuplicate(baseArray: self!.recognizedOps, addingArray: ops)
                    }
                    
                    self!.recognitionCounter += 1
                    let number = self!.recognitionCounter
                    print("recognizing #\(number) finished")
                    
                    if self!.recognitionCounter == self!.loadedPhotos.count {
                        self!.loadOps()
                    }
                }
            }
        }
        
    }
    
    private func loadOps() {
        print(recognizedOps)
        recognizingActivityIndicator.stopAnimating()
        recognizeButton.isHidden = false
        
        checkAndReplaceCategoriesIfNeeded()
        operations = sumWithoutDuplicate(baseArray: operations, addingArray: recognizedOps)
        updateTableView()
        recognitionCounter = 0
    }
    
    
    // replace recognized catagories with existing (if such as pattern exist)
    // otherwise add new pattern with new raw category
    private func checkAndReplaceCategoriesIfNeeded() {
        var patternFound = false
        for op in recognizedOps {
            if let flowOp = op as? FlowOperation {
                patternFound = false
                for pattern in presenter.settings.categoryPatterns {
                    if pattern.type == (flowOp.value < 0 ? .outcome : .income) && pattern.rawValue == flowOp.category {
                        flowOp.category = pattern.existingCategory ?? flowOp.category
                        patternFound = true
                        break;
                    }
                }
                if !patternFound {
                    let newPattern = OperationCategoryPattern(rawValue: flowOp.category, type: (flowOp.value < 0 ? .outcome : .income))
                    presenter.settings.categoryPatterns.append(newPattern)
                }
            }
        }
    }
    
    
    private func sumWithoutDuplicate(baseArray: [Operation], addingArray: [Operation]) -> [Operation] {
        var duplicateIndices = [Int]()
        for op1 in baseArray {
            for (index, op2) in addingArray.enumerated() {
                if op1.value == op2.value &&
                    op1.account == op2.account &&
                    op1.currency == op2.currency &&
                    op1.date == op2.date {
                    if !duplicateIndices.contains(index) {
                        duplicateIndices.append(index)
                    }
                }
            }
        }
        debugPrint("removed \(duplicateIndices.count) duplicates")
        let sum = baseArray + addingArray.enumerated().compactMap { duplicateIndices.contains($0.offset) ? nil : $0.element }
        return sum
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let vc = navVC.viewControllers[0] as? ImagePickerCollectionViewController {
                vc.delegate = self
            }
            if let vc = navVC.viewControllers[0] as? AddOperationViewController {
                vc.delegate = self
                if let indexPath = sender as? IndexPath {
                    vc.operationToBeEditted = operationsByDays[indexPath.section].ops[indexPath.row]
                } else if let date = lastUsedDate {
                    vc.dateToBeSet = date + 1*60
                }
            }
        }
    }
    
    enum AddingViewControllerMode { case add, recognize, none }
}

extension AddingViewController: AddOperationViewControllerDelegate {
    func addedOperation(_ operation: Operation) {
        operations.append(operation)
        updateTableView()
        lastUsedDate = operation.date
    }
    func editedOperation(_ operation: Operation) {
        let specialField = ((operation as? FlowOperation)?.category ?? (operation as? DebtOperation)?.contact) ?? (operation as? TransferOperation)?.destinationAccount
        let comment: String? = (operation as? FlowOperation)?.comment ?? (operation as? DebtOperation)?.comment
        for op in operations {
            if op.id == operation.id {
                if let flowOp = operation as? FlowOperation {
                    flowOp.date = operation.date
                    flowOp.value = operation.value
                    flowOp.currency = operation.currency
                    flowOp.category = specialField ?? ""
                    flowOp.account = operation.account
                    flowOp.comment = comment
                } else if let debtOp = operation as? DebtOperation {
                    debtOp.date = operation.date
                    debtOp.value = operation.value
                    debtOp.currency = operation.currency
                    debtOp.contact = specialField ?? ""
                    debtOp.account = operation.account
                    debtOp.comment = comment
                } else if let transferOp = operation as? TransferOperation {
                    transferOp.date = operation.date
                    transferOp.value = operation.value
                    transferOp.currency = operation.currency
                    transferOp.account = operation.account
                    transferOp.destinationAccount = specialField ?? ""
                }
            }
            break
        }
        updateTableView()
        lastUsedDate = operation.date
        // это крашит приложение когда я меняю дату у последней операции в секции
        //        if let indexPath = indexPathToScroll {
        //            tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        //            indexPathToScroll = nil
        //        }
    }
}

extension UIView {
    func addRoundedShadow(corners: UIRectCorner, radius: CGSize) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(roundedRect:bounds, byRoundingCorners: corners, cornerRadii: radius).cgPath
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        layer.shadowRadius = max(radius.width, radius.height)
    }
    func removeShadow() {
        layer.shadowPath = nil
        layer.shadowColor = UIColor.clear.cgColor
        
    }
}

