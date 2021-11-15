//
//  HeaderCollectionReusableView.swift
//  romanova
//
//  Created by Roman Fedotov on 27.10.2021.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
        static let identifier = "HeaderCollectionReusableView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("screen.main.playlist.title", comment: "")
        label.font = .rounded(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 3
        return label
    }()
    
    public func configure() {
        backgroundColor = .white
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}

