//
//  SharingViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/13/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit
import Social

class SharingViewController: UIViewController {
    
    @IBOutlet weak var drawingImageView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var effectsView: UIView!
    @IBOutlet weak var sharingView: UIView!
    
    var snapshot: UIImage?
    var selectedEffectControl: UIControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 5)
        navigationBar.layer.shadowRadius = 3
        navigationBar.layer.shadowOpacity = 0.3
        guard let originalImage = snapshot else { return }
        drawingImageView.image = originalImage
        
        guard let watermark = UIImage(named: "watermark") else { return}
        UIGraphicsBeginImageContextWithOptions(originalImage.size, true, originalImage.scale)
        drawingImageView.image?.draw(at: .zero)
        let posX = originalImage.size.width - watermark.size.width
        let posY = originalImage.size.height - watermark.size.height
        watermark.draw(at: CGPoint(x: posX, y: posY))
        drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5) {
                [unowned self] in
                self.effectsView.alpha = 1.0
                self.sharingView.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                [unowned self] in
                self.effectsView.alpha = 0
                self.sharingView.alpha = 1.0
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func applyTexture(originalImage: UIImage, textureImage: UIImage) {
        UIGraphicsBeginImageContextWithOptions(originalImage.size, true, originalImage.scale)
        textureImage.draw(in: CGRect(origin: CGPoint.zero, size: originalImage.size))
        let resizedTextureImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let inputImage = CIImage(image: originalImage)
        let backgroundImage = CIImage(image: resizedTextureImage)
        let filter = CIFilter(name: "CISoftLightBlendMode")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
        
        let newCIImage = (filter?.outputImage)!
        
        let context = CIContext(options: nil)
        
        let newCGImage = context.createCGImage(newCIImage, from: newCIImage.extent)!
        
        drawingImageView.image = UIImage(cgImage: newCGImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        drawingImageView.contentMode = .scaleAspectFit
        
        guard let watermark = UIImage(named: "watermark") else { return}
        UIGraphicsBeginImageContextWithOptions(originalImage.size, true, originalImage.scale)
        drawingImageView.image?.draw(at: .zero)
        let posX = originalImage.size.width - watermark.size.width
        let posY = originalImage.size.height - watermark.size.height
        watermark.draw(at: CGPoint(x: posX, y: posY))
        drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func makeSelection(control: UIControl) {
        if let previous = selectedEffectControl {
            previous.layer.borderColor = nil
            previous.layer.borderWidth = 0
        }
        control.layer.borderColor = UIColor(hex: 0x39B68A).cgColor
        control.layer.borderWidth = 3.0
        
        selectedEffectControl = control
    }
    
    @IBAction func removeTexture(_ sender: UIControl) {
        guard let originalImage = snapshot else { return }
        makeSelection(control: sender)
        drawingImageView.image = originalImage
    }
    
    @IBAction func applyTextureWood(_ sender: UIControl) {
        guard let originalImage = snapshot, let textureImage = UIImage(named: "textureWood.jpg")
            else { return }
        makeSelection(control: sender)
        applyTexture(originalImage: originalImage, textureImage: textureImage)
    }
    
    @IBAction func applyTextureAcryl(_ sender: UIControl) {
        guard let originalImage = snapshot, let textureImage = UIImage(named: "textureAcryl.jpg")
            else { return }
        makeSelection(control: sender)
        applyTexture(originalImage: originalImage, textureImage: textureImage)
        
    }
    
    @IBAction func applyTextureBrush(_ sender: UIControl) {
        guard let originalImage = snapshot, let textureImage = UIImage(named: "textureBrush.jpg")
            else { return }
        makeSelection(control: sender)
        applyTexture(originalImage: originalImage, textureImage: textureImage)
    }
    
    @IBAction func applyTexturePaper(_ sender: UIControl) {
        guard let originalImage = snapshot, let textureImage = UIImage(named: "texturePaper.jpg")
            else { return }
        makeSelection(control: sender)
        applyTexture(originalImage: originalImage, textureImage: textureImage)
    }
    
    @IBAction func applyTexturePencil(_ sender: UIControl) {
        guard let originalImage = snapshot, let textureImage = UIImage(named: "texturePencil.jpg")
            else { return }
        makeSelection(control: sender)
        applyTexture(originalImage: originalImage, textureImage: textureImage)
    }
    
    @IBAction func applyTextureWatercolor(_ sender: UIControl) {
        guard let originalImage = snapshot, let textureImage = UIImage(named: "textureWatercolor.jpg")
            else { return }
        makeSelection(control: sender)
        applyTexture(originalImage: originalImage, textureImage: textureImage)
    }
    
    @IBAction func applyTextureBrick(_ sender: UIControl) {
        guard let originalImage = snapshot, let textureImage = UIImage(named: "textureBrick.jpg")
            else { return }
        makeSelection(control: sender)
        applyTexture(originalImage: originalImage, textureImage: textureImage)
    }
    
    
    @IBAction func shareOnTwitter(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let composeVC:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            composeVC.setInitialText(Constants.defaultSharingMessage)
            composeVC.add(drawingImageView.image)
            self.present(composeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareOnFacebook(_ sender: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let composeVC:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            composeVC.setInitialText(Constants.defaultSharingMessage)
            composeVC.add(drawingImageView.image)
            self.present(composeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareOnInstagram(_ sender: UIButton) {
        InstagramManager.sharedManager.postImageToInstagramWithCaption(drawingImageView.image!, instagramCaption: Constants.defaultSharingMessage, view: sender)
    }
    
    @IBAction func share(_ sender: UIButton) {
        let activityVC = UIActivityViewController(activityItems: [Constants.defaultSharingMessage, drawingImageView.image!], applicationActivities: nil)
        activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        activityVC.popoverPresentationController?.sourceView = sender
        activityVC.popoverPresentationController?.sourceRect = CGRect(origin: sender.center, size: CGSize(width: 1, height: 1))
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: AnyObject) {
        // Go to gallery
        if let navController = self.presentingViewController as? UINavigationController{
            navController.popViewController(animated: false)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "didRequestInterstitial"), object: nil)
    }
    
    @IBAction func back(_ sender: AnyObject) {
        // Go back to drawing
        self.dismiss(animated: true, completion: nil)
    }
    
}
