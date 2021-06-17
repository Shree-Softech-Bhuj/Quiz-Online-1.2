//
//  CollectionViewCell.swift
//  Quiz
//
//  Created by Harish Vekariya on 27/05/21.
//  Copyright © 2021 WR Team. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var CatNumber: UILabel!
 
    override public class var layerClass: AnyClass { CAGradientLayer.self }
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    func setGradienttt(_ color1: UIColor,_ color2: UIColor)
    {
        gradientLayer.startPoint = .init(x: 0, y: 1)//.init(x: 0.5, y: 0)
        gradientLayer.endPoint = .init(x: 1, y: 0)//.init(x: 0.5, y: 1)
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.cornerRadius = 20

    }
}

extension UIColor {
    static func random(from colors: [UIColor]) -> UIColor? {
        return colors.randomElement()
    }
}

