//
//  DatabaseModel.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation
import RealmSwift

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
struct DatabasePastQuery
{
    var queryText: String = ""
    var businesses: [YelpBusiness] = []
}

struct YelpBusiness
{
    var name: String = ""
    var phone: String = ""
    var rating: Double = 0.0
    var categories: [String] = []
}
