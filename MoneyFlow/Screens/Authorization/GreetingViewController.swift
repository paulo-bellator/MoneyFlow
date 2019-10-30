//
//  GreetingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 30/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class GreetingViewController: UIViewController {

    let singInSegueIdentifier = "singInSegue"
    let singUpSegueIdentifier = "singUpSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let authVC = segue.destination as? AuthViewController {
            if let identifier = segue.identifier {
                authVC.isSingingUp = (identifier == singUpSegueIdentifier)
            }
        }
    }
    

}
