//
//  TestViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, ImagePickerCollectionViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var loadedPhotos = [UIImage]() { didSet { startRecognition() }}
    
    let operationTableViewDesignCellIdentifier = "OperationDesignCell"
    let emptyListTableViewCellIdentifier = "emptyOperationsListCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let tableViewSectionHeaderHeight: CGFloat = 35
    let tableViewRowHeight: CGFloat = 100
    let filterPeriod: Presenter.DateFilterUnit = .days
    var upperBound: Double = 0.0
    let mainCurrency = Currency.rub
    
    lazy var operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod, operations: recognizedOps)
    private let presenter = Presenter()
    private lazy var recognizer = OperationVisionRecognizer()
    private var recognizedOps = [Operation]()
    private var recognitionCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        countUpperBound()
        
    }
    
    private func startRecognition() {
        print("start recognition with \(loadedPhotos.count) photos")
        
        for image in loadedPhotos {
            recognizer.recognize(from: image) { [weak self] operations, error in
                if let ops = operations {
                    self?.recognizedOps += ops
                }
                if self != nil {
                    let number = self!.recognitionCounter + 1
                    print("recognizing #\(number) finished")
                    self?.recognitionCounter += 1
                    if self!.recognitionCounter == self!.loadedPhotos.count {
                        self!.loadOps()
                    }
                }
            }
        }
        
    }
    
    private func loadOps() {
        print(recognizedOps)
        //                removeDuplicateOperations()
        operationsByDays = presenter.operationsSorted(byFormatted: filterPeriod, operations: recognizedOps)
        tableView.reloadData()
        recognitionCounter = 0
    }
    
    private func countUpperBound() {
        let ops = presenter.all().map({ abs($0.value) }).sorted(by: <)
        if ops.isEmpty { return }
        let upperBoundConstant = 0.15
        let index = Int(Double(ops.count - 1) * (1.0 - upperBoundConstant))
        upperBound = ops[index]
    }
    
    private func removeDuplicateOperations() {
        var indicesToBeRemoved = [Int]()
        for op1 in recognizedOps {
            for (index, op2) in recognizedOps.enumerated() {
                if op1.id != op2.id {
                    if op1.value == op2.value &&
                        op1.account == op2.account &&
                        op1.currency == op2.currency &&
                        op1.date == op2.date {
                        if !indicesToBeRemoved.contains(index) {
                            indicesToBeRemoved.append(index)
                        }
                    }
                }
            }
        }
        indicesToBeRemoved.forEach { recognizedOps.remove(at: $0) }
        print("removed \(indicesToBeRemoved.count) operations")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let vc = navVC.viewControllers[0] as? ImagePickerCollectionViewController {
                vc.delegate = self
            }
        }
    }
    
    
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource  {
    
    private var operationListIsEmpty: Bool {
        return operationsByDays.isEmpty
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operationListIsEmpty ? 1 : operationsByDays[section].ops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if operationListIsEmpty { return tableView.dequeueReusableCell(withIdentifier: emptyListTableViewCellIdentifier)! }
        
        let operation = operationsByDays[indexPath.section].ops[indexPath.row]
        let operationPresenter = OperationPresenter(operation)
        let cell = tableView.dequeueReusableCell(withIdentifier: operationTableViewDesignCellIdentifier, for: indexPath) as! OperationsDesignedTableViewCell
        
        cell.valueLabel.text = operationPresenter.valueString
        cell.mainLabel.text = operationPresenter.categoryString ?? operationPresenter.contactString
        cell.accountLabel.text = operationPresenter.accountString
        cell.commentLabel.text = operationPresenter.commentString
        cell.measureValue = CGFloat(abs(operation.value) / upperBound)
        
        switch operation {
        case _ where operation is DebtOperation:
            cell.measureColor = #colorLiteral(red: 0.4, green: 0.462745098, blue: 0.9490196078, alpha: 1)
        case _ where operation is FlowOperation && (operation.value >= 0.0):
            cell.measureColor = #colorLiteral(red: 0.7725490196, green: 0.8784313725, blue: 0.7058823529, alpha: 1)
        case _ where operation is FlowOperation && (operation.value < 0.0):
            cell.measureColor = #colorLiteral(red: 0.9568627451, green: 0.6941176471, blue: 0.5137254902, alpha: 1)
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return operationListIsEmpty ? 1 : operationsByDays.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if operationListIsEmpty { return nil }
        let header = tableView.dequeueReusableCell(withIdentifier: operationsHeaderTableViewCellIdentifier) as! OperationsHeaderTableViewCell
        header.periodLabel.text = operationsByDays[section].formattedPeriod
        let sum = operationsByDays[section].ops.valuesSum(mainCurrency)
        header.sumLabel.text = (sum > 0 ? "+" : "") + sum.currencyFormattedDescription(mainCurrency)
        
        return header.contentView
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let idOfOperationsToRemove = operationsByDays[indexPath.section].ops.remove(at: indexPath.row).id
            print(idOfOperationsToRemove)
            presenter.removeOperationWith(identifier: idOfOperationsToRemove)
            tableView.deleteRows(at: [indexPath], with: .fade)
//            presenter.syncronize()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

}


