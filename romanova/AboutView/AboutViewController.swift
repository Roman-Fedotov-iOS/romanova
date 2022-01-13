//
//  AboutViewController.swift
//  OnBoardingScreen
//
//  Created by Roman Fedotov on 23.08.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class AboutViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var aboutImage: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var telegramButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sharingButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("screen.main.about_author.text.top_view_title", comment: "")
        titleLabel.font = .rounded(ofSize: 18, weight: .bold)
        textView.text = NSLocalizedString("screen.about_author.text.about_author", comment: "")
        textView.font = .rounded(ofSize: 16, weight: .regular)
        nameLabel.text = NSLocalizedString("screen.about_author.text.author_name", comment: "")
        nameLabel.font = .rounded(ofSize: 24, weight: .bold)
        jobLabel.text = NSLocalizedString("screen.about_author.text.job_label", comment: "")
        jobLabel.font = .rounded(ofSize: 14, weight: .regular)
        exitButton.setImage(UIImage(named: UserDefaults.standard.string(forKey: "image") ?? "exitButton"), for: .normal)
    }
    
    // MARK: - IBOutlets
    
    func showAlert() {
        let alert = UIAlertController(title: NSLocalizedString("case.warning_label", comment: ""), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("case.agreement_label", comment: ""), style: .default) {_ in
            try! Auth.auth().signOut()
            UserDefaults.standard.hasSignedIn = false
            
            if let controller = self.storyboard?.instantiateViewController(identifier: "MethodsVC") as? MethodsViewController {
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("case.deny_label", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func exitButtonAction(_ sender: UIButton) {
        player?.pause()
        if UserDefaults.standard.string(forKey: "authMethod") != nil {
            showAlert()
        } else if UserDefaults.standard.string(forKey: "authMethod") == nil {
            try! Auth.auth().signOut()
            UserDefaults.standard.hasSignedIn = false
            
            if let controller = storyboard?.instantiateViewController(identifier: "MethodsVC") as? MethodsViewController {
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .fullScreen
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func telegramButtonAction(_ sender: UIButton) {
        let screenName =  "romanova_vera"
        
        let appURL = URL(string:  "https://t.me/\(screenName)")
        let webURL = URL(string:  "https://t.me/\(screenName)")
        
        if UIApplication.shared.canOpenURL(appURL!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL!)
            }
        } else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL!)
            }
        }
    }
    
    @IBAction func facebookButtonAction(_ sender: UIButton) {
        let screenName =  "100002949897243"
        
        let appURL = URL(string:  "https://www.messenger.com/t/\(screenName)")
        let webURL = URL(string:  "https://www.messenger.com/t/\(screenName)")
        
        if UIApplication.shared.canOpenURL(appURL!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL!)
            }
        } else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL!)
            }
        }
    }
    
    @IBAction func sharingButtonAction(_ sender: UIButton) {
        let message = [URL(string: "https://apps.apple.com/us/app/romanova/id1587390788")!]
        let ac = UIActivityViewController(activityItems: message, applicationActivities: nil)
        present(ac, animated: true)
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
