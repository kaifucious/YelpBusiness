//
//  Label.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/14/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

@IBDesignable class Label: UILabel
{
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var topInset:    CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset:   CGFloat = 5.0
    @IBInspectable var rightInset: CGFloat = 5.0
    
    override func drawText(in rect: CGRect)
    {
        let insets = UIEdgeInsets(top: self.topInset,
                                  left: self.leftInset,
                                  bottom: self.bottomInset,
                                  right: self.rightInset)
        
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += self.topInset + self.bottomInset
            contentSize.width += self.leftInset + self.rightInset
            return contentSize
        }
    }
}
