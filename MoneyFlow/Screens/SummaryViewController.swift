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
    
    private let presenter = SummaryPresenter()
    private let summaryCellIdentifier = "summaryCell"
    private let summaryGraphCellIdentifier = "summaryGraphCell"
    let summaryHeaderCellIdentifier = "summaryHeader"
    var isCircleChartPresentationType = false
    
    lazy var mainCurrency: Currency = presenter.settings.currencies.first!
    private lazy var summaryByMonth = presenter.summary(by: .months, for: mainCurrency)
    private lazy var summaryMinMax = presenter.maxAndMinValuesFromSummary(by: .months, for: mainCurrency)
    var currentMonthIndex = 0
    var periods: [DateInterval] {
        return presenter.periodsFor(monthFrom: summaryByMonth[currentMonthIndex].period.end)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        chartView.delegate = self
        chartView.minValueLabel.text = "0"
        chartView.midValueLabel.text = (summaryMinMax.max/2.0).shortString
        chartView.allowsSelection = true
        self.chartView.measureLinesColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.5)
        mainHeaderView.addRoundedRectMask()
        
        mainMoneyAmountBigLabel.text = presenter.totalMoney(in: mainCurrency).currencyFormattedDescription(mainCurrency)
        mainMoneyAmountSmallLabel.text = presenter.availableMoney(in: mainCurrency).currencyFormattedDescription(mainCurrency)
        
        setupMonthHeader()
        
        print(summaryByMonth[currentMonthIndex].period)
        print(presenter.iOwe(until: summaryByMonth[currentMonthIndex].period.end, in: mainCurrency).shortString)
        print(presenter.iOwe(until: periods[0].end, in: mainCurrency).shortString)
        print(presenter.iOwe(until: periods[1].end, in: mainCurrency).shortString)
        print(presenter.iOwe(until: periods[2].end, in: mainCurrency).shortString)
        print(presenter.iOwe(until: periods[3].end, in: mainCurrency).shortString)
        
        print(presenter.oweMe(until: summaryByMonth[currentMonthIndex].period.end, in: mainCurrency).shortString)
        print(presenter.oweMe(until: periods[0].end, in: mainCurrency).shortString)
        print(presenter.oweMe(until: periods[1].end, in: mainCurrency).shortString)
        print(presenter.oweMe(until: periods[2].end, in: mainCurrency).shortString)
        print(presenter.oweMe(until: periods[3].end, in: mainCurrency).shortString)
        
