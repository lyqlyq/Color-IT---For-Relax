//
//  AppDelegate+JPushXZ.swift
//  SweetsInHindi
//
//  Created by mac on 2019/4/2.
//  Copyright © 2019年 Harikrushna. All rights reserved.
//
import UIKit

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PalettesPushManager.shareInstance().palettes_RegisterToken(deviceToken)
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if application.keyWindow?.tag == Int(6666) {
            return UIInterfaceOrientationMask.all
        }else{
            return UIInterfaceOrientationMask.portrait
        }
    }
    
}
