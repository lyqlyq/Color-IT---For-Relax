//
//  DrawingViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 9/19/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit
import CoreImage

class DrawingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var palettesView: UICollectionView!
    @IBOutlet weak var palettesViewWidth: NSLayoutConstraint!
    @IBOutlet weak var palettesViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var undoBtn:UIButton!
    @IBOutlet weak var redoBtn:UIButton!
    @IBOutlet weak var stopView:MessageView!
    @IBOutlet weak var undoView:MessageView!
    @IBOutlet weak var redoView:MessageView!
    
    var palettesBtnTapped = false
    var selectedPaletteIdOnPopOver = 0
    
    var drawingView: DrawingView!
    var contentView: UIView!
    var contentViewTop: NSLayoutConstraint!
    var contentViewBottom: NSLayoutConstraint!
    var contentViewTrailing: NSLayoutConstraint!
    var contentViewLeading: NSLayoutConstraint!
    var lastZoomScale: CGFloat?
    var imageSize: CGSize!
    var imageScale: CGFloat!
    var thumbImageSize: CGSize!
    var thumbImageScale: CGFloat!
    var minZoomScale: CGFloat!
    var fitZoomScale: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopView.isHidden = true
        undoView.isHidden = true
        redoView.isHidden = true
        
        PalettesManager.sharedInstance.selectedPaletteId = 0
        PalettesManager.sharedInstance.selectedColorId = 0
        
        let cell = HorizontalPaletteView()
        let cellSpacing = (view.bounds.width - cell.view.frame.size.width) / 2
        palettesViewWidth.constant = cell.view.frame.size.width + cellSpacing * 2
        palettesViewHeight.constant = cell.view.frame.size.height
        let layout: CenterCellCollectionViewFlowLayout = CenterCellCollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: cellSpacing, bottom: 0, right: cellSpacing)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = cellSpacing
        layout.itemSize = CGSize(width: cell.view.frame.size.width, height: cell.view.frame.size.height)
        palettesView.decelerationRate = UIScrollView.DecelerationRate.fast
        palettesView.collectionViewLayout = layout
        if #available(iOS 10.0, *) { palettesView.isPrefetchingEnabled = false }
        
        scrollView.delegate = self
        palettesView.delegate = self
        palettesView.dataSource = self
        
        palettesView.register(HorizontalPaletteView.self, forCellWithReuseIdentifier: "PaletteCell")
        palettesView.backgroundColor = UIColor.clear
        
        let smoothLinesImage = DataManager.sharedInstance.getSelectedImage()!
        imageSize = smoothLinesImage.size
        imageScale = smoothLinesImage.scale
        
        let borders = UIImageView(image: smoothLinesImage)
        drawingView = DrawingView(frame: borders.frame)
        drawingView.scrollView = scrollView
        DrawingManager.sharedInstance.selectedTool = .Fill
        drawingView.tool = DrawingManager.sharedInstance.selectedTool
        
        let updateUndoRedoButtons:(()->Void) = {
            [weak self] in
            if DrawingUndoManager.sharedInstance.hasUndo() {
                self?.undoBtn.isEnabled = true
                self?.undoBtn.alpha = 1.0
            } else {
                self?.undoBtn.isEnabled = false
                self?.undoBtn.alpha = 0.5
            }
            if DrawingUndoManager.sharedInstance.hasRedo() {
                self?.redoBtn.isEnabled = true
                self?.redoBtn.alpha = 1.0
            } else {
                self?.redoBtn.isEnabled = false
                self?.redoBtn.alpha = 0.5
            }
        }
        
        DrawingUndoManager.sharedInstance.onUpdate = updateUndoRedoButtons
        DrawingUndoManager.sharedInstance.reset()
        
        let saveSnapShot:((UIImage) -> Void) = {
            image in DrawingUndoManager.sharedInstance.saveSnapshot(image)
        }
        
        let showImage:(()->Void) = {
            [weak self] in self?.contentView.isHidden = false
        }
        
        drawingView.onImageDraw = saveSnapShot
        drawingView.onProcessComplete = showImage
        
        
        drawingView.loadImage(smoothLinesImage, savedImage: DataManager.sharedInstance.getSavedImage())
        
        contentView = UIView(frame: drawingView.frame)
        contentView.backgroundColor = UIColor.red
        contentView.addSubview(drawingView)
        contentView.addSubview(borders)
        contentView.isHidden = true
        
        
        contentView.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
        
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
        
        if SettingsManager.sharedInstance.undoSwipe {
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
            leftSwipe.direction = .left
            leftSwipe.numberOfTouchesRequired = 2
            scrollView.addGestureRecognizer(leftSwipe)
            
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(_:)))
            rightSwipe.direction = .right
            rightSwipe.numberOfTouchesRequired = 2
            scrollView.addGestureRecognizer(rightSwipe)
            
            scrollView.panGestureRecognizer.require(toFail: leftSwipe)
            scrollView.panGestureRecognizer.require(toFail: rightSwipe)
            scrollView.pinchGestureRecognizer?.require(toFail: leftSwipe)
            scrollView.pinchGestureRecognizer?.require(toFail: rightSwipe)
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewTop = contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0)
        contentViewTop.isActive = true
        contentViewBottom = contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0)
        contentViewBottom.isActive = true
        contentViewLeading = contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0)
        contentViewLeading.isActive = true
        contentViewTrailing = contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0)
        contentViewTrailing.isActive = true
    }
    
    deinit {
        //print("DrawingVC deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateZoom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SettingsManager.sharedInstance.waitForTransition = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func playUndoRedoSound() {
        if SettingsManager.sharedInstance.soundEffects, let url = Bundle.main.url(forResource: "undo", withExtension: "aiff") {
            let player = AudioPlayer.playerWithURL(url)
            player?.play()
        }
    }
    
    func playNoUndoRedoSound() {
        if SettingsManager.sharedInstance.soundEffects, let url = Bundle.main.url(forResource: "wrong", withExtension: "aiff") {
            let player = AudioPlayer.playerWithURL(url)
            player?.play()
        }
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .right) {
            if DrawingUndoManager.sharedInstance.hasRedo() {
                guard let image = DrawingUndoManager.sharedInstance.redo() else { return }
                playUndoRedoSound()
//                view.bringSubview(toFront: redoView)
                view.bringSubviewToFront(redoView)
                redoView.fadeOut()
                drawingView.updateImage(image)
            } else {
                playNoUndoRedoSound()
//                view.bringSubview(toFront: stopView)
                view.bringSubviewToFront(stopView)
                stopView.fadeOut()
            }
        } else if (sender.direction == .left) {
            if DrawingUndoManager.sharedInstance.hasUndo() {
                guard let image = DrawingUndoManager.sharedInstance.undo() else { return }
                playUndoRedoSound()
//                view.bringSubview(toFront: undoView)
                view.bringSubviewToFront(undoView)
                undoView.fadeOut()
                drawingView.updateImage(image)
            } else {
                playNoUndoRedoSound()
//                view.bringSubview(toFront: stopView)
                view.bringSubviewToFront(stopView)
                stopView.fadeOut()
            }
            
        }
    }
    
    
    @IBAction func undo(_ sender: AnyObject) {
        guard let image = DrawingUndoManager.sharedInstance.undo() else { return }
        playUndoRedoSound()
        drawingView.updateImage(image)
    }
    
    @IBAction func redo(_ sender: AnyObject) {
        guard let image = DrawingUndoManager.sharedInstance.redo() else { return }
        playUndoRedoSound()
        drawingView.updateImage(image)
    }
    
    func updateConstraints() {
        let viewWidth = scrollView.bounds.size.width
        let viewHeight = scrollView.bounds.size.height
        
        // Center image if it is smaller than the scroll view
        let xOffset = max(0, (viewWidth - scrollView.zoomScale * imageSize.width) * 0.5)
        let yOffset = max(0, (viewHeight - scrollView.zoomScale * imageSize.height) * 0.5)
        
        contentViewTop.constant = yOffset
        contentViewBottom.constant = yOffset
        contentViewTrailing.constant = xOffset
        contentViewLeading.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    private func updateZoom() {
        let widthScale = scrollView.bounds.size.width / imageSize.width
        let heightScale = scrollView.bounds.size.height / imageSize.height
        
        fitZoomScale = min(widthScale, heightScale)
        minZoomScale = fitZoomScale * 0.5
        
        scrollView.maximumZoomScale = 6
        scrollView.minimumZoomScale = minZoomScale
        
        if let lastScale = lastZoomScale {
            if lastScale < minZoomScale {
                scrollView.zoomScale = minZoomScale
            } else {
                scrollView.zoomScale = lastScale
            }
            
            if scrollView.zoomScale > fitZoomScale {
                scrollView.minimumZoomScale = fitZoomScale
            }
            
        } else {
            scrollView.zoomScale = fitZoomScale
        }
        
        lastZoomScale = scrollView.zoomScale
        updateConstraints()
    }
    
    func colorTapped() {
        performSegue(withIdentifier: "ShowPalettesAndColor", sender: nil)
    }
    
    
    @IBAction func shareAndSave(_ sender: AnyObject) {
        performSegue(withIdentifier: "ShowSharingViewController", sender: nil)
    }
    
    @IBAction func showPalettesAndColor(_ sender: AnyObject) {
        palettesBtnTapped = true
        performSegue(withIdentifier: "ShowPalettesAndColor", sender: nil)
    }
    
    @IBAction func changeTool(_ sender: AnyObject) {
        if DrawingManager.sharedInstance.selectedTool == .Fill {
            DrawingManager.sharedInstance.selectedTool = .Pen
            if let toolBtn = sender as? UIButton {
                toolBtn.setImage(UIImage(named: "fillBtn"), for: .normal)
            }
        } else {
            DrawingManager.sharedInstance.selectedTool = .Fill
            if let toolBtn = sender as? UIButton {
                toolBtn.setImage(UIImage(named: "pencilBtn"), for: .normal)
            }
        }
        drawingView.tool = DrawingManager.sharedInstance.selectedTool
    }
    
    @IBAction func backToGallery(_ sender: AnyObject) {
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPalettesAndColor" {
            guard let popoverViewController = segue.destination as? PalettesNavigationController else {return}
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController?.delegate = self
            popoverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            popoverViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: 0,height: 0)
            if palettesBtnTapped {
                popoverViewController.showPalettes()
            } else {
                popoverViewController.showColorPicker()
            }
            
            palettesBtnTapped = false
            
            selectedPaletteIdOnPopOver = PalettesManager.sharedInstance.selectedPaletteId
            
            popoverViewController.close = {
                [unowned self] in
                self.palettesView.reloadData()
                if self.selectedPaletteIdOnPopOver != PalettesManager.sharedInstance.selectedPaletteId {
                    let indexPath = IndexPath(item: PalettesManager.sharedInstance.selectedPaletteId, section: 0)
                    self.palettesView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                }
            }
        } else if segue.identifier == "ShowSharingViewController" {
            guard let sharingViewController = segue.destination as? SharingViewController else {return}
            // Take snapshot of current drawing
            // Send it to sharing view controller
            UIGraphicsBeginImageContextWithOptions(imageSize, true, imageScale)
            contentView.layer.render(in: UIGraphicsGetCurrentContext()!)
            sharingViewController.snapshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Save current drawing for later use
            guard drawingView.isChanged() else { return }
            UIGraphicsBeginImageContextWithOptions(imageSize, true, imageScale)
            drawingView.layer.render(in: UIGraphicsGetCurrentContext()!)
            DataManager.sharedInstance.saveImage(UIGraphicsGetImageFromCurrentImageContext()!)
            UIGraphicsEndImageContext()
        }
    }
}

extension DrawingViewController:UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        lastZoomScale = scrollView.zoomScale
        updateConstraints()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // Update min zoom scale (2 steps zooming)
        if scrollView.zoomScale > fitZoomScale {
            scrollView.minimumZoomScale = fitZoomScale
        } else {
            scrollView.minimumZoomScale = minZoomScale
        }
    }
}

extension DrawingViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PalettesManager.sharedInstance.palettes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = palettesView.dequeueReusableCell(withReuseIdentifier: "PaletteCell", for: indexPath) as! HorizontalPaletteView
        let paletteName = PalettesManager.sharedInstance.palettes[indexPath.item].name
        let paletteColors = PalettesManager.sharedInstance.palettes[indexPath.item].colors
        
        let isUserGenerated = PalettesManager.sharedInstance.palettes[indexPath.item].isUserGenerated
        
        cell.configureCellWithId(indexPath.item, collection: palettesView, title: paletteName, colors: paletteColors)
        
        cell.addColorTapped = {
            [unowned self] in if isUserGenerated { self.colorTapped() }
        }
        
        return cell
    }
    
}


extension DrawingViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

