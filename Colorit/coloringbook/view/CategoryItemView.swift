//
//  CategoryItemView.swift
//  coloringbook
//
//  Created by Iulian Dima on 8/18/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class CategoryItemView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    var index: Int = 0
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var selected: Bool! {
        didSet {
            changeBackgroundColor()
        }
    }
    
    convenience init (title: String, index: Int) {

        self.init(frame: CGRect.zero)
        self.index = index
        defer {
            self.title = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        Bundle.main.loadNibNamed("CategoryItem", owner: self, options: nil)
        self.view.frame = bounds
        self.view.layer.cornerRadius = 5
        self.addSubview(self.view)
    }
    
    private func changeBackgroundColor() {
        if selected == true {
            self.view.backgroundColor = UIColor(hex: 0x39B68A)
            self.titleLabel.textColor = UIColor.white
        } else {
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.view.backgroundColor = UIColor.white
                self.titleLabel.textColor = UIColor.black
            }
        }
    }
}
