//
//  SummaryViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 15/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {

    @IBOutlet weak var chartView: ChartView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mainMoneyAmountSmallLabel: UILabel!
    @IBOutlet weak var mainMoneyAmountBigLabel: UILabel!
    
    @IBOutlet weak var mainHeaderView: UIView!
    @IBOutlet weak var mounthLabel: UILabel!
    @IBOutlet weak var monthMoneyAmountSmallLabel: UILabel!
    @IBOutlet weak var monthMoneyAmountBigLabel: UILabel!
    
    @IBOutlet var weekLabels: [UILabel]!
    @IBOutlet var weekResultLabels: [UILabel]!
    
    let presenter = SummaryPresenter()
    let summaryCellIdentifier = "summaryCell"
    let summaryGraphCellIdentifier = "summaryGraphCell"
    let summaryHeaderCellIdentifier = "summaryHeader"
    var isCircleChartPresentationType = true
    
    lazy var mainCurrency: Currency = presenter.settings.currencies.first!
    lazy var summaryByMonth = presenter.summary(by: .months, for: mainCurrency)
    lazy var summaryMinMax = presenter.maxAndMinValuesFromSummary(by: .months, for: mainCurrency)
    var currentMonthIndex = 0 { didSet { updateMonthData(); setupMonthHeader() } }
    var periods: [DateInterval] {
        return presenter.periodsFor(monthFrom: summaryByMonth[currentMonthIndex].period.end)
    }
    lazy var monthData = SummaryMonthData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        chartView.delegate = self
        chartView.minValueLabel.text = "0"
        chartView.midValueLabel.text = (summaryMinMax.max/2.0).shortString
        chartView.allowsSelection = true
        chartView.measureLinesColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.5)
        
        mainMoneyAmountBigLabel.text = presenter.totalMoney(in: mainCurrency).currencyFormattedDescription(mainCurrency)
        mainMoneyAmountSmallLabel.text = presenter.availableMoney(in: mainCurrency).currencyFormattedDescription(mainCurrency)
        
        mainHeaderView.addRoundedRectMask()
        updateMonthData()
        setupMonthHeader()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func presentationTypeButtonTouched(_ sender: UIButton) {
        isCircleChartPresentationType.toggle()
        tableView.reloadData()
    }
    
    private func setupMonthHeader() {
        mounthLabel.text =  monthData.monthName
        monthMoneyAmountSmallLabel.text = monthData.availableMoneyAmountFormatted
        monthMoneyAmountBigLabel.text = monthData.totalMoneyAmountFormatted
        
        for (index, label) in weekLabels.enumerated() {
            label.text = monthData.formattedPeriodForWeek[index]
        }
        for (index, label) in weekResultLabels.enumerated() {
            label.text = monthData.formattedResultForWeek[index]
        }
    }
    
    private func updateMonthData() {
        monthData.loadData(source: presenter, period: summaryByMonth[currentMonthIndex].period, currency: mainCurrency)
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


extension Double {
    var shortString: String {
        let intValue = abs(Int(self))
        let sign = self < 0 ? "-" : ""
        switch intValue {
        case _ where intValue < 1000: return "\(intValue)"
        case _ where intValue < 100_000:
            var result = "\(intValue / 1000)" + "."
            let remainder = Int(round(Double(intValue % 1000), toNearest: 10))/10
            result += "\(remainder)к"
            return sign + result
            
        case _ where intValue < 1_000_000:
            var result = "\(intValue / 1000)" + "."
            let remainder = Int(round(Double(intValue % 1000), toNearest: 100))/100
            result += "\(remainder)к"
            return sign + result
        default:
            let valueRoundedToK = round(Double(intValue), toNearest: 1000)/1000
            return sign + valueRoundedToK.shortString + "к"
        }
    }
    
    private func round(_ value: Double, toNearest: Double) -> Double {
        return (value / toNearest).rounded() * toNearest
    }
}
