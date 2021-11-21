//
//  ImageDownloader.swift
//  romanova
//
//  Created by Roman Fedotov on 04.09.2021.
//

import UIKit
import Kingfisher

protocol ImageDownloader {
    func download(result: @escaping (ImageDownloaderResult) -> ())
}

class ImageDownloaderImpl: ImageDownloader {
    
    let url: String
    
    func download(result: @escaping (ImageDownloaderResult) -> ()) {
        let compessionFactor: Float = 0.2
        KingfisherManager.shared.retrieveImage(with: url.asURL!, options: nil, progressBlock: nil) { kfResult in
            switch kfResult {
            case .success(let value):
                let scaledImage = value.image.scalePreservingAspectRatio(targetSize: CGSize(width: CGFloat(Float(value.image.size.width) * compessionFactor) , height: CGFloat(Float(value.image.size.height) * compessionFactor)))
                
                result(ImageDownloaderResult(imageData: ImageData(imageData: scaledImage.pixelData!, imageWidth: UInt16(scaledImage.size.width)), hasError: false))
            case .failure(let error):
                result(ImageDownloaderResult(imageData: nil, hasError: true))
            }
        }
    }
    
    init(url: String) {
        self.url = url
    }
}

extension UIImage {
    var pixelData: [UInt8]? {
        get {
            let size = self.size
            let dataSize = size.width * size.height * 4
            var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: &pixelData,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 4 * Int(size.width),
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
            guard let cgImage = self.cgImage else { return nil }
            context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            return pixelData
        }
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
            // Determine the scale factor that preserves aspect ratio
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            
            let scaleFactor = min(widthRatio, heightRatio)
            
            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )

            // Draw and return the resized UIImage
            let renderer = UIGraphicsImageRenderer(
                size: scaledImageSize
            )

            let scaledImage = renderer.image { _ in
                self.draw(in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                ))
            }
            
            return scaledImage
        }
}

class ImageDownloaderResult {
    
    let imageData: ImageData?
    let hasError: Bool
    
    init(imageData: ImageData?, hasError: Bool) {
        self.imageData = imageData
        self.hasError = hasError
    }
}

class ImageData {
    let imageData: [UInt8]
    let imageWidth: UInt16
    
    init(imageData: [UInt8], imageWidth: UInt16) {
        self.imageData = imageData
        self.imageWidth = imageWidth
    }
}
