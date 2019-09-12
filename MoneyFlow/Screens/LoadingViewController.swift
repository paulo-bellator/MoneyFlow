//
//  LoadingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 12/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, FirebaseDataSourceDelegate {
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    let tabBarSegueIdentifier = "tabBarSegue"
    
    var downloadProgress = 0.0 {
        didSet {
            progressView.progress = Float(downloadProgress)
            progressLabel.text = "\(Int(100*downloadProgress)) %"
            
            if downloadProgress == 1.0 {
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                    self?.performSegue(withIdentifier: self!.tabBarSegueIdentifier, sender: nil)
                }
            }
        }
    }
    
    var uploadProgress = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseDataSource.shared.delegate = self
        progressView.progress = 0.0
        progressLabel.text = "0 %"

        progressView.transform = progressView.transform.scaledBy(x: 1, y: 2)
        
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.performSegue(withIdentifier: self!.tabBarSegueIdentifier, sender: nil)
        }
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
            self?.progressView.isHidden = true
            self?.progressLabel.text = "Данные не загружены"
        }

    }

}
