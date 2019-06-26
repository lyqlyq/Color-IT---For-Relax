//
//  CollectionViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 7/27/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {

    fileprivate let reuseIdentifier = "PhotoCell"
    fileprivate var thumbnailSize:CGSize = CGSize.zero
    fileprivate let itemSpacing:CGFloat = 10
    fileprivate var freeImagesCount:Int = 0
    fileprivate var isPurchased:Bool = false
    var categoryIndex:Int = 0
    
    var collectionViewDidScroll:((UIScrollView)->Void)? = nil
    var collectionViewWillEndDragging:((UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>)->Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        freeImagesCount = DataManager.sharedInstance.freeImagesForProduct(index: self.categoryIndex)
        if Constants.packsPurchaseEnabled {
            isPurchased = UserDefaults.standard.bool(forKey: DataManager.sharedInstance.idForProduct(index: self.categoryIndex))
        } else {
            isPurchased = true
        }
        // Return the number of items
        return DataManager.sharedInstance.lengthForCategory(index: self.categoryIndex)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageIndex = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        let image =  DataManager.sharedInstance.getThumbAt(categoryIndex: self.categoryIndex, imageIndex: imageIndex)

        if indexPath.item < freeImagesCount || isPurchased {
            cell.lockView.isHidden = true
        } else {
            cell.lockView.isHidden = false
        }
        
        cell.imageView.image = image
        cell.imageView.layer.cornerRadius = 6
        cell.imageView.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 3
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 6).cgPath

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        DataManager.sharedInstance.selectedCategoryIndex = self.categoryIndex
        DataManager.sharedInstance.selectedImageIndex = indexPath.row
        let dict = ["locked": !cell.lockView.isHidden]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "didSelectDrawingNotification"), object: nil, userInfo: dict)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionViewDidScroll?(scrollView)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionViewWillEndDragging?(scrollView, velocity, targetContentOffset)
    }
    
}

extension CollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Calculate thumbnail size based on device
        if traitCollection.userInterfaceIdiom == .pad {
            //print("iPad")
            if UIDevice.current.orientation.isLandscape {
                thumbnailSize.width = floor((collectionView.frame.size.width - itemSpacing * 5) / 4)
            } else {
                thumbnailSize.width = floor((collectionView.frame.size.width - itemSpacing * 4) / 3)
            }
        } else if traitCollection.userInterfaceIdiom == .phone {
            //print("iPhone")
            thumbnailSize.width = floor((collectionView.frame.size.width - itemSpacing * 3) / 2)
        }
        
        
        thumbnailSize.height = thumbnailSize.width

        return thumbnailSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: itemSpacing, left: itemSpacing, bottom: itemSpacing, right: itemSpacing)
    }
}
