//
//  StartViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 31/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import LocalAuthentication
import FirebaseAuth

class StartViewController: UIViewController {

    @IBOutlet weak var logInButton: UIButton!
    
    private let greetingSegueIdentifier = "greeingVCSegue"
    private let tabBarSegueIdentifier = "tabBarSegue"
    private let context = LAContext()
    private var canEvaluatePolicy = false
    
    
    @IBAction func logInButtonTouched(_ sender: UIButton) {
        logIn()
        try? Auth.auth().signOut()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            canEvaluatePolicy = true
            switch context.biometryType {
            case .touchID:
                logInButton.setTitle("Войти при помощи Touch ID", for: .normal)
                logIn()
            case .faceID:
                logInButton.setTitle("Войти при помощи FaceID", for: .normal)
            default:
                logInButton.isHidden = true
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [unowned self] _ in
                    self.segueToNextScreen()
                }
            }
        } else {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [unowned self] _ in
                self.segueToNextScreen()
            }
        }
    }
    
    private func logIn() {
        let biometricService = context.biometryType == .faceID ? "FaceID" : "Touch ID"
        if canEvaluatePolicy {
            let reason = "Авторизуйтесь при помощи " + biometricService
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self.segueToNextScreen()
                    } else {
                        let errorMessage = authenticationError?.localizedDescription ?? "Неизвестная ошибка"
                        let ac = UIAlertController(title: "Авторизация не пройдена", message: errorMessage, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        }
    }


    private func segueToNextScreen() {
        performSegue(withIdentifier: tabBarSegueIdentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarVC = segue.destination as? UITabBarController {
            tabBarVC.selectedIndex = 1
        }
    }
    

   
}
