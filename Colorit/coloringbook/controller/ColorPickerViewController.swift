//
//  ColorPickerControllerViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/8/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit
//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l > r
//  default:
//    return rhs < lhs
//  }
//}


class ColorPickerViewController: UIViewController {

    @IBOutlet weak var colorWell: ColorWell?
    @IBOutlet weak var colorPicker: ColorPicker?
    @IBOutlet weak var huePicker: HuePicker?
    
    var pickerController: ColorPickerController!
    var pickedColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickedColor = DrawingManager.sharedInstance.selectedColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pickerController = ColorPickerController(svPickerView: colorPicker!, huePickerView: huePicker!, colorWell: colorWell!)
        pickerController?.color = pickedColor
        // get color updates
        pickerController?.onColorChange = {[unowned self] (color, finished) in
            if finished { self.pickedColor = color }
        }
    }
    
    @IBAction func saveColor(_ sender: AnyObject) {
        
        let changedColorId = PalettesManager.sharedInstance.changedColorId
        let changedPaletteId = PalettesManager.sharedInstance.changedPaletteId
        
        PalettesManager.sharedInstance.saveColor(pickedColor, colorId: changedColorId, paletteId: changedPaletteId)
        
        if let navController = self.navigationController {
            if navController.viewControllers.index(of: self)! > 0 {
                navController.popViewController(animated: true)
            } else {
                navController.dismiss(animated: true, completion: nil)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func cancel(_ sender: AnyObject) {
        if let navController = self.navigationController {
            if navController.viewControllers.index(of: self)! > 0 {
                navController.popViewController(animated: true)
            } else {
                navController.dismiss(animated: true, completion: nil)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

}
