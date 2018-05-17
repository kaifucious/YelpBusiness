//
//  ImageView.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

@IBDesignable class ImageView: UIImageView
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
}
