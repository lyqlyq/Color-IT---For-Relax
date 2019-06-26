//
//  UIColor+.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/6/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    public func hexString(includeAlpha: Bool = true) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if (includeAlpha) {
            return String(format: "%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
    
    public func hex() -> Int {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
    }

    func interpolateRGBColorTo(end:UIColor, fraction:CGFloat) -> UIColor {
        let f = min(1, max(0, fraction))
        let c1: [CGFloat] = self.cgColor.components!
        let c2: [CGFloat]  = end.cgColor.components!
        let r = (c1[0] + (c2[0] - c1[0]) * f)
        let g = (c1[1] + (c2[1] - c1[1]) * f)
        let b = (c1[2] + (c2[2] - c1[2]) * f)
        let a = (c1[3] + (c2[3] - c1[3]) * f)
        return UIColor.init(red:r, green:g, blue:b, alpha:a)
    }
}
