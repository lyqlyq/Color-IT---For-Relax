//
//  HorizontalPaletteView.swift
//  coloringbook
//
//  Created by Iulian Dima on 9/29/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class HorizontalPaletteView: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    private weak var collection: UICollectionView!
    private var cellId: Int!
    private var selectedColorView: ColorCircleView?
    
    var addColorTapped:(()->Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        if UIScreen.main.traitCollection.userInterfaceIdiom == .pad {
            Bundle.main.loadNibNamed("HorizontalPaletteIPad", owner: self, options: nil)
        } else if UIScreen.main.traitCollection.userInterfaceIdiom == .phone {
            Bundle.main.loadNibNamed("HorizontalPaletteIPhone", owner: self, options: nil)
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        
        view.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
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
                
                if PalettesManager.sharedInstance.selectedPaletteId == cellId && PalettesManager.sharedInstance.selectedColorId == i {
                    selectColorCircle(colorView)
                }
                i += 1
            }
        }
    }
    
    func configureCellWithId(_ id: Int, collection: UICollectionView, title: String, colors: [UIColor?]) {
        self.cellId = id
        self.titleLbl.text = title
        self.collection = collection
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
        if let cell = collection.cellForItem(at: indexPath) as? HorizontalPaletteView {
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
    }
}
