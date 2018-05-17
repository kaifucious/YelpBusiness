//
//  QueryCollectionViewCell.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/15/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit
import CDYelpFusionKit
import Alamofire
import AlamofireImage

class QueryCollectionViewCell: UICollectionViewCell
{
    var businessLocationTapped: ((String, Double, Double) -> Void)?
    var businessPhoneTapped: ((String) -> Void)?
    
    private var businessName: String?
    private var businessPhone: String?
    private var businessLatitude: Double?
    private var businessLongitude: Double?
    
    @IBOutlet private weak var imageView: ImageView!
    @IBOutlet private weak var businessRatingLabel: Label!
    @IBOutlet private weak var businessNameLabel: Label!
    @IBOutlet private weak var businessPhoneLabel: Label!
    @IBOutlet private weak var businessIsOpenImageView: ImageView!
    
    // -MARK: -Cell Configuring
    func configure(business: Any)
    {
        let businessMapGestureRecognizer = UITapGestureRecognizer()
        businessMapGestureRecognizer.addTarget(self, action: #selector(self.businessLocationImageViewTapped(_:)))
        self.imageView.addGestureRecognizer(businessMapGestureRecognizer)
        
        let businessPhoneTapGestureRecognizer = UITapGestureRecognizer()
        businessPhoneTapGestureRecognizer.addTarget(self, action: #selector(self.businessPhoneLabelTapped(_:)))
        self.businessPhoneLabel.addGestureRecognizer(businessPhoneTapGestureRecognizer)
        
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
        self.imageView.image = AppDelegate.Default.imagePlaceholder
        
        if let business = business as? CDYelpBusiness {
            if let rating = business.rating {
                self.businessRatingLabel.text = "Rating: \(rating)"
            } else {
                self.businessRatingLabel.text = "Not Rated"
            }
            
            self.businessNameLabel.text = business.name ?? "Business"
            
            self.businessPhoneLabel.text = business.phone ?? ""
            
            if let closed = business.isClosed, closed == false {
                self.businessIsOpenImageView.image = AppDelegate.Default.isBusinessOpenPlaceholder
            }

            if let imageURL = business.imageUrl {
                Alamofire.request(imageURL).responseImage { [weak self] response in
                    if let image = response.result.value {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                    }
                }
            }
            
            self.businessName = business.name ?? ""
            self.businessPhone = business.phone ?? ""
            self.businessLatitude = business.coordinates?.latitude ?? 0.0
            self.businessLongitude = business.coordinates?.longitude ?? 0.0
            
        } else if let business = business as? YelpBusiness {
            self.businessRatingLabel.text = "Rating: \(business.rating)"
            self.businessNameLabel.text = business.name
            self.businessPhoneLabel.text = business.phone
            
            self.businessName = business.name
            self.businessPhone = business.phone
        }
    }
    
    // MARK: -Phone Call Callback
    @objc func businessPhoneLabelTapped(_ sender: UITapGestureRecognizer)
    {
        guard let phoneNumber = self.businessPhone else { return }
        
        self.businessPhoneTapped?(phoneNumber)
    }
    
    // MARK: -Location Mapping Callback
    @objc func businessLocationImageViewTapped(_ sender: UITapGestureRecognizer)
    {
        guard let name = self.businessName,
              let latitude = self.businessLatitude,
              let longitude = self.businessLongitude else {
                return
        }
        
        self.businessLocationTapped?(name, latitude, longitude)
    }
}
