//
//  VerifyEmailViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 30/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import FirebaseAuth

class VerifyEmailViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var didNotVerifiedLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sendAgainButton: UIButton!
    
    let segueIdentifier = "tabBarSegue"
    var user: User!
    
    @IBAction func verifyButtonTouched(_ sender: UIButton) {
        guard user != nil else { return }
        didNotVerifiedLabel.isHidden = true
        startLoading()
        
        user.reload { [weak self] error in
            guard let strongSelf = self else { return }
            self!.stopLoading()
            if self!.user.isEmailVerified {
                self!.emailDidVerified()
            } else {
                self!.didNotVerifiedLabel.isHidden = false
            }
        }
    }
    
    @IBAction func sendAgainButtonTouched(_ sender: UIButton) {
        
    }
    
    private func emailDidVerified() {
        print("User Verified!")
        didNotVerifiedLabel.text = "Почта подтверждена"
        didNotVerifiedLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        didNotVerifiedLabel.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            if let self = self {
                self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
            }
        }
        
    }
    
    private func startLoading() {
        verifyButton.isHidden = true
        activityIndicator.startAnimating()
    }
    private func stopLoading() {
        activityIndicator.stopAnimating()
        verifyButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLabel.text = ""
        if let user = user {
            if let email = user.email {
                emailLabel.text = email
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarVC = segue.destination as? UITabBarController {
            tabBarVC.selectedIndex = 1
        }
    }
    

}
