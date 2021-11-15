//
//  OnboardingCollectionViewCell.swift
//  OnBoardingScreen
//
//  Created by Roman Fedotov on 21.08.2021.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var onboardingImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    // MARK: - Properties
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    func setup(_ slide: OnboardingSlide) {
        onboardingImage.image = slide.image
        title.text = slide.title
        title.font = .rounded(ofSize: 38, weight: .bold)
//        title.text = NSLocalizedString("screen.onboarding.page_one.title", comment: "")
    }
}
