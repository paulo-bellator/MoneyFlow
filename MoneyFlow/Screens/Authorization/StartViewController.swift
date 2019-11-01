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
    fileprivate var timer: Timer?
    
    
    @IBAction func logInButtonTouched(_ sender: UIButton) {
        logIn()
        try? Auth.auth().signOut()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.isHidden = true
        Auth.auth().currentUser!.reload { [weak self] error in
            if let self = self {
                if let error = error, !error.localizedDescription.contains("Network error") {
                    print(error.localizedDescription)
                    if Auth.auth().currentUser == nil {
                        self.performSegue(withIdentifier: self.greetingSegueIdentifier, sender: nil)
                    }
                } else {
                    self.checkBiometricAuthPossibilities()
                    self.logInButton.isHidden = false
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currencySignsAppearingAnimation()
    }
    
    private func checkBiometricAuthPossibilities() {
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
                [weak self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self?.segueToNextScreen()
                    } else {
                        let errorMessage = authenticationError?.localizedDescription ?? "Неизвестная ошибка"
                        if !errorMessage.contains("Canceled") {
                            let ac = UIAlertController(title: "Авторизация не пройдена", message: errorMessage, preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            self?.present(ac, animated: true)
                        }
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


extension StartViewController {
    private struct Constants {
        static let currencySigns = ["$","€","¥","£","₽"]
        static let colors: [UIColor] = [#colorLiteral(red: 0.7725490196, green: 0.8784313725, blue: 0.7058823529, alpha: 1), #colorLiteral(red: 0.4, green: 0.462745098, blue: 0.9490196078, alpha: 1), #colorLiteral(red: 0.9568627451, green: 0.6941176471, blue: 0.5137254902, alpha: 1)]
        static let font = UIFont(name: "CenturyGothic-Bold", size: 18.0)
        static let fontSizes: [CGFloat] = [12.0, 14.0, 16.0, 18.0 , 20.0, 22.0, 24.0]
        static let minRotationAngle: CGFloat = -CGFloat.pi / 4
        static let maxRotationAngle: CGFloat = CGFloat.pi / 4
        static let borderSpacing: CGFloat = 20.0
    }
    
    func currencySignsAppearingAnimation() {
        currencySignAppear()
        for step in 1...7 {
            Timer.scheduledTimer(withTimeInterval: 0.15 * Double(step), repeats: false) { [weak self] _ in
                self?.currencySignAppear()
            }
        }
        timer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            for step in 0...7 {
                Timer.scheduledTimer(withTimeInterval: 0.15 * Double(step), repeats: false) { [weak self] _ in
                    self?.currencySignAppear()
                }
            }
        }
    }
    
    private func currencySignAppear() {
        let label = UILabel()
        label.text = Constants.currencySigns.randomElement()!
        label.sizeToFit()
        label.textColor = Constants.colors.randomElement()!
        label.font = Constants.font?.withSize(Constants.fontSizes.randomElement()!)
        label.frame = randomFrame(for: label)
        let rotationAngle = CGFloat.random(in: Constants.minRotationAngle...Constants.maxRotationAngle)
        label.transform = CGAffineTransform.init(rotationAngle: rotationAngle)
        label.alpha = 0.0
        self.view.addSubview(label)
        
        UIView.animate(
            withDuration: 0.5,
            animations: { label.alpha = 1.0 },
            completion: { _ in
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    UIView.animate(
                        withDuration: 0.5,
                        animations: { label.alpha = 0.0 },
                        completion: { _ in label.removeFromSuperview() })
                }
            })
    }
    
    private func randomFrame(for label: UILabel) -> CGRect {
        let width = label.bounds.width * 2
        let height = label.bounds.height * 2
        
        let minX = Constants.borderSpacing
        let maxX = view.bounds.maxX - Constants.borderSpacing - width
        let minY = Constants.borderSpacing
        let maxY = view.bounds.maxY - Constants.borderSpacing - height
        
        var originX = minX
        var originY = minY
        var resultFrame = CGRect.zero
        
        var areCoordinatesCorrect = false
        var counter = 0
        let maxCount = 50
        
        while !areCoordinatesCorrect {
            counter += 1
            originX = CGFloat.random(in: minX...maxX)
            originY = CGFloat.random(in: minY...maxY)
            resultFrame = CGRect(x: originX, y: originY, width: width, height: height)
            areCoordinatesCorrect = true
            
            for subview in view.subviews {
                if subview.frame.intersects(resultFrame) {
                    areCoordinatesCorrect = false
                    break
                }
            }
            
            if counter == maxCount {
                resultFrame = CGRect.zero
                break
            }
        }
        
        return resultFrame
    }
}
