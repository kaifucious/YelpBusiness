//
//  View.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/14/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

@IBDesignable class View: UIView
{
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }

    @IBInspectable var borderColor: UIColor {
        get {
            return self.borderColor
        }
        set {
            self.layer.borderColor = newValue.cgColor
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return self.shadowColor
        }
        set {
            self.layer.shadowColor = newValue.cgColor
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return self.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var bottomSeparator: Bool {
        get {
            return self.bottomSeparator
        }
        set(show) {
            if show == true {
                let layer = CALayer()
                layer.name = "bottomSeparator"
                layer.frame = CGRect(x: 0, y: self.frame.size.height - 1.0,
                                     width: self.frame.width, height: 1.0)
                
                layer.backgroundColor = UIColor.lightGray.cgColor
                
                self.layer.addSublayer(layer)
            } else {
                let layer = self.layer.sublayers?.filter { $0.name == "bottomSeparator" }.first
                
                if layer != nil {
                    layer?.removeFromSuperlayer()
                }
            }
        }
    }
}
