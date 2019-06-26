//
//  VerticalPaletteViewTableViewCell.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/4/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class VerticalPaletteView: UITableViewCell {
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    private weak var table: UITableView!
    private var selectedColorView: ColorCircleView?
    private var cellId: Int!
    
    var addColorTapped:(()->Void)? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        Bundle.main.loadNibNamed("VerticalPalette", owner: self, options: nil)
        addSubview(view)
        view.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setColors(_ colors: [UIColor?]) {
        var i = 0
        for subview in view.subviews {
            if let colorView = subview as? ColorCircleView {

                colorView.id = i
                
                let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(colorTapped(_ :)))
                colorView.addGestureRecognizer(tapGestureRecognizer)
                colorView.isUserInteractionEnabled = true

                if let validColor = colors[i] {
                    colorView.color = validColor
                    colorView.state = .normal
                } else {
                    colorView.color = UIColor.lightGray
                    colorView.state = .empty
                }
                
                if PalettesManager.sharedInstance.selectedPaletteId == cellId &&
                PalettesManager.sharedInstance.selectedColorId == i {
                    selectColorCircle(colorView)
                }
                i += 1
            }
        }
    }
    
    func configureCellWithId(_ id: Int, table: UITableView, title: String, colors: [UIColor?]) {
        self.cellId = id
        self.titleLbl.text = title
        self.table = table
        setColors(colors)
    }
    
    
    @objc func colorTapped(_ tap: UITapGestureRecognizer) {
        if let colorView = tap.view as? ColorCircleView {
            if colorView.state == .normal {
                deselectCurrentCircle()
                selectColorCircle(colorView)
            } else {
                PalettesManager.sharedInstance.changedColorId = colorView.id!
                PalettesManager.sharedInstance.changedPaletteId = cellId
                addColorTapped?()
            }
        }
    }
    
    func deselectCurrentCircle() {
        let indexPath = IndexPath(row: PalettesManager.sharedInstance.selectedPaletteId, section: 0)
        if let cell = table.cellForRow(at: indexPath) as? VerticalPaletteView {
            cell.selectedColorView?.state = .normal
        }
    }
    
    private func selectColorCircle(_ colorCircle: ColorCircleView) {
        // Set new selection
        PalettesManager.sharedInstance.selectedColorId = colorCircle.id!
        DrawingManager.sharedInstance.selectedColor = colorCircle.color
        PalettesManager.sharedInstance.selectedPaletteId = cellId
        selectedColorView = colorCircle
        selectedColorView!.state = .selected
        // Select table row
//        let indexPath = IndexPath(row: PalettesManager.sharedInstance.selectedPaletteId, section: 0)
//        table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
    


}
