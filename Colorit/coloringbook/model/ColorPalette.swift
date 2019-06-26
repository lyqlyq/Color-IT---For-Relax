//
//  ColorPalette.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/6/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import Foundation
import UIKit

class ColorPalette {
    
    let name: String
    private(set) var colors: [UIColor?]
    let isUserGenerated: Bool
    
    init (name: String, colors: [UIColor?], isUserGenerated:Bool = false) {
        self.name = name
        self.colors = colors
        self.isUserGenerated = isUserGenerated
    }
    
    func setColor(_ color: UIColor, atIndex index:Int) {
        colors[index] = color
    }
    
    
}
