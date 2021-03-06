//
//  DatabaseModel.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation
import CDYelpFusionKit
import RealmSwift

protocol Configurable { }

extension CDYelpBusiness: Configurable { }

class DatabaseModel: Object
{
    // Read/Write Properties
    @objc dynamic var db_primary_key: String = ""
    @objc dynamic var db_business_query_results: String = ""
    
    override static func primaryKey() -> String
    {
        return "db_primary_key"
    }
}

// These structs are for Offline past queries.
struct DatabasePastQuery: Configurable
{
    var queryText: String = ""
    var businesses: [YelpBusiness] = []
}

struct YelpBusiness: Configurable
{
    let name: String!
    let phone: String!
    let rating: Double!
    let categories: [String]!
}
