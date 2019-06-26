//
//  PalettesNavigationController.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/11/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class PalettesNavigationController: UINavigationController {

    var close:(()->Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 5)
        navigationBar.layer.shadowRadius = 3
        navigationBar.layer.shadowOpacity = 0.3
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        close?()
    }
    
    func showPalettes() {
        performSegue(withIdentifier: "ShowPalettesFirst", sender: nil)
    }
    
    func showColorPicker() {
        performSegue(withIdentifier: "ShowColorPickerFirst", sender: nil)
    }
}
