//
//  Slider.swift
//  HomeVision
//
//  Created by Batuhan on 30.03.2023.
//

import UIKit

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let scaledImage = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        
        return scaledImage
    }
}

class Slider: UISlider {
    override func awakeFromNib() {
        super.awakeFromNib()
        let thumbSize = CGSize(width: 16, height: 16)
        setThumbImage(UIImage(named: "thumb")?.scalePreservingAspectRatio(targetSize: thumbSize), for: .normal)
        setThumbImage(UIImage(named: "thumb")?.scalePreservingAspectRatio(targetSize: thumbSize), for: .highlighted)
        setThumbImage(UIImage(named: "thumb.disabled")?.scalePreservingAspectRatio(targetSize: thumbSize), for: .disabled)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        let trackHeight: CGFloat = 12.0 // increase this value to make the track wider
        let customBounds = CGRect(x: defaultBounds.origin.x, y: defaultBounds.origin.y - trackHeight/2, width: defaultBounds.size.width, height: trackHeight)
        return customBounds
    }
}
