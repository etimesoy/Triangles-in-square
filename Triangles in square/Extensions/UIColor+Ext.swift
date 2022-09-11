//
//  UIColor+Ext.swift
//  Triangles in square
//
//  Created by Руслан on 11.09.2022.
//

import UIKit

extension UIColor {
    static var randomRGB: UIColor {
        var random0to1Value: CGFloat { .random(in: 0 ... 1) }
        let (red, green, blue) = (random0to1Value, random0to1Value, random0to1Value)
        guard red < 1 || green < 1 || blue < 1 else {
            return UIColor.randomRGB
        }
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
