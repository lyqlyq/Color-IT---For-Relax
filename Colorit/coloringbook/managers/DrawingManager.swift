//
//  DrawingManager.swift
//  coloringbook
//
//  Created by Iulian Dima on 11/3/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import Foundation
import UIKit

enum DrawingTools: Int {
    case Fill, Pen
}

class DrawingManager {
    
    static let sharedInstance = DrawingManager()
    
    var selectedColor: UIColor = UIColor.brown {
        didSet {
            if selectedColor.hex() == 0x000000 {
                selectedColor = UIColor(hex: 0x111111)
            }
        }
    }
    
    var selectedTool: DrawingTools = .Fill
    
    // For a different line width change this value
    var lineWidth: CGFloat = 20
    
    private init() {
        
    }
}
