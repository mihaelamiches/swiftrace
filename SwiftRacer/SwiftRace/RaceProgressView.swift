//
//  RaceProgressView.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/5/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit

@IBDesignable class RaceProgressView: UIView {
    @IBInspectable var percentCompleted: CGFloat = 50.0
    
    override func draw(_ rect: CGRect) {
        let carLabel = UILabel.carLabel()
        let barWidth = (percentCompleted * (rect.width - carLabel.bounds.width))/100
        let barSize = CGSize(width: barWidth, height: rect.height)
        let progressColors: [UIColor] = [.red, .yellow]
        
        carLabel.frame.origin = CGPoint(x: rect.width - (carLabel.bounds.width + barWidth), y: -carLabel.frame.height/2)
        
        let path = UIBezierPath(rect: CGRect(origin: CGPoint(x: frame.width - barSize.width, y: 0), size: barSize))
        let progressLayer = CAShapeLayer()
        progressLayer.path = path.cgPath

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = progressColors.map { $0.cgColor }
        gradientLayer.mask = progressLayer
        
        backgroundColor = .clear
        layer.addSublayer(gradientLayer)
        addSubview(carLabel)
    }
}
