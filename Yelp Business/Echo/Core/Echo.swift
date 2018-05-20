//
//  Echo.swift
//  Echo
//
//  Created by Kai Lamarr on 11/5/17.
//  Copyright © 2017 Kai Lamarr. All rights reserved.
//  __version__ 1.3

import UIKit

/// Echo is a lightweight framework to send small pieces of data
/// across an application, and a way of triggering of events upon receiving
/// that data. It is built on top of iOS' Notification Center and GCD,
/// but has similitaries to the React paradigm. This removes the need for
/// unnecessary protocols/delegates or callbacks, although implementing these
/// alongside Echo is supported as well.
class Echo
{
    /// Echo's current observers. Access any observer is accessed by using
    /// the observers Echo name, i.e., observers[Network.name]
    private(set) static var observers = [String: Observable]()
    
    /// Echo Quality of Service for a dispatched Echo object.
    enum QOS: String {
        /// background: Useful for behind-the-scenes work, such as API calls
        case background = "EchoBackgroundDispatchQueue"
        
        /// main: Useful for UI updates
        case main = "EchoMainDispatchQueue"
    }

    /// Echo Logging. If debugging is on, Echo will print relevant information
    /// in the console.
    static var isLoggingEnabled: Bool {
        get {
            #if DEBUG
                return true
            #else
                return false
            #endif
        }
    }
    
    /// Echo Constant Initializer. Usually called in AppDelegate.
    /// - parameter constants: Static continously updating observables, i.e, Network
    static func initalize(_ constants: [Observable])
    {
        for constant in constants {
            Echo.observers[constant.name] = constant
        }
    }

    /// Echo console Logging. Can also be fused with [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver)
    /// for even easier log reading
    /// - parameter prefix: An arbitrary log prefix
    /// - parameter message: The log message
    static func log(prefix: String = "[Echo]", message: Any? = nil)
    {
        if Echo.isLoggingEnabled {
            let newLog = prefix + " " + "\(message ?? "")\n"
            print(newLog)
        }
    }
    
    /// Echo console Logging. Can also be fused with [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver)
    /// for even easier log reading
    /// - parameter prefix: An arbitrary log prefix
    /// - parameter dispatcher: The Echo dispatcher that dispatched the Echo object
    /// - parameter observer: The Echo Observer that observed the dispatched Echo Object
    /// - parameter object: The emitted Echo Object
    /// - parameter message: The log message
    static func log(prefix: String = "[Echo]", dispatcher: Dispatchable, observer: Observable, object: EchoObject, message: Any? = nil)
    {
        if Echo.isLoggingEnabled {
            let newLog = prefix + " " + "\(observer.name) observed an Object: \(object) dispatched from \(dispatcher.name). \(message ?? "")\n"
            print(newLog)
        }
    }
    
    /// Add an Echo Observer
    /// - parameter observer: The Echo Observer to be added to Echo
    static func addObserver(_ observer: Observable)
    {
        var didAddObserver = false

        if Echo.observers[observer.name] == nil {
            Echo.observers[observer.name] = observer
            didAddObserver = true
        }

        if didAddObserver {
            NotificationCenter.default.addObserver(forName: Notification.Name.EchoObjectValueChanged, object: nil, queue: nil) { notification in
                DispatchQueue.main.async {
                        guard let dispatcher = notification.object as? Dispatchable,
                              let intendedObserverNames = notification.userInfo?["intendedObserverNames"] as? [String],
                              let echoObject = notification.userInfo?["echoObject"] as? EchoObject else {
                            return
                    }

                    if Echo.observers[observer.name] != nil {
                        Echo.log(dispatcher: dispatcher, observer: observer, object: echoObject)
                        
                        observer.handle(intendedObserverNames: intendedObserverNames,
                                        dispatcher: dispatcher,
                                        object: echoObject)
                    }
                }
            }
            
            Echo.log(message: "\(observer.name) started observing.")
        }
    }
    
    /// Remove an Echo Observer
    /// - parameter observer: The Echo Observer to be removed from Echo
    static func removeObserver(_ observer: Observable)
    {
        if Echo.observers[observer.name] != nil {
            Echo.observers[observer.name] = nil
            
            NotificationCenter.default.removeObserver(observer, name: Notification.Name.EchoObjectValueChanged, object: nil)
            
            Echo.log(message: "\(observer.name) stopped observing.")
        }
    }
    
    /// Remove all Echo Observers
    /// - parameter observers: The Echo Observers to be removed from Echo
    static func removeObservers(_ observers: [Observable])
    {
        for observer in observers {
            Echo.removeObserver(observer)
        }
    }
}


/// The Echo Object Protocol that all Echo Observers *must* conform to
protocol EchoObject
{
    /// value: The value of the emitted Echo object
    var value: (Any)? { get }
    
    /// emit: The function to be called when you're ready to fire an Echo Object
    /// - parameter after: An arbitrary delay before firing the Echo Object
    /// - parameter qos: The Quality of Service of the Echo Object
    /// - parameter intendedObserverNames: The intended Observer Echo names for the Echo Object. Default is all Observers
    /// - parameter dispatcher: The Echo Object dispatcher
    func emit(after: TimeInterval, qos: Echo.QOS, intendedObserverNames: [String]?, dispatcher: Dispatchable)
}

/// The Echo Object Protocol extension defaut implementation
extension EchoObject
{
    func emit(after: TimeInterval = 0.0,
              qos: Echo.QOS = .background,
              intendedObserverNames: [String]? = nil,
              dispatcher: Dispatchable)
    {
        let userInfo: [AnyHashable: Any] = [
            "intendedObserverNames": intendedObserverNames ?? Echo.observers.map { $0.key },
            "echoObject": self
        ]
        
        let dispatchQOS: DispatchQoS = qos == .background ? .background : .userInteractive
        let dispatchQueue = DispatchQueue(label: qos.rawValue, qos: dispatchQOS)
        
        dispatchQueue.asyncAfter(deadline: .now() + after) {
            NotificationCenter.default.post(name: Notification.Name.EchoObjectValueChanged,
                                            object: dispatcher,
                                            userInfo: userInfo)

            Echo.log(message: "\(dispatcher.name) emitted an Object \(self), intended for \(intendedObserverNames ?? ["all observers"]) after \(after)s.")
        }
    }
}

/// Echo Notification Names
extension Notification.Name
{
    /// EchoObjectValueChanged: Fired automtically when -emit is called on an Echo Object.
    static let EchoObjectValueChanged = Notification.Name("EchoObjectValueChangedNotification")
}
