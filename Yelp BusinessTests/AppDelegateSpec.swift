//
//  Yelp_BusinessTests.swift
//  Yelp BusinessTests
//
//  Created by Ghost Maverick on 5/14/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import XCTest
import UIKit
@testable import Yelp_Business

class AppDelegateSpec: XCTestCase
{
    var subject: AppDelegate!
    
    override func setUp()
    {
        super.setUp()
        
        self.subject = AppDelegate.shared
    }
    
    func testDefaults()
    {
        // Test Yelp API Key
        XCTLog(subject: self.subject, "The Yelp API Key should match the Info.plist")
        let yelpApiKey = AppDelegate.Default.yelpApiKey
        XCTAssertEqual(yelpApiKey, "YELP_API_KEY", "The Yelp API Key should match the Info.plist")
   
        // Test Yelp API Value
        XCTLog(subject: self.subject, "The value for the Yelp API key should not be nil")
        let yelpApiValue = AppDelegate.Default.valueForInfoKey(yelpApiKey)
        XCTAssertNotNil(yelpApiValue, "The value for the Yelp API key should not be nil")
        
        // Test regular font
        XCTLog(subject: self.subject, "The regular font should be set correctly")
        let fontName = AppDelegate.Default.fontName
        XCTAssertEqual(fontName, "Verdana", "The regular font should be set correctly")
        
        // Test bold font
        XCTLog(subject: self.subject, "The bold font should be set correctly")
        let fontNameBold = AppDelegate.Default.fontNameBold
        XCTAssertEqual(fontNameBold, "Verdana-Bold", "The bold font should be set correctly")
        
        // Test image placeholder
        XCTLog(subject: self.subject, "The image placeholder should be set correctly")
        let imagePlaceholder = AppDelegate.Default.imagePlaceholder
        XCTAssertEqual(imagePlaceholder, #imageLiteral(resourceName: "image_placeholder"), "The image placeholder should be set correctly")
        
        // Test business open placeholder
        XCTLog(subject: self.subject, "The business open placeholder should be set correctly")
        let isBusinessOpenPlaceholder = AppDelegate.Default.isBusinessOpenPlaceholder
        XCTAssertEqual(isBusinessOpenPlaceholder, #imageLiteral(resourceName: "is_open_30"),"The business open placeholder should be set correctly")
        
        // Test color 
        XCTLog(subject: self.subject, "The app default color should be set correctly")
        let color = AppDelegate.Default.color
        let intendedColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        XCTAssertEqual(color, intendedColor, "The app default color should be set correctly")
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
}
