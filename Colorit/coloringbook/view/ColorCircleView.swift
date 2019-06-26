//
//  ColorCircleView.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/6/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

enum ColorCircleState {
    case empty, normal, selected
}


final class ColorCircleView: UIView {
    
    let circleLayer = CAShapeLayer()
    let selectionLayer = CAShapeLayer()
    let plusLayer = CAShapeLayer()
    
    var id: Int?
    var state: ColorCircleState = .normal {
        didSet {
            switch state {
            case .empty:
                clearSelection()
                setEmpty()
            case .normal:
                clearSelection()
            case .selected:
                setSelection()
            }
        }
    }
    
    var color: UIColor = .red {
        didSet {
            circleLayer.fillColor = color.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createLayers()
    }
    
    func createLayers() {
        circleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 36, height: 36)  , cornerRadius: 18).cgPath
        circleLayer.position = CGPoint(x: self.bounds.midX - 18, y: self.bounds.midY - 18)
        circleLayer.fillColor = UIColor.white.cgColor
        layer.addSublayer(circleLayer)
        
        let shadowLayer = CALayer()
        shadowLayer.contents = UIImage(named: "colorCircleShadow")?.cgImage
        shadowLayer.frame = bounds
        layer.addSublayer(shadowLayer)
        createSelectionLayer()
        createPlusLayer()
    }

    private func clearSelection() {
        selectionLayer.removeFromSuperlayer()
        plusLayer.removeFromSuperlayer()
    }
    
    private func setSelection() {
        layer.addSublayer(selectionLayer)
    }
    
    private func setEmpty() {
        layer.addSublayer(plusLayer)
    }
    
    private func createSelectionLayer() {
        //
        let bigCircleLayer = CAShapeLayer()
        let radius: CGFloat = 7
        bigCircleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius)  , cornerRadius: radius).cgPath
        bigCircleLayer.position = CGPoint(x: self.bounds.midX - radius, y: self.bounds.midY - radius)
        bigCircleLayer.fillColor = UIColor.white.cgColor
        selectionLayer.addSublayer(bigCircleLayer)
        let smallCircleLayer = CAShapeLayer()
        smallCircleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 1.0 * radius, height: 1.0 * radius)  , cornerRadius: radius).cgPath
        smallCircleLayer.position = CGPoint(x: self.bounds.midX - radius/2, y: self.bounds.midY - radius/2)
        smallCircleLayer.fillColor = UIColor(hex: 0xEEEEEE).cgColor
        selectionLayer.addSublayer(smallCircleLayer)
    }
    
    private func createPlusLayer() {
        // Create a plus sign
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.5
        
        //create the path
        let plusPath = UIBezierPath()
    
        //to the start of the horizontal stroke
        plusPath.move(to: CGPoint(
            x:bounds.width/2 - plusWidth/2 + 0.5,
            y:bounds.height/2 + 0.5))
        
        //add a point to the path at the end of the stroke
        plusPath.addLine(to: CGPoint(
            x:bounds.width/2 + plusWidth/2 + 0.5,
            y:bounds.height/2 + 0.5))
        
        //move to the start of the vertical stroke
        plusPath.move(to: CGPoint(
            x:bounds.width/2 + 0.5,
            y:bounds.height/2 - plusWidth/2 + 0.5))
        
        //add the end point to the vertical stroke
        plusPath.addLine(to: CGPoint(
            x:bounds.width/2 + 0.5,
            y:bounds.height/2 + plusWidth/2 + 0.5))
        
        plusLayer.path = plusPath.cgPath
        plusLayer.lineWidth = 4.0
        plusLayer.strokeColor = UIColor.white.cgColor
        plusLayer.fillColor = UIColor.red.cgColor
    }
    
}
