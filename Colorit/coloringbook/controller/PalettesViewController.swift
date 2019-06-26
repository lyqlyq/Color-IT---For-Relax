//
//  PalettesViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/4/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class PalettesViewController: UIViewController {

    @IBOutlet weak var palettesTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cell = VerticalPaletteView()
        palettesTableView.rowHeight = cell.view.frame.size.height
        
        palettesTableView.delegate = self
        palettesTableView.dataSource = self
        
        palettesTableView.register(VerticalPaletteView.self, forCellReuseIdentifier: "PaletteCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        palettesTableView.reloadData()
    }
    
    @IBAction func addNewPalette(_ sender: AnyObject) {
        PalettesManager.sharedInstance.createNewUserPalette()
        palettesTableView.reloadData()
        let indexPath = IndexPath(item: PalettesManager.sharedInstance.palettes.count - 1, section: 0)
        palettesTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func showColorPicker() {
        performSegue(withIdentifier: "ShowColorPicker", sender: nil)
    }
}

extension PalettesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PalettesManager.sharedInstance.palettes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaletteCell") as! VerticalPaletteView
        let paletteName = PalettesManager.sharedInstance.palettes[indexPath.item].name
        let paletteColors = PalettesManager.sharedInstance.palettes[indexPath.item].colors
        
        let isUserGenerated = PalettesManager.sharedInstance.palettes[indexPath.item].isUserGenerated
        
        cell.configureCellWithId(indexPath.item, table: palettesTableView, title: paletteName, colors: paletteColors)
        
        cell.addColorTapped = {
            [unowned self] in if isUserGenerated { self.showColorPicker() }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if PalettesManager.sharedInstance.palettes[indexPath.item].isUserGenerated {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            PalettesManager.sharedInstance.deletePaletteAtIndex(indexPath.item)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
