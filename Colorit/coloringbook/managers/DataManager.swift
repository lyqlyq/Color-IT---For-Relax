//
//  DataManager.swift
//  coloringbook
//
//  Created by Iulian Dima on 11/6/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import Foundation
import UIKit

class DataManager {
    
    static let sharedInstance = DataManager()
    
    private var jsonData: JSON!
    private (set) var categoriesCount: Int = 0
    var selectedCategoryIndex: Int = 0
    var selectedImageIndex: Int = 0
    
    
    private init() {
        // Get data
        if let file = Bundle(for:AppDelegate.self).path(forResource: "Content", ofType: "json") {
            let data = try! Data(contentsOf: URL(fileURLWithPath: file))
            jsonData =  JSON(data:data)
            categoriesCount = jsonData["categories"].count
        }
    }
    
    func lengthForCategory(index: Int) -> Int {
        return jsonData["categories"][index]["images"].count
    }
    
    func titleForCategory(index: Int) -> String {
        return jsonData["categories"][index]["title"].stringValue
    }
    
    func tileForProduct(index: Int) -> String {
        return jsonData["categories"][index]["product"]["title"].stringValue
    }
    
    func descriptionForProduct(index: Int) -> String {
        return jsonData["categories"][index]["product"]["description"].stringValue
    }
    
    func idForProduct(index: Int) -> String {
        return jsonData["categories"][index]["product"]["id"].stringValue
    }
    
    func freeImagesForProduct(index: Int) -> Int {
         return jsonData["categories"][index]["product"]["freeImages"].intValue
    }
    
    func getBigImageName(categoryIndex: Int, imageIndex: Int) -> String{
        let imageName = jsonData["categories"][categoryIndex]["title"].stringValue
        let categoryName = jsonData["categories"][categoryIndex]["images"][imageIndex]["big"].stringValue
        let name = categoryName + "_big_" + imageName + ".png"
        
        return name
    }
    
    func getThumbImageName(categoryIndex: Int, imageIndex: Int) -> String{
        let categoryName = jsonData["categories"][categoryIndex]["title"].stringValue
        let imageName = jsonData["categories"][categoryIndex]["images"][imageIndex]["thumb"].stringValue
        let name = categoryName + "_thumb_" + imageName + ".png"
        
        print(name)
        return name
    }
    
    func getThumbAt(categoryIndex: Int, imageIndex: Int) -> UIImage? {
        guard let thumb  = UIImage(named: self.getThumbImageName(categoryIndex: categoryIndex, imageIndex: imageIndex)) else {return nil}
        
        // Get saved thumb
        
        var scale:String = ""
        
        if thumb.scale != 1 {
            scale = "@\(Int(thumb.scale))x"
        }
        
        let filename:String = "\(jsonData["categories"][categoryIndex]["title"].stringValue)\(imageIndex)thumb\(scale).png"
        
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let filePath = documentsDirectoryPath.appendingPathComponent(filename)
        
        if let savedThumb  =  UIImage(contentsOfFile: filePath.path) {
            return savedThumb
        } else {
            return thumb
        }
    }
    
    func getSelectedImage() -> UIImage? {
        let categoryName = jsonData["categories"][selectedCategoryIndex]["title"].stringValue
        let imageName = jsonData["categories"][selectedCategoryIndex]["images"][selectedImageIndex]["big"].stringValue
        let name = categoryName + "_big_" + imageName + ".png"
        return UIImage(named: name)
        
//      return UIImage(named: jsonData["categories"][selectedCategoryIndex]["images"][selectedImageIndex]["big"].stringValue)
    }
    
    func getSelectedThumb() -> UIImage? {
        let categoryName = jsonData["categories"][selectedCategoryIndex]["title"].stringValue
        let imageName = jsonData["categories"][selectedCategoryIndex]["images"][selectedImageIndex]["big"].stringValue
        let name = categoryName + "_thumb_" + imageName + ".png"
        return UIImage(named: name)

//        return UIImage(named: jsonData["categories"][selectedCategoryIndex]["images"][selectedImageIndex]["thumb"].stringValue)
    }
    
