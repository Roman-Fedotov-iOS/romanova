//
//  WaveFormView.swift
//  romanova
//
//  Created by Roman Fedotov on 02.09.2021.
//

import UIKit

 class WaveFormView: UIImageView {
    
    let cornerRad: CGFloat = 100
    
    var valuesImage: UIImage? = nil
    
    var duration: Float64 = 0
    
    var values: Array<Float> = []
    
    private var viewHeight: CGFloat {
        get { return self.bounds.size.height }
    }
    
    private var viewWidth: CGFloat {
        get { return self.bounds.size.width }
    }
    
    private let desiredLinePadding: CGFloat = 3
    
    private var linePadding: CGFloat = 0
    
    private let lineWidth: CGFloat = 4
    
    var linesCount: Int {
        get { Int(Float((viewWidth-linePadding))/Float((linePadding+lineWidth))) }
    }
    
    var desiredLinesCount: Int {
        get { Int(Float((viewWidth-desiredLinePadding))/Float((desiredLinePadding+lineWidth))) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setup(values: Array<Float>, duration: Float64) {
        self.values = values
        self.duration = duration
        self.linePadding = CGFloat(Float(desiredLinePadding) * Float(desiredLinesCount) / Float(values.count))
        valuesImage = drawValues(values: values)
        self.image = valuesImage
        if currentPodcastModel != nil {
        updateProgress(currentPosition: Float64(currentPodcastModel!.currentPlayTime))
        } else {
            updateProgress(currentPosition: 0.0)
        }
    }
    
    func updateProgress(currentPosition: Float64) {
        if let unwrappedImage = valuesImage {
        self.image = drawFill(playedPercent: CGFloat((currentPosition/duration)), timeline: unwrappedImage)
        }
    }
    
    func drawValues(values: Array<Float>) -> UIImage {
        
        
        let shapeLayer = CAShapeLayer()
        
        for (index, factor) in values.enumerated() {
            let rect = CGRect(x: CGFloat(index) * (linePadding + lineWidth),
                              y:  (viewHeight * CGFloat((1.0 - factor)))/2,
                              width: lineWidth,
                              height: viewHeight * CGFloat(factor))
            let clipPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRad).cgPath
            let shapeLayer1 = CAShapeLayer()
            shapeLayer1.path = clipPath
            shapeLayer1.fillColor = UIColor.gray.cgColor
            shapeLayer.addSublayer(shapeLayer1)
        }
        
        let timeLine = UIGraphicsImageRenderer(size:self.bounds.size).image {
            ctx in
            shapeLayer.render(in: ctx.cgContext)
        }
        return timeLine
    }
    
    func drawFill(playedPercent: CGFloat, timeline: UIImage) -> UIImage {
        let scaledWidth = viewWidth - linePadding * CGFloat((linesCount - 1))
        let filledScaledWidth = scaledWidth * playedPercent
        let filledRectsCount = Int(filledScaledWidth / lineWidth)
        let paddingAdditionalWidth = linePadding * CGFloat(filledRectsCount)
        
        let fill = UIGraphicsImageRenderer(size: self.bounds.size).image {
            ctx in
            UIColor.black.setFill()
            
            ctx.fill(CGRect(x: 0, y: 0, width: paddingAdditionalWidth + filledScaledWidth, height: viewHeight))
        }
        let result = UIGraphicsImageRenderer(size: self.bounds.size).image {
            ctx in
            fill.draw(at: .zero)
            timeline.draw(at: .zero, blendMode: .destinationAtop, alpha: 1)
        }
        return result
    }
 }
