//
//  DrawingUndoManager.swift
//  coloringbook
//
//  Created by Iulian Dima on 10/25/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import Foundation
import UIKit

class DrawingUndoManager {
    
    static let sharedInstance = DrawingUndoManager()
    
    var onUpdate:(()->Void)? = nil
    
    private var snapshots = [String]()
    private var undoIndex = -1
    
    private init() {
        
    }
    
    func reset() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: NSTemporaryDirectory() + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        snapshots = [String]()
        undoIndex = -1
        onUpdate?()
    }
    
    private func clearTempFolderOfEntries(entriesToDelete: [String]) {
        let fileManager = FileManager.default
        for entrie in entriesToDelete {
            do {
                try fileManager.removeItem(atPath: NSTemporaryDirectory() + entrie)
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        }
    }
    
    func hasUndo() -> Bool {
        return undoIndex > 0
    }
    
    func hasRedo() -> Bool {
        return undoIndex < snapshots.count - 1
    }
    
    func undo() -> UIImage? {
        if(undoIndex > 0) {
            undoIndex = undoIndex - 1
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(snapshots[undoIndex])
            onUpdate?()
            return UIImage(contentsOfFile: fileURL.path)!
        }
        return nil
    }
    
    func redo() -> UIImage? {
        if(undoIndex < snapshots.count - 1) {
            undoIndex = undoIndex + 1
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(snapshots[undoIndex])
            onUpdate?()
            return UIImage(contentsOfFile: fileURL.path)!
        }
        return nil
    }
    
    func saveSnapshot(_ image: UIImage) {
        DispatchQueue.global(qos: .background).async {
            if let data = image.jpegData(compressionQuality: 1.0){
                if(self.undoIndex < 50) {
                    self.undoIndex = self.undoIndex + 1
                } else {
                    let snapshotsToDelete = Array(self.snapshots[0 ... self.undoIndex - 50])
                    self.clearTempFolderOfEntries(entriesToDelete: snapshotsToDelete)
                    self.snapshots.removeSubrange(0 ... self.undoIndex - 50)
                }
                let snapshotsToDelete = Array(self.snapshots[self.undoIndex ..< self.snapshots.count])
                self.clearTempFolderOfEntries(entriesToDelete: snapshotsToDelete)
                self.snapshots.removeSubrange(self.undoIndex ..< self.snapshots.count)

                var filename:String = "\(ProcessInfo.processInfo.globallyUniqueString).png"
                let scale = Int(UIScreen.main.scale)
                if scale != 0 {
                    filename = "\(ProcessInfo.processInfo.globallyUniqueString)@\(scale)x.png"
                }
                let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
                self.snapshots.insert(filename, at: self.snapshots.count)
                try? data.write(to: URL(fileURLWithPath: fileURL.path), options: [.atomic])
                DispatchQueue.main.async {
                    self.onUpdate?()
                }
            }
        }
    }
    
}
