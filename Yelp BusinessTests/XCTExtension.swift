//
//  XCTestLog.swift
//  Yelp BusinessTests
//
//  Created by Ghost Maverick on 5/20/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import XCTest
import UIKit
@testable import Yelp_Business

func XCTLog(subject: AnyObject, _ message: String)
{
    print("\n*********************************************************")
    print("[\(String(describing: type(of: subject))) TEST]: \(message)\n")
}
