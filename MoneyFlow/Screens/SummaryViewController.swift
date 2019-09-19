//
//  SummaryViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 15/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var chartView: ChartView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mainMoneyAmountSmallLabel: UILabel!
    @IBOutlet weak var mainMoneyAmountBigLabel: UILabel!
    
    @IBOutlet weak var mainHeaderView: UIView!
    @IBOutlet weak var mounthLabel: UILabel!
    @IBOutlet weak var monthMoneyAmountSmallLabel: UILabel!
    @IBOutlet weak var monthMoneyAmountBigLabel: UILabel!
    
    @IBOutlet weak var week1Label: UILabel!
    @IBOutlet weak var week2Label: UILabel!
    @IBOutlet weak var week3Label: UILabel!
    @IBOutlet weak var week4Label: UILabel!
    @IBOutlet weak var week1ResultLabel: UILabel!
    @IBOutlet weak var week2ResultLabel: UILabel!
    @IBOutlet weak var week3ResultLabel: UILabel!
    @IBOutlet weak var week4ResultLabel: UILabel!
    
    private let presenter = SettingsPresenter.shared
    private let summaryCellIdentifier = "summaryCell"
    private let summaryGraphCellIdentifier = "summaryGraphCell"
    let summaryHeaderCellIdentifier = "summaryHeader"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        chartView.delegate = self
        chartView.minValueLabel.text = "0"
        chartView.midValueLabel.text = "50K"
        self.chartView.measureLinesColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.5)
        mainHeaderView.addRoundedRectMask()
        
        
        let presenter = SummaryPresenter()
        print("\n")
        print(presenter.periodsStringFor(month: "Сентябрь"))

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func presentationTypeButtonTouched(_ sender: UIButton) {
        // TODO: change bool false and reaload tableView
    }
    func chartView(didSelectColumnAt index: Int) {
        print("Selected in \(index)")
    }
    
    func chartViewNumberOfColumns() -> Int {
        return 12
    }
    
    func chartView(labelForColumnAt index: Int) -> String {
        return "Dec"
    }
    
    func chartView(mainValueForColumnAt index: Int) -> CGFloat {
        return CGFloat(Double.random(in: 0.1...0.8))
    }
    
    func chartView(secondValueForColumnAt index: Int) -> CGFloat? {
        return CGFloat(Double.random(in: 0.4...1.0))
    }
}

private extension UIView {
    func addRoundedRectMask() {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 20.0, height: 25.0))
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        layer.mask = shape
    }
}

extension SummaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return presenter.incomeCategories.count + 1
        case 1: return presenter.outcomeCategories.count + 1
        case 2: return 2 + 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let header = tableView.dequeueReusableCell(withIdentifier: summaryHeaderCellIdentifier) as! SummaryHeaderTableViewCell
            header.layoutIfNeeded()
            return header
        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: summaryCellIdentifier, for: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: summaryGraphCellIdentifier, for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case _ where cell is SummaryHeaderTableViewCell:
            let header = cell as! SummaryHeaderTableViewCell
            switch indexPath.section {
            case 0: header.leftLabel.text = "Доходы"
            case 1: header.leftLabel!.text = "Расходы"
            case 2: header.leftLabel!.text = "Долги"
            default: break
            }
            header.rightLabel.text = Double.random(in: 8000...120000).currencyFormattedDescription(.rub)
//            header.layoutIfNeeded()
        
        case _ where cell is  SummaryTableViewCell:
            let cell = cell as! SummaryTableViewCell
            switch indexPath.section {
            case 0: cell.titleLabel.text = presenter.incomeCategories[indexPath.row-1]
            case 1: cell.titleLabel.text = presenter.outcomeCategories[indexPath.row-1]
            case 2: cell.titleLabel.text = indexPath.row-1 == 0 ? "Я должен" : "Мне должны"
            default: break
            }
            cell.value1Label.text = formattedString(from: Double.random(in: 0...120000))
            cell.value2Label.text = formattedString(from: Double.random(in: 0...120000))
            cell.value3Label.text = formattedString(from: Double.random(in: 0...120000))
            cell.value4Label.text = formattedString(from: Double.random(in: 0...120000))
       
        case _ where cell is  SummaryGraphTableViewCell:
            let cell = cell as! SummaryGraphTableViewCell
            switch indexPath.section {
            case 0: cell.titleLabel.text = presenter.incomeCategories[indexPath.row-1]
            case 1: cell.titleLabel.text = presenter.outcomeCategories[indexPath.row-1]
            case 2: cell.titleLabel.text = indexPath.row-1 == 0 ? "Я должен" : "Мне должны"
            default: break
            }
            cell.graph1.value = CGFloat.random(in: 0.0...0.9)
            cell.graph1.backgroundColor = colorFor(value: cell.graph1.value)
            
            cell.graph2.value = CGFloat.random(in: 0.0...0.9)
            cell.graph2.backgroundColor = colorFor(value: cell.graph2.value)
            
            cell.graph3.value = CGFloat.random(in: 0.0...0.9)
            cell.graph3.backgroundColor = colorFor(value: cell.graph3.value)
            
            cell.graph4.value = CGFloat.random(in: 0.0...0.9)
            cell.graph4.backgroundColor = colorFor(value: cell.graph4.value)
            
            cell.isItFirtsLine = indexPath.row-1 == 0
            cell.isItLastLine = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            cell.layoutIfNeeded()
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    // 1 159 678 - 967
    private func formattedString(from value: Double) -> String {
        let intValue = Int(value)
        switch intValue {
        case _ where intValue < 1000: return "\(intValue)"
        case _ where intValue < 100_000:
            var result = "\(intValue / 1000)" + "."
            let remainder = Int(round(Double(intValue % 1000), toNearest: 10))/10
            result += "\(remainder)к"
            return result
            
        case _ where intValue < 1_000_000:
            var result = "\(intValue / 1000)" + "."
            let remainder = Int(round(Double(intValue % 1000), toNearest: 100))/100
            result += "\(remainder)к"
            return result
        default:
            let valueRoundedToK = round(Double(intValue), toNearest: 1000)/1000
            return formattedString(from: valueRoundedToK) + "к"
        }
    }
    
    private func round(_ value: Double, toNearest: Double) -> Double {
        return (value / toNearest).rounded() * toNearest
    }
    
    private func colorFor(value: CGFloat) -> UIColor {
        switch value {
        case 0.0: return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        case ..<0.4: return #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        case 0.4..<0.6: return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        case 0.6...: return #colorLiteral(red: 0.4210376198, green: 0.5571454009, blue: 0.3162501818, alpha: 1)
        default: return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
}
