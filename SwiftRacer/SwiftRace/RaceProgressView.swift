//
//  RaceProgressView.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/5/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit

@IBDesignable class RaceProgressView: UIView {
    @IBInspectable var percentCompleted: CGFloat = 100.0
    
    override func draw(_ rect: CGRect) {
        let carLabel = UILabel.carLabel()
        let progressColors: [UIColor] = [.red,.red, .yellow]
        let padDelta = CGFloat(40)
        let maxProgressDelta = padDelta + carLabel.bounds.width
        let progressDelta = rect.width - ((rect.width - maxProgressDelta) * percentCompleted)/100
    
        let path = UIBezierPath(rect: rect.divided(atDistance: progressDelta, from: .minXEdge).remainder)
        let progressLayer = CAShapeLayer()
        progressLayer.path = path.cgPath
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = progressColors.map { $0.cgColor }
        gradientLayer.mask = progressLayer
        
        backgroundColor = .white
        layer.addSublayer(gradientLayer)
        
        addSubview(carLabel)
        carLabel.frame.origin = rect.divided(atDistance: progressDelta - carLabel.bounds.width + 7, from: .minXEdge).remainder.origin
        carLabel.frame.origin.y = -carLabel.bounds.height/2
    }
}
