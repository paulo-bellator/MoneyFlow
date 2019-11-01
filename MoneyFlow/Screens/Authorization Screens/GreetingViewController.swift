//
//  GreetingViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 30/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import FirebaseAuth

class GreetingViewController: UIViewController {

    let singInSegueIdentifier = "singInSegue"
    let singUpSegueIdentifier = "singUpSegue"
    let verifySegueIdentifier = "verifySegue"
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser, !user.isEmailVerified {
            performSegue(withIdentifier: verifySegueIdentifier, sender: user)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let authVC = segue.destination as? AuthViewController {
            if let identifier = segue.identifier {
                authVC.isSingingUp = (identifier == singUpSegueIdentifier)
            }
        }
        if let verifyVC = segue.destination as? VerifyEmailViewController {
            if let user = sender as? User {
                verifyVC.user = user
            }
        }
    }
    

}
