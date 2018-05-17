//
//  ObservableViewController.swift
//  Echo
//
//  Created by Kai Lamarr on 11/5/17.
//  Copyright © 2017 Kai Lamarr. All rights reserved.
//

import UIKit

/// Echo's Observable class Protocol
protocol Observable: class
{
    /// name (class): The name of the Observable class, usually just the name of the class itself
    static var name: String { get set }
    
    /// name (class): The name of the Observable class, usually just the name of the class itself
    var name: String { get set }
    
    /// Start Observing dispatched Echo Objects
    func startObserving()
    
    /// Stop Observing dispatched Echo Objects
    func stopObserving()
    
    /// Handle a dispatched Echo Object
    /// - parameter intendedObserverNames: The intended Observer Echo names for the Echo Object.
    /// - parameter dispatcher: The Echo Dispatcher that emitted the Echo Object
    /// - parameter object: The Echo Object that was emitted
    func handle(intendedObserverNames: [String], dispatcher: Dispatchable, object: EchoObject)
    
    /// A standard UIAlertController for displaying Echo Object information
    /// - parameter viewController: The Observerable view controller that is showing the alert
    /// - parameter title: The UIAlertController title
    /// - parameter message: The UIAlertController message
    /// - parameter isEditable: If set to `true`, display a UITextField with the UIAlertController
    /// - parameter editHandler: If isEditable is set to `true`, this is the completion handler for the UITextField
    /// - parameter completion: A completion handler for the displayed UIAlertController
    func displayAlert(on viewController: ObservableViewController,
                      title: String,
                      message: String,
                      isEditable: Bool,
                      editHandler: ((UITextField) -> Void)?,
                      completion: (() -> Void)?)
}

/// The Observable Protocol default extension implementation
extension Observable
{
    /// name (class): The name of the Observable class, usually just the name of the class itself
    static var name: String {
        get {
            let className = String(describing: type(of: self))
            return className.components(separatedBy: ".").first ?? ""
        }
        set { self.name = newValue }
    }
    
    /// name (class): The name of the Observable class, usually just the name of the class itself
    var name: String {
        get { return String(describing: type(of: self)) }
        set { self.name = newValue }
    }

    /// A standard UIAlertController for displaying Echo Object information
    /// - parameter viewController: The Observerable view controller that is showing the alert
    /// - parameter title: The UIAlertController title
    /// - parameter message: The UIAlertController message
    /// - parameter isEditable: If set to `true`, display a UITextField with the UIAlertController. Default is `false`
    /// - parameter editHandler: If isEditable is set to `true`, this is the completion handler for the UITextField
    /// - parameter completion: A completion handler for the displayed UIAlertController
    func displayAlert(on viewController: ObservableViewController,
                      title: String,
                      message: String,
                      isEditable: Bool = false,
                      editHandler: ((UITextField) -> Void)? = nil,
                      completion: (() -> Void)? = nil)
    {
        guard viewController.isPresentingViewController == false else { return }
        
        let presentedAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { action in
            viewController.isPresentingViewController = false
            completion?()
            viewController.presentedAlertController = nil
        }
        presentedAlertController.addAction(action)
        
        if isEditable {
            presentedAlertController.addTextField(configurationHandler: editHandler)
        }
        
        viewController.presentedAlertController = presentedAlertController
        viewController.isPresentingViewController = true
        
        DispatchQueue.main.async {
            viewController.present(viewController.presentedAlertController!, animated: true, completion: nil)
        }
    }
    
    /// Start Observing dispatched Echo Objects
    func startObserving()
    {
        Echo.addObserver(self)
    }
    
    /// Stop Observing dispatched Echo Objects
    func stopObserving()
    {
        Echo.removeObserver(self)
    }
}

/// The Echo Observable base UIViewController class. Any UIViewController
/// that inherits from this will be able to observe Echo Objects
class ObservableViewController: UIViewController, Observable
{
    /// A flag denoting whether or not the view controller is displaying another view controller
    var isPresentingViewController: Bool = false
    
    /// The current presented UIAlertController (if any)
    var presentedAlertController: UIAlertController?
    
    /// The default Echo Observer handler. If you do not override this in a subclassed view controller,
    /// nothing will happen
    func handle(intendedObserverNames: [String], dispatcher: Dispatchable, object: EchoObject)
    {
        // Handled by subclasses of ObservableViewController
    }

    /// When the class is being deinitialized, stop observing for Echo Objects
    deinit
    {
        self.stopObserving()
    }
}
