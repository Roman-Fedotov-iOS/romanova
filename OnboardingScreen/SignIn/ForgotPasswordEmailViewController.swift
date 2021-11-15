//
//  ForgetPasswordEmailViewController.swift
//  romanova
//
//  Created by Roman Fedotov on 13.10.2021.
//

import UIKit
import Firebase

class ForgotPasswordEmailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailGrayView: UIView!
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailFieldBorder: UIImageView!
    @IBOutlet weak var refreshButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabelTap()
        emailFieldBorder.isHidden = true
        screenTitle.font = .rounded(ofSize: 36, weight: .bold)
        screenTitle.text = NSLocalizedString("screen.forgot_password_email.title", comment: "")
        refreshButton.setTitle(NSLocalizedString("screen.forgot_password_email.button.text", comment: ""), for: .normal)
    }
    
    func setupLabelTap() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func showEmailAlert() {
        let alert = UIAlertController(title: NSLocalizedString("case.exception_label", comment: ""), message: NSLocalizedString("case.incorrect_email_label", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func emailFieldAction(_ sender: UITextField) {
        emailGrayView.isHidden = true
        UIView.transition(with: emailFieldBorder, duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
            self.emailFieldBorder.isHidden = false
                      })
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonAction(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: emailField.text!) { error in
            if error == nil {
                if let controller = self.storyboard?.instantiateViewController(identifier: "BackToSignInVC") as? BackToSignInViewController {
                    controller.modalTransitionStyle = .crossDissolve
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
            } else {
                self.showEmailAlert()
            }
        }
    }
    
}
