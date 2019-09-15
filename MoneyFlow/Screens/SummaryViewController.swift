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
    @IBOutlet weak var mainHeaderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.delegate = self
        chartView.minValueLabel.text = "0"
        chartView.midValueLabel.text = "50K"
        self.chartView.measureLinesColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.5)
        mainHeaderView.addRoundedRectMask()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
