//
//  SettingsTableViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 11/21/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var UndoSwipeSwitch: UISwitch!
    @IBOutlet weak var SmartBordersSwitch: UISwitch!
    @IBOutlet weak var SoundEffectsSwitch: UISwitch!
    
    var container = UIView()
    var loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.object(forKey: "undowSwipe") != nil {
            UndoSwipeSwitch.isOn = UserDefaults.standard.bool(forKey: "undowSwipe")
            SettingsManager.sharedInstance.undoSwipe = UndoSwipeSwitch.isOn
        } else {
            UndoSwipeSwitch.isOn = SettingsManager.sharedInstance.undoSwipe
        }
        if UserDefaults.standard.object(forKey: "smartBorders") != nil {
            SmartBordersSwitch.isOn = UserDefaults.standard.bool(forKey: "smartBorders")
            SettingsManager.sharedInstance.smartBorders = SmartBordersSwitch.isOn
        } else {
            SmartBordersSwitch.isOn = SettingsManager.sharedInstance.smartBorders
        }
        if UserDefaults.standard.object(forKey: "soundEffects") != nil {
            SoundEffectsSwitch.isOn = UserDefaults.standard.bool(forKey: "soundEffects")
            SettingsManager.sharedInstance.soundEffects = SoundEffectsSwitch.isOn
        } else {
            SoundEffectsSwitch.isOn = SettingsManager.sharedInstance.soundEffects
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SwitchDidChange(_ sender: UISwitch) {
        switch sender {
        case UndoSwipeSwitch:
            UserDefaults.standard.set(UndoSwipeSwitch.isOn, forKey: "undowSwipe")
            SettingsManager.sharedInstance.undoSwipe = UndoSwipeSwitch.isOn
        case SmartBordersSwitch:
            UserDefaults.standard.set(SmartBordersSwitch.isOn, forKey: "smartBorders")
            SettingsManager.sharedInstance.smartBorders = SmartBordersSwitch.isOn
        case SoundEffectsSwitch:
            UserDefaults.standard.set(SoundEffectsSwitch.isOn, forKey: "soundEffects")
            SettingsManager.sharedInstance.soundEffects = SoundEffectsSwitch.isOn
        default:
            break
        }
    }
    
    enum TableRow: Int {
        case Rate = 5, MoreApps, Facebook
        case PurchasePacks = 900, RemoveAds, RestorePurchases
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = TableRow(rawValue: indexPath.item) else { return }
        
        switch  row {
        case .PurchasePacks:
            showShop()
        case .RemoveAds:
            removeAds()
        case .RestorePurchases:
            restorePurchases()
        case .Rate:
            rate()
        case .MoreApps:
            moreApps()
        case .Facebook:
            openFacebookPage()
        }
    }
    
    func showActivityIndicator() {
        container.frame = view.bounds
        container.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        container.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColor(red: 57/255, green: 182/255, blue: 138/255, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2,
                                           y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showShop() {
        performSegue(withIdentifier: "ShowShop", sender: nil)
    }
    
    func removeAds() {
        showActivityIndicator()
        
        SwiftyStoreKit.purchaseProduct(Constants.removeAdsID, atomically: true) {
            [unowned self] result in
            switch result {
            case .success(let product):
                UserDefaults.standard.set(true, forKey: Constants.removeAdsID)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didRemoveAdsNotification"), object: nil)
                print("Purchase Success: \(product)")
            case .error(let error):
                self.showAlert(title: "Purchase Failed!", message: "Cannot connect to iTunes Store")
                print("Purchase Failed: \(error)")
            }
            self.hideActivityIndicator()
        }
    }
    
    func restorePurchases() {
        SwiftyStoreKit.restorePurchases(atomically: true) { [unowned self] results in
            if results.restoreFailedPurchases.count > 0 {
                self.showAlert(title: "Restore Failed!", message: "Cannot connect to iTunes Store")
                
            }
            else if results.restoredPurchases.count > 0 {
                self.showAlert(title: "Restore Success!", message: "All purchased products have been restored")
                
                for product in results.restoredPurchases {
                    if product.productId == Constants.removeAdsID {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "didRemoveAdsNotification"), object: nil)
                    }
                    UserDefaults.standard.set(true, forKey: product.productId)
                }
            }
            else {
                self.showAlert(title: "Nothing to Restore!", message: "")
                print("Nothing to Restore")
            }
        }
    }
    
    func openFacebookPage() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: Constants.facebookURL)!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: Constants.facebookURL)!)
        }
    }

    func rate() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: Constants.rateAppURL)!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: Constants.rateAppURL)!)
        }
    }
    
    func moreApps() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: Constants.rateAppURL)!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: Constants.moreAppsURL)!)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == TableRow.PurchasePacks.rawValue {
            if !Constants.packsPurchaseEnabled {
                return 0
            }
        }
        
        if indexPath.item == TableRow.RemoveAds.rawValue {
            if !Constants.interstialEnabled && !Constants.bannerEnabled {
                return 0
            }
            
            if UserDefaults.standard.bool( forKey: Constants.removeAdsID) {
                return 0
            }

        }
        
        if indexPath.item == TableRow.RestorePurchases.rawValue {
            if !Constants.packsPurchaseEnabled && ((!Constants.interstialEnabled && !Constants.bannerEnabled) || UserDefaults.standard.bool( forKey: Constants.removeAdsID)) {
                return 0
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
