//
//  DrawingView.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/28/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    
    weak var scrollView: UIScrollView?
    
    var onImageDraw:((_ drawingImage: UIImage)->Void)? = nil
    var onProcessComplete:(()->Void)? = nil
    
    private var image: UIImage!
    private var borders: UIImage!
    private var lineWidth: CGFloat!
    private var path = UIBezierPath()
    private var pointsCount: Int = 0
    private var maskLayer = CALayer()
    private var drawingLayer = CAShapeLayer()
    private var imageData: UnsafeMutablePointer<UInt32>!
    private var regionsData: UnsafeMutablePointer<UInt32>!
    private var maskData: UnsafeMutablePointer<UInt32>!
    private var imageWidth: Int!
    private var imageHeight: Int!
    private var imageScale: CGFloat!
    private var imageContext: CGContext!
    private var maskContext: CGContext!
    private var smartBorders = true
    private let blackColor: UInt32 = 4278190080
    private let whiteColor: UInt32 = 4294967295
    
    var tool:DrawingTools = .Pen {
        didSet {
            if tool == .Fill {
                drawingLayer.isHidden = true
                maskLayer.isHidden = true
            } else {
                drawingLayer.isHidden = false
                maskLayer.isHidden = false
                maskLayer.contents = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lineWidth = DrawingManager.sharedInstance.lineWidth
        smartBorders = SettingsManager.sharedInstance.smartBorders
        
        clipsToBounds = true
        backgroundColor = UIColor.white
        layer.addSublayer(drawingLayer)
        
        // Layer for creating a masking
        // When smart borders is on
        if smartBorders {
            maskLayer.bounds = bounds
            maskLayer.position = center
            drawingLayer.mask = maskLayer
        }
        
        layer.drawsAsynchronously = true
        
        isMultipleTouchEnabled = false
    }
    
    deinit {
        // TODO: Fix it in swift 5
//        regionsData.deallocate(capacity: imageWidth * imageHeight)
        //print("DrawingV deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadImage(_ image: UIImage, savedImage: UIImage?) {

        DispatchQueue.global(qos: .background).async {
            self.processRegions(image, lastImage: savedImage)
        }
        
        let imageTap = UITapGestureRecognizer(target:self, action:#selector(imageTapped(_ :)))
        imageTap.numberOfTapsRequired = 1
        addGestureRecognizer(imageTap)
    }
    
    func processRegions(_ image: UIImage, lastImage: UIImage?) {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let imageCG = image.cgImage!
        imageWidth = imageCG.width
        imageHeight = imageCG.height
        imageScale = image.scale
        
        //print(imageWidth)
        //print(imageHeight)
        
        let bitsPerComponent = imageCG.bitsPerComponent
        let bytesPerRow = 4 * imageWidth
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        
        imageContext = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)!
        imageContext.draw(imageCG, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        
        let rawPointer = imageContext.data
        imageData = rawPointer!.bindMemory(to: UInt32.self, capacity: imageWidth * imageHeight)
        
        var pointer: UnsafeMutablePointer<UInt32> = imageData
        
        // Scan image and make all pixels color to white except where is black
        
        for _ in 0...(imageHeight - 1) {
            for _ in 0...(imageWidth - 1) {
                pointer = pointer.successor()

                if (pointer.pointee >> 24) > 100 {
                    pointer.pointee = blackColor
                } else {
                    pointer.pointee = whiteColor
                }
            }
        }
        
        // Copy to regionsData
        
        regionsData = UnsafeMutablePointer<UInt32>.allocate(capacity: imageWidth * imageHeight)
        regionsData.assign(from: imageData, count: imageWidth * imageHeight)
        
        // Color each region with unique color
        
        var byteIndex, x, y: Int
        var pointsStack: Stack<CGPoint>
        var newColor: UInt32 = blackColor
        var pixelColor: UInt32
        var spanLeft, spanRight: Bool
        
        for i in 0...(imageHeight - 1) {
            for j in 0...(imageWidth - 1) {
                x = j
                y = i
                byteIndex = (imageWidth * y) + x
                
                pixelColor = regionsData.advanced(by: byteIndex).pointee

                if pixelColor != whiteColor { continue }
                
                pointsStack = Stack<CGPoint>()
                pointsStack.push(CGPoint(x: x, y: y))
                
                newColor += 1
                
                spanLeft = false
                spanRight = false
                
                while let point = pointsStack.pop() {
                    x = Int(round(point.x))
                    y = Int(round(point.y))
                    byteIndex = (imageWidth * y) + x
                    pixelColor = regionsData.advanced(by: byteIndex).pointee
                    
                    while y >= 0 &&  pixelColor != blackColor{
                        y -= 1
                        if y >= 0 {
                            byteIndex = (imageWidth * y) + x
                            pixelColor = regionsData.advanced(by: byteIndex).pointee
                        }
                    }
                    
                    y += 1
                    
                    spanLeft = false
                    spanRight = false
                    
                    byteIndex = (imageWidth * y) + x
                    pixelColor = regionsData.advanced(by: byteIndex).pointee
                    
                    while y < imageHeight && pixelColor != blackColor &&  pixelColor != newColor {
                        regionsData.advanced(by: byteIndex).pointee = newColor
                        
                        if x > 0 {
                            byteIndex = (imageWidth * y) + (x - 1)
                            pixelColor = regionsData.advanced(by: byteIndex).pointee
                            
                            if !spanLeft && x > 0 && pixelColor != blackColor {
                                pointsStack.push(CGPoint(x: (x - 1), y: y))
                                spanLeft = true
                            } else if spanLeft && x > 0 && pixelColor == blackColor {
                                spanLeft = false
                            }
                        }
                        
                        if x < (imageWidth - 1) {
                            byteIndex = (imageWidth * y) + (x + 1)
                            pixelColor = regionsData.advanced(by: byteIndex).pointee
                            
                            if !spanRight && pixelColor != blackColor {
                                pointsStack.push(CGPoint(x: (x + 1), y: y))
                                spanRight = true
                            } else if spanRight && pixelColor == blackColor {
                                spanRight = false
                            }
                        }
                        
                        y += 1
                        
                        if y < imageHeight {
                            byteIndex = (imageWidth * y) + x
                            pixelColor = regionsData.advanced(by: byteIndex).pointee
                        }
                    }
                }
            }
        }
        
        self.borders = UIImage(cgImage: imageContext.makeImage()!, scale: imageScale, orientation: .up)
        if let cgLastImage = lastImage?.cgImage {
            imageContext.draw(cgLastImage, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        }
        
        self.image = UIImage(cgImage: imageContext.makeImage()!)
        
        DispatchQueue.main.async {
            CATransaction.setDisableActions(true)
            self.layer.contents = self.image.cgImage
            self.onProcessComplete?()
            self.onImageDraw?(self.image)
        }
        
        maskContext = CGContext(data: nil, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)!
        maskContext.clear(CGRect(origin: .zero, size: CGSize(width: imageWidth, height: imageHeight)))
        maskData = maskContext.data!.bindMemory(to: UInt32.self, capacity: imageWidth * imageHeight)
    }
    
    func fillRegion(pixelX: Int, pixelY: Int, withColor color: UIColor) {
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let newColor = (UInt32)(alpha*255)<<24 | (UInt32)(red*255)<<16 | (UInt32)(green*255)<<8 | (UInt32)(blue*255)<<0
        
        let pixelColor = regionsData.advanced(by: (pixelY * imageWidth) + pixelX).pointee
        
        if pixelColor == blackColor { return }
        
        var pointerRegionsData: UnsafeMutablePointer<UInt32> = regionsData
        var pointerImageData: UnsafeMutablePointer<UInt32> = imageData
        
        var pixelsChanged = false
        
        for i in 0...(imageHeight * imageWidth - 1) {
            if pointerRegionsData.pointee == pixelColor {
                pointerImageData = imageData.advanced(by: i)
                if pointerImageData.pointee != newColor {
                    pointerImageData.pointee = newColor
                    pixelsChanged = true
                }
            }
            pointerRegionsData = pointerRegionsData.successor()
        }
        
        if !pixelsChanged && Constants.clearFill {
            // Clear fill
            pointerRegionsData = regionsData
            pointerImageData = imageData
            
            for i in 0...(imageHeight * imageWidth - 1) {
                if pointerRegionsData.pointee == pixelColor {
                    pointerImageData = imageData.advanced(by: i)
                    pointerImageData.pointee = whiteColor
                }
                pointerRegionsData = pointerRegionsData.successor()
            }
            
        }
        
        if pixelsChanged || Constants.clearFill {
            self.image = UIImage(cgImage: imageContext.makeImage()!)
            DispatchQueue.main.async {
                // Fade color animation
                let fadeAnim:CABasicAnimation = CABasicAnimation(keyPath: "contents")
                fadeAnim.fromValue = self.layer.contents
                fadeAnim.toValue   = self.image.cgImage
                fadeAnim.duration  = 0.5         //smoothest value
                self.layer.add(fadeAnim, forKey: "contents")

                self.layer.contents = self.image.cgImage
                self.onImageDraw?(self.image)
            }
            self.playTapSound()
        }

    }
    
    func fillMask(pixelX: Int, pixelY: Int) {
        
        let pixelColor = regionsData.advanced(by: (pixelY * imageWidth) + pixelX).pointee
        
        if pixelColor == blackColor { return }
        
        var pointerRegionsData: UnsafeMutablePointer<UInt32> = regionsData
        var pointerMaskData: UnsafeMutablePointer<UInt32> = maskData
        
        for _ in 0...(imageHeight * imageWidth - 1) {
            if pointerRegionsData.pointee == pixelColor {
                pointerMaskData.pointee = blackColor
            } else {
                pointerMaskData.pointee = 0
            }
            pointerRegionsData = pointerRegionsData.successor()
            pointerMaskData = pointerMaskData.successor()
        }
        
        CATransaction.setDisableActions(true)
        self.maskLayer.contents = self.maskContext.makeImage()
    }
    
    func isChanged() -> Bool {
        
        var pointerImageData: UnsafeMutablePointer<UInt32> = imageData
        
        for _ in 0...(imageHeight * imageWidth - 1) {
            if pointerImageData.pointee != blackColor && pointerImageData.pointee != whiteColor && pointerImageData.pointee != 0 {
                return true
            }
            pointerImageData = pointerImageData.successor()
        }
        return false
    }
    
    func updateImage(_ image: UIImage) {
        self.image = image
        imageContext.draw(self.image.cgImage!, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        CATransaction.setDisableActions(true)
        layer.contents = self.image.cgImage
    }
    
    
    func playTapSound() {
        if SettingsManager.sharedInstance.soundEffects, let url = Bundle.main.url(forResource: "click", withExtension: "aiff") {
            let player = AudioPlayer.playerWithURL(url)
            player?.play()
        }
    }
    
    @objc func imageTapped(_ tap: UITapGestureRecognizer) {
        
        if tool != .Fill { return }
        
        let tapPos = tap.location(in: self)
        let pixelPosX = Int(tapPos.x / self.frame.size.width * CGFloat(imageWidth))
        let pixelPosY = Int(tapPos.y / self.frame.size.height  * CGFloat(imageHeight))
        
        DispatchQueue.global(qos: .background).async {
            //let startTime = CFAbsoluteTimeGetCurrent()
            self.fillRegion(pixelX: pixelPosX, pixelY: pixelPosY, withColor: DrawingManager.sharedInstance.selectedColor)
            //print("Time elapsed to fill color: \((CFAbsoluteTimeGetCurrent() - startTime) * 1000) ms")
        }
    }
    
    func imageDoubleTapped(_ tap: UITapGestureRecognizer) {
        
        //if tool != .Fill { return }
        
        let tapPos = tap.location(in: self)
        let pixelPosX = Int(tapPos.x / self.frame.size.width * CGFloat(imageWidth))
        let pixelPosY = Int(tapPos.y / self.frame.size.height  * CGFloat(imageHeight))
        
        DispatchQueue.global(qos: .background).async {
            //let startTime = CFAbsoluteTimeGetCurrent()
            self.fillRegion(pixelX: pixelPosX, pixelY: pixelPosY, withColor: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
            //print("Time elapsed to fill color: \((CFAbsoluteTimeGetCurrent() - startTime) * 1000) ms")
        }
    }
    
    private func startPath(point: CGPoint) {
        
        path = UIBezierPath()
        path.move(to: point)
        pointsCount = 1
    }
    
    private func updatePath(point: CGPoint) {
        
        if path.isEmpty { return }
        
        CATransaction.setDisableActions(true)
        drawingLayer.strokeColor = DrawingManager.sharedInstance.selectedColor.cgColor
        drawingLayer.fillColor = nil
        drawingLayer.lineWidth = lineWidth
        drawingLayer.lineCap = CAShapeLayerLineCap.round
        drawingLayer.lineJoin = CAShapeLayerLineJoin.round
        
        path.addLine(to: point)
        drawingLayer.path = path.cgPath
        pointsCount += 1
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if tool != .Pen || touches.count > 1 { return }
        
        enableScrollView(false)
        
        let touchPos = touches.first!.location(in: self)
        
        if smartBorders {
            let pixelPosX = Int(touchPos.x / self.frame.size.width * CGFloat(imageWidth))
            let pixelPosY = Int(touchPos.y / self.frame.size.height  * CGFloat(imageHeight))
            self.fillMask(pixelX: pixelPosX, pixelY: pixelPosY)
        }
        startPath(point: touchPos)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard tool == .Pen && touches.count == 1 else { return }
        
        let currentPoint = touches.first!.location(in: self)
        updatePath(point: currentPoint)
        
        guard pointsCount > 100 else { return }
        
        
        image = takeSnapshot()
        imageContext.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        CATransaction.setDisableActions(true)
        layer.contents = image.cgImage
        drawingLayer.path = nil
        path = UIBezierPath()
        path.move(to: currentPoint)
        pointsCount = 1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if tool != .Pen { return }
        
        enableScrollView(true)
        
        let currentPoint = touches.first!.location(in: self)
        updatePath(point: currentPoint)
        
        image = takeSnapshot()
        imageContext.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        CATransaction.setDisableActions(true)
        layer.contents = image.cgImage
        drawingLayer.path = nil
        path = UIBezierPath()
        
        onImageDraw?(image)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        
        if tool != .Pen { return }
        
        touchesEnded(touches!, with: event)
    }
    
    private func enableScrollView(_ enable: Bool) {
        scrollView?.isScrollEnabled  = enable
        scrollView?.pinchGestureRecognizer?.isEnabled = enable
        scrollView?.panGestureRecognizer.isEnabled = enable
    }
    
    private func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, imageScale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        if !smartBorders { borders.draw(at: CGPoint.zero, blendMode: .darken, alpha: 1)}
        let savedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return savedImage
    }
    
}
