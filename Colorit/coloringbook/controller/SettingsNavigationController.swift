//
//  SettingsNavigationControllerViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 11/28/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class SettingsNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 5)
        navigationBar.layer.shadowRadius = 3
        navigationBar.layer.shadowOpacity = 0.3
    }
    
    func showSettings() {
        performSegue(withIdentifier: "ShowSettingsFirst", sender: nil)
    }
    
    func showShop() {
        performSegue(withIdentifier: "ShowShopFirst", sender: nil)
    }
}
