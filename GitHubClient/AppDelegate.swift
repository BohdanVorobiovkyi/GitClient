//
//  AppDelegate.swift
//  GitHubClient
//
//  Created by usr01 on 19.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let searchVC = ModuleBuilder.createController()
        
//        let searchVC = SearchViewController(with: presenter)
        let rootNavigation = UINavigationController(rootViewController: searchVC)
        rootNavigation.navigationBar.barTintColor = .darkText
        rootNavigation.navigationBar.isTranslucent = false
        window?.rootViewController = rootNavigation
        window?.makeKeyAndVisible()
        
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
        cache.memoryStorage.config.expiration = .days(1)

        return true
    }
}

