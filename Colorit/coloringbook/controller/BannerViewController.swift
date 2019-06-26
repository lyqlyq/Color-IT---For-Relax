//
//  TestViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 11/16/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import GoogleMobileAds
import UIKit

class BannerViewController: UIViewController, GADBannerViewDelegate, GADInterstitialDelegate {

    @IBOutlet weak var containerBottom: NSLayoutConstraint!

    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard !UserDefaults.standard.bool( forKey: Constants.removeAdsID) else { return}
        
        if Constants.bannerEnabled { loadBanner() }
    
        if Constants.interstialEnabled {
        
            loadInterstitial()
            NotificationCenter.default.addObserver(self, selector: #selector(showInterstitial(_:)),
                                                   name: NSNotification.Name(rawValue: "didRequestInterstitial"),
                                                   object :nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveAds(_:)),
                                               name: NSNotification.Name(rawValue: "didRemoveAdsNotification"),
                                               object :nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadInterstitial() {
        interstitial = GADInterstitial(adUnitID: Constants.AdMobInterstialID)
        interstitial.delegate = self

        let request = GADRequest()
        //request.testDevices = ["ec6f17ba434933bdd37fa053da7863b4", kGADSimulatorID]
        interstitial.load(request)
    }
    
    @objc func showInterstitial(_ notification: Notification) -> Void {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        loadInterstitial()
    }
    
    func loadBanner() {
        if bannerView == nil {
            bannerView = GADBannerView()
            bannerView.delegate = self
            bannerView.adUnitID = Constants.AdMobAdUnitID
            bannerView.rootViewController = self
            
            view.addSubview(bannerView)
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            
            // Layout constraints that align the banner view to the bottom center of the screen.
            view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .bottom,
                                                  relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .centerX,
                                                  relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        }
        
        let request = GADRequest()
        //request.testDevices = ["ec6f17ba434933bdd37fa053da7863b4", kGADSimulatorID]
        
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.isHidden = true
        bannerView.load(request)
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
        if SettingsManager.sharedInstance.waitForTransition {
            delay(0.6) { self.containerBottom.constant = self.bannerView.frame.size.height }
        } else {
            self.containerBottom.constant = self.bannerView.frame.size.height
        }
    }
    
    @objc func didRemoveAds(_ notification: Notification) -> Void {
        if bannerView != nil {
            bannerView.removeFromSuperview()
            bannerView = nil
            containerBottom.constant = 0
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
}

