//
//  ViewController.swift
//  OnBoardingScreen
//
//  Created by Roman Fedotov on 21.08.2021.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var slides: [OnboardingSlide] = []
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                nextButton.setTitle(NSLocalizedString("screen.onboarding.page.button.to_main_screen", comment: ""), for: .normal)
            } else {
                nextButton.setTitle(NSLocalizedString("screen.onboarding.page.button.to_next_page", comment: ""), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewShadow()
        collectionView.delegate = self
        collectionView.dataSource = self
        slides = [OnboardingSlide(title: NSLocalizedString("screen.onboarding.page_one.title", comment: ""), image: UIImage(named: "onboarding1")!), OnboardingSlide(title: NSLocalizedString("screen.onboarding.page_two.title", comment: ""), image: UIImage(named: "onboarding2")!)]
        pageControl.numberOfPages = slides.count
        nextButton.setTitle(NSLocalizedString("screen.onboarding.page.button.to_next_page", comment: ""), for: .normal)
        nextButton.titleLabel?.font = .rounded(ofSize: 16, weight: .medium)
        skipButton.setTitle(NSLocalizedString("screen.onboarding.page.button.skip_to_main", comment: ""), for: .normal)
        skipButton.titleLabel?.font = .rounded(ofSize: 14, weight: .regular)
    }
    
    // MARK: - Funcs
    
    func collectionViewShadow() {
        collectionView.layer.borderWidth = 1.0
        collectionView.layer.borderColor = UIColor.clear.cgColor
        collectionView.layer.masksToBounds = true
        collectionView.layer.cornerRadius = 25
        collectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowRadius = 25
        collectionView.layer.shadowOffset = CGSize(width: 0, height: -10)
        collectionView.layer.shadowOpacity = 1
        collectionView.layer.masksToBounds = false
    }
    
    // MARK: - IBActions
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            if let controller = storyboard?.instantiateViewController(identifier: "MethodsVC") {
                controller.modalTransitionStyle = .coverVertical
                controller.modalPresentationStyle = .fullScreen
                UserDefaults.standard.hasOnboarded = true
                UserDefaults.standard.hasSignedIn = false
                present(controller, animated: true, completion: nil)
            }
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(identifier: "MethodsVC") {
            controller.modalTransitionStyle = .coverVertical
            controller.modalPresentationStyle = .fullScreen
            UserDefaults.standard.hasOnboarded = true
            UserDefaults.standard.hasSignedIn = false
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - Extensions

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath ) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x/width)
    }
}

