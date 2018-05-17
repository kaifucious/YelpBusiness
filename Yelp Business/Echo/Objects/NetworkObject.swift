//
//  NetworkObject.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation

enum NetworkObject: EchoObject
{
    case networkStatusUpdated(Bool)
    
    var value: (Any)? {
        switch self {
            case .networkStatusUpdated(let networkConnected):
                return (networkConnected)
        }
    }
}
