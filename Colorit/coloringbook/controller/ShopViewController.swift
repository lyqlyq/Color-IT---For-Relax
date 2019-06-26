//
//  PacksViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 11/21/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class ShopViewController: UIViewController {

    
    @IBOutlet weak var IAPProductsTableView: UITableView!
    var container = UIView()
    var loadingView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        IAPProductsTableView.delegate = self
        IAPProductsTableView.dataSource = self
    }

    override var prefersStatusBarHidden: Bool {
        return true
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
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.categoriesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! IAPProductCell
        cell.titleLbl.text = DataManager.sharedInstance.tileForProduct(index: indexPath.item)
        cell.descriptionLbl.text = DataManager.sharedInstance.descriptionForProduct(index: indexPath.item)
        cell.isUserInteractionEnabled = true
        let productId = DataManager.sharedInstance.idForProduct(index: indexPath.item)

        if(UserDefaults.standard.bool(forKey: productId)) {
            cell.isUserInteractionEnabled = false
            cell.iconImageView.image = UIImage(named: "purchaseComplete")
        } else {
            cell.isUserInteractionEnabled = true
            cell.iconImageView.image = UIImage(named: "purchaseBtn")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! IAPProductCell
    
        showActivityIndicator()
        
        let productId = DataManager.sharedInstance.idForProduct(index: indexPath.item)
        
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) {
            [unowned self] result in
            switch result {
            case .success(let product):
                UserDefaults.standard.set(true, forKey: productId)
                cell.iconImageView.image = UIImage(named: "purchaseComplete")
                cell.isUserInteractionEnabled = false
                NotificationCenter.default.post(name: Notification.Name(rawValue: "didPurchasePackNotification"), object: nil)
                print("Purchase Success: \(product)")
            case .error(let error):
                self.showAlert(title: "Purchase Failed!", message: "Cannot connect to iTunes Store")
                print("Purchase Failed: \(error)")
            }
            self.hideActivityIndicator()
        }
        
    }
    
    
}