//        print("test formattedString()")
//        for val in stride(from: -2_000_000, to: 2_000_000, by: 7234.56) {
//            print(val.shortString)
//        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func presentationTypeButtonTouched(_ sender: UIButton) {
        isCircleChartPresentationType.toggle()
        tableView.reloadData()
    }
    
    
    private func setupMonthHeader() {
        let monthEndDate = summaryByMonth[currentMonthIndex].period.end
        let monthName = monthEndDate.formatted(in: "LLLL")
        mounthLabel.text =  monthName.prefix(1).capitalized + monthName.dropFirst()
        
        monthMoneyAmountSmallLabel.text = presenter.availableMoney(in: mainCurrency, at: monthEndDate).currencyFormattedDescription(mainCurrency)
        monthMoneyAmountBigLabel.text = presenter.totalMoney(in: mainCurrency, at: monthEndDate).currencyFormattedDescription(mainCurrency)
        
        week1Label.text = periods[0].end.formatted(in: "dd LLL")
        week2Label.text = periods[1].end.formatted(in: "dd LLL")
        week3Label.text = periods[2].end.formatted(in: "dd LLL")
        week4Label.text = periods[3].end.formatted(in: "dd LLL")
        
        let week1Result = presenter.totalMoney(in: mainCurrency, at: periods[0].end) - presenter.totalMoney(in: mainCurrency, at: periods[0].start)
        week1ResultLabel.text = (week1Result > 0 ? "+" : "") + week1Result.shortString
        let week2Result = presenter.totalMoney(in: mainCurrency, at: periods[1].end) - presenter.totalMoney(in: mainCurrency, at: periods[1].start)
        week2ResultLabel.text = (week2Result > 0 ? "+" : "") + week2Result.shortString
        let week3Result = presenter.totalMoney(in: mainCurrency, at: periods[2].end) - presenter.totalMoney(in: mainCurrency, at: periods[2].start)
        week3ResultLabel.text = (week3Result > 0 ? "+" : "") + week3Result.shortString
        let week4Result = presenter.totalMoney(in: mainCurrency, at: periods[3].end) - presenter.totalMoney(in: mainCurrency, at: periods[3].start)
        week4ResultLabel.text = (week4Result > 0 ? "+" : "") + week4Result.shortString
    }
    
    
    func chartView(didSelectColumnAt index: Int) {
        print("Selected in \(index)")
        currentMonthIndex = index
        setupMonthHeader()
        tableView.reloadData()
    }
    
    func chartViewNumberOfColumns() -> Int {
        return summaryByMonth.count
    }
    
    func chartView(labelForColumnAt index: Int) -> String {
        return summaryByMonth[index].period.end.formatted(in: "LLL")
    }
    
    func chartView(mainValueForColumnAt index: Int) -> CGFloat {
//        let measureUnit = summaryMinMax.max - summaryMinMax.min
//        let value = summaryByMonth[index].availableMoney - summaryMinMax.min
        let measureUnit = summaryMinMax.max
        let value = max(0, summaryByMonth[index].availableMoney)
        return CGFloat(value/measureUnit)
    }
    
    func chartView(secondValueForColumnAt index: Int) -> CGFloat? {
//        let measureUnit = summaryMinMax.max - summaryMinMax.min
//        let value = summaryByMonth[index].totalMoney - summaryMinMax.min
        let measureUnit = summaryMinMax.max
        let value = max(0, summaryByMonth[index].totalMoney)
        return CGFloat(value/measureUnit)
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
        case 0: return presenter.settings.incomeCategories.count + 1
        case 1: return presenter.settings.outcomeCategories.count + 1
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
            let cellIdentifier = isCircleChartPresentationType ? summaryGraphCellIdentifier : summaryCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case _ where cell is SummaryHeaderTableViewCell:
            let header = cell as! SummaryHeaderTableViewCell
            switch indexPath.section {
            case 0:
                header.leftLabel.text = "Доходы"
                let income = presenter.income(for: summaryByMonth[currentMonthIndex].period, in: mainCurrency)
                header.rightLabel.text = income.currencyFormattedDescription(mainCurrency)
            case 1:
                header.leftLabel!.text = "Расходы"
                let outcome = presenter.outcome(for: summaryByMonth[currentMonthIndex].period, in: mainCurrency)
                header.rightLabel.text = outcome.currencyFormattedDescription(mainCurrency)
            case 2:
                header.leftLabel!.text = "Долги"
                let iOwe = presenter.iOwe(until: summaryByMonth[currentMonthIndex].period.end, in: mainCurrency)
                let oweMe = presenter.oweMe(until: summaryByMonth[currentMonthIndex].period.end, in: mainCurrency)
                header.rightLabel.text = (oweMe - iOwe).currencyFormattedDescription(mainCurrency)
            default: break
            }
        
        case _ where cell is  SummaryTableViewCell:
            let cell = cell as! SummaryTableViewCell
            switch indexPath.section {
            case 0:
                let category = presenter.settings.incomeCategories[indexPath.row-1]
                cell.titleLabel.text = category
                cell.value1Label.text = presenter.income(for: periods[0], from: [category], in: mainCurrency).shortString
                cell.value2Label.text = presenter.income(for: periods[1], from: [category], in: mainCurrency).shortString
                cell.value3Label.text = presenter.income(for: periods[2], from: [category], in: mainCurrency).shortString
                cell.value4Label.text = presenter.income(for: periods[3], from: [category], in: mainCurrency).shortString
            case 1:
                let category = presenter.settings.outcomeCategories[indexPath.row-1]
                cell.titleLabel.text = category
                cell.value1Label.text = presenter.outcome(for: periods[0], from: [category], in: mainCurrency).shortString
                cell.value2Label.text = presenter.outcome(for: periods[1], from: [category], in: mainCurrency).shortString
                cell.value3Label.text = presenter.outcome(for: periods[2], from: [category], in: mainCurrency).shortString
                cell.value4Label.text = presenter.outcome(for: periods[3], from: [category], in: mainCurrency).shortString
            case 2:
                switch (indexPath.row-1) {
                case 0:
                     cell.titleLabel.text = "Я должен"
                    cell.value1Label.text = presenter.iOwe(until: periods[0].end, in: mainCurrency).shortString
                    cell.value2Label.text = presenter.iOwe(until: periods[1].end, in: mainCurrency).shortString
                    cell.value3Label.text = presenter.iOwe(until: periods[2].end, in: mainCurrency).shortString
                    cell.value4Label.text = presenter.iOwe(until: periods[3].end, in: mainCurrency).shortString
                case 1:
                    cell.titleLabel.text = "Мне должны"
                    cell.value1Label.text = presenter.oweMe(until: periods[0].end, in: mainCurrency).shortString
                    cell.value2Label.text = presenter.oweMe(until: periods[1].end, in: mainCurrency).shortString
                    cell.value3Label.text = presenter.oweMe(until: periods[2].end, in: mainCurrency).shortString
                    cell.value4Label.text = presenter.oweMe(until: periods[3].end, in: mainCurrency).shortString
                default: break
                }
            default: break
            }
       
        case _ where cell is  SummaryGraphTableViewCell:
            let cell = cell as! SummaryGraphTableViewCell
            switch indexPath.section {
            case 0: cell.titleLabel.text = presenter.settings.incomeCategories[indexPath.row-1]
            case 1: cell.titleLabel.text = presenter.settings.outcomeCategories[indexPath.row-1]
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

private extension Double {
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
