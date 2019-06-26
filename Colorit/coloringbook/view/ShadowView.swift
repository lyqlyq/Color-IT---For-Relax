//
//  TopShadowView.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/23/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

@IBDesignable class ShadowView: UIView {

    @IBInspectable var offsetX: CGFloat = 0 {
        didSet { setupView() }
    }
    @IBInspectable var offsetY: CGFloat = 5 {
        didSet { setupView() }
    }
    @IBInspectable var radius: CGFloat = 3 {
        didSet { setupView() }
    }
    @IBInspectable var opacity: Float = 0.3 {
        didSet { setupView() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        setupView()
    }
    
    func setupView() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }

}
