//
//  InstagramManager.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/6/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import Foundation
import UIKit

class InstagramManager: NSObject, UIDocumentInteractionControllerDelegate {
    
    private let instagramURL = "instagram://"
    private let UTI = "com.instagram.exclusivegram"
    private let fileNameExtension = "instagram.igo"
    private let alertTitle = "Accounts"
    private let alertMessage = "Please login to an Instagram account to share."
    private let documentInteractionController = UIDocumentInteractionController()
    // Singleton manager
    class var sharedManager: InstagramManager {
        struct Singleton {
            static let instance = InstagramManager()
        }
        return Singleton.instance
    }
    
    func postImageToInstagramWithCaption(_ imageInstagram: UIImage, instagramCaption: String, view: UIView) {
        // Called to post image with caption to the instagram application
        
        let instagramURL = URL(string: self.instagramURL)
        if UIApplication.shared.canOpenURL(instagramURL!) {
            let jpgPath = NSTemporaryDirectory() + fileNameExtension
            try? imageInstagram.jpegData(compressionQuality: 1.0)!.write(to: URL(fileURLWithPath: jpgPath), options: [.atomic])
            let rect = view.bounds
            let fileURL = URL(fileURLWithPath: jpgPath)
            documentInteractionController.url = fileURL
            documentInteractionController.delegate = self
            documentInteractionController.uti = UTI
            
            // Adding caption for the image
            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            documentInteractionController.presentOpenInMenu(from: rect, in: view, animated: true)
        }
        else {
            
            // Alert displayed when the instagram application is not available in the device
            showAlert(title: alertTitle, message: alertMessage)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alertController.addAction(okAction)
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}
