//
//  Storyboard.swift
//  Never Again
//
//  Created by Ghost Maverick on 2/26/18.
//  Copyright © 2018 NeverAgain. All rights reserved.
//

import UIKit

class Storyboard
{
    enum ViewController: String {
        case RootViewController
        case QueryViewController
        case QueryContentViewController
    }
    
    enum Storyboard: String {
        case Main
        case LaunchScreen
    }
    
    static func instantiate(_ viewController: ViewController, inStoryboard: Storyboard) -> UIViewController? {
        let sb = UIStoryboard(name: inStoryboard.rawValue, bundle: nil)
        return sb.instantiateViewController(withIdentifier: viewController.rawValue)
    }
}
