//
//  BackToSignInViewController.swift
//  romanova
//
//  Created by Roman Fedotov on 13.10.2021.
//

import UIKit

class BackToSignInViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var screenTitle: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailButtonLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenTitle.font = .rounded(ofSize: 36, weight: .bold)
        screenTitle.text = NSLocalizedString("screen.back_to_sign_in.title", comment: "")
        successLabel.font = .rounded(ofSize: 14, weight: .regular)
        successLabel.text = NSLocalizedString("screen.back_to_sign_in.description_label", comment: "")
        emailButtonLabel.font = .rounded(ofSize: 14, weight: .bold)
        emailButtonLabel.text = NSLocalizedString("screen.back_to_sign_in.email_button.text", comment: "")
    }
    
    // MARK: - IBActions
    
    @IBAction func emailButtonAction(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(identifier: "SignInVC") as? SignInViewController {
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }
    
}
