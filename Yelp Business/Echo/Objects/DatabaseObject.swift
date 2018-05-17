//
//  DatabaseObject.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation
import CDYelpFusionKit

enum DatabaseObject: EchoObject
{
    case databaseSaveBusinesses(String, [CDYelpBusiness])
    
    var value: (Any)? {
        switch self {
            case .databaseSaveBusinesses(let query, let businesses):
                return (query, businesses)
        }
    }
}
