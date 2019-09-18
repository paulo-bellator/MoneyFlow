//
//  TestViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, ChartViewDelegate {
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
    

    @IBOutlet weak var chartView: ChartView!
    override func viewDidLoad() {
        super.viewDidLoad()

        chartView.delegate = self
        chartView.minValueLabel.text = "0"
        chartView.midValueLabel.text = "50K"
        self.chartView.measureLinesColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
        chartView.allowsSelection = true
//        chartView.updateUI()
//
//        Timer.scheduledTimer(withTimeInterval: 4.2, repeats: false) { _ in
//            self.chartView.bounds.size.height -= 200
////            self.chartView.layoutIfNeeded()
////            self.chartView.collectionView.reloadData()
////            self.chartView.layoutIfNeeded()
//        }
//        Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { _ in
////            self.chartView.layoutIfNeeded()
//            print("height: \(self.chartView.bounds.height)")
//        }
        
//        Timer.scheduledTimer(withTimeInterval: 4.3, repeats: false) { _ in
//            self.chartView.updateUI()
//        }
//        chartView.updateLayoutsOfSubviews()
        
        
        
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    


}