    func saveImage(_ image: UIImage) {
        
        // Save image
        
        if let data = image.jpegData(compressionQuality: 1.0) {
            
            var scale:String = ""
            
            if image.scale != 1 {
                scale = "@\(Int(image.scale))x"
            }
            
            let filename:String = "\(jsonData["categories"][selectedCategoryIndex]["title"].stringValue)\(selectedImageIndex)\(scale).png"
            
            let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
            let filePath = documentsDirectoryPath.appendingPathComponent(filename)
            
            do {
                //print(filePath.path)
                try data.write(to: URL(fileURLWithPath: filePath.path), options: [.atomic])
            } catch let error as NSError {
                NSLog("Unable to save image \(error.debugDescription)")
            }
        }
        
        // Save thumb image
        
        var thumb = getSelectedThumb()!
        
        var ratio = thumb.size.width / image.size.width
        
        if image.size.height * ratio > thumb.size.height {
            ratio = thumb.size.height / image.size.height
        }
        
        let drawingRect = CGRect(x: (thumb.size.width - image.size.width * ratio) * 0.5,
                                 y: (thumb.size.height - image.size.height * ratio) * 0.5,
                                 width: image.size.width * ratio,
                                 height: image.size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(thumb.size, true, thumb.scale)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: thumb.size))
        image.draw(in: drawingRect)
        thumb = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if let data = thumb.jpegData(compressionQuality: 1.0){
            
            var scale:String = ""
            
            if thumb.scale != 1 {
                scale = "@\(Int(thumb.scale))x"
            }
            
            let filename:String = "\(jsonData["categories"][selectedCategoryIndex]["title"].stringValue)\(selectedImageIndex)thumb\(scale).png"
            
            let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
            let filePath = documentsDirectoryPath.appendingPathComponent(filename)
            
            do {
                //print(filePath.path)
                try data.write(to: URL(fileURLWithPath: filePath.path), options: [.atomic])
            } catch let error as NSError {
                NSLog("Unable to save thumb image \(error.debugDescription)")
            }
        }
    }
    
    func getSavedImage() -> UIImage? {
        
        let image = getSelectedImage()!
        
        var scale:String = ""
        
        if image.scale != 1 {
            scale = "@\(Int(image.scale))x"
        }
        
        let filename:String = "\(jsonData["categories"][selectedCategoryIndex]["title"].stringValue)\(selectedImageIndex)\(scale).png"
        
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let filePath = documentsDirectoryPath.appendingPathComponent(filename)
        
        return UIImage(contentsOfFile: filePath.path)
        
    }
    
    func isOriginalImage() -> Bool {
        let image = getSelectedImage()!
        
        var scale:String = ""
        
        if image.scale != 1 {
            scale = "@\(Int(image.scale))x"
        }
        
        let filename:String = "\(jsonData["categories"][selectedCategoryIndex]["title"].stringValue)\(selectedImageIndex)\(scale).png"
        
        let fileManager = FileManager.default
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let filePath = documentsDirectoryPath.appendingPathComponent(filename)
       
        return !fileManager.fileExists(atPath: filePath.path)
    }
    
    
    func deleteImage() {
        
        // Delete image
        
        let image = getSelectedImage()!
        
        var scale:String = ""
        
        if image.scale != 1 {
            scale = "@\(Int(image.scale))x"
        }
        
        var filename:String = "\(jsonData["categories"][selectedCategoryIndex]["title"].stringValue)\(selectedImageIndex)\(scale).png"
        
        let fileManager = FileManager.default
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        var filePath = documentsDirectoryPath.appendingPathComponent(filename)
        
        do {
            try fileManager.removeItem(atPath: filePath.path)
        } catch {
            print("Could not delete image \(error)")
        }
        
        // Delete thumb image
        
        let thumb = getSelectedThumb()!
        
        scale = ""
        
        if thumb.scale != 1 {
            scale = "@\(Int(thumb.scale))x"
        }
        
        filename = "\(jsonData["categories"][selectedCategoryIndex]["title"].stringValue)\(selectedImageIndex)thumb\(scale).png"
        

        filePath = documentsDirectoryPath.appendingPathComponent(filename)
        
        do {
            try fileManager.removeItem(atPath: filePath.path)
        } catch {
            print("Could not delete image \(error)")
        }
    }
    
}

