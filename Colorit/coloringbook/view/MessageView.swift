//
//  RoundCornersView.swift
//  coloringbook
//
//  Created by Iulian Dima on 11/26/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

@IBDesignable final class MessageView: UIView {

    @IBInspectable var radius: CGFloat = 20 {
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
    
    private func setupView() {
        layer.cornerRadius = radius
    }
    
    func fadeOut(){
        self.isHidden = false
        self.alpha = 1.0
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            [unowned self] in self.alpha = 0.0
            }, completion: nil)
    }

}
