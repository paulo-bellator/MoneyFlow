//
//  LoadingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 12/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, CloudDataSourceDelegate {
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    let tabBarSegueIdentifier = "tabBarSegue"
    
    var downloadProgress = 0.0 {
        didSet {
            progressView.progress = Float(downloadProgress)
            var progress = (100*downloadProgress).rounded()
            if progress.isNaN { progress = 100.0 }
            progressLabel.text = "\(Int(progress)) %"
        }
    }
    var uploadProgress = 0.0
    
    func downloadComplete(with error: Error?) {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            if self != nil { self!.performSegue(withIdentifier: self!.tabBarSegueIdentifier, sender: nil) }
        }
        print("download complete in LoadingVC")
        print(error)
    }
    func uploadComplete(with error: Error?) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        MainData.source.delegate = self
        progressView.progress = 0.0
        progressLabel.text = "0 %"

        progressView.transform = progressView.transform.scaledBy(x: 1, y: 2)
    }

}
