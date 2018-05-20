//
//  AppDelegate.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/14/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit
import CDYelpFusionKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var yelpClient: CDYelpAPIClient?
    
    static let shared = AppDelegate()
    
    // MARK: -App Defaults
    struct Default {
        static let yelpApiKey = "YELP_API_KEY"
        static let fontName = "Verdana"
        static let fontNameBold = "Verdana-Bold"
        static let imagePlaceholder = #imageLiteral(resourceName: "image_placeholder")
        static let isBusinessOpenPlaceholder = #imageLiteral(resourceName: "is_open_30")
        static let color = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        
        static func valueForInfoKey(_ key: String) -> Any? {
            return Bundle.main.object(forInfoDictionaryKey: key)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Echo Constant Initialization
        // These are objects who continuously observe during the life cycle of the app. This includes
        // network and database updates, as these happen quite frequently.
        let constants: [Observable] = [
            Network(),
            Database()
        ]
        
        Echo.initalize(constants)
        
        // Yelp Client Initialization
        let apiKey = Default.valueForInfoKey(Default.yelpApiKey) as? String ?? ""
        AppDelegate.shared.yelpClient = CDYelpAPIClient(apiKey: apiKey)
        
        AppDelegate.shared.applyTheme()
    
        return true
    }
    
    // MARK: -Theme Application
    private func applyTheme()
    {
        let foregroundColor = AppDelegate.Default.color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: foregroundColor]
        
        UITextField.appearance().tintColor = AppDelegate.Default.color
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.foregroundColor: foregroundColor,
            NSAttributedStringKey.font: UIFont(name: AppDelegate.Default.fontName, size: 16.0)!
        ], for: .normal)
    }
}

