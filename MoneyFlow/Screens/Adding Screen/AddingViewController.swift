//
//  AddingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 22/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class AddingViewController: UIViewController, ImagePickerCollectionViewControllerDelegate, AddOperationViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftButtonsSubstrateView: UIView!
    @IBOutlet weak var rightButtonsSubstrateView: UIView!
    
    var loadedPhotos = [UIImage]() { didSet { startRecognition() }}
    
    let operationTableViewCellIdentifier = "OperationCleanDesignCell"
    let emptyListTableViewCellIdentifier = "emptyOperationsListCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let tableViewSectionHeaderHeight: CGFloat = 55
    let tableViewRowHeight: CGFloat = 100
    let filterPeriod: Presenter.DateFilterUnit = .days
    let mainCurrency = Currency.rub
    
    lazy var operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod, operations: operations)
    private let presenter = Presenter()
    private lazy var recognizer = OperationVisionRecognizer()
    private var recognizedOps = [Operation]()
    private var operations = [Operation]()
    private var recognitionCounter = 0
    
    
    
    @IBAction func backButtonTouched(_ sender: UIButton) { dismiss(animated: true) }
    @IBAction func saveButtonTouched(_ sender: UIButton) { addAndSave(); dismiss(animated: true) }
    @IBAction func addOperationButtonTouched(_ sender: UIButton) {
    }
    @IBAction func recognizeOperationsButtonTouched(_ sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let radius = CGSize(width: leftButtonsSubstrateView.bounds.height/2.0, height: leftButtonsSubstrateView.bounds.height/2.0)
        leftButtonsSubstrateView.layer.cornerRadius = leftButtonsSubstrateView.bounds.height/2.0
        rightButtonsSubstrateView.layer.cornerRadius = rightButtonsSubstrateView.bounds.height/2.0
        leftButtonsSubstrateView.addRoundedShadow(corners: .allCorners, radius: radius)
        rightButtonsSubstrateView.addRoundedShadow(corners: .allCorners, radius: radius)
        
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.sectionHeaderHeight = tableViewSectionHeaderHeight
    }
    
    private func addAndSave() {
        operations.forEach { presenter.add(operation: $0) }
        presenter.syncronize()
    }
    
    func addedOperation(_ operation: Operation) {
        operations.append(operation)
        updateTableView()
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
                    
                    let number = self!.recognitionCounter + 1
                    print("recognizing #\(number) finished")
                    self!.recognitionCounter += 1
                    if self!.recognitionCounter == self!.loadedPhotos.count {
                        self!.loadOps()
                    }
                }
            }
        }
        
    }
    
    private func loadOps() {
        print(recognizedOps)
        operations = sumWithoutDuplicate(baseArray: operations, addingArray: recognizedOps)
        updateTableView()
        recognitionCounter = 0
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
            }
        }
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

