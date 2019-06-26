//
//  PalettesManager.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/6/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import Foundation
import UIKit

class PalettesManager {
    
    static let sharedInstance = PalettesManager()
    
    private (set) var palettes = [ColorPalette]()
    
    var selectedColorId: Int = 0
    var selectedPaletteId: Int = 0
    
    var changedColorId: Int = 0
    var changedPaletteId: Int = 0
    
    private init() {
        
        // Get the predifined palettes
        if let file = Bundle(for:AppDelegate.self).path(forResource: "Palettes", ofType: "json") {
            addPalettesFromFile(file)
        }
        
        // Get the .json file from Documents folder
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("UserPalettes.json").absoluteString
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // Get the user palettes if the file exists
        if fileManager.fileExists(atPath: jsonFilePath, isDirectory: &isDirectory) {
            addPalettesFromFile(jsonFilePath, isUserGenerated: true)
        }
        
    }
    
    private func addPalettesFromFile(_ file: String, isUserGenerated: Bool = false) {
        let data = try! Data(contentsOf: URL(fileURLWithPath: file))
        let palettesJSON =  JSON(data:data)
        
        for i in 0 ..< palettesJSON["palettes"].count {
            
            let title = palettesJSON["palettes"][i]["title"].stringValue
            var colors = [UIColor?]()
            
            for j in 0 ..< palettesJSON["palettes"][i]["colors"].count {
                let colorString = palettesJSON["palettes"][i]["colors"][j].stringValue
                if colorString == "" {
                    colors.append(nil)
                } else {
                    let color = UIColor(hex: Int(colorString, radix: 16)!)
                    colors.append(color)
                }
            }
            
            let palette = ColorPalette(name: title, colors: colors, isUserGenerated: isUserGenerated)
            palettes.append(palette)
        }
    }
    
    func createNewUserPalette() {
        let title = "Custom Palette"
        var colors = [UIColor?]()
        
        for _ in 0 ..< 9 {
            colors.append(nil)
        }
        
        let palette = ColorPalette(name: title, colors: colors, isUserGenerated: true)
        palettes.append(palette)
    }
    
    func deletePaletteAtIndex(_ index:Int) {
        palettes.remove(at: index)
    }
    
    func saveColor(_ color: UIColor, colorId: Int, paletteId: Int) {
        palettes[paletteId].setColor(color, atIndex: colorId)
        saveUserPalettes()
    }
    
    func saveUserPalettes() {
        
        var str = "{\"palettes\":["
        
        for palette in palettes {
            if !palette.isUserGenerated {continue}
            str.append("{\"title\": \"\(palette.name)\",")
            str.append("\"colors\": [")
            
            for color in palette.colors {
                if let validColor = color {
                    str.append("\"\(validColor.hexString(includeAlpha: false))\",")
                } else {
                    str.append("\"\",")
                }
            }
            str = String(str.dropLast())
            str.append("]},")
            
        }
        str = String(str.dropLast())
        str.append("]}")
        
        let data = str.data(using: String.Encoding.utf8)!

        // Get the .json file from Documents folder
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("UserPalettes.json")
        let fileManager = FileManager.default

        // Create a .json file in the Documents folder
        fileManager.createFile(atPath: jsonFilePath.absoluteString, contents: nil, attributes: nil)

        
        // Write the data to the .json file
        do {
            let file = try FileHandle(forWritingTo: jsonFilePath)
            file.write(data)
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
        
    }
}
