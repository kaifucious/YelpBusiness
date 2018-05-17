//
//  DipatchableViewController.swift
//  Echo
//
//  Created by Kai Lamarr on 11/5/17.
//  Copyright © 2017 Kai Lamarr. All rights reserved.
//

import UIKit

/// Echo's Dispatchable class Protocol.
protocol Dispatchable: class
{
    /// name (class): The name of the Dispatchable class, usually just the name of the class itself
    static var name: String { get set }
    
    /// name (instance): The name of the Dispatchable class, usually just the name of the class itself
    var name: String { get set }
}

/// The Dispatchable Protocol default extension implementation
extension Dispatchable
{
    /// name (class): The name of the Dispatchable class, usually just the name of the class itself
    static var name: String {
        get {
            let className = String(describing: type(of: self))
            return className.components(separatedBy: ".").first ?? ""
        }
        set { self.name = newValue }
    }
    
    /// name (instance): The name of the Dispatchable class, usually just the name of the class itself
    var name: String {
        get { return String(describing: type(of: self)) }
        set { self.name = newValue }
    }
}

/// The Echo Dispatchable base UIViewController class. Any UIViewController
/// that inherits from this will be able to emit an Echo Object
class DispatchableViewController: UIViewController, Dispatchable { }
